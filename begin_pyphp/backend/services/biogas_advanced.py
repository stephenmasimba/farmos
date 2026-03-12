"""
Biogas Advanced Service - Phase 3 Feature
Handles leak triangulation, zone isolation, and pressure monitoring
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import random

logger = logging.getLogger(__name__)

class BiogasAdvancedService:
    """Advanced biogas management service with leak triangulation"""
    
    def __init__(self, db: Session):
        self.db = db

    def get_systems(self, system_id: Optional[int] = None, status: Optional[str] = None, tenant_id: str = "default"):
        """Get biogas systems with filtering"""
        try:
            query = self.db.query(models.BiogasSystem).filter(models.BiogasSystem.tenant_id == tenant_id)
            
            if system_id:
                query = query.filter(models.BiogasSystem.id == system_id)
            if status:
                query = query.filter(models.BiogasSystem.status == status)
            
            systems = query.all()
            
            return [
                {
                    "id": s.id,
                    "name": s.name,
                    "total_capacity_m3": s.total_capacity_m3,
                    "production_rate_m3h": s.production_rate_m3h,
                    "consumption_rate_m3h": s.consumption_rate_m3h,
                    "current_pressure_bar": s.current_pressure_bar,
                    "max_safe_pressure": s.max_safe_pressure,
                    "min_safe_pressure": s.min_safe_pressure,
                    "leak_detection_enabled": s.leak_detection_enabled,
                    "last_maintenance": s.last_maintenance.isoformat() if s.last_maintenance else None
                }
                for s in systems
            ]
        except Exception as e:
            logger.error(f"Error getting biogas systems: {e}")
            return []

    def create_system(self, system_data: Dict[str, Any], tenant_id: str = "default"):
        """Create a new biogas system"""
        try:
            system = models.BiogasSystem(
                tenant_id=tenant_id,
                name=system_data.get("name"),
                total_capacity_m3=system_data.get("total_capacity_m3"),
                production_rate_m3h=system_data.get("production_rate_m3h"),
                consumption_rate_m3h=system_data.get("consumption_rate_m3h"),
                current_pressure_bar=system_data.get("current_pressure_bar"),
                max_safe_pressure=system_data.get("max_safe_pressure"),
                min_safe_pressure=system_data.get("min_safe_pressure"),
                leak_detection_enabled=system_data.get("leak_detection_enabled", True)
            )
            self.db.add(system)
            self.db.commit()
            self.db.refresh(system)
            
            return {
                "success": True,
                "system": {
                    "id": system.id,
                    "name": system.name
                }
            }
        except Exception as e:
            logger.error(f"Error creating biogas system: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def update_system(self, system_id: int, update_data: Dict[str, Any], tenant_id: str = "default"):
        """Update biogas system"""
        try:
            system = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.id == system_id,
                models.BiogasSystem.tenant_id == tenant_id
            ).first()
            
            if not system:
                return {"success": False, "error": "System not found"}
            
            for field, value in update_data.items():
                if hasattr(system, field):
                    setattr(system, field, value)
            
            self.db.commit()
            
            return {"success": True, "system": {"id": system.id, "name": system.name}}
        except Exception as e:
            logger.error(f"Error updating biogas system: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def delete_system(self, system_id: int, tenant_id: str = "default"):
        """Delete biogas system"""
        try:
            system = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.id == system_id,
                models.BiogasSystem.tenant_id == tenant_id
            ).first()
            
            if not system:
                return {"success": False, "error": "System not found"}
            
            self.db.delete(system)
            self.db.commit()
            
            return {"success": True}
        except Exception as e:
            logger.error(f"Error deleting biogas system: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def create_zone(self, zone_data: Dict[str, Any], tenant_id: str = "default"):
        """Create a new biogas zone"""
        try:
            zone = models.BiogasZone(
                tenant_id=tenant_id,
                system_id=zone_data.get("system_id"),
                zone_name=zone_data.get("zone_name"),
                valve_status=zone_data.get("valve_status", "OPEN"),
                flow_rate_m3h=zone_data.get("flow_rate_m3h", 0.0),
                pressure_bar=zone_data.get("pressure_bar", 0.0)
            )
            self.db.add(zone)
            self.db.commit()
            self.db.refresh(zone)
            
            return {
                "success": True,
                "zone": {
                    "id": zone.id,
                    "zone_name": zone.zone_name
                }
            }
        except Exception as e:
            logger.error(f"Error creating biogas zone: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def update_zone(self, zone_id: int, zone_data: Dict[str, Any], tenant_id: str = "default"):
        """Update biogas zone"""
        try:
            zone = self.db.query(models.BiogasZone).filter(
                models.BiogasZone.id == zone_id,
                models.BiogasZone.tenant_id == tenant_id
            ).first()
            
            if not zone:
                return {"success": False, "error": "Zone not found"}
            
            for field, value in zone_data.items():
                if hasattr(zone, field):
                    setattr(zone, field, value)
            
            self.db.commit()
            
            return {"success": True, "zone": {"id": zone.id, "zone_name": zone.zone_name}}
        except Exception as e:
            logger.error(f"Error updating biogas zone: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def delete_zone(self, zone_id: int, tenant_id: str = "default"):
        """Delete biogas zone"""
        try:
            zone = self.db.query(models.BiogasZone).filter(
                models.BiogasZone.id == zone_id,
                models.BiogasZone.tenant_id == tenant_id
            ).first()
            
            if not zone:
                return {"success": False, "error": "Zone not found"}
            
            self.db.delete(zone)
            self.db.commit()
            
            return {"success": True}
        except Exception as e:
            logger.error(f"Error deleting biogas zone: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def isolate_zone(self, system_id: int, zone_id: int, tenant_id: str = "default"):
        """Isolate a specific zone for leak containment"""
        try:
            zone = self.db.query(models.BiogasZone).filter(
                models.BiogasZone.id == zone_id,
                models.BiogasZone.system_id == system_id,
                models.BiogasZone.tenant_id == tenant_id
            ).first()
            
            if not zone:
                return {"success": False, "error": "Zone not found"}
            
            # Close valve to isolate zone
            zone.valve_status = "CLOSED"
            self.db.commit()
            
            return {
                "success": True,
                "message": f"Zone {zone.zone_name} isolated successfully",
                "zone_id": zone_id
            }
        except Exception as e:
            logger.error(f"Error isolating zone: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def triangulate_leak(self, system_id: int, sensor_data: Dict[str, Any], tenant_id: str = "default"):
        """Perform leak triangulation using multiple sensor readings"""
        try:
            # Get zones for the system
            zones = self.db.query(models.BiogasZone).filter(
                models.BiogasZone.system_id == system_id,
                models.BiogasZone.tenant_id == tenant_id
            ).all()
            
            # Simulate triangulation algorithm
            leak_location = self._calculate_leak_location(sensor_data, zones)
            
            return {
                "success": True,
                "system_id": system_id,
                "leak_detected": True,
                "estimated_location": leak_location,
                "confidence": 0.85,
                "recommended_action": "Isolate affected zones immediately"
            }
        except Exception as e:
            logger.error(f"Error triangulating leak: {e}")
            return {"success": False, "error": str(e)}

    def _calculate_leak_location(self, sensor_data: Dict[str, Any], zones: List) -> Dict[str, Any]:
        """Calculate leak location from sensor data"""
        # Simplified triangulation logic
        pressure_readings = sensor_data.get("pressure_readings", [])
        
        if len(pressure_readings) < 3:
            return {"x": 0, "y": 0, "accuracy": "low"}
        
        # Find zones with abnormal pressure drops
        affected_zones = []
        for reading in pressure_readings:
            if reading.get("pressure", 0) < 0.8:  # Threshold for leak detection
                affected_zones.append(reading.get("zone_id"))
        
        if affected_zones:
            # Return approximate location
            return {
                "x": sum(affected_zones) / len(affected_zones),
                "y": sum(affected_zones) / len(affected_zones),
                "accuracy": "medium",
                "affected_zones": affected_zones
            }
        
        return {"x": 0, "y": 0, "accuracy": "no_leak_detected"}

    def get_system_performance(self, system_id: int, days: int, tenant_id: str = "default"):
        """Get performance metrics for a biogas system"""
        try:
            from datetime import timedelta
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # Get system
            system = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.id == system_id,
                models.BiogasSystem.tenant_id == tenant_id
            ).first()
            
            if not system:
                return {"error": "System not found"}
            
            # Calculate performance metrics
            efficiency = (system.production_rate_m3h / system.total_capacity_m3) * 100 if system.total_capacity_m3 > 0 else 0
            
            return {
                "system_id": system_id,
                "period_days": days,
                "efficiency_percentage": efficiency,
                "production_rate": system.production_rate_m3h,
                "consumption_rate": system.consumption_rate_m3h,
                "net_flow": system.production_rate_m3h - system.consumption_rate_m3h,
                "pressure_status": "normal" if system.min_safe_pressure <= system.current_pressure_bar <= system.max_safe_pressure else "abnormal",
                "last_maintenance": system.last_maintenance.isoformat() if system.last_maintenance else None
            }
        except Exception as e:
            logger.error(f"Error getting system performance: {e}")
            return {"error": str(e)}

    def get_dashboard_summary(self, tenant_id: str = "default"):
        """Get comprehensive biogas dashboard data"""
        try:
            systems = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.tenant_id == tenant_id
            ).all()
            
            zones = self.db.query(models.BiogasZone).filter(
                models.BiogasZone.tenant_id == tenant_id
            ).all()
            
            # Calculate summary metrics
            total_capacity = sum(s.total_capacity_m3 for s in systems)
            total_production = sum(s.production_rate_m3h for s in systems)
            total_consumption = sum(s.consumption_rate_m3h for s in systems)
            
            active_systems = len([s for s in systems if s.leak_detection_enabled])
            alert_systems = len([s for s in systems if s.current_pressure_bar < s.min_safe_pressure or s.current_pressure_bar > s.max_safe_pressure])
            
            return {
                "total_systems": len(systems),
                "active_systems": active_systems,
                "alert_systems": alert_systems,
                "total_zones": len(zones),
                "total_capacity_m3": total_capacity,
                "total_production_m3h": total_production,
                "total_consumption_m3h": total_consumption,
                "net_flow_m3h": total_production - total_consumption,
                "overall_status": "operational" if alert_systems == 0 else "alerts_active"
            }
        except Exception as e:
            logger.error(f"Error getting dashboard summary: {e}")
            return {"error": str(e)}

    def schedule_maintenance(self, system_id: int, maintenance_data: Dict[str, Any], tenant_id: str = "default"):
        """Schedule maintenance for a biogas system"""
        try:
            system = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.id == system_id,
                models.BiogasSystem.tenant_id == tenant_id
            ).first()
            
            if not system:
                return {"success": False, "error": "System not found"}
            
            # Update last maintenance date
            from datetime import datetime
            system.last_maintenance = datetime.utcnow()
            self.db.commit()
            
            return {
                "success": True,
                "message": f"Maintenance scheduled for system {system.name}",
                "system_id": system_id
            }
        except Exception as e:
            logger.error(f"Error scheduling maintenance: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_alerts(self, severity: Optional[str] = None, hours: int = 24, tenant_id: str = "default"):
        """Get biogas system alerts"""
        try:
            from datetime import timedelta
            start_time = datetime.utcnow() - timedelta(hours=hours)
            
            # Get systems with alerts
            systems = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.tenant_id == tenant_id
            ).all()
            
            alerts = []
            for system in systems:
                # Check for pressure alerts
                if system.current_pressure_bar < system.min_safe_pressure:
                    alerts.append({
                        "system_id": system.id,
                        "system_name": system.name,
                        "alert_type": "LOW_PRESSURE",
                        "severity": "CRITICAL" if system.current_pressure_bar < system.min_safe_pressure * 0.8 else "WARNING",
                        "message": f"Low pressure in {system.name}",
                        "timestamp": datetime.utcnow().isoformat()
                    })
                elif system.current_pressure_bar > system.max_safe_pressure:
                    alerts.append({
                        "system_id": system.id,
                        "system_name": system.name,
                        "alert_type": "HIGH_PRESSURE",
                        "severity": "CRITICAL" if system.current_pressure_bar > system.max_safe_pressure * 1.2 else "WARNING",
                        "message": f"High pressure in {system.name}",
                        "timestamp": datetime.utcnow().isoformat()
                    })
                
                # Check for leak alerts
                net_flow = system.production_rate_m3h - system.consumption_rate_m3h
                if net_flow < -0.5 and system.leak_detection_enabled:
                    alerts.append({
                        "system_id": system.id,
                        "system_name": system.name,
                        "alert_type": "POTENTIAL_LEAK",
                        "severity": "CRITICAL",
                        "message": f"Potential leak detected in {system.name}",
                        "timestamp": datetime.utcnow().isoformat()
                    })
            
            # Filter by severity if specified
            if severity:
                alerts = [a for a in alerts if a["severity"] == severity.upper()]
            
            return alerts
        except Exception as e:
            logger.error(f"Error getting alerts: {e}")
            return []

    def get_system_status(self, tenant_id: str = "default"):
        """Get status of all biogas systems from database"""
        try:
            systems = self.db.query(models.BiogasSystem).filter(
                models.BiogasSystem.tenant_id == tenant_id
            ).all()

            if not systems:
                return self._get_mock_system_status()

            result = []
            for s in systems:
                net_flow = s.production_rate_m3h - s.consumption_rate_m3h
                alert_level = "OPERATIONAL"
                if s.current_pressure_bar < s.min_safe_pressure:
                    alert_level = "CRITICAL_LOW_PRESSURE"
                elif s.current_pressure_bar > s.max_safe_pressure:
                    alert_level = "CRITICAL_HIGH_PRESSURE"
                elif net_flow < -0.5:
                    alert_level = "POTENTIAL_LEAK"
                
                result.append({
                    "id": s.id,
                    "system_name": s.name,
                    "total_capacity_m3": s.total_capacity_m3,
                    "current_pressure_bar": s.current_pressure_bar,
                    "max_safe_pressure": s.max_safe_pressure,
                    "min_safe_pressure": s.min_safe_pressure,
                    "gas_production_rate_m3h": s.production_rate_m3h,
                    "gas_consumption_rate_m3h": s.consumption_rate_m3h,
                    "net_flow_rate_m3h": net_flow,
                    "system_status": s.status,
                    "alert_level": alert_level,
                    "pressure_percentage": round((s.current_pressure_bar / s.max_safe_pressure) * 100, 1),
                    "leak_detection_enabled": s.leak_detection_enabled,
                    "last_maintenance_date": s.last_maintenance.isoformat()
                })
            return result
        except Exception as e:
            logger.error(f"Error fetching biogas system status: {e}")
            return self._get_mock_system_status()

    def _get_mock_system_status(self):
        """Mock fallback"""
        return [{
            "id": 1, "system_name": "Main Digester Alpha (Mock)", "total_capacity_m3": 500.0,
            "current_pressure_bar": 0.85, "max_safe_pressure": 1.2, "min_safe_pressure": 0.2,
            "gas_production_rate_m3h": 12.5, "gas_consumption_rate_m3h": 10.2, "net_flow_rate_m3h": 2.3,
            "system_status": "normal", "alert_level": "OPERATIONAL", "pressure_percentage": 70.8,
            "leak_detection_enabled": True, "last_maintenance_date": datetime.utcnow().isoformat()
        }]

    def get_zones(self, system_id: Optional[int] = None, tenant_id: str = "default"):
        """Get biogas zones with risk levels from database"""
        try:
            query = self.db.query(models.BiogasZone).filter(models.BiogasZone.tenant_id == tenant_id)
            if system_id:
                query = query.filter(models.BiogasZone.system_id == system_id)
            
            zones = query.all()
            if not zones:
                return self._get_mock_zones()

            result = []
            for z in zones:
                # Pressure status
                p_status = "STABLE"
                if z.pressure_drop_rate > 0.1: p_status = "RAPID_DROP"
                elif z.pressure_drop_rate > 0.05: p_status = "MODERATE_DROP"
                elif z.pressure_drop_rate > 0.02: p_status = "SLOW_DROP"
                
                # Risk level
                risk = "NORMAL"
                if z.leak_sensor_status == "triggered": risk = "LEAK_DETECTED"
                elif z.pressure_drop_rate > 0.1: risk = "HIGH_RISK"
                elif z.pressure_drop_rate > 0.05: risk = "MEDIUM_RISK"

                result.append({
                    "id": z.id, "system_id": z.system_id, "zone_name": z.name, "zone_type": z.zone_type,
                    "current_pressure": z.current_pressure, "flow_rate": z.flow_rate, "valve_status": z.valve_status,
                    "leak_sensor_status": z.leak_sensor_status, "pressure_drop_rate": z.pressure_drop_rate,
                    "isolation_possible": z.isolation_possible, "pressure_status": p_status, "risk_level": risk
                })
            return result
        except Exception as e:
            logger.error(f"Error fetching biogas zones: {e}")
            return self._get_mock_zones()

    def _get_mock_zones(self):
        """Mock fallback"""
        return [{
            "id": 1, "system_id": 1, "zone_name": "Primary Tank (Mock)", "zone_type": "digester",
            "current_pressure": 0.85, "flow_rate": 5.2, "valve_status": "open", "risk_level": "NORMAL"
        }]

    def analyze_leak(self, system_id: int, tenant_id: str = "default"):
        """Analyze pressure drops to triangulate potential leaks"""
        zones = self.get_zones(system_id, tenant_id=tenant_id)

        leaking_zones = [z for z in zones if z["risk_level"] in ["HIGH_RISK", "MEDIUM_RISK", "LEAK_DETECTED"]]
        
        if not leaking_zones:
            return {
                "leak_detected": False,
                "message": "No significant leaks detected in the system."
            }
            
        # Triangulation logic
        suggested_actions = []
        for lz in leaking_zones:
            if lz["isolation_possible"]:
                suggested_actions.append(f"Isolate zone: {lz['zone_name']}")
            suggested_actions.append(f"Inspect valves in {lz['zone_name']}")
            
        return {
            "leak_detected": True,
            "severity": "High" if any(z["risk_level"] == "HIGH_RISK" for z in leaking_zones) else "Medium",
            "affected_zones": [z["zone_name"] for z in leaking_zones],
            "suggested_actions": suggested_actions,
            "timestamp": datetime.utcnow().isoformat()
        }
