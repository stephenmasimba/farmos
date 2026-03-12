from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["tasks"])

# --- Models ---

class TaskBase(BaseModel):
    title: str = Field(..., min_length=1, description="Task title")
    description: Optional[str] = None
    assigned_to: Optional[str] = None
    status: str = Field("pending", pattern="^(pending|in_progress|completed)$", description="pending, in_progress, completed")
    priority: str = Field("medium", pattern="^(low|medium|high)$", description="low, medium, high")
    due_date: str # Changed to str

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    assigned_to: Optional[str] = None
    status: Optional[str] = Field(None, pattern="^(pending|in_progress|completed)$")
    priority: Optional[str] = Field(None, pattern="^(low|medium|high)$")
    due_date: Optional[str] = None

class Task(TaskBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/", response_model=List[Task])
async def get_all_tasks(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.Task).filter(models.Task.tenant_id == tenant_id).all()

@router.get("/{id}", response_model=Task)
async def get_task_by_id(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    task = db.query(models.Task).filter(
        models.Task.id == id,
        models.Task.tenant_id == tenant_id
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.post("/", response_model=Task, status_code=status.HTTP_201_CREATED)
async def create_task(
    task: TaskCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    db_task = models.Task(**task.model_dump(), tenant_id=tenant_id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@router.put("/{id}", response_model=Task)
async def update_task(
    id: int, 
    task_update: TaskUpdate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    task = db.query(models.Task).filter(
        models.Task.id == id,
        models.Task.tenant_id == tenant_id
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    update_data = task_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(task, key, value)
    
    db.commit()
    db.refresh(task)
    return task

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    task = db.query(models.Task).filter(
        models.Task.id == id,
        models.Task.tenant_id == tenant_id
    ).first()
    if task:
        db.delete(task)
        db.commit()
    return

@router.patch("/{id}/status", response_model=Task)
async def update_task_status(
    id: int, 
    status: str, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    task = db.query(models.Task).filter(
        models.Task.id == id,
        models.Task.tenant_id == tenant_id
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if status not in ["pending", "in_progress", "completed"]:
        raise HTTPException(status_code=400, detail="Invalid status")
        
    task.status = status
    db.commit()
    db.refresh(task)
    return task
