from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.predictive_maintenance import PredictiveMaintenanceService
from ..common.dependencies import get_tenant_id
from typing import Optional, List

router = APIRouter()

@router.get("/alerts")
async def get_alerts(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get maintenance alerts"""
    service = PredictiveMaintenanceService(db)
    return service.get_maintenance_alerts(tenant_id)

@router.get("/fleet-health")
async def get_fleet_health(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get fleet health summary"""
    service = PredictiveMaintenanceService(db)
    return service.get_fleet_health(tenant_id)
