from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["timesheets"])

class TimesheetBase(BaseModel):
    user_id: int
    work_date: str
    hours_worked: float = Field(..., ge=0.0)
    task_description: Optional[str] = None
    status: str = Field("pending")  # pending, approved, rejected

class TimesheetCreate(TimesheetBase):
    pass

class TimesheetUpdate(BaseModel):
    work_date: Optional[str] = None
    hours_worked: Optional[float] = Field(None, ge=0.0)
    task_description: Optional[str] = None
    status: Optional[str] = None

class Timesheet(TimesheetBase):
    id: int
    created_at: str
    
    class Config:
        from_attributes = True

@router.get("/", response_model=List[Timesheet])
async def get_all_timesheets(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return (
        db.query(models.Timesheet)
        .join(models.User, models.User.id == models.Timesheet.user_id)
        .filter(models.User.tenant_id == tenant_id)
        .all()
    )

@router.post("/", response_model=Timesheet, status_code=status.HTTP_201_CREATED)
async def create_timesheet(
    sheet: TimesheetCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    user = db.query(models.User).filter(
        models.User.id == sheet.user_id,
        models.User.tenant_id == tenant_id
    ).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found for this tenant")
    
    db_sheet = models.Timesheet(**sheet.model_dump())
    db.add(db_sheet)
    db.commit()
    db.refresh(db_sheet)
    return db_sheet

@router.patch("/{id}/status")
async def update_timesheet_status(
    id: int, 
    status_update: dict, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    sheet = (
        db.query(models.Timesheet)
        .join(models.User, models.User.id == models.Timesheet.user_id)
        .filter(models.Timesheet.id == id, models.User.tenant_id == tenant_id)
        .first()
    )
    if not sheet:
        raise HTTPException(status_code=404, detail="Timesheet not found")
    if "status" in status_update:
        sheet.status = status_update["status"]
        if sheet.status == "approved":
            sheet.approved_by = current_user.get("id")
    db.commit()
    db.refresh(sheet)
    return sheet

@router.get("/stats")
async def get_stats(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    if current_user.get("role") not in ["admin", "manager"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    sheets = (
        db.query(models.Timesheet)
        .join(models.User, models.User.id == models.Timesheet.user_id)
        .filter(models.User.tenant_id == tenant_id)
        .all()
    )
    total_hours = sum(s.hours_worked or 0.0 for s in sheets)
    pending_count = sum(1 for s in sheets if (s.status or "").lower() == "pending")
    return {"total_hours": total_hours, "pending_approvals": pending_count}
