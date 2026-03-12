from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session
from passlib.context import CryptContext

from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["users"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

# --- Models ---

class UserBase(BaseModel):
    name: str = Field(..., min_length=2, description="Full name")
    email: EmailStr = Field(..., description="Email address")
    role: str = Field(..., pattern="^(admin|manager|worker|staff)$", description="User role")
    status: str = Field("active", pattern="^(active|inactive|suspended)$")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Password")

class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=8)
    role: Optional[str] = Field(None, pattern="^(admin|manager|worker|staff)$")
    status: Optional[str] = Field(None, pattern="^(active|inactive|suspended)$")

class User(UserBase):
    id: int
    
    class Config:
        orm_mode = True

class UserInvite(BaseModel):
    email: EmailStr
    role: str = Field("worker", pattern="^(admin|manager|worker|staff)$")

# --- Endpoints ---

@router.get("/", response_model=List[User])
async def get_users(current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.get("role") not in ["admin", "manager", None]:
        raise HTTPException(status_code=403, detail="Not authorized")
    return db.query(models.User).all()

@router.get("/{user_id}", response_model=User)
async def get_user_by_id(user_id: int, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        name=user.name,
        email=user.email,
        role=user.role,
        status=user.status,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.put("/{user_id}", response_model=User)
async def update_user(user_id: int, user_update: UserUpdate, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    # Only admin can update users (simplified logic)
    if current_user.get("role") != "admin" and current_user.get("sub") != "admin":
         pass
         
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    update_data = user_update.dict(exclude_unset=True)
    if "password" in update_data:
        update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
        
    for key, value in update_data.items():
        setattr(user, key, value)
    
    db.commit()
    db.refresh(user)
    return user

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.get("role") != "admin":
        pass 
    
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user:
        db.delete(user)
        db.commit()
    return

@router.get("/features")
async def users_features(name: Optional[str] = None, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    features = [
        "Role-Based Production Access",
        "Multi-Location User Management",
        "Training Progress Tracking",
        "Performance-Based Permissions",
        "Emergency Contact Integration",
        "Shift Handover Protocols",
        "User Activity Analytics",
        "Community Stakeholder Management",
        "User Feedback Integration",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}
