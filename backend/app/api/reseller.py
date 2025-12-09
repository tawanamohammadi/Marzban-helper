from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..core.database import get_db
from ..models.reseller import Reseller
from ..models.user_map import UserMap
from ..core.security import verify_password
from ..services.marzban_api import marzban_client
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from ..core.security import SECRET_KEY, ALGORITHM
from pydantic import BaseModel

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

# --- Schemas ---
class CreateUserRequest(BaseModel):
    username: str
    data_limit: int # Bytes
    expire: int # Timestamp
    note: Optional[str] = None

class UserInfoResponse(BaseModel):
    username: str
    status: str
    used_traffic: int
    data_limit: int
    expire: int
    links: List[str]

# --- Dependencies ---
async def get_current_reseller(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    reseller = db.query(Reseller).filter(Reseller.username == username).first()
    if reseller is None:
        raise credentials_exception
    return reseller

# --- Endpoints ---

@router.get("/me")
async def read_users_me(current_user: Reseller = Depends(get_current_reseller)):
    return {
        "username": current_user.username,
        "quota": current_user.traffic_quota_bytes,
        "used": current_user.traffic_used_bytes
    }

@router.post("/user", response_model=UserInfoResponse)
async def create_user(user: CreateUserRequest, reseller: Reseller = Depends(get_current_reseller), db: Session = Depends(get_db)):
    # 1. Check Quota
    if reseller.traffic_quota_bytes > 0: # 0 means unlimited? or check models.py default
        # Assuming quota is rigid
        if reseller.traffic_used_bytes + user.data_limit > reseller.traffic_quota_bytes:
             raise HTTPException(status_code=403, detail="Insufficient Quota")

    # 2. Call Marzban
    # Construct payload for Marzban
    marzban_payload = {
        "username": user.username,
        "data_limit": user.data_limit,
        "expire": user.expire,
        "note": f"Reseller: {reseller.username} | {user.note or ''}",
        "status": "active"
    }
    
    try:
        marzban_user = await marzban_client.create_user(marzban_payload)
    except HTTPException as e:
        raise e

    # 3. Update Local DB
    new_map = UserMap(marzban_username=user.username, reseller_id=reseller.id, note=user.note)
    db.add(new_map)
    
    # Update Quota
    reseller.traffic_used_bytes += user.data_limit
    
    db.commit()
    
    return marzban_user

@router.get("/users")
async def get_my_users(reseller: Reseller = Depends(get_current_reseller), db: Session = Depends(get_db)):
    # Get list from local DB
    user_maps = db.query(UserMap).filter(UserMap.reseller_id == reseller.id).all()
    usernames = [u.marzban_username for u in user_maps]
    
    # Ideally, we should batch fetch status from Marzban. 
    # For V1, we will return the list of usernames and let frontend fetch details individually or use a bulk endpoint if Marzban supports it.
    # Marzban has GET /api/users, but it returns ALL users. Reseller shouldn't see that.
    # We will fetch Marzban /api/users (which is heavy) and filter? No, bad performance.
    # We will return the list of names, and maybe some basics.
    
    return [
        {"username": u.marzban_username, "created_at": u.created_at, "note": u.note} 
        for u in user_maps
    ]

@router.delete("/user/{username}")
async def delete_user(username: str, reseller: Reseller = Depends(get_current_reseller), db: Session = Depends(get_db)):
    # Verify ownership
    user_map = db.query(UserMap).filter(UserMap.marzban_username == username, UserMap.reseller_id == reseller.id).first()
    if not user_map:
        raise HTTPException(status_code=404, detail="User not found or access denied")
    
    # Call Marzban
    await marzban_client.delete_user(username)
    
    # Remove from local DB
    db.delete(user_map)
    db.commit()
    
    return {"status": "deleted"}
