from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["livestock"])

# --- Models ---

class LivestockBatchBase(BaseModel):
    name: str = Field(..., min_length=1, description="Batch name or ID")
    type: str = Field(..., description="Type of livestock (e.g., Cattle, Poultry)")
    breed: Optional[str] = None
    count: int = Field(..., ge=0, description="Number of animals")
    quantity: Optional[int] = Field(None, ge=0, description="Quantity for standardized tracking")
    status: str = Field("active", description="active, sold, deceased")
    start_date: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None

class LivestockBatchCreate(LivestockBatchBase):
    pass

class LivestockBatchUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    breed: Optional[str] = None
    count: Optional[int] = Field(None, ge=0)
    quantity: Optional[int] = Field(None, ge=0)
    status: Optional[str] = None
    start_date: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None

class LivestockBatch(LivestockBatchBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

class LivestockEventBase(BaseModel):
    batch_id: int
    type: str = Field(..., description="vaccination, treatment, mortality, weight")
    details: str
    date: Optional[str] = None
    performed_by: Optional[str] = None
    cost: Optional[float] = 0.0

class LivestockEventCreate(LivestockEventBase):
    pass

class LivestockEvent(LivestockEventBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

class BreedingRecordBase(BaseModel):
    dam_batch_id: int
    sire_batch_id: Optional[int] = None
    breeding_date: str
    expected_birth_date: Optional[str] = None
    offspring_batch_id: Optional[int] = None
    notes: Optional[str] = None

class BreedingRecordCreate(BreedingRecordBase):
    pass

class BreedingRecord(BreedingRecordBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/", response_model=List[LivestockBatch])
async def get_all_batches(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.LivestockBatch).filter(models.LivestockBatch.tenant_id == tenant_id).all()

@router.get("/{id}", response_model=LivestockBatch)
async def get_batch_by_id(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    batch = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Livestock batch not found")
    return batch

@router.post("/", response_model=LivestockBatch, status_code=status.HTTP_201_CREATED)
async def create_batch(
    batch: LivestockBatchCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    batch_data = batch.model_dump()
    if batch_data.get('quantity') is None:
        batch_data['quantity'] = batch_data.get('count', 0)
        
    db_batch = models.LivestockBatch(**batch_data, tenant_id=tenant_id)
    db.add(db_batch)
    db.commit()
    db.refresh(db_batch)
    return db_batch

@router.put("/{id}", response_model=LivestockBatch)
async def update_batch(
    id: int, 
    batch_update: LivestockBatchUpdate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    batch = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Livestock batch not found")
    
    update_data = batch_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(batch, key, value)
    
    db.commit()
    db.refresh(batch)
    return batch

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_batch(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    batch = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if batch:
        db.delete(batch)
        db.commit()
    return

@router.get("/breeding", response_model=List[BreedingRecord])
async def get_breeding_records(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.BreedingRecord).filter(models.BreedingRecord.tenant_id == tenant_id).all()

@router.post("/breeding", response_model=BreedingRecord, status_code=status.HTTP_201_CREATED)
async def create_breeding_record(
    record: BreedingRecordCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    dam = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == record.dam_batch_id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if not dam:
        raise HTTPException(status_code=404, detail="Dam batch not found")

    sire_id = record.sire_batch_id
    if sire_id is not None:
        sire = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.id == sire_id,
            models.LivestockBatch.tenant_id == tenant_id
        ).first()
        if not sire:
            raise HTTPException(status_code=404, detail="Sire batch not found")
    try:
        db_record = models.BreedingRecord(**record.model_dump(), tenant_id=tenant_id)
        db.add(db_record)
        db.commit()
        db.refresh(db_record)
        return db_record
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Invalid breeding record data")

# --- Event Endpoints ---

@router.get("/{batch_id}/events", response_model=List[LivestockEvent])
async def get_batch_events(
    batch_id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Verify batch exists for this tenant
    batch = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == batch_id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Livestock batch not found")
        
    return db.query(models.LivestockEvent).filter(
        models.LivestockEvent.batch_id == batch_id,
        models.LivestockEvent.tenant_id == tenant_id
    ).all()

@router.post("/{batch_id}/events", response_model=LivestockEvent, status_code=status.HTTP_201_CREATED)
async def create_batch_event(
    batch_id: int,
    event: LivestockEventCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Verify batch exists for this tenant
    batch = db.query(models.LivestockBatch).filter(
        models.LivestockBatch.id == batch_id,
        models.LivestockBatch.tenant_id == tenant_id
    ).first()
    if not batch:
        raise HTTPException(status_code=404, detail="Livestock batch not found")
        
    event_data = event.model_dump()
    event_data['batch_id'] = batch_id
    
    db_event = models.LivestockEvent(**event_data, tenant_id=tenant_id)
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    return db_event

@router.get("/features")
async def livestock_features(
    name: Optional[str] = None, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user)
):
    features = [
        "Multi-Species Production Dashboard",
        "Feed Conversion Optimization",
        "Health Monitoring Integration",
        "Production Cycle Synchronization",
        "Waste-to-Feed Loop Tracking",
        "Climate-Adaptive Management",
        "Integrated Performance Analytics",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}
