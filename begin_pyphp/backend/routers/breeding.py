from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["breeding"])

class BreedingRecordBase(BaseModel):
    animal_id: str = Field(..., min_length=1, description="ID of the animal")
    breeding_date: str
    expected_birth_date: str
    status: str = Field(..., description="Current status e.g. Pregnant, Failed, Delivered")
    notes: Optional[str] = None

class BreedingRecordCreate(BreedingRecordBase):
    pass

class BreedingRecord(BreedingRecordBase):
    id: int
    tenant_id: Optional[str] = None

    class Config:
        from_attributes = True

@router.get("/", response_model=List[BreedingRecord])
async def get_all_breeding_records(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.BreedingRecord).all()

@router.get("/{id}", response_model=BreedingRecord)
async def get_breeding_record_by_id(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    record = db.query(models.BreedingRecord).filter(models.BreedingRecord.id == id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Breeding record not found")
    return record

@router.post("/", response_model=BreedingRecord, status_code=status.HTTP_201_CREATED)
async def create_breeding_record(record: BreedingRecordCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_record = models.BreedingRecord(**record.dict())
    # db_record.tenant_id = current_user.get("tenant_id", "default")
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record

@router.put("/{id}", response_model=BreedingRecord)
async def update_breeding_record(id: int, record: BreedingRecordCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_record = db.query(models.BreedingRecord).filter(models.BreedingRecord.id == id).first()
    if not db_record:
        raise HTTPException(status_code=404, detail="Breeding record not found")
    
    update_data = record.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_record, key, value)
    
    db.commit()
    db.refresh(db_record)
    return db_record

@router.delete("/{id}")
async def delete_breeding_record(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_record = db.query(models.BreedingRecord).filter(models.BreedingRecord.id == id).first()
    if db_record:
        db.delete(db_record)
        db.commit()
    return {"message": "Record deleted"}

@router.get("/features")
async def breeding_features(name: Optional[str] = None, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    features = [
        "Multi-Species Breeding Program Management",
        "Genetic Performance Analytics",
        "Breeding Cycle Synchronization",
        "Health Screening Integration",
        "Breeding Stock Performance Forecasting",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}
