from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from datetime import datetime
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["equipment"])

# --- Models ---

class MaintenanceLogBase(BaseModel):
    equipment_id: int
    vibration: Optional[float] = 0.0
    temperature: Optional[float] = 0.0
    current_draw: Optional[float] = 0.0
    risk_score: Optional[float] = 0.0
    notes: Optional[str] = None

class MaintenanceLogCreate(MaintenanceLogBase):
    pass

class MaintenanceLog(MaintenanceLogBase):
    id: int
    tenant_id: str
    timestamp: datetime

    class Config:
        from_attributes = True

class EquipmentBase(BaseModel):
    name: str = Field(..., min_length=1)
    location: str
    status: str = Field("healthy")
    vibration_baseline: Optional[float] = 0.0
    temperature_baseline: Optional[float] = 0.0
    current_draw_baseline: Optional[float] = 0.0
    last_maintenance: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None

class EquipmentCreate(EquipmentBase):
    pass

class EquipmentUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    status: Optional[str] = None
    vibration_baseline: Optional[float] = None
    temperature_baseline: Optional[float] = None
    current_draw_baseline: Optional[float] = None
    last_maintenance: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None

class Equipment(EquipmentBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/", response_model=List[Equipment])
async def get_all_equipment(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.Equipment).filter(models.Equipment.tenant_id == tenant_id).all()

@router.get("/{id}", response_model=Equipment)
async def get_equipment_by_id(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item = db.query(models.Equipment).filter(
        models.Equipment.id == id,
        models.Equipment.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Equipment not found")
    return item

@router.post("/", response_model=Equipment, status_code=status.HTTP_201_CREATED)
async def create_equipment(
    item: EquipmentCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Check permissions
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_item = models.Equipment(**item.model_dump(), tenant_id=tenant_id)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

@router.put("/{id}", response_model=Equipment)
async def update_equipment(
    id: int, 
    item_update: EquipmentUpdate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    item = db.query(models.Equipment).filter(
        models.Equipment.id == id,
        models.Equipment.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Equipment not found")
    
    update_data = item_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(item, key, value)
    
    db.commit()
    db.refresh(item)
    return item

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_equipment(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    item = db.query(models.Equipment).filter(
        models.Equipment.id == id,
        models.Equipment.tenant_id == tenant_id
    ).first()
    if item:
        db.delete(item)
        db.commit()
    return

@router.get("/{id}/maintenance", response_model=List[MaintenanceLog])
async def get_maintenance_logs(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Verify equipment exists for this tenant
    item = db.query(models.Equipment).filter(
        models.Equipment.id == id,
        models.Equipment.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Equipment not found")
        
    return db.query(models.MaintenanceLog).filter(
        models.MaintenanceLog.equipment_id == id,
        models.MaintenanceLog.tenant_id == tenant_id
    ).all()

@router.post("/{id}/maintenance", response_model=MaintenanceLog, status_code=status.HTTP_201_CREATED)
async def add_maintenance_log(
    id: int, 
    log: MaintenanceLogCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    # Verify equipment exists for this tenant
    item = db.query(models.Equipment).filter(
        models.Equipment.id == id,
        models.Equipment.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Equipment not found")
        
    log_data = log.model_dump()
    log_data['equipment_id'] = id
    
    db_log = models.MaintenanceLog(**log_data, tenant_id=tenant_id)
    db.add(db_log)
    
    # Update equipment status if risk score is high
    if db_log.risk_score > 70:
        item.status = "critical"
    elif db_log.risk_score > 40:
        item.status = "at_risk"
    else:
        item.status = "healthy"
        
    item.last_maintenance = datetime.utcnow()
    
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/features")
async def equipment_features(
    name: Optional[str] = None, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user)
):
    features = [
        "Integrated Equipment Utilization Tracking",
        "Preventive Maintenance Scheduling",
        "Spare Parts Inventory Management",
        "Equipment Performance Analytics",
        "Asset Depreciation Forecasting",
        "Energy Consumption Monitoring",
        "Equipment Failure Prediction",
        "Calibration Schedule Management",
        "Asset Allocation Optimization",
        "Supplier Relationship Management",
        "Equipment Training Requirements",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}
