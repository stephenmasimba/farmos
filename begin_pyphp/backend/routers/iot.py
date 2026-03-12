from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.iot import IoTService
from ..common.dependencies import get_tenant_id
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(tags=["iot"])

class SensorDataInput(BaseModel):
    device_id: int
    sensor_type: str
    value: float
    unit: str

class ControlInput(BaseModel):
    equipment_id: int
    action: str
    params: Optional[Dict[str, Any]] = None

class WaterQualityLogInput(BaseModel):
    date: str
    source: str
    ph: float
    dissolved_oxygen: float
    turbidity: float
    notes: Optional[str] = None

class DeviceCreate(BaseModel):
    name: str
    type: str
    location: str
    status: Optional[str] = "offline"
    last_seen: Optional[str] = None

@router.get("/devices")
async def get_devices(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get all registered IoT devices"""
    service = IoTService(db, tenant_id=tenant_id)
    return service.get_devices()

@router.post("/devices", status_code=status.HTTP_201_CREATED)
async def create_device(
    data: DeviceCreate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    service = IoTService(db, tenant_id=tenant_id)
    result = service.add_device(
        name=data.name,
        device_type=data.type,
        location=data.location,
        status=data.status or "offline",
        last_seen=data.last_seen,
    )
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result.get("device")

@router.post("/ingest")
async def ingest_data(
    data: SensorDataInput,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Ingest sensor data"""
    service = IoTService(db, tenant_id=tenant_id)
    result = service.ingest_sensor_data(data.device_id, data.sensor_type, data.value, data.unit)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/water-quality")
async def get_water_quality_logs(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    service = IoTService(db, tenant_id=tenant_id)
    return service.get_water_quality_logs()

@router.post("/water-quality", status_code=status.HTTP_201_CREATED)
async def create_water_quality_log(
    data: WaterQualityLogInput,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    service = IoTService(db, tenant_id=tenant_id)
    result = service.add_water_quality_log(
        date=data.date,
        source=data.source,
        ph=data.ph,
        dissolved_oxygen=data.dissolved_oxygen,
        turbidity=data.turbidity,
        notes=data.notes,
    )
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result.get("log")

@router.get("/sensors/latest")
async def get_latest_readings(
    sensor_type: Optional[str] = None,
    limit: int = 10,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get latest sensor readings"""
    service = IoTService(db, tenant_id=tenant_id)
    return service.get_latest_readings(sensor_type=sensor_type, limit=limit)

@router.post("/control")
async def control_actuator(
    control: ControlInput,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Control an actuator"""
    service = IoTService(db, tenant_id=tenant_id)
    result = service.control_actuator(control.equipment_id, control.action, control.params)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/alerts")
async def get_alerts(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    service = IoTService(db, tenant_id=tenant_id)
    return service.get_active_alerts()
