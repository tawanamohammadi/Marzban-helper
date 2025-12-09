from fastapi import APIRouter, Depends, HTTPException
from ..services.marzban_api import marzban_client
from ..api.reseller import get_current_reseller
from ..models.reseller import Reseller
from pydantic import BaseModel
from typing import List, Dict, Any, Optional

router = APIRouter()

# --- Models ---
class DNSConfig(BaseModel):
    servers: List[Dict[str, Any]]

class InboundConfig(BaseModel):
    tag: str
    protocol: str
    port: int
    settings: Dict[str, Any]
    streamSettings: Dict[str, Any]

# --- Endpoints ---

@router.get("/core/config")
async def get_core_config(admin: Reseller = Depends(get_current_reseller)):
    # In V1, we assume the "Reseller" who is "SuperAdmin" (huge quota) is the one accessing this.
    # Real implementation should have a role field.
    return await marzban_client.get_core_config()

@router.put("/core/config")
async def update_core_config(config: Dict[str, Any], admin: Reseller = Depends(get_current_reseller)):
    return await marzban_client.update_core_config(config)

@router.post("/core/restart")
async def restart_core(admin: Reseller = Depends(get_current_reseller)):
    return await marzban_client.restart_core()

@router.get("/nodes")
async def get_nodes(admin: Reseller = Depends(get_current_reseller)):
    return await marzban_client.get_nodes()
