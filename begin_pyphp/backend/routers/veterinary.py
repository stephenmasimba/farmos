from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.veterinary import VeterinaryService
from ..common.dependencies import get_tenant_id
from typing import Optional, List

router = APIRouter()

@router.get("/logs")
async def get_logs(
    batch_id: Optional[int] = None,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get veterinary medical logs"""
    service = VeterinaryService(db, tenant_id=tenant_id)
    return service.get_medical_logs(batch_id=batch_id)

@router.get("/vaccinations")
async def get_vaccinations(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get vaccination schedule"""
    service = VeterinaryService(db, tenant_id=tenant_id)
    return service.get_vaccination_schedule()

@router.get("/withdrawals")
async def get_withdrawals(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get withdrawal alerts"""
    service = VeterinaryService(db, tenant_id=tenant_id)
    return service.get_withdrawal_alerts()
