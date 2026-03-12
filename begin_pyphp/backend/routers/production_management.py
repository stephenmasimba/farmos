from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.production_management import ProductionManagementService
from typing import Optional, List

router = APIRouter()

@router.get("/pest-disease")
async def get_pest_disease(field_id: Optional[int] = None, status: Optional[str] = None, db: Session = Depends(get_db)):
    """Get pest and disease reports"""
    service = ProductionManagementService(db)
    return service.get_pest_disease_reports(field_id, status)

@router.get("/crop-rotation")
async def get_crop_rotation(field_id: Optional[int] = None, db: Session = Depends(get_db)):
    """Get crop rotation analysis"""
    service = ProductionManagementService(db)
    return service.get_crop_rotation_analysis(field_id)

@router.get("/genealogy/{animal_id}")
async def get_genealogy(animal_id: int, db: Session = Depends(get_db)):
    """Get animal genealogy"""
    service = ProductionManagementService(db)
    return service.get_animal_genealogy(animal_id)
