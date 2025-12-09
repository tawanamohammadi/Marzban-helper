from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..models.reseller import Reseller
from ..core.security import verify_password, create_access_token, get_password_hash
from .. import schemas
from datetime import timedelta
import os
import httpx

router = APIRouter()

# --- Marzban Login Logic for Setup ---
async def get_marzban_token(username, password):
    base_url = os.getenv("MARZBAN_BASE_URL", "http://127.0.0.1:8000")
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                f"{base_url}/api/admin/token",
                data={"username": username, "password": password, "grant_type": "password"},
                headers={"Content-Type": "application/x-www-form-urlencoded"}
            )
            response.raise_for_status()
            return response.json().get("access_token")
        except Exception as e:
            print(f"Error connecting to Marzban: {e}")
            return None

@router.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # 1. Try Local Reseller DB first
    user = db.query(Reseller).filter(Reseller.username == form_data.username).first()
    
    if user and verify_password(form_data.password, user.hashed_password):
        # Local Login Success
        access_token_expires = timedelta(minutes=1440)
        access_token = create_access_token(
            data={"sub": user.username}, expires_delta=access_token_expires
        )
        return {"access_token": access_token, "token_type": "bearer"}

    # 2. If not found locally, try Marzban Auth (Auto-Import Admin)
    # This allows the Main Admin to log in immediately without manual setup
    marzban_token = await get_marzban_token(form_data.username, form_data.password)
    
    if marzban_token:
        # Check if we should create a local shadow user for them
        if not user:
            new_admin = Reseller(
                username=form_data.username,
                hashed_password=get_password_hash(form_data.password),
                is_active=True,
                traffic_quota_bytes=1000 * 1024 * 1024 * 1024 * 1024 # 1000 TB for real admins
            )
            db.add(new_admin)
            db.commit()
        
        # We assume if they can login to Marzban, they are trusted.
        # Ideally, we should check `is_sudo` here by calling /api/admin/me on Marzban.
        
        access_token_expires = timedelta(minutes=1440)
        access_token = create_access_token(
            data={"sub": form_data.username}, expires_delta=access_token_expires
        )
        return {"access_token": access_token, "token_type": "bearer"}

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Incorrect username or password",
        headers={"WWW-Authenticate": "Bearer"},
    )
