from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..models.reseller import Reseller
from ..services.marzban_api import marzban_client
from .reseller import get_current_reseller
from pydantic import BaseModel
import asyncio

router = APIRouter()

@router.get("/dashboard-stats")
async def get_dashboard_stats(admin: Reseller = Depends(get_current_reseller)):
    # 1. Fetch Reseller-specific data (Quota)
    # 2. Fetch Global System data from Marzban (Realtime)
    
    try:
        system_stats = await marzban_client.get_system_stats()
        # Ensure we await the coroutine if it is one, though marzban_client methods are async
        
        return {
            "reseller": {
                "username": admin.username,
                "quota": admin.traffic_quota_bytes,
                "used_by_my_users": admin.traffic_used_bytes
            },
            "system": {
                "version": system_stats.get("version", "Unknown"),
                "total_users": system_stats.get("total_user", 0),
                "active_users": system_stats.get("users_active", 0),
                "incoming_bandwidth": system_stats.get("incoming_bandwidth", 0),
                "outgoing_bandwidth": system_stats.get("outgoing_bandwidth", 0),
                "mem_total": system_stats.get("mem_total", 0),
                "mem_used": system_stats.get("mem_used", 0),
                "cpu_usage": system_stats.get("cpu_usage", 0)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to fetch data from Marzban: {str(e)}")
