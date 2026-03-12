"""
Crop Cycle Manager - Phase 3 Feature
Advanced crop management with planting schedules, growth monitoring, and yield optimization
Derived from Begin Reference System
"""

import logging
import asyncio
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
from decimal import Decimal

logger = logging.getLogger(__name__)

from ..common import models

class CropCycleManagerService:
    """Advanced crop cycle management and monitoring system"""
    
    def __init__(self, db: Session):
        self.db = db
        self.crop_requirements = {
            'maize': {
                'growth_days': 120,
                'water_requirement': 500,  # mm per season
                'nitrogen_requirement': 150,  # kg/ha
                'phosphorus_requirement': 60,  # kg/ha
                'potassium_requirement': 50,  # kg/ha
                'optimal_temperature': {'min': 15, 'max': 30},
                'optimal_ph': {'min': 5.5, 'max': 7.5}
            },
            'wheat': {
                'growth_days': 110,
                'water_requirement': 450,
                'nitrogen_requirement': 120,
                'phosphorus_requirement': 50,
                'potassium_requirement': 40,
                'optimal_temperature': {'min': 10, 'max': 25},
                'optimal_ph': {'min': 6.0, 'max': 7.5}
            },
            'soybean': {
                'growth_days': 100,
                'water_requirement': 400,
                'nitrogen_requirement': 40,  # Lower due to nitrogen fixation
                'phosphorus_requirement': 50,
                'potassium_requirement': 60,
                'optimal_temperature': {'min': 20, 'max': 30},
                'optimal_ph': {'min': 6.0, 'max': 7.0}
            },
            'tomato': {
                'growth_days': 90,
                'water_requirement': 600,
                'nitrogen_requirement': 100,
                'phosphorus_requirement': 80,
                'potassium_requirement': 150,
                'optimal_temperature': {'min': 18, 'max': 28},
                'optimal_ph': {'min': 6.0, 'max': 7.0}
            }
        }

    async def create_crop_cycle(self, cycle_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Create new crop cycle with planning and scheduling"""
        try:
            # Validate crop type
            crop_type = cycle_data.get('crop_type')
            if crop_type not in self.crop_requirements:
                return {"error": f"Unsupported crop type: {crop_type}"}
            
            # Calculate expected dates based on crop requirements
            planting_date = datetime.strptime(cycle_data['planting_date'], '%Y-%m-%d').date() if isinstance(cycle_data.get('planting_date'), str) else cycle_data.get('planting_date')
            growth_days = self.crop_requirements[crop_type]['growth_days']
            expected_harvest_date = planting_date + timedelta(days=growth_days)
            
            # Create crop cycle record
            new_cycle = models.CropCycle(
                cycle_name=cycle_data['cycle_name'],
                crop_type=crop_type,
                variety=cycle_data.get('variety'),
                field_id=cycle_data.get('field_id'),
                planting_date=planting_date,
                expected_harvest_date=expected_harvest_date,
                actual_harvest_date=None,
                area_hectares=cycle_data.get('area_hectares'),
                expected_yield=cycle_data.get('expected_yield'),
                actual_yield=None,
                status='planned',
                planting_method=cycle_data.get('planting_method', 'direct'),
                irrigation_system=cycle_data.get('irrigation_system'),
                soil_type=cycle_data.get('soil_type'),
                previous_crop=cycle_data.get('previous_crop'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            self.db.add(new_cycle)
            self.db.commit()
            
            # Create initial growth stage record
            await self._create_growth_stage(new_cycle.id, 'planting', planting_date, tenant_id)
            
            # Generate task schedule for the crop cycle
            await self._generate_task_schedule(new_cycle.id, crop_type, planting_date, expected_harvest_date, tenant_id)
            
            return {
                "success": True,
                "cycle_id": new_cycle.id,
                "cycle_name": new_cycle.cycle_name,
                "expected_harvest_date": expected_harvest_date.strftime('%Y-%m-%d'),
                "message": "Crop cycle created successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating crop cycle: {e}")
            self.db.rollback()
            return {"error": "Crop cycle creation failed"}

    async def update_crop_stage(self, cycle_id: int, stage_data: Dict[str, Any], 
                              tenant_id: str = "default") -> Dict[str, Any]:
        """Update crop growth stage and record observations"""
        try:
            cycle = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.id == cycle_id,
                    models.CropCycle.tenant_id == tenant_id
                )
            ).first()
            
            if not cycle:
                return {"error": "Crop cycle not found"}
            
            # Create growth stage record
            growth_stage = models.CropGrowthStage(
                cycle_id=cycle_id,
                stage_name=stage_data['stage_name'],
                stage_date=datetime.strptime(stage_data['stage_date'], '%Y-%m-%d').date() if isinstance(stage_data.get('stage_date'), str) else stage_data.get('stage_date'),
                plant_height=stage_data.get('plant_height'),
                leaf_count=stage_data.get('leaf_count'),
                health_status=stage_data.get('health_status', 'healthy'),
                pest_pressure=stage_data.get('pest_pressure', 'low'),
                disease_pressure=stage_data.get('disease_pressure', 'low'),
                weed_pressure=stage_data.get('weed_pressure', 'low'),
                soil_moisture=stage_data.get('soil_moisture'),
                notes=stage_data.get('notes'),
                images_json=json.dumps(stage_data.get('images', [])),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(growth_stage)
            
            # Update cycle status if harvesting
            if stage_data['stage_name'] == 'harvesting':
                cycle.status = 'harvested'
                cycle.actual_harvest_date = stage_data.get('stage_date', datetime.utcnow().date())
                if 'actual_yield' in stage_data:
                    cycle.actual_yield = stage_data['actual_yield']
            
            cycle.updated_at = datetime.utcnow()
            
            # Check for alerts based on observations
            await self._check_crop_alerts(cycle_id, stage_data, tenant_id)
            
            self.db.commit()
            
            return {
                "success": True,
                "message": "Growth stage updated successfully",
                "stage_id": growth_stage.id
            }
            
        except Exception as e:
            logger.error(f"Error updating crop stage: {e}")
            self.db.rollback()
            return {"error": "Stage update failed"}

    async def record_field_operation(self, cycle_id: int, operation_data: Dict[str, Any], 
                                   tenant_id: str = "default") -> Dict[str, Any]:
        """Record field operations (planting, fertilizing, spraying, irrigation)"""
        try:
            cycle = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.id == cycle_id,
                    models.CropCycle.tenant_id == tenant_id
                )
            ).first()
            
            if not cycle:
                return {"error": "Crop cycle not found"}
            
            # Create field operation record
            operation = models.CropFieldOperation(
                cycle_id=cycle_id,
                operation_type=operation_data['operation_type'],
                operation_date=datetime.strptime(operation_data['operation_date'], '%Y-%m-%d').date() if isinstance(operation_data.get('operation_date'), str) else operation_data.get('operation_date'),
                material_type=operation_data.get('material_type'),
                material_quantity=operation_data.get('material_quantity'),
                material_unit=operation_data.get('material_unit', 'kg'),
                equipment_used=operation_data.get('equipment_used'),
                labor_hours=operation_data.get('labor_hours'),
                cost=operation_data.get('cost'),
                weather_conditions=operation_data.get('weather_conditions'),
                notes=operation_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(operation)
            
            # Update nutrient status if fertilization
            if operation_data['operation_type'] == 'fertilization':
                await self._update_nutrient_status(cycle_id, operation_data, tenant_id)
            
            # Update irrigation status if irrigation
            elif operation_data['operation_type'] == 'irrigation':
                await self._update_irrigation_status(cycle_id, operation_data, tenant_id)
            
            cycle.updated_at = datetime.utcnow()
            self.db.commit()
            
            return {
                "success": True,
                "message": "Field operation recorded successfully",
                "operation_id": operation.id
            }
            
        except Exception as e:
            logger.error(f"Error recording field operation: {e}")
            self.db.rollback()
            return {"error": "Operation recording failed"}

    async def get_crop_performance(self, cycle_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive crop performance analysis"""
        try:
            cycle = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.id == cycle_id,
                    models.CropCycle.tenant_id == tenant_id
                )
            ).first()
            
            if not cycle:
                return {"error": "Crop cycle not found"}
            
            # Get growth stages
            growth_stages = self.db.query(models.CropGrowthStage).filter(
                and_(
                    models.CropGrowthStage.cycle_id == cycle_id,
                    models.CropGrowthStage.tenant_id == tenant_id
                )
            ).order_by(models.CropGrowthStage.stage_date).all()
            
            # Get field operations
            operations = self.db.query(models.CropFieldOperation).filter(
                and_(
                    models.CropFieldOperation.cycle_id == cycle_id,
                    models.CropFieldOperation.tenant_id == tenant_id
                )
            ).order_by(models.CropFieldOperation.operation_date).all()
            
            # Get environmental data if available
            environmental_data = await self._get_crop_environmental_data(cycle_id, tenant_id)
            
            # Calculate performance metrics
            performance = await self._calculate_crop_performance(cycle, growth_stages, operations)
            
            return {
                "cycle_info": {
                    "id": cycle.id,
                    "cycle_name": cycle.cycle_name,
                    "crop_type": cycle.crop_type,
                    "variety": cycle.variety,
                    "area_hectares": cycle.area_hectares,
                    "planting_date": cycle.planting_date.strftime('%Y-%m-%d'),
                    "expected_harvest_date": cycle.expected_harvest_date.strftime('%Y-%m-%d'),
                    "actual_harvest_date": cycle.actual_harvest_date.strftime('%Y-%m-%d') if cycle.actual_harvest_date else None,
                    "status": cycle.status,
                    "expected_yield": cycle.expected_yield,
                    "actual_yield": cycle.actual_yield
                },
                "performance_metrics": performance,
                "growth_stages": [
                    {
                        "stage_name": gs.stage_name,
                        "stage_date": gs.stage_date.strftime('%Y-%m-%d'),
                        "plant_height": gs.plant_height,
                        "health_status": gs.health_status,
                        "pest_pressure": gs.pest_pressure,
                        "disease_pressure": gs.disease_pressure
                    } for gs in growth_stages
                ],
                "operations_summary": await self._summarize_operations(operations),
                "environmental_conditions": environmental_data,
                "recommendations": await self._generate_crop_recommendations(cycle, growth_stages, operations)
            }
            
        except Exception as e:
            logger.error(f"Error getting crop performance: {e}")
            return {"error": "Performance analysis failed"}

    async def get_field_utilization(self, field_id: Optional[int] = None, 
                                  year: Optional[int] = None, tenant_id: str = "default") -> Dict[str, Any]:
        """Get field utilization and rotation analysis"""
        try:
            if not year:
                year = datetime.utcnow().year
            
            query = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.tenant_id == tenant_id,
                    func.extract('year', models.CropCycle.planting_date) == year
                )
            )
            
            if field_id:
                query = query.filter(models.CropCycle.field_id == field_id)
            
            cycles = query.all()
            
            # Calculate field utilization metrics
            total_area = sum(c.area_hectares for c in cycles if c.area_hectares)
            harvested_area = sum(c.area_hectares for c in cycles if c.status == 'harvested' and c.area_hectares)
            
            # Crop rotation analysis
            crop_sequence = {}
            for cycle in cycles:
                if cycle.field_id not in crop_sequence:
                    crop_sequence[cycle.field_id] = []
                crop_sequence[cycle.field_id].append({
                    'crop_type': cycle.crop_type,
                    'planting_date': cycle.planting_date,
                    'harvest_date': cycle.actual_harvest_date or cycle.expected_harvest_date
                })
            
            # Yield analysis by crop type
            yield_by_crop = {}
            for cycle in cycles:
                if cycle.crop_type not in yield_by_crop:
                    yield_by_crop[cycle.crop_type] = {
                        'total_area': 0, 'total_yield': 0, 'cycles': 0
                    }
                
                if cycle.area_hectares and cycle.actual_yield:
                    yield_by_crop[cycle.crop_type]['total_area'] += cycle.area_hectares
                    yield_by_crop[cycle.crop_type]['total_yield'] += cycle.actual_yield
                    yield_by_crop[cycle.crop_type]['cycles'] += 1
            
            # Calculate average yields
            for crop_type in yield_by_crop:
                if yield_by_crop[crop_type]['total_area'] > 0:
                    yield_by_crop[crop_type]['avg_yield_per_hectare'] = (
                        yield_by_crop[crop_type]['total_yield'] / yield_by_crop[crop_type]['total_area']
                    )
            
            return {
                "year": year,
                "field_id": field_id,
                "utilization_summary": {
                    "total_planted_area": total_area,
                    "total_harvested_area": harvested_area,
                    "utilization_rate": (harvested_area / total_area * 100) if total_area > 0 else 0,
                    "total_cycles": len(cycles)
                },
                "crop_rotation": crop_sequence,
                "yield_analysis": yield_by_crop,
                "seasonal_breakdown": await self._analyze_seasonal_performance(cycles)
            }
            
        except Exception as e:
            logger.error(f"Error getting field utilization: {e}")
            return {"error": "Field utilization analysis failed"}

    async def generate_crop_calendar(self, crop_types: List[str], 
                                   start_date: str, end_date: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Generate optimized crop calendar and planting schedule"""
        try:
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            calendar_events = []
            
            for crop_type in crop_types:
                if crop_type not in self.crop_requirements:
                    continue
                
                requirements = self.crop_requirements[crop_type]
                growth_days = requirements['growth_days']
                
                # Generate optimal planting windows
                current_date = start_dt
                while current_date <= end_dt:
                    planting_date = current_date.date()
                    harvest_date = planting_date + timedelta(days=growth_days)
                    
                    if harvest_date <= end_dt.date():
                        # Check if this conflicts with existing cycles
                        conflict = await self._check_planting_conflict(planting_date, harvest_date, tenant_id)
                        
                        calendar_events.append({
                            "crop_type": crop_type,
                            "planting_date": planting_date.strftime('%Y-%m-%d'),
                            "harvest_date": harvest_date.strftime('%Y-%m-%d'),
                            "growth_days": growth_days,
                            "water_requirement": requirements['water_requirement'],
                            "conflict": conflict,
                            "recommendation": "Suitable for planting" if not conflict else "Check field availability"
                        })
                    
                    current_date += timedelta(days=30)  # Next potential planting window
            
            # Sort by planting date
            calendar_events.sort(key=lambda x: x['planting_date'])
            
            return {
                "calendar_period": {
                    "start_date": start_date,
                    "end_date": end_date
                },
                "events": calendar_events,
                "summary": {
                    "total_events": len(calendar_events),
                    "conflict_free_events": len([e for e in calendar_events if not e['conflict']]),
                    "crop_breakdown": {
                        crop_type: len([e for e in calendar_events if e['crop_type'] == crop_type])
                        for crop_type in crop_types
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error generating crop calendar: {e}")
            return {"error": "Calendar generation failed"}

    # Helper methods
    async def _create_growth_stage(self, cycle_id: int, stage_name: str, stage_date, tenant_id: str):
        """Create initial growth stage record"""
        try:
            growth_stage = models.CropGrowthStage(
                cycle_id=cycle_id,
                stage_name=stage_name,
                stage_date=stage_date,
                health_status='healthy',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(growth_stage)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating growth stage: {e}")

    async def _generate_task_schedule(self, cycle_id: int, crop_type: str, 
                                    planting_date, harvest_date, tenant_id: str):
        """Generate scheduled tasks for crop cycle"""
        try:
            requirements = self.crop_requirements[crop_type]
            tasks = []
            
            # Planting task
            tasks.append({
                'task_name': 'Planting',
                'scheduled_date': planting_date,
                'task_type': 'planting',
                'priority': 'high'
            })
            
            # Fertilization tasks (split applications)
            fertilization_dates = [
                planting_date + timedelta(days=20),  # Early growth
                planting_date + timedelta(days=50),  # Mid growth
                planting_date + timedelta(days=80),  # Late growth
            ]
            
            for i, fert_date in enumerate(fertilization_dates):
                if fert_date <= harvest_date:
                    tasks.append({
                        'task_name': f'Fertilization Application {i+1}',
                        'scheduled_date': fert_date,
                        'task_type': 'fertilization',
                        'priority': 'medium'
                    })
            
            # Irrigation monitoring tasks
            current_date = planting_date
            while current_date <= harvest_date:
                tasks.append({
                    'task_name': 'Irrigation Check',
                    'scheduled_date': current_date,
                    'task_type': 'irrigation',
                    'priority': 'medium'
                })
                current_date += timedelta(days=7)  # Weekly checks
            
            # Pest and disease monitoring
            current_date = planting_date + timedelta(days=14)  # Start 2 weeks after planting
            while current_date <= harvest_date:
                tasks.append({
                    'task_name': 'Pest & Disease Monitoring',
                    'scheduled_date': current_date,
                    'task_type': 'monitoring',
                    'priority': 'medium'
                })
                current_date += timedelta(days=10)  # Every 10 days
            
            # Harvest task
            tasks.append({
                'task_name': 'Harvesting',
                'scheduled_date': harvest_date,
                'task_type': 'harvesting',
                'priority': 'high'
            })
            
            # Create task records
            for task in tasks:
                task_record = models.CropTask(
                    cycle_id=cycle_id,
                    task_name=task['task_name'],
                    scheduled_date=task['scheduled_date'],
                    task_type=task['task_type'],
                    priority=task['priority'],
                    status='pending',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                self.db.add(task_record)
            
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error generating task schedule: {e}")

    async def _check_crop_alerts(self, cycle_id: int, stage_data: Dict[str, Any], tenant_id: str):
        """Check for crop alerts based on stage data"""
        try:
            alerts = []
            
            # Health status alerts
            if stage_data.get('health_status') in ['poor', 'critical']:
                alerts.append({
                    'alert_type': 'health_issue',
                    'message': f"Crop health status: {stage_data['health_status']}",
                    'severity': 'high'
                })
            
            # Pest pressure alerts
            if stage_data.get('pest_pressure') == 'high':
                alerts.append({
                    'alert_type': 'pest_pressure',
                    'message': "High pest pressure detected",
                    'severity': 'medium'
                })
            
            # Disease pressure alerts
            if stage_data.get('disease_pressure') == 'high':
                alerts.append({
                    'alert_type': 'disease_pressure',
                    'message': "High disease pressure detected",
                    'severity': 'high'
                })
            
            # Create alert records
            for alert in alerts:
                alert_record = models.CropAlert(
                    cycle_id=cycle_id,
                    alert_type=alert['alert_type'],
                    message=alert['message'],
                    severity=alert['severity'],
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                self.db.add(alert_record)
            
            if alerts:
                self.db.commit()
            
        except Exception as e:
            logger.error(f"Error checking crop alerts: {e}")

    async def _update_nutrient_status(self, cycle_id: int, operation_data: Dict[str, Any], tenant_id: str):
        """Update nutrient status after fertilization"""
        try:
            # This would typically update a nutrient balance table
            # For now, we'll log the operation
            logger.info(f"Updated nutrient status for cycle {cycle_id} with fertilization: {operation_data}")
            
        except Exception as e:
            logger.error(f"Error updating nutrient status: {e}")

    async def _update_irrigation_status(self, cycle_id: int, operation_data: Dict[str, Any], tenant_id: str):
        """Update irrigation status"""
        try:
            # This would typically update soil moisture levels
            logger.info(f"Updated irrigation status for cycle {cycle_id}: {operation_data}")
            
        except Exception as e:
            logger.error(f"Error updating irrigation status: {e}")

    async def _get_crop_environmental_data(self, cycle_id: int, tenant_id: str) -> Dict:
        """Get environmental data for crop cycle"""
        try:
            # This would typically query environmental monitoring data
            # For now, return mock data
            return {
                "average_temperature": 22.5,
                "total_rainfall": 350,
                "average_humidity": 65,
                "growing_degree_days": 1450
            }
            
        except Exception as e:
            logger.error(f"Error getting environmental data: {e}")
            return {}

    async def _calculate_crop_performance(self, cycle: models.CropCycle, 
                                         growth_stages: List, operations: List) -> Dict:
        """Calculate crop performance metrics"""
        try:
            performance = {
                "growth_rate": 0,
                "yield_efficiency": 0,
                "cost_efficiency": 0,
                "total_operations": len(operations),
                "total_cost": sum(op.cost for op in operations if op.cost)
            }
            
            # Calculate growth rate
            if len(growth_stages) >= 2:
                first_stage = growth_stages[0]
                last_stage = growth_stages[-1]
                
                if first_stage.plant_height and last_stage.plant_height:
                    height_diff = last_stage.plant_height - first_stage.plant_height
                    days_diff = (last_stage.stage_date - first_stage.stage_date).days
                    performance["growth_rate"] = height_diff / days_diff if days_diff > 0 else 0
            
            # Calculate yield efficiency
            if cycle.actual_yield and cycle.expected_yield and cycle.area_hectares:
                performance["yield_efficiency"] = (cycle.actual_yield / cycle.expected_yield) * 100
            
            # Calculate cost efficiency
            if performance["total_cost"] > 0 and cycle.actual_yield:
                performance["cost_efficiency"] = performance["total_cost"] / cycle.actual_yield
            
            return performance
            
        except Exception as e:
            logger.error(f"Error calculating crop performance: {e}")
            return {}

    async def _summarize_operations(self, operations: List) -> Dict:
        """Summarize field operations"""
        try:
            summary = {
                "total_operations": len(operations),
                "by_type": {},
                "total_cost": 0,
                "total_labor_hours": 0
            }
            
            for op in operations:
                if op.operation_type not in summary["by_type"]:
                    summary["by_type"][op.operation_type] = 0
                summary["by_type"][op.operation_type] += 1
                
                if op.cost:
                    summary["total_cost"] += op.cost
                if op.labor_hours:
                    summary["total_labor_hours"] += op.labor_hours
            
            return summary
            
        except Exception as e:
            logger.error(f"Error summarizing operations: {e}")
            return {}

    async def _generate_crop_recommendations(self, cycle: models.CropCycle, 
                                           growth_stages: List, operations: List) -> List[str]:
        """Generate crop management recommendations"""
        recommendations = []
        
        try:
            # Yield-based recommendations
            if cycle.actual_yield and cycle.expected_yield:
                if cycle.actual_yield < cycle.expected_yield * 0.8:
                    recommendations.append("Yield below expectations - consider soil testing and nutrient adjustment")
            
            # Health-based recommendations
            recent_stages = growth_stages[-3:] if len(growth_stages) >= 3 else growth_stages
            for stage in recent_stages:
                if stage.pest_pressure == 'high':
                    recommendations.append("Implement integrated pest management strategies")
                if stage.disease_pressure == 'high':
                    recommendations.append("Consider disease-resistant varieties for next planting")
            
            # Operation-based recommendations
            fertilization_ops = [op for op in operations if op.operation_type == 'fertilization']
            if len(fertilization_ops) < 2:
                recommendations.append("Consider split fertilization applications for better nutrient efficiency")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {e}")
            return []

    async def _check_planting_conflict(self, planting_date, harvest_date, tenant_id: str) -> bool:
        """Check if planting dates conflict with existing cycles"""
        try:
            conflicting_cycles = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.tenant_id == tenant_id,
                    models.CropCycle.status.in_(['planted', 'growing']),
                    or_(
                        and_(
                            models.CropCycle.planting_date <= planting_date,
                            models.CropCycle.expected_harvest_date >= planting_date
                        ),
                        and_(
                            models.CropCycle.planting_date <= harvest_date,
                            models.CropCycle.expected_harvest_date >= harvest_date
                        )
                    )
                )
            ).count()
            
            return conflicting_cycles > 0
            
        except Exception as e:
            logger.error(f"Error checking planting conflict: {e}")
            return False

    async def _analyze_seasonal_performance(self, cycles: List) -> Dict:
        """Analyze seasonal performance patterns"""
        try:
            seasonal_data = {
                'spring': {'cycles': 0, 'total_yield': 0},
                'summer': {'cycles': 0, 'total_yield': 0},
                'autumn': {'cycles': 0, 'total_yield': 0},
                'winter': {'cycles': 0, 'total_yield': 0}
            }
            
            for cycle in cycles:
                # Determine season based on planting month
                month = cycle.planting_date.month
                
                if month in [3, 4, 5]:
                    season = 'spring'
                elif month in [6, 7, 8]:
                    season = 'summer'
                elif month in [9, 10, 11]:
                    season = 'autumn'
                else:
                    season = 'winter'
                
                seasonal_data[season]['cycles'] += 1
                if cycle.actual_yield:
                    seasonal_data[season]['total_yield'] += cycle.actual_yield
            
            # Calculate averages
            for season in seasonal_data:
                if seasonal_data[season]['cycles'] > 0:
                    seasonal_data[season]['avg_yield'] = (
                        seasonal_data[season]['total_yield'] / seasonal_data[season]['cycles']
                    )
                else:
                    seasonal_data[season]['avg_yield'] = 0
            
            return seasonal_data
            
        except Exception as e:
            logger.error(f"Error analyzing seasonal performance: {e}")
            return {}
