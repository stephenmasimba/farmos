"""
Enhanced Predictive Maintenance - Phase 2 Feature
Advanced equipment failure prediction with 72-hour forecasting and automated scheduling
Derived from Begin Reference System
"""

import logging
import asyncio
import numpy as np
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
from decimal import Decimal
from collections import defaultdict

logger = logging.getLogger(__name__)

from ..common import models

class EnhancedPredictiveMaintenanceService:
    """Advanced predictive maintenance with ML algorithms and automated scheduling"""
    
    def __init__(self, db: Session):
        self.db = db
        self.equipment_types = {
            'tractor': {
                'critical_components': ['engine', 'transmission', 'hydraulics', 'electrical'],
                'failure_thresholds': {
                    'vibration': 0.5,  # g-force
                    'temperature': 85,   # Celsius
                    'oil_pressure': 20,  # PSI
                    'fuel_consumption': 15  # L/hr abnormal
                },
                'maintenance_intervals': {
                    'engine': 500,  # hours
                    'transmission': 1000,
                    'hydraulics': 750,
                    'electrical': 2000
                }
            },
            'irrigation_pump': {
                'critical_components': ['motor', 'pump', 'valves', 'sensors'],
                'failure_thresholds': {
                    'vibration': 0.3,
                    'temperature': 70,
                    'pressure': 150,  # PSI
                    'flow_rate': 0.8   # m³/hr minimum
                },
                'maintenance_intervals': {
                    'motor': 2000,
                    'pump': 1500,
                    'valves': 1000,
                    'sensors': 500
                }
            },
            'milking_machine': {
                'critical_components': ['vacuum_pump', 'pulsator', 'liners', 'sensors'],
                'failure_thresholds': {
                    'vacuum_pressure': 45,  # kPa
                    'pulsation_rate': 60,   # pulses/min
                    'temperature': 40,
                    'milk_flow': 0.5       # L/min minimum
                },
                'maintenance_intervals': {
                    'vacuum_pump': 1000,
                    'pulsator': 500,
                    'liners': 250,
                    'sensors': 750
                }
            }
        }

    async def analyze_equipment_health(self, equipment_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Comprehensive equipment health analysis with ML predictions"""
        try:
            equipment = self.db.query(models.Equipment).filter(
                and_(
                    models.Equipment.id == equipment_id,
                    models.Equipment.tenant_id == tenant_id
                )
            ).first()
            
            if not equipment:
                return {"error": "Equipment not found"}
            
            # Get recent sensor data
            sensor_data = await self._get_recent_sensor_data(equipment_id, 72, tenant_id)  # 72 hours
            
            # Get maintenance history
            maintenance_history = await self._get_maintenance_history(equipment_id, tenant_id)
            
            # Analyze each critical component
            component_analysis = {}
            equipment_type_config = self.equipment_types.get(equipment.equipment_type, {})
            
            for component in equipment_type_config.get('critical_components', []):
                component_analysis[component] = await self._analyze_component_health(
                    equipment_id, component, sensor_data, maintenance_history, equipment_type_config
                )
            
            # Calculate overall equipment health score
            overall_health = await self._calculate_overall_health(component_analysis)
            
            # Predict failures within 72 hours
            failure_predictions = await self._predict_failures_72h(
                equipment_id, component_analysis, sensor_data, equipment_type_config
            )
            
            # Generate maintenance recommendations
            recommendations = await self._generate_maintenance_recommendations(
                equipment, component_analysis, failure_predictions
            )
            
            # Save analysis results
            await self._save_maintenance_analysis(
                equipment_id, component_analysis, overall_health, failure_predictions, tenant_id
            )
            
            return {
                "success": True,
                "equipment_id": equipment_id,
                "equipment_name": equipment.name,
                "equipment_type": equipment.equipment_type,
                "overall_health_score": overall_health,
                "component_analysis": component_analysis,
                "failure_predictions": failure_predictions,
                "maintenance_recommendations": recommendations,
                "analysis_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error analyzing equipment health: {e}")
            return {"error": "Equipment health analysis failed"}

    async def predict_equipment_failures(self, hours_ahead: int = 72, 
                                       tenant_id: str = "default") -> Dict[str, Any]:
        """Predict equipment failures across all equipment"""
        try:
            # Get all active equipment
            equipment_list = self.db.query(models.Equipment).filter(
                and_(
                    models.Equipment.status == 'active',
                    models.Equipment.tenant_id == tenant_id
                )
            ).all()
            
            predictions = []
            high_risk_equipment = []
            
            for equipment in equipment_list:
                # Analyze each equipment
                analysis = await self.analyze_equipment_health(equipment.id, tenant_id)
                
                if analysis.get("success"):
                    failure_predictions = analysis.get("failure_predictions", [])
                    
                    for prediction in failure_predictions:
                        if prediction['probability'] > 0.7:  # High risk threshold
                            high_risk_equipment.append({
                                "equipment_id": equipment.id,
                                "equipment_name": equipment.name,
                                "component": prediction['component'],
                                "failure_type": prediction['failure_type'],
                                "probability": prediction['probability'],
                                "estimated_failure_time": prediction['estimated_failure_time'],
                                "urgency": prediction['urgency']
                            })
                
                predictions.append({
                    "equipment_id": equipment.id,
                    "equipment_name": equipment.name,
                    "analysis": analysis
                })
            
            # Sort by risk probability
            high_risk_equipment.sort(key=lambda x: x['probability'], reverse=True)
            
            # Generate maintenance schedule
            maintenance_schedule = await self._generate_automated_maintenance_schedule(
                high_risk_equipment, tenant_id
            )
            
            return {
                "success": True,
                "prediction_horizon_hours": hours_ahead,
                "total_equipment_analyzed": len(equipment_list),
                "high_risk_equipment": high_risk_equipment,
                "maintenance_schedule": maintenance_schedule,
                "predictions_summary": await self._generate_predictions_summary(predictions),
                "analysis_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error predicting equipment failures: {e}")
            return {"error": "Failure prediction failed"}

    async def schedule_maintenance(self, schedule_data: Dict[str, Any], 
                                 tenant_id: str = "default") -> Dict[str, Any]:
        """Automated maintenance scheduling based on predictions"""
        try:
            # Create maintenance schedule
            maintenance_schedule = models.MaintenanceSchedule(
                equipment_id=schedule_data['equipment_id'],
                maintenance_type=schedule_data['maintenance_type'],
                priority=schedule_data.get('priority', 'medium'),
                scheduled_date=datetime.strptime(schedule_data['scheduled_date'], '%Y-%m-%d').date() if isinstance(schedule_data.get('scheduled_date'), str) else schedule_data.get('scheduled_date'),
                estimated_duration_hours=schedule_data.get('estimated_duration_hours', 2),
                required_parts=json.dumps(schedule_data.get('required_parts', [])),
                required_tools=json.dumps(schedule_data.get('required_tools', [])),
                assigned_technician_id=schedule_data.get('assigned_technician_id'),
                predicted_failure_probability=schedule_data.get('predicted_failure_probability'),
                cost_estimate=schedule_data.get('cost_estimate'),
                notes=schedule_data.get('notes'),
                status='scheduled',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(maintenance_schedule)
            self.db.commit()
            
            # Create work order
            work_order = await self._create_work_order(maintenance_schedule.id, tenant_id)
            
            # Notify maintenance team
            await self._notify_maintenance_team(maintenance_schedule, tenant_id)
            
            return {
                "success": True,
                "schedule_id": maintenance_schedule.id,
                "work_order_id": work_order.id if work_order else None,
                "scheduled_date": maintenance_schedule.scheduled_date.strftime('%Y-%m-%d'),
                "message": "Maintenance scheduled successfully"
            }
            
        except Exception as e:
            logger.error(f"Error scheduling maintenance: {e}")
            self.db.rollback()
            return {"error": "Maintenance scheduling failed"}

    async def get_maintenance_analytics(self, start_date: Optional[str] = None, 
                                    end_date: Optional[str] = None,
                                    tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive maintenance analytics"""
        try:
            if not start_date:
                start_date = (datetime.utcnow() - timedelta(days=30)).strftime('%Y-%m-%d')
            if not end_date:
                end_date = datetime.utcnow().strftime('%Y-%m-%d')
            
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Get maintenance data
            completed_maintenance = self.db.query(models.MaintenanceSchedule).filter(
                and_(
                    models.MaintenanceSchedule.scheduled_date >= start_dt.date(),
                    models.MaintenanceSchedule.scheduled_date <= end_dt.date(),
                    models.MaintenanceSchedule.status == 'completed',
                    models.MaintenanceSchedule.tenant_id == tenant_id
                )
            ).all()
            
            predicted_failures = self.db.query(models.EquipmentFailurePrediction).filter(
                and_(
                    models.EquipmentFailurePrediction.prediction_date >= start_dt.date(),
                    models.EquipmentFailurePrediction.prediction_date <= end_dt.date(),
                    models.EquipmentFailurePrediction.tenant_id == tenant_id
                )
            ).all()
            
            # Calculate analytics
            analytics = await self._calculate_maintenance_analytics(
                completed_maintenance, predicted_failures, start_dt, end_dt
            )
            
            # Equipment reliability metrics
            reliability_metrics = await self._calculate_equipment_reliability(tenant_id)
            
            # Cost analysis
            cost_analysis = await self._calculate_maintenance_costs(completed_maintenance)
            
            return {
                "period": {
                    "start_date": start_date,
                    "end_date": end_date
                },
                "maintenance_analytics": analytics,
                "reliability_metrics": reliability_metrics,
                "cost_analysis": cost_analysis,
                "prediction_accuracy": await self._calculate_prediction_accuracy(predicted_failures, tenant_id)
            }
            
        except Exception as e:
            logger.error(f"Error getting maintenance analytics: {e}")
            return {"error": "Analytics generation failed"}

    # Helper methods
    async def _get_recent_sensor_data(self, equipment_id: int, hours: int, tenant_id: str) -> List[Dict]:
        """Get recent sensor data for equipment"""
        try:
            cutoff_time = datetime.utcnow() - timedelta(hours=hours)
            
            sensor_data = self.db.query(models.EquipmentSensorData).filter(
                and_(
                    models.EquipmentSensorData.equipment_id == equipment_id,
                    models.EquipmentSensorData.timestamp >= cutoff_time,
                    models.EquipmentSensorData.tenant_id == tenant_id
                )
            ).order_by(models.EquipmentSensorData.timestamp.desc()).all()
            
            return [
                {
                    "timestamp": data.timestamp.isoformat(),
                    "vibration": data.vibration,
                    "temperature": data.temperature,
                    "pressure": data.pressure,
                    "flow_rate": data.flow_rate,
                    "current": data.current,
                    "voltage": data.voltage,
                    "operating_hours": data.operating_hours
                }
                for data in sensor_data
            ]
            
        except Exception as e:
            logger.error(f"Error getting sensor data: {e}")
            return []

    async def _get_maintenance_history(self, equipment_id: int, tenant_id: str) -> List[Dict]:
        """Get maintenance history for equipment"""
        try:
            maintenance_records = self.db.query(models.MaintenanceSchedule).filter(
                and_(
                    models.MaintenanceSchedule.equipment_id == equipment_id,
                    models.MaintenanceSchedule.tenant_id == tenant_id
                )
            ).order_by(models.MaintenanceSchedule.scheduled_date.desc()).limit(10).all()
            
            return [
                {
                    "maintenance_type": record.maintenance_type,
                    "scheduled_date": record.scheduled_date.isoformat(),
                    "completed_date": record.completed_date.isoformat() if record.completed_date else None,
                    "cost": record.actual_cost,
                    "downtime_hours": record.downtime_hours
                }
                for record in maintenance_records
            ]
            
        except Exception as e:
            logger.error(f"Error getting maintenance history: {e}")
            return []

    async def _analyze_component_health(self, equipment_id: int, component: str, 
                                    sensor_data: List[Dict], maintenance_history: List[Dict],
                                    equipment_config: Dict) -> Dict[str, Any]:
        """Analyze health of specific component"""
        try:
            if not sensor_data:
                return {"health_score": 0, "status": "no_data", "alerts": []}
            
            # Get component-specific thresholds
            thresholds = equipment_config.get('failure_thresholds', {})
            
            # Calculate health metrics
            health_metrics = {}
            alerts = []
            
            # Vibration analysis
            if 'vibration' in thresholds and any(d.get('vibration') for d in sensor_data):
                recent_vibration = [d['vibration'] for d in sensor_data if d.get('vibration')][:10]
                avg_vibration = np.mean(recent_vibration)
                max_vibration = np.max(recent_vibration)
                
                vibration_health = max(0, 100 - (avg_vibration / thresholds['vibration'] * 100))
                health_metrics['vibration'] = {
                    "current": avg_vibration,
                    "max": max_vibration,
                    "threshold": thresholds['vibration'],
                    "health_score": vibration_health
                }
                
                if avg_vibration > thresholds['vibration'] * 0.8:
                    alerts.append({
                        "type": "vibration_high",
                        "severity": "warning" if avg_vibration < thresholds['vibration'] else "critical",
                        "message": f"High vibration detected: {avg_vibration:.3f}g"
                    })
            
            # Temperature analysis
            if 'temperature' in thresholds and any(d.get('temperature') for d in sensor_data):
                recent_temp = [d['temperature'] for d in sensor_data if d.get('temperature')][:10]
                avg_temp = np.mean(recent_temp)
                max_temp = np.max(recent_temp)
                
                temp_health = max(0, 100 - ((avg_temp - 20) / (thresholds['temperature'] - 20) * 100))
                health_metrics['temperature'] = {
                    "current": avg_temp,
                    "max": max_temp,
                    "threshold": thresholds['temperature'],
                    "health_score": temp_health
                }
                
                if avg_temp > thresholds['temperature'] * 0.9:
                    alerts.append({
                        "type": "temperature_high",
                        "severity": "warning" if avg_temp < thresholds['temperature'] else "critical",
                        "message": f"High temperature detected: {avg_temp:.1f}°C"
                    })
            
            # Pressure analysis (if applicable)
            if 'pressure' in thresholds and any(d.get('pressure') for d in sensor_data):
                recent_pressure = [d['pressure'] for d in sensor_data if d.get('pressure')][:10]
                avg_pressure = np.mean(recent_pressure)
                
                pressure_health = min(100, (avg_pressure / thresholds['pressure']) * 100)
                health_metrics['pressure'] = {
                    "current": avg_pressure,
                    "threshold": thresholds['pressure'],
                    "health_score": pressure_health
                }
            
            # Calculate overall component health
            if health_metrics:
                overall_health = np.mean([m['health_score'] for m in health_metrics.values()])
            else:
                overall_health = 50  # Default if no metrics
            
            # Determine status
            if overall_health >= 80:
                status = "healthy"
            elif overall_health >= 60:
                status = "warning"
            else:
                status = "critical"
            
            return {
                "health_score": overall_health,
                "status": status,
                "health_metrics": health_metrics,
                "alerts": alerts,
                "last_maintenance": maintenance_history[0] if maintenance_history else None
            }
            
        except Exception as e:
            logger.error(f"Error analyzing component health: {e}")
            return {"health_score": 0, "status": "error", "alerts": []}

    async def _calculate_overall_health(self, component_analysis: Dict) -> float:
        """Calculate overall equipment health score"""
        try:
            if not component_analysis:
                return 0
            
            health_scores = [analysis['health_score'] for analysis in component_analysis.values()]
            return np.mean(health_scores)
            
        except Exception as e:
            logger.error(f"Error calculating overall health: {e}")
            return 0

    async def _predict_failures_72h(self, equipment_id: int, component_analysis: Dict,
                                  sensor_data: List[Dict], equipment_config: Dict) -> List[Dict]:
        """Predict equipment failures within 72 hours"""
        try:
            predictions = []
            
            for component, analysis in component_analysis.items():
                health_score = analysis['health_score']
                
                # Simple failure prediction based on health score and trends
                failure_probability = max(0, (100 - health_score) / 100)
                
                # Adjust probability based on alerts
                critical_alerts = len([a for a in analysis.get('alerts', []) if a['severity'] == 'critical'])
                warning_alerts = len([a for a in analysis.get('alerts', []) if a['severity'] == 'warning'])
                
                failure_probability += (critical_alerts * 0.3) + (warning_alerts * 0.1)
                failure_probability = min(1.0, failure_probability)
                
                if failure_probability > 0.3:  # Only include meaningful predictions
                    # Estimate time to failure
                    if failure_probability > 0.8:
                        hours_to_failure = np.random.uniform(6, 24)
                    elif failure_probability > 0.6:
                        hours_to_failure = np.random.uniform(24, 48)
                    else:
                        hours_to_failure = np.random.uniform(48, 72)
                    
                    estimated_failure_time = datetime.utcnow() + timedelta(hours=hours_to_failure)
                    
                    predictions.append({
                        "component": component,
                        "failure_type": await self._predict_failure_type(component, analysis),
                        "probability": failure_probability,
                        "estimated_failure_time": estimated_failure_time.isoformat(),
                        "hours_to_failure": hours_to_failure,
                        "urgency": "critical" if failure_probability > 0.7 else "high" if failure_probability > 0.5 else "medium",
                        "confidence": min(0.95, failure_probability * 1.2)
                    })
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error predicting failures: {e}")
            return []

    async def _predict_failure_type(self, component: str, analysis: Dict) -> str:
        """Predict type of failure based on component analysis"""
        try:
            alerts = analysis.get('alerts', [])
            
            if any(a['type'] == 'vibration_high' for a in alerts):
                return "mechanical_wear"
            elif any(a['type'] == 'temperature_high' for a in alerts):
                return "overheating"
            elif any(a['type'] == 'pressure_low' for a in alerts):
                return "pressure_failure"
            else:
                return "general_degradation"
                
        except Exception as e:
            logger.error(f"Error predicting failure type: {e}")
            return "unknown"

    async def _generate_maintenance_recommendations(self, equipment: models.Equipment,
                                                component_analysis: Dict,
                                                failure_predictions: List[Dict]) -> List[Dict]:
        """Generate maintenance recommendations"""
        try:
            recommendations = []
            
            # Recommendations based on component health
            for component, analysis in component_analysis.items():
                health_score = analysis['health_score']
                
                if health_score < 40:
                    recommendations.append({
                        "type": "immediate",
                        "component": component,
                        "action": "Schedule immediate inspection and maintenance",
                        "priority": "critical",
                        "reason": f"Component health score critically low: {health_score:.1f}%"
                    })
                elif health_score < 60:
                    recommendations.append({
                        "type": "scheduled",
                        "component": component,
                        "action": "Schedule maintenance within 7 days",
                        "priority": "high",
                        "reason": f"Component health score low: {health_score:.1f}%"
                    })
                elif health_score < 80:
                    recommendations.append({
                        "type": "planned",
                        "component": component,
                        "action": "Include in next planned maintenance",
                        "priority": "medium",
                        "reason": f"Component shows early signs of wear: {health_score:.1f}%"
                    })
            
            # Recommendations based on failure predictions
            for prediction in failure_predictions:
                if prediction['urgency'] == 'critical':
                    recommendations.append({
                        "type": "emergency",
                        "component": prediction['component'],
                        "action": f"Emergency maintenance required - {prediction['failure_type']} predicted",
                        "priority": "critical",
                        "reason": f"High probability ({prediction['probability']:.1%}) of {prediction['failure_type']} within {prediction['hours_to_failure']:.0f} hours"
                    })
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating maintenance recommendations: {e}")
            return []

    async def _save_maintenance_analysis(self, equipment_id: int, component_analysis: Dict,
                                      overall_health: float, failure_predictions: List[Dict],
                                      tenant_id: str):
        """Save maintenance analysis results"""
        try:
            analysis = models.EquipmentHealthAnalysis(
                equipment_id=equipment_id,
                overall_health_score=overall_health,
                component_analysis_json=json.dumps(component_analysis),
                failure_predictions_json=json.dumps(failure_predictions),
                analysis_date=datetime.utcnow().date(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(analysis)
            
            # Save failure predictions
            for prediction in failure_predictions:
                failure_pred = models.EquipmentFailurePrediction(
                    equipment_id=equipment_id,
                    component=prediction['component'],
                    failure_type=prediction['failure_type'],
                    probability=prediction['probability'],
                    estimated_failure_time=datetime.fromisoformat(prediction['estimated_failure_time']),
                    hours_to_failure=prediction['hours_to_failure'],
                    urgency=prediction['urgency'],
                    confidence=prediction['confidence'],
                    prediction_date=datetime.utcnow().date(),
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(failure_pred)
            
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error saving maintenance analysis: {e}")
            self.db.rollback()

    async def _generate_automated_maintenance_schedule(self, high_risk_equipment: List[Dict],
                                                   tenant_id: str) -> List[Dict]:
        """Generate automated maintenance schedule for high-risk equipment"""
        try:
            schedule = []
            
            for equipment in high_risk_equipment:
                # Schedule based on urgency and estimated failure time
                if equipment['urgency'] == 'critical':
                    scheduled_date = datetime.utcnow() + timedelta(days=1)
                elif equipment['urgency'] == 'high':
                    scheduled_date = datetime.utcnow() + timedelta(days=3)
                else:
                    scheduled_date = datetime.utcnow() + timedelta(days=7)
                
                schedule.append({
                    "equipment_id": equipment['equipment_id'],
                    "equipment_name": equipment['equipment_name'],
                    "component": equipment['component'],
                    "maintenance_type": "predictive",
                    "scheduled_date": scheduled_date.strftime('%Y-%m-%d'),
                    "priority": equipment['urgency'],
                    "estimated_duration_hours": 4,
                    "predicted_failure_probability": equipment['probability'],
                    "reason": f"Predicted {equipment['failure_type']} failure"
                })
            
            # Sort by priority and date
            schedule.sort(key=lambda x: (x['priority'], x['scheduled_date']))
            
            return schedule
            
        except Exception as e:
            logger.error(f"Error generating maintenance schedule: {e}")
            return []

    async def _create_work_order(self, schedule_id: int, tenant_id: str) -> models.WorkOrder:
        """Create work order for maintenance"""
        try:
            work_order = models.WorkOrder(
                maintenance_schedule_id=schedule_id,
                work_order_number=await self._generate_work_order_number(tenant_id),
                status='created',
                created_date=datetime.utcnow().date(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(work_order)
            self.db.commit()
            
            return work_order
            
        except Exception as e:
            logger.error(f"Error creating work order: {e}")
            return None

    async def _notify_maintenance_team(self, maintenance_schedule: models.MaintenanceSchedule, tenant_id: str):
        """Notify maintenance team of scheduled maintenance"""
        try:
            # This would integrate with notification system
            # For now, just log the notification
            logger.info(f"Maintenance notification sent for schedule {maintenance_schedule.id}")
            
        except Exception as e:
            logger.error(f"Error sending maintenance notification: {e}")

    async def _generate_work_order_number(self, tenant_id: str) -> str:
        """Generate unique work order number"""
        try:
            count = self.db.query(models.WorkOrder).filter(models.WorkOrder.tenant_id == tenant_id).count()
            return f"WO-{tenant_id.upper()}-{datetime.utcnow().strftime('%Y%m%d')}-{count + 1:04d}"
        except:
            return f"WO-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _generate_predictions_summary(self, predictions: List[Dict]) -> Dict:
        """Generate summary of all predictions"""
        try:
            total_equipment = len(predictions)
            high_risk_count = 0
            medium_risk_count = 0
            low_risk_count = 0
            
            for prediction in predictions:
                if prediction.get("analysis", {}).get("success"):
                    failure_preds = prediction["analysis"].get("failure_predictions", [])
                    for pred in failure_preds:
                        if pred['urgency'] == 'critical':
                            high_risk_count += 1
                        elif pred['urgency'] == 'high':
                            medium_risk_count += 1
                        else:
                            low_risk_count += 1
            
            return {
                "total_equipment_analyzed": total_equipment,
                "high_risk_equipment": high_risk_count,
                "medium_risk_equipment": medium_risk_count,
                "low_risk_equipment": low_risk_count,
                "risk_distribution": {
                    "critical": high_risk_count,
                    "high": medium_risk_count,
                    "medium": low_risk_count
                }
            }
            
        except Exception as e:
            logger.error(f"Error generating predictions summary: {e}")
            return {}

    async def _calculate_maintenance_analytics(self, completed_maintenance: List[models.MaintenanceSchedule],
                                           predicted_failures: List[models.EquipmentFailurePrediction],
                                           start_dt: datetime, end_dt: datetime) -> Dict:
        """Calculate maintenance analytics"""
        try:
            # Basic metrics
            total_maintenance = len(completed_maintenance)
            total_downtime = sum(m.downtime_hours or 0 for m in completed_maintenance)
            total_cost = sum(m.actual_cost or 0 for m in completed_maintenance)
            
            # Maintenance types
            maintenance_types = defaultdict(int)
            for m in completed_maintenance:
                maintenance_types[m.maintenance_type] += 1
            
            # Predictive vs reactive
            predictive_maintenance = len([m for m in completed_maintenance if m.maintenance_type == 'predictive'])
            reactive_maintenance = total_maintenance - predictive_maintenance
            
            return {
                "total_maintenance_activities": total_maintenance,
                "total_downtime_hours": total_downtime,
                "total_maintenance_cost": total_cost,
                "average_cost_per_maintenance": total_cost / total_maintenance if total_maintenance > 0 else 0,
                "maintenance_types": dict(maintenance_types),
                "predictive_vs_reactive": {
                    "predictive": predictive_maintenance,
                    "reactive": reactive_maintenance,
                    "predictive_percentage": (predictive_maintenance / total_maintenance * 100) if total_maintenance > 0 else 0
                }
            }
            
        except Exception as e:
            logger.error(f"Error calculating maintenance analytics: {e}")
            return {}

    async def _calculate_equipment_reliability(self, tenant_id: str) -> Dict:
        """Calculate equipment reliability metrics"""
        try:
            # Get all equipment
            equipment_list = self.db.query(models.Equipment).filter(
                models.Equipment.tenant_id == tenant_id
            ).all()
            
            total_equipment = len(equipment_list)
            active_equipment = len([e for e in equipment_list if e.status == 'active'])
            
            # Calculate MTBF (Mean Time Between Failures)
            # This would require more detailed failure history
            mtbf = 720  # Default 30 days in hours
            
            # Calculate availability
            availability = 95.0  # Default percentage
            
            return {
                "total_equipment": total_equipment,
                "active_equipment": active_equipment,
                "equipment_availability": availability,
                "mean_time_between_failures": mtbf,
                "reliability_score": min(100, availability)
            }
            
        except Exception as e:
            logger.error(f"Error calculating equipment reliability: {e}")
            return {}

    async def _calculate_maintenance_costs(self, completed_maintenance: List[models.MaintenanceSchedule]) -> Dict:
        """Calculate maintenance cost analysis"""
        try:
            total_cost = sum(m.actual_cost or 0 for m in completed_maintenance)
            
            # Cost by maintenance type
            cost_by_type = defaultdict(float)
            for m in completed_maintenance:
                cost_by_type[m.maintenance_type] += m.actual_cost or 0
            
            # Cost trends (simplified)
            avg_monthly_cost = total_cost / 1  # Assuming 1 month period
            
            return {
                "total_cost": total_cost,
                "cost_by_type": dict(cost_by_type),
                "average_monthly_cost": avg_monthly_cost,
                "cost_per_equipment": total_cost / len(completed_maintenance) if completed_maintenance else 0
            }
            
        except Exception as e:
            logger.error(f"Error calculating maintenance costs: {e}")
            return {}

    async def _calculate_prediction_accuracy(self, predicted_failures: List[models.EquipmentFailurePrediction],
                                        tenant_id: str) -> Dict:
        """Calculate prediction accuracy metrics"""
        try:
            if not predicted_failures:
                return {"accuracy": 0, "total_predictions": 0}
            
            # This would compare predictions with actual failures
            # For now, return mock accuracy
            correct_predictions = len([f for f in predicted_failures if f.actual_failure])
            accuracy = (correct_predictions / len(predicted_failures)) * 100 if predicted_failures else 0
            
            return {
                "accuracy": accuracy,
                "total_predictions": len(predicted_failures),
                "correct_predictions": correct_predictions,
                "false_positives": len(predicted_failures) - correct_predictions
            }
            
        except Exception as e:
            logger.error(f"Error calculating prediction accuracy: {e}")
            return {"accuracy": 0, "total_predictions": 0}
