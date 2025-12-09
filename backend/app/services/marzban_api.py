import httpx
import os
from fastapi import HTTPException
from dotenv import load_dotenv

load_dotenv()

MARZBAN_BASE_URL = os.getenv("MARZBAN_BASE_URL")
MARZBAN_SUDO_TOKEN = os.getenv("MARZBAN_SUDO_TOKEN")

if not MARZBAN_BASE_URL:
    raise ValueError("MARZBAN_BASE_URL is not set in .env")

class MarzbanAPI:
    def __init__(self):
        self.base_url = MARZBAN_BASE_URL
        self.headers = {"Authorization": f"Bearer {MARZBAN_SUDO_TOKEN}"}

    async def _request(self, method: str, endpoint: str, json: dict = None, params: dict = None):
        async with httpx.AsyncClient() as client:
            try:
                response = await client.request(
                    method, 
                    f"{self.base_url}{endpoint}", 
                    headers=self.headers, 
                    json=json, 
                    params=params
                )
                response.raise_for_status()
                return response.json()
            except httpx.HTTPStatusError as e:
                # Pass Marzban's error details back to our frontend
                raise HTTPException(status_code=e.response.status_code, detail=e.response.json())
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Connection to Marzban failed: {str(e)}")

    async def create_user(self, user_data: dict):
        return await self._request("POST", "/api/user", json=user_data)

    async def get_user(self, username: str):
        return await self._request("GET", f"/api/user/{username}")

    async def modify_user(self, username: str, data: dict):
        return await self._request("PUT", f"/api/user/{username}", json=data)
    
    async def delete_user(self, username: str):
        return await self._request("DELETE", f"/api/user/{username}")

    async def get_system_stats(self):
        return await self._request("GET", "/api/system")

    async def get_nodes(self):
        return await self._request("GET", "/api/nodes")

    async def get_inbounds(self):
        return await self._request("GET", "/api/inbounds")
    
    async def get_core_config(self):
        return await self._request("GET", "/api/core/config")

    async def update_core_config(self, config: dict):
        return await self._request("PUT", "/api/core/config", json=config)

    async def restart_core(self):
        return await self._request("POST", "/api/core/restart")

marzban_client = MarzbanAPI()
