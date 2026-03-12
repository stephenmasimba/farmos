from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from typing import List
from datetime import date
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["contracts"])

class ContractBase(BaseModel):
    grower_name: str = Field(..., min_length=1)
    crop: str = Field(..., min_length=1)
    acreage: float = Field(..., gt=0)
    agreed_price_per_kg: float = Field(..., gt=0)
    start_date: date
    end_date: date
    status: str = "Active" # Active, Completed, Terminated

class ContractCreate(ContractBase):
    pass

class Contract(ContractBase):
    id: int
    
    class Config:
        from_attributes = True

@router.get("/contracts", response_model=List[Contract])
async def get_contracts(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.Contract).all()

@router.post("/contracts", response_model=Contract, status_code=status.HTTP_201_CREATED)
async def create_contract(contract: ContractCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Serialize dates to strings for DB
    contract_data = contract.dict()
    contract_data["start_date"] = contract.start_date.isoformat()
    contract_data["end_date"] = contract.end_date.isoformat()
    
    new_contract = models.Contract(**contract_data)
    # new_contract.tenant_id = current_user.get("tenant_id", "default")
    
    db.add(new_contract)
    db.commit()
    db.refresh(new_contract)
    return new_contract
