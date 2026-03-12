"""
Weather-Integrated Irrigation Service - Phase 7 Feature
Prevents irrigation based on rainfall forecasts
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from ..common import models

logger = logging.getLogger(__name__)

class WeatherIrrigationService:
    """Weather-aware irrigation scheduling and management"""
    
    def __init__(self, db: Session):
        self.db = db

    def get_weather_decision(self, tenant_id: str = "default"):
        """Analyze forecast and decide if irrigation should be skipped (Simulated realistic weather)"""
        # Simulate weather based on month and random variance
        import random
        from datetime import datetime
        
        now = datetime.utcnow()
        month = now.month
        hour = now.hour
        
        # Base temperature by season (assuming Southern Hemisphere / Zimbabwe context based on "Masimba")
        # Summer: Oct-Mar (Hot/Wet), Winter: May-Aug (Cool/Dry)
        if 10 <= month or month <= 3:
            base_temp = 25.0
            rain_prob = 0.6
        else:
            base_temp = 15.0
            rain_prob = 0.1
            
        # Day/Night variance
        if 6 <= hour <= 18:
            temp = base_temp + random.uniform(0, 10)
        else:
            temp = base_temp - random.uniform(0, 5)
            
        # Simulate rain event
        is_raining = random.random() < rain_prob
        forecast_rain = random.uniform(5, 25) if is_raining else 0.0
        
        humidity = 60 + (20 if is_raining else 0) + random.uniform(-10, 10)
        humidity = max(0, min(100, humidity))
        
        should_skip = forecast_rain > 5.0
        
        return {
            "current_temp": round(temp, 1),
            "humidity": int(humidity),
            "forecast_rain_12h": round(forecast_rain, 1),
            "should_skip_irrigation": should_skip,
            "skip_reason": f"Significant rainfall ({round(forecast_rain, 1)}mm) predicted" if should_skip else "No significant rain forecast",
            "next_rain_event": (now + timedelta(hours=random.randint(1, 12))).isoformat() if should_skip else None,
            "confidence_score": random.randint(80, 95)
        }

    def get_irrigation_schedule(self, tenant_id: str = "default"):
        """Get list of scheduled and skipped irrigation tasks from database"""
        try:
            events = self.db.query(models.IrrigationEvent).filter(
                models.IrrigationEvent.tenant_id == tenant_id
            ).order_by(models.IrrigationEvent.scheduled_time.desc()).all()

            if not events:
                return self._get_mock_schedule()

            result = []
            for ev in events:
                zone = self.db.query(models.IrrigationZone).filter(models.IrrigationZone.id == ev.zone_id).first()
                result.append({
                    "id": ev.id,
                    "zone_name": zone.name if zone else "Unknown Zone",
                    "field_name": "Managed Field", # Could link to field
                    "scheduled_time": ev.scheduled_time.isoformat(),
                    "duration_min": ev.duration_minutes,
                    "status": ev.status,
                    "reason": ev.reason
                })
            return result
        except Exception as e:
            logger.error(f"Error fetching irrigation schedule: {e}")
            return self._get_mock_schedule()

    def _get_mock_schedule(self):
        """Mock fallback"""
        now = datetime.utcnow()
        return [
            {
                "id": 1, "zone_name": "North Orchard (Mock)", "field_name": "Field A",
                "scheduled_time": (now + timedelta(hours=2)).isoformat(),
                "duration_min": 45, "status": "AUTO_SKIPPED", "reason": "Rain Forecast"
            }
        ]

    def get_soil_moisture_stats(self, tenant_id: str = "default"):
        """Summary of soil moisture across zones from database"""
        try:
            zones = self.db.query(models.IrrigationZone).filter(
                models.IrrigationZone.tenant_id == tenant_id
            ).all()

            if not zones:
                return self._get_mock_moisture_stats()

            return [
                {
                    "zone": z.name,
                    "moisture_pct": z.current_moisture,
                    "status": z.status,
                    "threshold": z.moisture_threshold
                } for z in zones
            ]
        except Exception as e:
            logger.error(f"Error fetching soil moisture stats: {e}")
            return self._get_mock_moisture_stats()

    def _get_mock_moisture_stats(self):
        """Mock fallback"""
        return [{"zone": "North Orchard (Mock)", "moisture_pct": 72, "status": "WET", "threshold": 40}]
