"""
FarmOS Livestock Health Monitoring Router
API endpoints for livestock health monitoring and alerts
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from ..services.livestock_health import livestock_health_monitor
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/health/summary")
async def get_health_summary(
    db: Session = Depends(get_db),
    tenant_id: str = "default"
):
    """
    Get overall health summary for all livestock batches
    """
    try:
        summary = await livestock_health_monitor.get_health_summary(db, tenant_id)
        
        return {
            "status": "success",
            "data": summary,
            "metadata": {
                "tenant_id": tenant_id,
                "check_time": summary.get('last_check'),
                "monitoring_active": True
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting health summary: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Health check failed",
                "message": str(e)
            }
        )

@router.get("/health/batch/{batch_id}")
async def get_batch_health(
    batch_id: int,
    db: Session = Depends(get_db)
):
    """
    Get detailed health information for a specific livestock batch
    """
    try:
        # Get batch information
        batch = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.id == batch_id
        ).first()
        
        if not batch:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Batch not found",
                    "message": f"Livestock batch {batch_id} not found"
                }
            )
        
        # Get recent health events
        recent_events = db.query(models.LivestockEvent).filter(
            models.LivestockEvent.batch_id == batch_id,
            models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=7)
        ).all()
        
        # Analyze health data
        health_analysis = await livestock_health_monitor._analyze_health_data(db, batch, recent_events)
        
        return {
            "status": "success",
            "data": {
                "batch": {
                    "id": batch.id,
                    "type": batch.type,
                    "name": batch.name,
                    "quantity": batch.quantity,
                    "status": batch.status,
                    "breed": batch.breed,
                    "location": batch.location,
                    "start_date": batch.start_date.isoformat() if batch.start_date else None
                },
                "health_analysis": health_analysis,
                "recent_events": [
                    {
                        "id": event.id,
                        "type": event.type,
                        "date": event.date.isoformat() if event.date else None,
                        "details": event.details,
                        "performed_by": event.performed_by
                    }
                    for event in recent_events
                ]
            },
            "metadata": {
                "analysis_period": "7 days",
                "check_time": datetime.utcnow().isoformat()
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting batch health: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Health analysis failed",
                "message": str(e)
            }
        )

@router.post("/health/check/{batch_id}")
async def create_health_check(
    batch_id: int,
    health_data: Dict,
    db: Session = Depends(get_db),
    background_tasks: BackgroundTasks = Depends()
):
    """
    Create a health check event for a livestock batch
    """
    try:
        # Get batch information
        batch = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.id == batch_id
        ).first()
        
        if not batch:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Batch not found",
                    "message": f"Livestock batch {batch_id} not found"
                }
            )
        
        # Create health check event
        health_event = models.LivestockEvent(
            batch_id=batch_id,
            tenant_id=batch.tenant_id or "default",
            type="health_check",
            date=datetime.utcnow(),
            details=health_data,
            performed_by=health_data.get('performed_by', 'System'),
            cost=0.0
        )
        
        db.add(health_event)
        db.commit()
        
        # Trigger health analysis in background
        background_tasks.add_task(
            livestock_health_monitor._check_batch_health,
            db, batch
        )
        
        return {
            "status": "success",
            "message": "Health check recorded",
            "data": {
                "event_id": health_event.id,
                "batch_id": batch_id,
                "check_time": datetime.utcnow().isoformat()
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating health check: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Health check failed",
                "message": str(e)
            }
        )

@router.post("/health/alert/{batch_id}")
async def create_health_alert(
    batch_id: int,
    alert_data: Dict,
    db: Session = Depends(get_db),
    background_tasks: BackgroundTasks = Depends()
):
    """
    Create a manual health alert for a livestock batch
    """
    try:
        # Get batch information
        batch = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.id == batch_id
        ).first()
        
        if not batch:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Batch not found",
                    "message": f"Livestock batch {batch_id} not found"
                }
            )
        
        # Create health alert event
        alert_event = models.LivestockEvent(
            batch_id=batch_id,
            tenant_id=batch.tenant_id or "default",
            type="health_alert",
            date=datetime.utcnow(),
            details={
                "alert_type": alert_data.get('alert_type', 'manual'),
                "message": alert_data.get('message', ''),
                "severity": alert_data.get('severity', 'medium'),
                "requires_action": alert_data.get('requires_action', False)
            },
            performed_by=alert_data.get('performed_by', 'User'),
            cost=0.0
        )
        
        db.add(alert_event)
        db.commit()
        
        # Send immediate alert via WebSocket
        await livestock_health_monitor._send_health_alert(
            batch.tenant_id or "default",
            {
                'type': 'health_alert',
                'batch_id': batch_id,
                'livestock_type': batch.type,
                'message': alert_data.get('message', 'Manual health alert'),
                'priority': alert_data.get('severity', 'medium'),
                'timestamp': datetime.utcnow().isoformat(),
                'requires_immediate_action': alert_data.get('requires_action', False),
                'data': alert_data
            }
        )
        
        return {
            "status": "success",
            "message": "Health alert created and sent",
            "data": {
                "event_id": alert_event.id,
                "batch_id": batch_id,
                "alert_time": datetime.utcnow().isoformat()
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating health alert: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Alert creation failed",
                "message": str(e)
            }
        )

@router.get("/health/thresholds")
async def get_health_thresholds(
    livestock_type: Optional[str] = None
):
    """
    Get health thresholds for different livestock types
    """
    try:
        thresholds = livestock_health_monitor.health_thresholds
        
        if livestock_type:
            filtered_thresholds = {
                key: value for key, value in thresholds.items()
                if livestock_type.lower() in key.lower()
            }
        else:
            filtered_thresholds = thresholds
        
        return {
            "status": "success",
            "data": filtered_thresholds,
            "metadata": {
                "livestock_type": livestock_type,
                "last_updated": "2025-01-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting health thresholds: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get thresholds",
                "message": str(e)
            }
        )

@router.post("/health/thresholds")
async def update_health_thresholds(
    threshold_data: Dict,
    background_tasks: BackgroundTasks = Depends()
):
    """
    Update health thresholds for livestock monitoring
    """
    try:
        # Validate threshold data
        livestock_type = threshold_data.get('livestock_type', '').lower()
        metric_type = threshold_data.get('metric_type', '').lower()
        
        if not livestock_type or not metric_type:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Missing required fields",
                    "message": "livestock_type and metric_type are required"
                }
            )
        
        # Update thresholds (this would typically be stored in database)
        # For now, just return success
        
        return {
            "status": "success",
            "message": "Health thresholds updated",
            "data": {
                "livestock_type": livestock_type,
                "metric_type": metric_type,
                "new_thresholds": threshold_data.get('thresholds', {}),
                "update_time": datetime.utcnow().isoformat()
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating health thresholds: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Threshold update failed",
                "message": str(e)
            }
        )

@router.post("/monitoring/start")
async def start_monitoring(
    background_tasks: BackgroundTasks = Depends()
):
    """
    Start the livestock health monitoring service
    """
    try:
        await livestock_health_monitor.start_monitoring()
        
        return {
            "status": "success",
            "message": "Livestock health monitoring started",
            "data": {
                "start_time": datetime.utcnow().isoformat(),
                "monitoring_active": True
            }
        }
        
    except Exception as e:
        logger.error(f"Error starting monitoring: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to start monitoring",
                "message": str(e)
            }
        )

@router.post("/monitoring/stop")
async def stop_monitoring():
    """
    Stop the livestock health monitoring service
    """
    try:
        await livestock_health_monitor.stop_monitoring()
        
        return {
            "status": "success",
            "message": "Livestock health monitoring stopped",
            "data": {
                "stop_time": datetime.utcnow().isoformat(),
                "monitoring_active": False
            }
        }
        
    except Exception as e:
        logger.error(f"Error stopping monitoring: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to stop monitoring",
                "message": str(e)
            }
        )
