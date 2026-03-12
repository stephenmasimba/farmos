"""
Biogas Router - Advanced Biogas Management
Handles biogas systems, zones, leak detection, and monitoring
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.biogas_advanced import BiogasAdvancedService
from ..common.dependencies import get_tenant_id
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class BiogasSystemCreate(BaseModel):
    name: str
    total_capacity_m3: float
    production_rate_m3h: float
    consumption_rate_m3h: float
    current_pressure_bar: float
    max_safe_pressure: float
    min_safe_pressure: float
    leak_detection_enabled: bool = True

class BiogasSystemUpdate(BaseModel):
    name: Optional[str] = None
    total_capacity_m3: Optional[float] = None
    production_rate_m3h: Optional[float] = None
    consumption_rate_m3h: Optional[float] = None
    current_pressure_bar: Optional[float] = None
    max_safe_pressure: Optional[float] = None
    min_safe_pressure: Optional[float] = None
    leak_detection_enabled: Optional[bool] = None

class BiogasZoneCreate(BaseModel):
    system_id: int
    zone_name: str
    valve_status: str = "OPEN"
    flow_rate_m3h: float = 0.0
    pressure_bar: float = 0.0

@router.get("/status")
async def get_status(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get status of all biogas systems"""
    service = BiogasAdvancedService(db)
    return service.get_system_status(tenant_id=tenant_id)

@router.get("/systems")
async def get_systems(
    system_id: Optional[int] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get biogas systems with filtering"""
    service = BiogasAdvancedService(db)
    return service.get_systems(system_id, status, tenant_id=tenant_id)

@router.post("/systems")
async def create_system(
    system_data: BiogasSystemCreate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Create a new biogas system"""
    service = BiogasAdvancedService(db)
    result = service.create_system(system_data.dict(), tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.put("/systems/{system_id}")
async def update_system(
    system_id: int,
    system_data: BiogasSystemUpdate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Update biogas system"""
    service = BiogasAdvancedService(db)
    result = service.update_system(system_id, system_data.dict(exclude_unset=True), tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.delete("/systems/{system_id}")
async def delete_system(
    system_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Delete biogas system"""
    service = BiogasAdvancedService(db)
    result = service.delete_system(system_id, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/zones")
async def get_zones(
    system_id: Optional[int] = None,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get biogas zones"""
    service = BiogasAdvancedService(db)
    return service.get_zones(system_id, tenant_id=tenant_id)

@router.post("/zones")
async def create_zone(
    zone_data: BiogasZoneCreate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Create a new biogas zone"""
    service = BiogasAdvancedService(db)
    result = service.create_zone(zone_data.dict(), tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.put("/zones/{zone_id}")
async def update_zone(
    zone_id: int,
    zone_data: Dict[str, Any],
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Update biogas zone"""
    service = BiogasAdvancedService(db)
    result = service.update_zone(zone_id, zone_data, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.delete("/zones/{zone_id}")
async def delete_zone(
    zone_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Delete biogas zone"""
    service = BiogasAdvancedService(db)
    result = service.delete_zone(zone_id, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/analyze/{system_id}")
async def analyze_leak(
    system_id: int, 
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Analyze system for potential leaks"""
    service = BiogasAdvancedService(db)
    return service.analyze_leak(system_id, tenant_id=tenant_id)

@router.post("/systems/{system_id}/isolate-zone/{zone_id}")
async def isolate_zone(
    system_id: int,
    zone_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Isolate a specific zone for leak containment"""
    service = BiogasAdvancedService(db)
    result = service.isolate_zone(system_id, zone_id, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.post("/systems/{system_id}/triangulate-leak")
async def triangulate_leak(
    system_id: int,
    sensor_data: Dict[str, Any],
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Perform leak triangulation using multiple sensor readings"""
    service = BiogasAdvancedService(db)
    result = service.triangulate_leak(system_id, sensor_data, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/systems/{system_id}/performance")
async def get_system_performance(
    system_id: int,
    days: int = 30,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get performance metrics for a biogas system"""
    service = BiogasAdvancedService(db)
    return service.get_system_performance(system_id, days, tenant_id=tenant_id)

@router.get("/dashboard")
async def get_biogas_dashboard(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get comprehensive biogas dashboard data"""
    service = BiogasAdvancedService(db)
    return service.get_dashboard_summary(tenant_id=tenant_id)

@router.post("/systems/{system_id}/maintenance")
async def schedule_maintenance(
    system_id: int,
    maintenance_data: Dict[str, Any],
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Schedule maintenance for a biogas system"""
    service = BiogasAdvancedService(db)
    result = service.schedule_maintenance(system_id, maintenance_data, tenant_id=tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/alerts")
async def get_alerts(
    severity: Optional[str] = None,
    hours: int = 24,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get biogas system alerts"""
    service = BiogasAdvancedService(db)
    return service.get_alerts(severity, hours, tenant_id=tenant_id)

