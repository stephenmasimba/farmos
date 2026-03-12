"""
Camera Router - Surveillance and Monitoring
Handles camera registration, streaming, and motion detection
"""

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.camera_integration import CameraIntegrationService
from ..common.dependencies import get_tenant_id
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
import json

router = APIRouter()

class CameraRegistration(BaseModel):
    name: str
    rtsp_url: str
    location: str
    camera_type: str = "ip_camera"
    resolution: Optional[str] = "1920x1080"
    fps: Optional[int] = 30
    motion_detection: Optional[bool] = True

class CameraUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    status: Optional[str] = None
    motion_detection: Optional[bool] = None

@router.post("/register")
async def register_camera(
    camera_data: CameraRegistration,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Register a new IP camera"""
    service = CameraIntegrationService(db)
    result = await service.register_camera(camera_data.dict(), tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/list")
async def list_cameras(
    status: Optional[str] = None,
    location: Optional[str] = None,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """List all cameras for the tenant"""
    service = CameraIntegrationService(db)
    return await service.list_cameras(tenant_id, status, location)

@router.get("/{camera_id}")
async def get_camera(
    camera_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get camera details"""
    service = CameraIntegrationService(db)
    camera = await service.get_camera(camera_id, tenant_id)
    if not camera:
        raise HTTPException(status_code=404, detail="Camera not found")
    return camera

@router.put("/{camera_id}")
async def update_camera(
    camera_id: int,
    camera_data: CameraUpdate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Update camera configuration"""
    service = CameraIntegrationService(db)
    result = await service.update_camera(camera_id, camera_data.dict(exclude_unset=True), tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.delete("/{camera_id}")
async def delete_camera(
    camera_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Delete a camera"""
    service = CameraIntegrationService(db)
    result = await service.delete_camera(camera_id, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.post("/{camera_id}/start-stream")
async def start_stream(
    camera_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Start video streaming for a camera"""
    service = CameraIntegrationService(db)
    result = await service.start_stream(camera_id, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.post("/{camera_id}/stop-stream")
async def stop_stream(
    camera_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Stop video streaming for a camera"""
    service = CameraIntegrationService(db)
    result = await service.stop_stream(camera_id, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/{camera_id}/snapshot")
async def get_snapshot(
    camera_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get current snapshot from camera"""
    service = CameraIntegrationService(db)
    result = await service.get_snapshot(camera_id, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/{camera_id}/motion-events")
async def get_motion_events(
    camera_id: int,
    limit: int = 50,
    hours: int = 24,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get motion detection events for a camera"""
    service = CameraIntegrationService(db)
    return await service.get_motion_events(camera_id, tenant_id, limit, hours)

@router.post("/{camera_id}/motion-detection")
async def toggle_motion_detection(
    camera_id: int,
    enabled: bool,
    sensitivity: Optional[float] = 0.3,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Enable/disable motion detection for a camera"""
    service = CameraIntegrationService(db)
    result = await service.toggle_motion_detection(camera_id, enabled, sensitivity, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.websocket("/{camera_id}/stream")
async def websocket_stream(
    websocket: WebSocket,
    camera_id: int,
    tenant_id: str = "default"
):
    """WebSocket endpoint for real-time video streaming"""
    await websocket.accept()
    
    try:
        # Initialize camera service
        from ..common.database import SessionLocal
        db = SessionLocal()
        service = CameraIntegrationService(db)
        
        # Start streaming to WebSocket
        await service.websocket_stream(websocket, camera_id, tenant_id)
        
    except WebSocketDisconnect:
        print(f"WebSocket disconnected for camera {camera_id}")
    except Exception as e:
        print(f"WebSocket error: {e}")
        await websocket.close(code=1000)
    finally:
        db.close()

@router.get("/system/status")
async def get_system_status(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get camera system status and statistics"""
    service = CameraIntegrationService(db)
    return await service.get_system_status(tenant_id)

@router.post("/system/health-check")
async def health_check_all_cameras(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Perform health check on all cameras"""
    service = CameraIntegrationService(db)
    return await service.health_check_all_cameras(tenant_id)
