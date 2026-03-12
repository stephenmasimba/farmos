"""
Livestock Tracking System - Phase 3 Feature
Comprehensive livestock management with health monitoring, growth tracking, and performance analytics
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

class LivestockTrackingService:
    """Advanced livestock tracking and management system"""
    
    def __init__(self, db: Session):
        self.db = db
        self.health_alert_thresholds = {
            'temperature': {'min': 38.0, 'max': 42.0},
            'weight_loss': {'threshold': 0.10},  # 10% weight loss triggers alert
            'feed_intake': {'min': 0.5},  # 50% of expected intake
            'mortality_rate': {'threshold': 0.05}  # 5% mortality rate
        }

    async def register_animal(self, animal_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Register new animal in the system"""
        try:
            # Generate unique ID if not provided
            if not animal_data.get('tag_id'):
                animal_data['tag_id'] = await self._generate_tag_id(tenant_id)
            
            # Check for duplicate tag ID
            existing = self.db.query(models.Livestock).filter(
                and_(
                    models.Livestock.tag_id == animal_data['tag_id'],
                    models.Livestock.tenant_id == tenant_id
                )
            ).first()
            
            if existing:
                return {"error": f"Animal with tag ID {animal_data['tag_id']} already exists"}
            
            # Create new animal record
            new_animal = models.Livestock(
                tag_id=animal_data['tag_id'],
                animal_type=animal_data['animal_type'],
                breed=animal_data.get('breed'),
                gender=animal_data.get('gender'),
                date_of_birth=datetime.strptime(animal_data['date_of_birth'], '%Y-%m-%d').date() if isinstance(animal_data.get('date_of_birth'), str) else animal_data.get('date_of_birth'),
                initial_weight=animal_data.get('initial_weight'),
                current_weight=animal_data.get('initial_weight'),
                location=animal_data.get('location', 'main_pen'),
                status=animal_data.get('status', 'active'),
                health_status=animal_data.get('health_status', 'healthy'),
                source=animal_data.get('source', 'purchased'),
                purchase_cost=animal_data.get('purchase_cost'),
                parent_sire_id=animal_data.get('parent_sire_id'),
                parent_dam_id=animal_data.get('parent_dam_id'),
                notes=animal_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            self.db.add(new_animal)
            self.db.commit()
            
            # Create initial health record
            health_record = models.LivestockHealth(
                animal_id=new_animal.id,
                checkup_date=datetime.utcnow().date(),
                weight=animal_data.get('initial_weight'),
                temperature=animal_data.get('temperature'),
                heart_rate=animal_data.get('heart_rate'),
                respiratory_rate=animal_data.get('respiratory_rate'),
                health_status=animal_data.get('health_status', 'healthy'),
                notes="Initial registration",
                veterinarian_id=animal_data.get('veterinarian_id'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(health_record)
            self.db.commit()
            
            return {
                "success": True,
                "animal_id": new_animal.id,
                "tag_id": new_animal.tag_id,
                "message": "Animal registered successfully"
            }
            
        except Exception as e:
            logger.error(f"Error registering animal: {e}")
            self.db.rollback()
            return {"error": "Registration failed"}

    async def update_animal_status(self, animal_id: int, status_data: Dict[str, Any], 
                                 tenant_id: str = "default") -> Dict[str, Any]:
        """Update animal status, weight, and health information"""
        try:
            animal = self.db.query(models.Livestock).filter(
                and_(
                    models.Livestock.id == animal_id,
                    models.Livestock.tenant_id == tenant_id
                )
            ).first()
            
            if not animal:
                return {"error": "Animal not found"}
            
            # Update basic information
            if 'current_weight' in status_data:
                weight_change = status_data['current_weight'] - animal.current_weight
                animal.current_weight = status_data['current_weight']
                
                # Check for significant weight loss
                if weight_change < 0 and abs(weight_change) / animal.current_weight > self.health_alert_thresholds['weight_loss']['threshold']:
                    await self._create_health_alert(animal_id, 'weight_loss', f"Significant weight loss: {abs(weight_change)}kg", tenant_id)
            
            if 'location' in status_data:
                animal.location = status_data['location']
            
            if 'health_status' in status_data:
                animal.health_status = status_data['health_status']
            
            if 'status' in status_data:
                animal.status = status_data['status']
            
            animal.updated_at = datetime.utcnow()
            
            # Create health record if health data provided
            if any(key in status_data for key in ['temperature', 'heart_rate', 'respiratory_rate', 'health_notes']):
                health_record = models.LivestockHealth(
                    animal_id=animal_id,
                    checkup_date=datetime.utcnow().date(),
                    weight=status_data.get('current_weight', animal.current_weight),
                    temperature=status_data.get('temperature'),
                    heart_rate=status_data.get('heart_rate'),
                    respiratory_rate=status_data.get('respiratory_rate'),
                    health_status=status_data.get('health_status', animal.health_status),
                    notes=status_data.get('health_notes'),
                    veterinarian_id=status_data.get('veterinarian_id'),
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(health_record)
                
                # Check for health alerts
                if 'temperature' in status_data:
                    temp = status_data['temperature']
                    if temp < self.health_alert_thresholds['temperature']['min'] or temp > self.health_alert_thresholds['temperature']['max']:
                        await self._create_health_alert(animal_id, 'temperature', f"Abnormal temperature: {temp}°C", tenant_id)
            
            self.db.commit()
            
            return {
                "success": True,
                "message": "Animal status updated successfully",
                "updated_fields": list(status_data.keys())
            }
            
        except Exception as e:
            logger.error(f"Error updating animal status: {e}")
            self.db.rollback()
            return {"error": "Update failed"}

    async def record_feed_intake(self, animal_id: int, feed_data: Dict[str, Any], 
                               tenant_id: str = "default") -> Dict[str, Any]:
        """Record feed intake for individual animal or group"""
        try:
            # Verify animal exists
            animal = self.db.query(models.Livestock).filter(
                and_(
                    models.Livestock.id == animal_id,
                    models.Livestock.tenant_id == tenant_id
                )
            ).first()
            
            if not animal:
                return {"error": "Animal not found"}
            
            # Create feed intake record
            feed_record = models.LivestockFeedIntake(
                animal_id=animal_id,
                feed_type=feed_data['feed_type'],
                quantity_kg=feed_data['quantity_kg'],
                feeding_time=datetime.strptime(feed_data['feeding_time'], '%Y-%m-%d %H:%M:%S') if isinstance(feed_data.get('feeding_time'), str) else datetime.utcnow(),
                feed_formulation_id=feed_data.get('feed_formulation_id'),
                waste_percentage=feed_data.get('waste_percentage', 0),
                notes=feed_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(feed_record)
            
            # Check for low feed intake alert
            expected_intake = await self._calculate_expected_feed_intake(animal_id)
            if feed_data['quantity_kg'] < expected_intake * self.health_alert_thresholds['feed_intake']['min']:
                await self._create_health_alert(animal_id, 'low_feed_intake', 
                                               f"Low feed intake: {feed_data['quantity_kg']}kg (expected: {expected_intake}kg)", 
                                               tenant_id)
            
            self.db.commit()
            
            return {
                "success": True,
                "message": "Feed intake recorded successfully",
                "record_id": feed_record.id
            }
            
        except Exception as e:
            logger.error(f"Error recording feed intake: {e}")
            self.db.rollback()
            return {"error": "Feed recording failed"}

    async def get_animal_performance(self, animal_id: int, days: int = 30, 
                                   tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive performance metrics for an animal"""
        try:
            animal = self.db.query(models.Livestock).filter(
                and_(
                    models.Livestock.id == animal_id,
                    models.Livestock.tenant_id == tenant_id
                )
            ).first()
            
            if not animal:
                return {"error": "Animal not found"}
            
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # Get weight history
            weight_history = self.db.query(models.LivestockHealth).filter(
                and_(
                    models.LivestockHealth.animal_id == animal_id,
                    models.LivestockHealth.checkup_date >= start_date.date(),
                    models.LivestockHealth.tenant_id == tenant_id
                )
            ).order_by(models.LivestockHealth.checkup_date).all()
            
            # Get feed intake history
            feed_history = self.db.query(models.LivestockFeedIntake).filter(
                and_(
                    models.LivestockFeedIntake.animal_id == animal_id,
                    models.LivestockFeedIntake.feeding_time >= start_date,
                    models.LivestockFeedIntake.tenant_id == tenant_id
                )
            ).order_by(models.LivestockFeedIntake.feeding_time).all()
            
            # Calculate performance metrics
            performance = await self._calculate_performance_metrics(animal, weight_history, feed_history, days)
            
            # Get health alerts
            alerts = self.db.query(models.LivestockHealthAlert).filter(
                and_(
                    models.LivestockHealthAlert.animal_id == animal_id,
                    models.LivestockHealthAlert.created_at >= start_date,
                    models.LivestockHealthAlert.tenant_id == tenant_id
                )
            ).order_by(desc(models.LivestockHealthAlert.created_at)).limit(10).all()
            
            return {
                "animal": {
                    "id": animal.id,
                    "tag_id": animal.tag_id,
                    "animal_type": animal.animal_type,
                    "breed": animal.breed,
                    "age_days": (datetime.utcnow().date() - animal.date_of_birth).days,
                    "current_weight": animal.current_weight,
                    "location": animal.location,
                    "status": animal.status,
                    "health_status": animal.health_status
                },
                "performance_metrics": performance,
                "weight_history": [
                    {
                        "date": wh.checkup_date.strftime('%Y-%m-%d'),
                        "weight": wh.weight,
                        "temperature": wh.temperature,
                        "health_status": wh.health_status
                    } for wh in weight_history
                ],
                "feed_intake_summary": {
                    "total_feed_kg": sum(fi.quantity_kg for fi in feed_history),
                    "average_daily": sum(fi.quantity_kg for fi in feed_history) / days if days > 0 else 0,
                    "feed_types": list(set(fi.feed_type for fi in feed_history))
                },
                "recent_alerts": [
                    {
                        "alert_type": alert.alert_type,
                        "message": alert.message,
                        "severity": alert.severity,
                        "created_at": alert.created_at.strftime('%Y-%m-%d %H:%M:%S')
                    } for alert in alerts
                ]
            }
            
        except Exception as e:
            logger.error(f"Error getting animal performance: {e}")
            return {"error": "Performance analysis failed"}

    async def get_herd_overview(self, animal_type: Optional[str] = None, 
                              tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive herd overview and statistics"""
        try:
            query = self.db.query(models.Livestock).filter(models.Livestock.tenant_id == tenant_id)
            
            if animal_type:
                query = query.filter(models.Livestock.animal_type == animal_type)
            
            animals = query.all()
            
            # Calculate herd statistics
            total_animals = len(animals)
            active_animals = len([a for a in animals if a.status == 'active'])
            healthy_animals = len([a for a in animals if a.health_status == 'healthy'])
            
            # Group by animal type
            by_type = {}
            for animal in animals:
                if animal.animal_type not in by_type:
                    by_type[animal.animal_type] = {'count': 0, 'total_weight': 0, 'avg_weight': 0}
                by_type[animal.animal_type]['count'] += 1
                if animal.current_weight:
                    by_type[animal.animal_type]['total_weight'] += animal.current_weight
            
            for animal_type in by_type:
                if by_type[animal_type]['count'] > 0:
                    by_type[animal_type]['avg_weight'] = by_type[animal_type]['total_weight'] / by_type[animal_type]['count']
            
            # Group by location
            by_location = {}
            for animal in animals:
                if animal.location not in by_location:
                    by_location[animal.location] = 0
                by_location[animal.location] += 1
            
            # Health status breakdown
            health_breakdown = {}
            for animal in animals:
                if animal.health_status not in health_breakdown:
                    health_breakdown[animal.health_status] = 0
                health_breakdown[animal.health_status] += 1
            
            # Recent mortality (last 30 days)
            thirty_days_ago = datetime.utcnow() - timedelta(days=30)
            recent_mortality = self.db.query(models.Livestock).filter(
                and_(
                    models.Livestock.tenant_id == tenant_id,
                    models.Livestock.status == 'deceased',
                    models.Livestock.updated_at >= thirty_days_ago
                )
            ).count()
            
            mortality_rate = recent_mortality / total_animals if total_animals > 0 else 0
            
            return {
                "summary": {
                    "total_animals": total_animals,
                    "active_animals": active_animals,
                    "healthy_animals": healthy_animals,
                    "health_percentage": (healthy_animals / total_animals * 100) if total_animals > 0 else 0,
                    "recent_mortality": recent_mortality,
                    "mortality_rate": round(mortality_rate * 100, 2)
                },
                "by_animal_type": by_type,
                "by_location": by_location,
                "health_breakdown": health_breakdown,
                "performance_indicators": await self._calculate_herd_performance(animals, tenant_id)
            }
            
        except Exception as e:
            logger.error(f"Error getting herd overview: {e}")
            return {"error": "Herd analysis failed"}

    async def generate_health_report(self, animal_type: Optional[str] = None, 
                                   start_date: Optional[str] = None, end_date: Optional[str] = None,
                                   tenant_id: str = "default") -> Dict[str, Any]:
        """Generate comprehensive health report"""
        try:
            if not start_date:
                start_date = (datetime.utcnow() - timedelta(days=30)).strftime('%Y-%m-%d')
            if not end_date:
                end_date = datetime.utcnow().strftime('%Y-%m-%d')
            
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Get health records in date range
            query = self.db.query(models.LivestockHealth).filter(
                and_(
                    models.LivestockHealth.checkup_date >= start_dt.date(),
                    models.LivestockHealth.checkup_date <= end_dt.date(),
                    models.LivestockHealth.tenant_id == tenant_id
                )
            )
            
            if animal_type:
                query = query.join(models.Livestock).filter(models.Livestock.animal_type == animal_type)
            
            health_records = query.all()
            
            # Get health alerts in date range
            alerts_query = self.db.query(models.LivestockHealthAlert).filter(
                and_(
                    models.LivestockHealthAlert.created_at >= start_dt,
                    models.LivestockHealthAlert.created_at <= end_dt,
                    models.LivestockHealthAlert.tenant_id == tenant_id
                )
            )
            
            if animal_type:
                alerts_query = alerts_query.join(models.Livestock).filter(models.Livestock.animal_type == animal_type)
            
            alerts = alerts_query.all()
            
            # Calculate health metrics
            total_checkups = len(health_records)
            if total_checkups > 0:
                avg_temperature = sum(r.temperature for r in health_records if r.temperature) / len([r for r in health_records if r.temperature])
                avg_weight = sum(r.weight for r in health_records if r.weight) / len([r for r in health_records if r.weight])
            else:
                avg_temperature = 0
                avg_weight = 0
            
            # Alert breakdown
            alert_breakdown = {}
            for alert in alerts:
                if alert.alert_type not in alert_breakdown:
                    alert_breakdown[alert.alert_type] = 0
                alert_breakdown[alert.alert_type] += 1
            
            return {
                "report_period": {
                    "start_date": start_date,
                    "end_date": end_date,
                    "animal_type": animal_type or "all"
                },
                "summary": {
                    "total_health_checkups": total_checkups,
                    "average_temperature": round(avg_temperature, 2),
                    "average_weight": round(avg_weight, 2),
                    "total_health_alerts": len(alerts),
                    "alert_types": alert_breakdown
                },
                "health_trends": await self._analyze_health_trends(health_records),
                "recommendations": await self._generate_health_recommendations(alerts, health_records)
            }
            
        except Exception as e:
            logger.error(f"Error generating health report: {e}")
            return {"error": "Report generation failed"}

    # Helper methods
    async def _generate_tag_id(self, tenant_id: str) -> str:
        """Generate unique tag ID for animal"""
        try:
            count = self.db.query(models.Livestock).filter(models.Livestock.tenant_id == tenant_id).count()
            return f"{tenant_id.upper()}-{datetime.utcnow().year}-{count + 1:04d}"
        except:
            return f"TAG-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _create_health_alert(self, animal_id: int, alert_type: str, message: str, tenant_id: str):
        """Create health alert for animal"""
        try:
            alert = models.LivestockHealthAlert(
                animal_id=animal_id,
                alert_type=alert_type,
                message=message,
                severity='high' if alert_type in ['temperature', 'weight_loss'] else 'medium',
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(alert)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating health alert: {e}")

    async def _calculate_expected_feed_intake(self, animal_id: int) -> float:
        """Calculate expected daily feed intake based on animal weight and type"""
        try:
            animal = self.db.query(models.Livestock).filter(models.Livestock.id == animal_id).first()
            if not animal:
                return 0
            
            # Basic feed intake calculation (can be enhanced with breed-specific factors)
            if animal.animal_type == 'broiler':
                return animal.current_weight * 0.05  # 5% of body weight
            elif animal.animal_type == 'layer':
                return animal.current_weight * 0.04  # 4% of body weight
            elif animal.animal_type == 'pig':
                return animal.current_weight * 0.03  # 3% of body weight
            elif animal.animal_type == 'cattle':
                return animal.current_weight * 0.025  # 2.5% of body weight
            else:
                return animal.current_weight * 0.03  # Default 3%
                
        except:
            return 0

    async def _calculate_performance_metrics(self, animal: models.Livestock, 
                                           weight_history: List, feed_history: List, days: int) -> Dict:
        """Calculate performance metrics for animal"""
        try:
            metrics = {
                "weight_gain": 0,
                "daily_weight_gain": 0,
                "feed_conversion_ratio": 0,
                "feed_efficiency": 0
            }
            
            if len(weight_history) >= 2:
                initial_weight = weight_history[0].weight
                final_weight = weight_history[-1].weight
                metrics["weight_gain"] = final_weight - initial_weight
                metrics["daily_weight_gain"] = metrics["weight_gain"] / days if days > 0 else 0
            
            total_feed = sum(fi.quantity_kg for fi in feed_history)
            if metrics["weight_gain"] > 0 and total_feed > 0:
                metrics["feed_conversion_ratio"] = total_feed / metrics["weight_gain"]
                metrics["feed_efficiency"] = metrics["weight_gain"] / total_feed
            
            return metrics
            
        except Exception as e:
            logger.error(f"Error calculating performance metrics: {e}")
            return {}

    async def _calculate_herd_performance(self, animals: List[models.Livestock], tenant_id: str) -> Dict:
        """Calculate overall herd performance indicators"""
        try:
            if not animals:
                return {}
            
            total_weight = sum(a.current_weight for a in animals if a.current_weight)
            avg_weight = total_weight / len(animals) if animals else 0
            
            # Get recent feed intake for herd
            thirty_days_ago = datetime.utcnow() - timedelta(days=30)
            total_feed_intake = self.db.query(func.sum(models.LivestockFeedIntake.quantity_kg)).filter(
                and_(
                    models.LivestockFeedIntake.feeding_time >= thirty_days_ago,
                    models.LivestockFeedIntake.tenant_id == tenant_id
                )
            ).scalar() or 0
            
            return {
                "average_weight": round(avg_weight, 2),
                "total_weight": round(total_weight, 2),
                "monthly_feed_consumption": round(total_feed_intake, 2),
                "feed_per_animal": round(total_feed_intake / len(animals), 2) if animals else 0
            }
            
        except Exception as e:
            logger.error(f"Error calculating herd performance: {e}")
            return {}

    async def _analyze_health_trends(self, health_records: List) -> Dict:
        """Analyze health trends from records"""
        try:
            if not health_records:
                return {}
            
            # Group by week
            weekly_data = {}
            for record in health_records:
                week = record.checkup_date.isocalendar()[1]
                if week not in weekly_data:
                    weekly_data[week] = {'weights': [], 'temperatures': []}
                
                if record.weight:
                    weekly_data[week]['weights'].append(record.weight)
                if record.temperature:
                    weekly_data[week]['temperatures'].append(record.temperature)
            
            # Calculate averages per week
            trends = {}
            for week, data in weekly_data.items():
                trends[f"week_{week}"] = {
                    "avg_weight": sum(data['weights']) / len(data['weights']) if data['weights'] else 0,
                    "avg_temperature": sum(data['temperatures']) / len(data['temperatures']) if data['temperatures'] else 0,
                    "record_count": len(data['weights']) + len(data['temperatures'])
                }
            
            return trends
            
        except Exception as e:
            logger.error(f"Error analyzing health trends: {e}")
            return {}

    async def _generate_health_recommendations(self, alerts: List, health_records: List) -> List[str]:
        """Generate health recommendations based on alerts and records"""
        recommendations = []
        
        try:
            # Alert-based recommendations
            alert_types = [alert.alert_type for alert in alerts]
            
            if 'temperature' in alert_types:
                recommendations.append("Monitor animals with abnormal temperature closely and consider veterinary consultation")
            
            if 'weight_loss' in alert_types:
                recommendations.append("Review feeding protocols and check for potential health issues causing weight loss")
            
            if 'low_feed_intake' in alert_types:
                recommendations.append("Evaluate feed quality and palatability, check for environmental stressors")
            
            # Record-based recommendations
            if len(health_records) < 10:  # Low number of health checks
                recommendations.append("Increase frequency of health monitoring for better trend analysis")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {e}")
            return []
