from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from ..core.database import Base
from datetime import datetime

class UserMap(Base):
    __tablename__ = "user_maps"

    id = Column(Integer, primary_key=True, index=True)
    marzban_username = Column(String, unique=True, index=True)
    reseller_id = Column(Integer, ForeignKey("resellers.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    note = Column(String, nullable=True)
