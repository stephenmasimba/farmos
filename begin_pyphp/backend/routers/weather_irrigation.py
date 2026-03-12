from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.weather_irrigation import WeatherIrrigationService
from ..common.dependencies import get_tenant_id
from typing import Optional, List

router = APIRouter()

@router.get("/decision")
async def get_decision(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get weather-based irrigation decision"""
    service = WeatherIrrigationService(db)
    return service.get_weather_decision(tenant_id)

@router.get("/schedule")
async def get_schedule(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get irrigation schedule"""
    service = WeatherIrrigationService(db)
    return service.get_irrigation_schedule(tenant_id)

@router.get("/moisture")
async def get_moisture(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get soil moisture stats"""
    service = WeatherIrrigationService(db)
    return service.get_soil_moisture_stats(tenant_id)
