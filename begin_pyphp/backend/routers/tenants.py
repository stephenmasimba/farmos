from fastapi import APIRouter, Depends, HTTPException
from typing import List
from pydantic import BaseModel
from .auth import get_current_user

router = APIRouter(tags=["tenants"])

class Tenant(BaseModel):
    id: int
    name: str
    domain: str
    status: str

# Mock data
tenants_list = [
    {"id": 1, "name": "Main Farm", "domain": "farm1.example.com", "status": "active"},
    {"id": 2, "name": "Secondary Site", "domain": "farm2.example.com", "status": "active"}
]

@router.get("/", response_model=List[Tenant])
async def get_all_tenants(current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    return tenants_list

@router.get("/{id}", response_model=Tenant)
async def get_tenant_by_id(id: int, current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    tenant = next((t for t in tenants_list if t["id"] == id), None)
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant

@router.post("/", response_model=Tenant)
async def create_tenant(tenant: Tenant, current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    tenants_list.append(tenant.dict())
    return tenant

@router.put("/{id}", response_model=Tenant)
async def update_tenant(id: int, tenant: Tenant, current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    return tenant

@router.delete("/{id}")
async def delete_tenant(id: int, current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    global tenants_list
    tenants_list = [t for t in tenants_list if t["id"] != id]
    return {"message": "Tenant deleted"}

@router.get("/current/info")
async def get_current_tenant(current_user: dict = Depends(get_current_user)):
    # Mock current tenant based on user context
    return tenants_list[0]

@router.get("/current/settings")
async def get_tenant_settings(current_user: dict = Depends(get_current_user)):
    return {"theme": "light", "currency": "USD", "timezone": "UTC"}

@router.put("/current/settings")
async def update_tenant_setting(settings: dict, current_user: dict = Depends(get_current_user)):
    return settings
