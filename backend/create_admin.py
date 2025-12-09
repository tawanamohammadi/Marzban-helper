from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.reseller import Reseller
from app.core.security import get_password_hash
import sys

def create_super_admin(username, password):
    db: Session = SessionLocal()
    
    # Check if exists
    existing = db.query(Reseller).filter(Reseller.username == username).first()
    if existing:
        print(f"User {username} already exists.")
        return

    hashed_pw = get_password_hash(password)
    # Super admin has huge quota
    admin = Reseller(
        username=username, 
        hashed_password=hashed_pw, 
        traffic_quota_bytes=1000 * 1024 * 1024 * 1024 * 1024, # 1000 TB
        is_active=True
    )
    
    db.add(admin)
    db.commit()
    print(f"Super Admin '{username}' created successfully.")
    db.close()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python create_admin.py <username> <password>")
    else:
        create_super_admin(sys.argv[1], sys.argv[2])
