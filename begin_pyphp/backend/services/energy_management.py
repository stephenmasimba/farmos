"""
Energy Management Service - Phase 4 Feature
Handles Smart Energy Monitoring and Automated Load Shedding
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models

logger = logging.getLogger(__name__)

class EnergyManagementService:
    """Smart energy monitoring and load shedding service"""
    
    def __init__(self, db: Session):
        self.db = db

    def get_system_status(self, tenant_id: str = "default"):
        """Get current energy system status from database logs"""
        try:
            latest_log = self.db.query(models.EnergyLog).filter(
                models.EnergyLog.tenant_id == tenant_id
            ).order_by(models.EnergyLog.timestamp.desc()).first()

            if not latest_log:
                return self._get_mock_system_status()

            return {
                "battery_voltage": latest_log.battery_voltage,
                "battery_percentage": latest_log.battery_percentage,
                "load_shedding_active": latest_log.battery_voltage < 48.0,
                "essential_loads_only": latest_log.battery_voltage < 47.0,
                "total_consumption_watts": latest_log.consumption_watts,
                "solar_generation_watts": latest_log.solar_generation_watts,
                "grid_status": latest_log.grid_status,
                "active_loads": self.db.query(models.EnergyLoad).filter(
                    models.EnergyLoad.tenant_id == tenant_id,
                    models.EnergyLoad.status == "on"
                ).count(),
                "non_essential_cutoff_v": 48.0,
                "critical_cutoff_v": 46.5,
                "recovery_v": 50.0,
                "last_event": "Real-time data from sensors"
            }
        except Exception as e:
            logger.error(f"Error fetching energy system status: {e}")
            return self._get_mock_system_status()

    def _get_mock_system_status(self):
        """Mock fallback"""
        return {
            "battery_voltage": 51.2, "battery_percentage": 78, "load_shedding_active": False,
            "essential_loads_only": False, "total_consumption_watts": 1250, "solar_generation_watts": 2100,
            "grid_status": "disconnected", "active_loads": 12
        }

    def get_loads(self, tenant_id: str = "default"):
        """Get list of electrical loads from database"""
        try:
            loads = self.db.query(models.EnergyLoad).filter(
                models.EnergyLoad.tenant_id == tenant_id
            ).all()

            if not loads:
                return self._get_mock_loads()

            return [
                {
                    "id": l.id, "name": l.name, "location": l.location, 
                    "type": l.load_type, "power_watts": l.power_watts, 
                    "is_essential": l.is_essential, "status": l.status, "priority": l.priority
                } for l in loads
            ]
        except Exception as e:
            logger.error(f"Error fetching energy loads: {e}")
            return self._get_mock_loads()

    def _get_mock_loads(self):
        """Mock fallback"""
        return [
            {"id": 1, "name": "Cold Storage A (Mock)", "location": "Main Barn", "type": "cooling", "power_watts": 450, "is_essential": True, "status": "on", "priority": 10}
        ]

    def get_consumption_history(self, hours: int = 24, tenant_id: str = "default"):
        """Get power consumption history from database logs"""
        try:
            since = datetime.utcnow() - timedelta(hours=hours)
            logs = self.db.query(models.EnergyLog).filter(
                models.EnergyLog.tenant_id == tenant_id,
                models.EnergyLog.timestamp >= since
            ).order_by(models.EnergyLog.timestamp.asc()).all()

            if not logs:
                return self._get_mock_history(hours)

            return [
                {
                    "timestamp": log.timestamp.isoformat(),
                    "consumption": log.consumption_watts,
                    "generation": log.solar_generation_watts
                } for log in logs
            ]
        except Exception as e:
            logger.error(f"Error fetching consumption history: {e}")
            return self._get_mock_history(hours)

    def _get_mock_history(self, hours):
        """Mock fallback history"""
        history = []
        now = datetime.utcnow()
        for i in range(hours):
            time = now - timedelta(hours=i)
            history.append({"timestamp": time.isoformat(), "consumption": 500, "generation": 0})
        return history[::-1]
