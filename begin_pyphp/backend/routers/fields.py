from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["fields"])

# --- Pydantic Models ---

class FieldBase(BaseModel):
    name: str = Field(..., min_length=1, description="Field name")
    area: float = Field(..., gt=0, description="Area size")
    unit: str = Field(..., description="Unit of measurement (e.g. hectares, acres)")
    crop: Optional[str] = None
    status: str = Field(..., description="active, fallow, prepared, planted, harvested")
    # boundary_coordinates is not yet in SQL model, ignoring for now or storing as JSON if needed.
    # For now, we'll skip it in SQL or add it later. The SQL model doesn't have it.

class FieldCreate(FieldBase):
    pass

class FieldUpdate(BaseModel):
    name: Optional[str] = None
    area: Optional[float] = Field(None, gt=0)
    unit: Optional[str] = None
    crop: Optional[str] = None
    status: Optional[str] = None

class FieldModel(FieldBase):
    id: int
    tenant_id: Optional[str] = None

    class Config:
        from_attributes = True

class FieldHistoryBase(BaseModel):
    field_id: int
    action: str = Field(..., description="Action taken (e.g. Planting, Spraying, Harvest)")
    details: str
    date: str # Changed to str to match SQL model string storage for now

class FieldHistoryCreate(FieldHistoryBase):
    pass

class FieldHistory(FieldHistoryBase):
    id: int
    
    class Config:
        from_attributes = True

class SoilHealthLogBase(BaseModel):
    field_id: int
    date: str
    organic_matter_percent: float
    ph: float
    notes: Optional[str] = None

class SoilHealthLogCreate(SoilHealthLogBase):
    pass

class SoilHealthLog(SoilHealthLogBase):
    id: int
    
    class Config:
        from_attributes = True

class HarvestLogBase(BaseModel):
    field_id: int
    date: str
    crop: str
    yield_amount: float
    unit: str # kg, tons
    target_yield: Optional[float] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None

class HarvestLogCreate(HarvestLogBase):
    pass

class HarvestLog(HarvestLogBase):
    id: int

    class Config:
        from_attributes = True

class RotationPlanBase(BaseModel):
    field_id: int
    year: int
    season: str # e.g. "Summer", "Winter"
    planned_crop: str
    notes: Optional[str] = None

class RotationPlanCreate(RotationPlanBase):
    pass

class RotationPlan(RotationPlanBase):
    id: int

    class Config:
        from_attributes = True

class ScoutingLogBase(BaseModel):
    field_id: int
    date: str
    observer: str
    pest_disease_name: str
    severity: str # Low, Medium, High
    photo_url: Optional[str] = None
    notes: Optional[str] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None

class ScoutingLogCreate(ScoutingLogBase):
    pass

class ScoutingLog(ScoutingLogBase):
    id: int

    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/", response_model=List[FieldModel])
async def get_all_fields(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.Field).all()

@router.get("/{id}", response_model=FieldModel)
async def get_field_by_id(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    field = db.query(models.Field).filter(models.Field.id == id).first()
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")
    return field

@router.post("/", response_model=FieldModel, status_code=status.HTTP_201_CREATED)
async def create_field(field: FieldCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Assuming tenant_id logic is handled or defaulted. For now using default.
    # In a real app, extract tenant_id from current_user
    db_field = models.Field(**field.dict())
    # db_field.tenant_id = current_user.get("tenant_id", "default") 
    db.add(db_field)
    db.commit()
    db.refresh(db_field)
    return db_field

@router.put("/{id}", response_model=FieldModel)
async def update_field(id: int, field_update: FieldUpdate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    field = db.query(models.Field).filter(models.Field.id == id).first()
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")
    
    update_data = field_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(field, key, value)
    
    db.commit()
    db.refresh(field)
    return field

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_field(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    field = db.query(models.Field).filter(models.Field.id == id).first()
    if field:
        db.delete(field)
        db.commit()
    return

# --- Sub-resource Endpoints ---

@router.get("/{id}/history", response_model=List[FieldHistory])
async def get_field_history(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Verify field exists
    if not db.query(models.Field).filter(models.Field.id == id).first():
        raise HTTPException(status_code=404, detail="Field not found")
    return db.query(models.FieldHistory).filter(models.FieldHistory.field_id == id).all()

@router.get("/features")
async def scouting_features(name: Optional[str] = None, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    features = [
        "Integrated Pest Monitoring",
        "Weather-Integrated Scouting",
        "Disease Surveillance Network",
        "Soil Health Assessment",
        "Water Quality Scouting",
        "Equipment Condition Checks",
        "Biodiversity Monitoring",
        "Yield Prediction Integration",
        "Climate Resilience Monitoring",
        "Integrated Reporting System",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}

@router.post("/history", response_model=FieldHistory, status_code=status.HTTP_201_CREATED)
async def add_field_history(history: FieldHistoryCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if not db.query(models.Field).filter(models.Field.id == history.field_id).first():
        raise HTTPException(status_code=404, detail="Field not found")
        
    db_history = models.FieldHistory(**history.dict())
    db.add(db_history)
    db.commit()
    db.refresh(db_history)
    return db_history

@router.get("/{id}/soil", response_model=List[SoilHealthLog])
async def get_soil_logs(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.SoilHealthLog).filter(models.SoilHealthLog.field_id == id).all()

@router.post("/soil", response_model=SoilHealthLog, status_code=status.HTTP_201_CREATED)
async def log_soil_health(log: SoilHealthLogCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if not db.query(models.Field).filter(models.Field.id == log.field_id).first():
         raise HTTPException(status_code=404, detail="Field not found")

    db_log = models.SoilHealthLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/{id}/harvest", response_model=List[HarvestLog])
async def get_harvest_logs(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.HarvestLog).filter(models.HarvestLog.field_id == id).all()

@router.post("/harvest", response_model=HarvestLog, status_code=status.HTTP_201_CREATED)
async def log_harvest(log: HarvestLogCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if not db.query(models.Field).filter(models.Field.id == log.field_id).first():
         raise HTTPException(status_code=404, detail="Field not found")

    db_log = models.HarvestLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/{id}/rotation", response_model=List[RotationPlan])
async def get_rotation_plan(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.RotationPlan).filter(models.RotationPlan.field_id == id).all()

@router.post("/rotation", response_model=RotationPlan, status_code=status.HTTP_201_CREATED)
async def create_rotation_plan(plan: RotationPlanCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if not db.query(models.Field).filter(models.Field.id == plan.field_id).first():
         raise HTTPException(status_code=404, detail="Field not found")

    db_plan = models.RotationPlan(**plan.dict())
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan

@router.get("/{id}/scouting", response_model=List[ScoutingLog])
async def get_scouting_logs(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.ScoutingLog).filter(models.ScoutingLog.field_id == id).all()

@router.post("/scouting", response_model=ScoutingLog, status_code=status.HTTP_201_CREATED)
async def log_scouting(log: ScoutingLogCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if not db.query(models.Field).filter(models.Field.id == log.field_id).first():
         raise HTTPException(status_code=404, detail="Field not found")

    db_log = models.ScoutingLog(**log.dict())
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log
