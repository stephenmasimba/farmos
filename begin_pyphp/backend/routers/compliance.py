from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import List, Optional
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["compliance"])

class ComplianceRequirementBase(BaseModel):
    standard: str = Field(..., description="e.g. GlobalGAP, Organic")
    section: str = Field(..., description="e.g. AF.1 Site History")
    description: str
    status: str = Field("Pending", pattern="^(Compliant|Non-Compliant|Pending|N/A)$")
    last_audit_date: Optional[str] = None
    auditor: Optional[str] = None
    evidence_url: Optional[str] = None

class ComplianceRequirementCreate(ComplianceRequirementBase):
    pass

class ComplianceRequirement(ComplianceRequirementBase):
    id: int
    tenant_id: Optional[str] = None

    class Config:
        from_attributes = True

@router.get("/requirements", response_model=List[ComplianceRequirement])
async def get_requirements(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.ComplianceRequirement).all()

@router.post("/requirements", response_model=ComplianceRequirement, status_code=status.HTTP_201_CREATED)
async def create_requirement(req: ComplianceRequirementCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_req = models.ComplianceRequirement(**req.dict())
    # db_req.tenant_id = current_user.get("tenant_id", "default")
    db.add(db_req)
    db.commit()
    db.refresh(db_req)
    return db_req

@router.put("/requirements/{id}", response_model=ComplianceRequirement)
async def update_requirement(id: int, req: ComplianceRequirementCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_req = db.query(models.ComplianceRequirement).filter(models.ComplianceRequirement.id == id).first()
    if not db_req:
        raise HTTPException(status_code=404, detail="Requirement not found")
    
    update_data = req.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_req, key, value)
        
    db.commit()
    db.refresh(db_req)
    return db_req
