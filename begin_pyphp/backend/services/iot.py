"""
IoT Service - Enhanced Version
Handles device management, sensor data ingestion, and actuator control
Aligned with Begin Reference System
"""

import logging
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..common import models

logger = logging.getLogger(__name__)

class IoTService:
    """IoT device management and data ingestion"""
    
    def __init__(self, db: Session, tenant_id: str = "default"):
        self.db = db
        self.tenant_id = tenant_id

    def get_devices(self):
        """Get all registered IoT devices for the tenant"""
        # In this system, we'll use Equipment as the base for IoT devices for now
        # or we could add a dedicated IoTDevice model. Let's use Equipment.
        devices = self.db.query(models.Equipment).filter(
            models.Equipment.tenant_id == self.tenant_id
        ).all()
        
        return [
            {
                "id": d.id,
                "name": d.name,
                "location": d.location,
                "status": d.status,
                "type": "sensor",
                "last_seen": d.last_maintenance.isoformat() if d.last_maintenance else None,
                "last_maintenance": d.last_maintenance.isoformat() if d.last_maintenance else None,
            } for d in devices
        ]

    def add_device(
        self,
        name: str,
        device_type: str,
        location: str,
        status: str = "offline",
        last_seen: Optional[str] = None,
    ):
        try:
            last_maintenance = None
            if last_seen:
                try:
                    last_maintenance = datetime.fromisoformat(last_seen)
                except ValueError:
                    last_maintenance = None
            equipment = models.Equipment(
                tenant_id=self.tenant_id,
                name=name,
                location=location,
                status=status or "offline",
                last_maintenance=last_maintenance,
            )
            self.db.add(equipment)
            self.db.commit()
            self.db.refresh(equipment)
            return {
                "success": True,
                "device": {
                    "id": equipment.id,
                    "name": equipment.name,
                    "location": equipment.location,
                    "status": equipment.status,
                    "type": device_type,
                    "last_seen": equipment.last_maintenance.isoformat() if equipment.last_maintenance else None,
                },
            }
        except Exception as e:
            logger.error(f"Error adding IoT device: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def ingest_sensor_data(self, device_id: int, sensor_type: str, value: float, unit: str):
        """Store incoming sensor data"""
        try:
            new_data = models.SensorData(
                tenant_id=self.tenant_id,
                sensor_type=sensor_type,
                value=value,
                unit=unit,
                timestamp=datetime.utcnow()
            )
            # In a more advanced version, we'd link to equipment_id
            self.db.add(new_data)
            self.db.commit()
            return {"success": True, "data_id": new_data.id}
        except Exception as e:
            logger.error(f"Error ingesting sensor data: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_latest_readings(self, sensor_type: Optional[str] = None, limit: int = 10):
        """Get latest sensor readings"""
        query = self.db.query(models.SensorData).filter(
            models.SensorData.tenant_id == self.tenant_id
        )
        if sensor_type:
            query = query.filter(models.SensorData.sensor_type == sensor_type)
            
        readings = query.order_by(desc(models.SensorData.timestamp)).limit(limit).all()
        
        return [
            {
                "id": r.id,
                "type": r.sensor_type,
                "value": r.value,
                "unit": r.unit,
                "timestamp": r.timestamp.isoformat(),
                "location": r.location
            } for r in readings
        ]

    def control_actuator(self, equipment_id: int, action: str, params: Dict[str, Any] = None):
        """Send command to an actuator"""
        # In a real system, this would communicate via MQTT/HTTP to the device
        # For now, we log the action and update equipment status
        equipment = self.db.query(models.Equipment).filter(
            models.Equipment.id == equipment_id,
            models.Equipment.tenant_id == self.tenant_id
        ).first()
        
        if not equipment:
            return {"success": False, "error": "Equipment not found"}
            
        # Log the command (could add a CommandLog model)
        logger.info(f"Command sent to {equipment.name}: {action} with params {params}")
        
        return {
            "success": True, 
            "message": f"Command {action} sent to {equipment.name}",
            "timestamp": datetime.utcnow().isoformat()
        }

    def get_water_quality_logs(self, limit: int = 100):
        try:
            query = self.db.query(models.WaterQualityLog).filter(
                models.WaterQualityLog.tenant_id == self.tenant_id
            ).order_by(models.WaterQualityLog.date.desc())
            logs = query.limit(limit).all()
            return [
                {
                    "id": log.id,
                    "date": log.date,
                    "source": log.source,
                    "ph": log.ph,
                    "dissolved_oxygen": log.dissolved_oxygen,
                    "turbidity": log.turbidity,
                    "notes": log.notes,
                }
                for log in logs
            ]
        except Exception as e:
            logger.error(f"Error fetching water quality logs: {e}")
            return []

    def add_water_quality_log(
        self,
        date: str,
        source: str,
        ph: float,
        dissolved_oxygen: float,
        turbidity: float,
        notes: Optional[str] = None,
    ):
        try:
            log = models.WaterQualityLog(
                tenant_id=self.tenant_id,
                date=date,
                source=source,
                ph=ph,
                dissolved_oxygen=dissolved_oxygen,
                turbidity=turbidity,
                notes=notes,
            )
            self.db.add(log)
            self.db.commit()
            self.db.refresh(log)
            return {
                "success": True,
                "log": {
                    "id": log.id,
                    "date": log.date,
                    "source": log.source,
                    "ph": log.ph,
                    "dissolved_oxygen": log.dissolved_oxygen,
                    "turbidity": log.turbidity,
                    "notes": log.notes,
                },
            }
        except Exception as e:
            logger.error(f"Error adding water quality log: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_active_alerts(self, limit: int = 20):
        alerts: List[Dict[str, Any]] = []
        try:
            logs = self.db.query(models.WaterQualityLog).filter(
                models.WaterQualityLog.tenant_id == self.tenant_id
            ).order_by(models.WaterQualityLog.date.desc()).limit(100).all()
            for log in logs:
                if log.ph is not None and (log.ph < 6.5 or log.ph > 8.5):
                    alerts.append(
                        {
                            "id": f"ph-{log.id}",
                            "message": f"{log.source} pH {log.ph} out of range",
                            "time": log.date,
                            "type": "warning",
                        }
                    )
                if log.dissolved_oxygen is not None and log.dissolved_oxygen < 5.0:
                    alerts.append(
                        {
                            "id": f"do-{log.id}",
                            "message": f"{log.source} dissolved oxygen low ({log.dissolved_oxygen} mg/L)",
                            "time": log.date,
                            "type": "critical",
                        }
                    )
                if log.turbidity is not None and log.turbidity > 5.0:
                    alerts.append(
                        {
                            "id": f"turbidity-{log.id}",
                            "message": f"{log.source} turbidity high ({log.turbidity} NTU)",
                            "time": log.date,
                            "type": "warning",
                        }
                    )
                if len(alerts) >= limit:
                    break
        except Exception as e:
            logger.error(f"Error computing IoT alerts: {e}")
        return alerts
