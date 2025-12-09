from sqlalchemy import Boolean, Column, Integer, String, BigInteger, Float
from sqlalchemy.orm import relationship
from ..core.database import Base

class Reseller(Base):
    __tablename__ = "resellers"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    
    # Quota Management
    traffic_quota_bytes = Column(BigInteger, default=0) # Total traffic they can sell
    traffic_used_bytes = Column(BigInteger, default=0)  # Total traffic their users have consumed
    
    # Access Control
    allowed_inbounds = Column(String, default="*") # JSON list of inbound tags or "*"
    max_users = Column(Integer, default=-1) # -1 for unlimited
