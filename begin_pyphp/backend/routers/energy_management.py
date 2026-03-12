from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.energy_management import EnergyManagementService
from ..common.dependencies import get_tenant_id
from typing import Optional, List

router = APIRouter()

@router.get("/status")
async def get_energy_status(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get current energy system status"""
    service = EnergyManagementService(db)
    return service.get_system_status(tenant_id)

@router.get("/loads")
async def get_loads(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get all electrical loads"""
    service = EnergyManagementService(db)
    return service.get_loads(tenant_id)

@router.get("/history")
async def get_history(hours: int = 24, db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get energy history"""
    service = EnergyManagementService(db)
    return service.get_consumption_history(hours, tenant_id)
