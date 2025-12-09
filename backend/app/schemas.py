from pydantic import BaseModel
from typing import Optional

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class ResellerBase(BaseModel):
    username: str

class ResellerCreate(ResellerBase):
    password: str

class Reseller(ResellerBase):
    id: int
    is_active: bool
    traffic_quota_bytes: int
    traffic_used_bytes: int

    class Config:
        from_attributes = True
