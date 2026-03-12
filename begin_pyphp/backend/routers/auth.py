from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
# from passlib.context import CryptContext
import bcrypt

from ..common.security import jwt_encode
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter()
# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    # return pwd_context.verify(plain_password, hashed_password)
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

@router.post("/login", response_model=LoginResponse)
async def login(body: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == body.email).first()
    if not user or not verify_password(body.password, user.hashed_password):
        # Fallback for demo if DB is empty or user is not found, though we should seed it.
        # But for strict security, just fail.
        # However, to keep existing tests/demos working if they rely on hardcoded "password123", we should ensure seeded users have this password.
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    token = jwt_encode({"sub": str(user.id), "id": user.id, "email": user.email, "role": user.role})
    return LoginResponse(
        access_token=token, 
        user={"id": user.id, "name": user.name, "email": user.email, "role": user.role}
    )

@router.get("/me")
async def me(current_user: dict = Depends(get_current_user)):
    return current_user
