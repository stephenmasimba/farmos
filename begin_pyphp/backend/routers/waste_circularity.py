from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.waste_circularity import WasteCircularityService
from ..common.dependencies import get_tenant_id
from typing import Optional, List

router = APIRouter()

@router.get("/compost")
async def get_compost(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get compost status"""
    service = WasteCircularityService(db)
    return service.get_compost_status(tenant_id)

@router.get("/carbon")
async def get_carbon(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get carbon metrics"""
    service = WasteCircularityService(db)
    return service.get_carbon_metrics(tenant_id)

from pydantic import BaseModel

class BSFCycleCreate(BaseModel):
    cycle_name: str
    waste_input_kg: float
    expected_yield_kg: float

@router.get("/bsf")
async def get_bsf(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get BSF tracking"""
    service = WasteCircularityService(db)
    return service.get_bsf_tracking(tenant_id)

@router.post("/bsf")
async def create_bsf(cycle: BSFCycleCreate, db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Create new BSF cycle"""
    service = WasteCircularityService(db)
    result = service.create_bsf_cycle(cycle.dict(), tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result
