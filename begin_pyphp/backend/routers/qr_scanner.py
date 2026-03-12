"""
FarmOS QR Scanner Integration
Backend API endpoints for QR code scanning functionality
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from pydantic import BaseModel
from ..common.database import get_db
from ..common import models
from datetime import datetime, timedelta
import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

class QRScanData(BaseModel):
    """QR code scan data model"""
    type: str
    data: Dict
    raw: str
    scanTime: str

class LivestockQRData(BaseModel):
    """Livestock QR code data structure"""
    breed: str
    id: str
    quantity: int
    location: Optional[str] = None
    age: Optional[str] = None
    notes: Optional[str] = None

@router.post("/qr-scan")
async def process_qr_scan(
    scan_data: QRScanData,
    db: Session = Depends(get_db)
):
    """
    Process QR code scan data
    """
    try:
        # Create scan record
        scan_record = {
            'scan_time': datetime.utcnow(),
            'scan_type': scan_data.type,
            'scan_data': scan_data.data,
            'raw_data': scan_data.raw
        }
        
        # Process based on scan type
        if scan_data.type == 'structured' and scan_data.data.get('type') == 'livestock':
            # Process livestock QR scan
            livestock_data = LivestockQRData(**scan_data.data)
            result = await process_livestock_qr_scan(livestock_data, db)
        else:
            # Process generic QR scan
            result = await process_generic_qr_scan(scan_data, db)
        
        return {
            "status": "success",
            "message": "QR scan processed successfully",
            "data": result,
            "scan_time": scan_record['scan_time'].isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error processing QR scan: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "QR scan processing failed",
                "message": str(e)
            }
        )

async def process_livestock_qr_scan(livestock_data: LivestockQRData, db: Session) -> Dict:
    """Process livestock-specific QR code scan"""
    try:
        # Look up livestock batch by ID
        batch = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.id == livestock_data.id
        ).first()
        
        if not batch:
            # Create new batch if not found
            batch = models.LivestockBatch(
                id=livestock_data.id,
                tenant_id="default",
                type=livestock_data.breed,
                name=f"Batch {livestock_data.id}",
                quantity=livestock_data.quantity,
                status="active",
                breed=livestock_data.breed,
                location=livestock_data.location,
                start_date=datetime.utcnow()
            )
            
            db.add(batch)
            db.commit()
            
            action = "created"
            message = f"New livestock batch {livestock_data.id} created"
            
        else:
            # Update existing batch
            batch.quantity = livestock_data.quantity
            batch.location = livestock_data.location
            batch.updated_at = datetime.utcnow()
            
            db.commit()
            
            action = "updated"
            message = f"Livestock batch {livestock_data.id} updated"
        
        # Create scan event record
        scan_event = models.LivestockEvent(
            batch_id=batch.id,
            tenant_id=batch.tenant_id or "default",
            type="qr_scan",
            date=datetime.utcnow(),
            details={
                "scan_type": "livestock_identification",
                "breed": livestock_data.breed,
                "quantity": livestock_data.quantity,
                "location": livestock_data.location,
                "age": livestock_data.age,
                "notes": livestock_data.notes
            },
            performed_by="QR Scanner",
            cost=0.0
        )
        
        db.add(scan_event)
        db.commit()
        
        return {
            "action": action,
            "batch_id": batch.id,
            "message": message,
            "livestock_data": {
                "id": batch.id,
                "breed": batch.breed,
                "quantity": batch.quantity,
                "location": batch.location,
                "status": batch.status
            }
        }
        
    except Exception as e:
        logger.error(f"Error processing livestock QR scan: {e}")
        raise

async def process_generic_qr_scan(scan_data: QRScanData, db: Session) -> Dict:
    """Process generic QR code scan"""
    try:
        # Log generic scan for analysis
        scan_record = models.LivestockEvent(
            batch_id=0,  # Generic scan
            tenant_id="default",
            type="qr_scan",
            date=datetime.utcnow(),
            details={
                "scan_type": "generic",
                "scan_data": scan_data.data,
                "raw_data": scan_data.raw
            },
            performed_by="QR Scanner",
            cost=0.0
        )
        
        db.add(scan_record)
        db.commit()
        
        return {
            "action": "logged",
            "message": "Generic QR scan logged for analysis",
            "scan_data": scan_data.data
        }
        
    except Exception as e:
        logger.error(f"Error processing generic QR scan: {e}")
        raise

@router.get("/qr-scans")
async def get_scan_history(
    db: Session = Depends(get_db),
    limit: int = 50,
    tenant_id: str = "default"
):
    """
    Get QR scan history
    """
    try:
        # Get scan events
        scan_events = db.query(models.LivestockEvent).filter(
            models.LivestockEvent.type == "qr_scan",
            models.LivestockEvent.tenant_id == tenant_id
        ).order_by(models.LivestockEvent.date.desc()).limit(limit).all()
        
        scan_history = []
        for event in scan_events:
            scan_history.append({
                "id": event.id,
                "scan_time": event.date.isoformat() if event.date else None,
                "scan_type": event.details.get("scan_type", "unknown") if event.details else "unknown",
                "scan_data": event.details.get("scan_data", {}) if event.details else {},
                "performed_by": event.performed_by,
                "batch_id": event.batch_id
            })
        
        return {
            "status": "success",
            "data": scan_history,
            "metadata": {
                "total_scans": len(scan_history),
                "limit": limit,
                "tenant_id": tenant_id
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting scan history: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get scan history",
                "message": str(e)
            }
        )

@router.get("/qr-templates")
async def get_qr_templates(
    template_type: Optional[str] = None
):
    """
    Get QR code templates for different uses
    """
    try:
        templates = {
            "livestock": {
                "poultry": {
                    "type": "livestock",
                    "data": {
                        "type": "livestock",
                        "breed": "Broiler",
                        "id": "BATCH-001",
                        "quantity": 100,
                        "location": "House A",
                        "age": "2 weeks",
                        "notes": "Vaccinated"
                    }
                },
                "pig": {
                    "type": "livestock",
                    "data": {
                        "type": "livestock",
                        "breed": "Large White",
                        "id": "BATCH-002",
                        "quantity": 25,
                        "location": "Pen 1",
                        "age": "8 weeks",
                        "notes": "Ready for breeding"
                    }
                }
            },
            "feed": {
                "layer_feed": {
                    "type": "feed",
                    "data": {
                        "type": "feed",
                        "name": "Layer Feed Premium",
                        "batch": "LF-2025-001",
                        "supplier": "FeedCo Ltd"
                    }
                },
                "pig_starter": {
                    "type": "feed",
                    "data": {
                        "type": "feed",
                        "name": "Pig Starter Feed",
                        "batch": "PS-2025-001",
                        "supplier": "NutriFeeds"
                    }
                }
            },
            "equipment": {
                "tractor": {
                    "type": "equipment",
                    "data": {
                        "type": "equipment",
                        "name": "John Deere 5075E",
                        "id": "EQ-001",
                        "maintenance_due": "2025-02-01"
                    }
                },
                "feed_mixer": {
                    "type": "equipment",
                    "data": {
                        "type": "equipment",
                        "name": "Feed Mixer 500kg",
                        "id": "EQ-002",
                        "last_maintenance": "2025-01-15"
                    }
                }
            }
        }
        
        # Filter by template type if specified
        if template_type:
            filtered_templates = {}
            if template_type in templates:
                filtered_templates[template_type] = templates[template_type]
        else:
            filtered_templates = templates
        
        return {
            "status": "success",
            "data": filtered_templates,
            "metadata": {
                "template_types": list(templates.keys()),
                "total_templates": sum(len(category) for category in templates.values()),
                "last_updated": "2025-01-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting QR templates: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get QR templates",
                "message": str(e)
            }
        )

@router.post("/qr-generate")
async def generate_qr_code(
    qr_data: Dict,
    format_type: str = "json",
    size: int = 200
):
    """
    Generate QR code for given data
    """
    try:
        import qrcode
        from io import BytesIO
        import base64
        
        # Create QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        
        qr.add_data(json.dumps(qr_data) if format_type == "json" else str(qr_data))
        
        # Generate image
        qr_img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64 for response
        buffer = BytesIO()
        qr_img.save(buffer, format='PNG')
        qr_base64 = base64.b64encode(buffer.getvalue()).decode()
        
        return {
            "status": "success",
            "data": {
                "qr_code": qr_base64,
                "format": "PNG",
                "size": size,
                "data": qr_data
            },
            "metadata": {
                "generated_at": datetime.utcnow().isoformat(),
                "format_type": format_type
            }
        }
        
    except Exception as e:
        logger.error(f"Error generating QR code: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "QR code generation failed",
                "message": str(e)
            }
        )

@router.get("/qr-analytics")
async def get_qr_analytics(
    db: Session = Depends(get_db),
    days: int = 30,
    tenant_id: str = "default"
):
    """
    Get QR scanning analytics
    """
    try:
        # Get scan analytics
        scan_events = db.query(models.LivestockEvent).filter(
            models.LivestockEvent.type == "qr_scan",
            models.LivestockEvent.tenant_id == tenant_id,
            models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=days)
        ).all()
        
        # Analyze scan patterns
        total_scans = len(scan_events)
        unique_batches = len(set(event.batch_id for event in scan_events if event.batch_id > 0))
        
        # Scan frequency by hour
        scan_frequency = {}
        for event in scan_events:
            if event.date:
                hour = event.date.hour
                scan_frequency[hour] = scan_frequency.get(hour, 0) + 1
        
        # Most active scanning hours
        top_hours = sorted(scan_frequency.items(), key=lambda x: x[1], reverse=True)[:5]
        
        return {
            "status": "success",
            "data": {
                "total_scans": total_scans,
                "unique_batches_scanned": unique_batches,
                "scan_frequency_by_hour": scan_frequency,
                "top_scanning_hours": top_hours,
                "average_scans_per_day": round(total_scans / days, 2),
                "analysis_period_days": days
            },
            "metadata": {
                "analysis_date": datetime.utcnow().isoformat(),
                "tenant_id": tenant_id
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting QR analytics: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Analytics failed",
                "message": str(e)
            }
        )
