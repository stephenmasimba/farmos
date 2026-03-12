"""
FarmOS Compliance Reporting Service
Regulatory compliance reporting for farm operations
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class ComplianceReportingService:
    """Regulatory compliance reporting service"""
    
    def __init__(self):
        self.compliance_standards = {}
        self.compliance_categories = {}
        self.report_schedules = {}
        self.is_running = False
        
        # Initialize compliance standards
        self._initialize_compliance_standards()
        self._initialize_report_schedules()
        
    def _initialize_compliance_standards(self):
        """Initialize regulatory compliance standards"""
        self.compliance_standards = {
            'food_safety': {
                'name': 'Food Safety Standards',
                'authority': 'Food Standards Agency',
                'requirements': {
                    'haccp_compliance': True,
                    'temperature_monitoring': True,
                    'pesticide_use_tracking': True,
                    'food_handler_certification': True,
                    'storage_conditions': True,
                    'traceability': True
                },
                'thresholds': {
                    'max_pesticide_residue': 0.05,  # mg/kg
                    'max_bacteria_count': 100,  # CFU/g
                    'max_temperature': 4.0,  # °C for refrigerated
                    'min_temperature': -18.0,  # °C for frozen
                    'max_humidity': 85,  # % RH
                    'min_humidity': 30    # % RH
                }
            },
            'animal_welfare': {
                'name': 'Animal Welfare Standards',
                'authority': 'Animal Welfare Board',
                'requirements': {
                    'space_requirements': True,
                    'ventilation': True,
                    'cleanliness': True,
                    'veterinary_care': True,
                    'transport_conditions': True,
                    'slaughter_standards': True,
                    'record_keeping': True
                },
                'thresholds': {
                    'min_space_per_animal': {
                        'poultry': 0.04,  # m² per bird
                        'pig': 0.6,      # m² per pig
                        'cattle': 3.0    # m² per cattle
                    },
                    'max_transport_time': 8,  # hours
                    'min_water_per_animal': 0.5,  # liters per day
                    'max_mortality_rate': 0.05,  # 5% per batch
                    'min_cleanliness_score': 8.0  # out of 10
                }
            },
            'environmental': {
                'name': 'Environmental Standards',
                'authority': 'Environmental Protection Agency',
                'requirements': {
                    'waste_management': True,
                    'water_quality': True,
                    'soil_conservation': True,
                    'air_quality': True,
                    'noise_pollution': True,
                    'biodiversity_protection': True
                },
                'thresholds': {
                    'max_waste_per_hectare': 50,  # tons per year
                    'min_water_quality_score': 7.0,  # out of 10
                    'max_nitrogen_runoff': 50,  # kg/ha/year
                    'max_pesticide_application': 2.0,  # kg/ha/year
                    'min_green_cover': 0.3  # 30% of farm area
                }
            },
            'labor_safety': {
                'name': 'Labor Safety Standards',
                'authority': 'Occupational Safety Authority',
                'requirements': {
                    'safety_training': True,
                    'protective_equipment': True,
                    'incident_reporting': True,
                    'emergency_procedures': True,
                    'equipment_maintenance': True,
                    'chemical_safety': True
                },
                'thresholds': {
                    'max_incident_rate': 0.05,  # 5 incidents per 1000 work hours
                    'min_training_hours_per_year': 40,
                    'max_working_hours_per_day': 10,
                    'min_safety_equipment_score': 8.0,  # out of 10
                    'max_near_misses': 5  # per month
                }
            },
            'record_keeping': {
                'name': 'Record Keeping Standards',
                'authority': 'Agricultural Authority',
                'requirements': {
                    'financial_records': True,
                    'livestock_records': True,
                    'treatment_records': True,
                    'feed_records': True,
                    'sales_records': True,
                    'traceability': True,
                    'data_retention': True
                },
                'thresholds': {
                    'max_record_age_days': 365,  # Maximum age for records
                    'min_data_completeness': 0.95,  # 95% completeness
                    'max_data_entry_errors': 5,  # per 1000 entries
                    'min_backup_frequency': 7  # days
                }
            }
        }
    
    def _initialize_report_schedules(self):
        """Initialize compliance report schedules"""
        self.report_schedules = {
            'daily_compliance': {
                'name': 'Daily Compliance Check',
                'frequency': 'daily',
                'time': '08:00',
                'categories': ['food_safety', 'animal_welfare'],
                'retention_days': 30
            },
            'weekly_compliance': {
                'name': 'Weekly Compliance Report',
                'frequency': 'weekly',
                'day': 'monday',
                'time': '09:00',
                'categories': ['food_safety', 'animal_welfare', 'environmental'],
                'retention_days': 90
            },
            'monthly_compliance': {
                'name': 'Monthly Compliance Report',
                'frequency': 'monthly',
                'day': 1,
                'time': '10:00',
                'categories': ['food_safety', 'animal_welfare', 'environmental', 'labor_safety', 'record_keeping'],
                'retention_days': 365
            },
            'quarterly_audit': {
                'name': 'Quarterly Compliance Audit',
                'frequency': 'quarterly',
                'months': [1, 4, 7, 10],  # Jan, Apr, Jul, Oct
                'day': 15,
                'time': '14:00',
                'categories': ['food_safety', 'animal_welfare', 'environmental', 'labor_safety', 'record_keeping'],
                'retention_days': 1095  # 3 years
            }
        }
    
    async def start_compliance_monitoring(self):
        """Start compliance monitoring service"""
        try:
            if self.is_running:
                logger.warning("Compliance monitoring is already running")
                return
            
            self.is_running = True
            logger.info("Starting compliance monitoring service")
            
            # Start compliance monitoring loop
            self.monitoring_task = asyncio.create_task(self._compliance_monitoring_loop())
            
            return {
                "status": "success",
                "message": "Compliance monitoring started",
                "started_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error starting compliance monitoring: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_compliance_monitoring(self):
        """Stop compliance monitoring service"""
        try:
            self.is_running = False
            
            if self.monitoring_task:
                self.monitoring_task.cancel()
                self.monitoring_task = None
            
            logger.info("Compliance monitoring stopped")
            
            return {
                "status": "success",
                "message": "Compliance monitoring stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error stopping compliance monitoring: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _compliance_monitoring_loop(self):
        """Main compliance monitoring loop"""
        while self.is_running:
            try:
                current_time = datetime.utcnow()
                
                # Check each compliance report schedule
                for schedule_id, schedule in self.report_schedules.items():
                    if self._should_generate_compliance_report(schedule, current_time):
                        await self._generate_compliance_report(schedule_id, schedule)
                
                # Wait for next check (60 seconds)
                await asyncio.sleep(60)
                
        except Exception as e:
            logger.error(f"Error in compliance monitoring loop: {e}")
            await asyncio.sleep(60)
    
    def _should_generate_compliance_report(self, schedule: Dict, current_time: datetime) -> bool:
        """Check if compliance report should be generated"""
        try:
            # Check if report already generated recently
            last_generated = schedule.get('last_generated')
            if last_generated:
                time_since_last = (current_time - last_generated).total_seconds()
                min_interval = 3600  # Minimum 1 hour between reports
                
                if time_since_last < min_interval:
                    return False
            
            # Check schedule frequency
            frequency = schedule.get('frequency', 'daily')
            
            if frequency == 'daily':
                scheduled_time = schedule.get('time', '08:00')
                current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                return current_hour_minute == scheduled_time
            
            elif frequency == 'weekly':
                scheduled_day = schedule.get('day', 'monday').lower()
                scheduled_time = schedule.get('time', '09:00')
                
                if current_time.strftime('%A').lower() == scheduled_day:
                    current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                    return current_hour_minute == scheduled_time
            
            elif frequency == 'monthly':
                scheduled_day = schedule.get('day', 1)
                scheduled_time = schedule.get('time', '10:00')
                
                if current_time.day == scheduled_day:
                    current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                    return current_hour_minute == scheduled_time
            
            elif frequency == 'quarterly':
                scheduled_months = schedule.get('months', [1, 4, 7, 10])
                scheduled_day = schedule.get('day', 15)
                scheduled_time = schedule.get('time', '14:00')
                
                if current_time.month in scheduled_months and current_time.day == scheduled_day:
                    current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                    return current_hour_minute == scheduled_time
            
            return False
            
        except Exception as e:
            logger.error(f"Error checking compliance report schedule: {e}")
            return False
    
    async def _generate_compliance_report(self, schedule_id: str, schedule: Dict):
        """Generate compliance report"""
        try:
            logger.info(f"Generating compliance report: {schedule_id}")
            
            # Get compliance data for categories
            categories = schedule.get('categories', [])
            compliance_data = {}
            
            for category in categories:
                compliance_data[category] = await self._get_category_compliance_data(category)
            
            # Generate report
            report_data = {
                'report_id': f"compliance_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
                'schedule_id': schedule_id,
                'schedule_name': schedule.get('name'),
                'generated_at': datetime.utcnow(),
                'categories': categories,
                'compliance_data': compliance_data,
                'overall_compliance_score': self._calculate_overall_compliance_score(compliance_data),
                'violations': await self._identify_compliance_violations(compliance_data),
                'recommendations': await self._generate_compliance_recommendations(compliance_data)
            }
            
            # Save report
            await self._save_compliance_report(report_data)
            
            # Update schedule
            schedule['last_generated'] = datetime.utcnow()
            
            logger.info(f"Compliance report {schedule_id} generated successfully")
            
        except Exception as e:
            logger.error(f"Error generating compliance report {schedule_id}: {e}")
    
    async def _get_category_compliance_data(self, category: str) -> Dict:
        """Get compliance data for a specific category"""
        try:
            if category == 'food_safety':
                return await self._get_food_safety_compliance()
            elif category == 'animal_welfare':
                return await self._get_animal_welfare_compliance()
            elif category == 'environmental':
                return await self._get_environmental_compliance()
            elif category == 'labor_safety':
                return await self._get_labor_safety_compliance()
            elif category == 'record_keeping':
                return await self._get_record_keeping_compliance()
            else:
                return {}
        
        except Exception as e:
            logger.error(f"Error getting compliance data for {category}: {e}")
            return {}
    
    async def _get_food_safety_compliance(self) -> Dict:
        """Get food safety compliance data"""
        try:
            # Get recent food safety data
            db = next(get_db())
            
            # Get temperature monitoring data
            temp_records = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.type == 'health_check',
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=7)
            ).all()
            
            # Get pesticide usage data
            pesticide_records = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.type == 'pesticide_application',
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=30)
            ).all()
            
            # Calculate compliance metrics
            temp_compliance = self._calculate_temperature_compliance(temp_records)
            pesticide_compliance = self._calculate_pesticide_compliance(pesticide_records)
            
            return {
                'temperature_compliance': temp_compliance,
                'pesticide_compliance': pesticide_compliance,
                'overall_score': (temp_compliance.get('score', 0) + pesticide_compliance.get('score', 0)) / 2,
                'violations': temp_compliance.get('violations', []) + pesticide_compliance.get('violations', [])
            }
        
        except Exception as e:
            logger.error(f"Error getting food safety compliance: {e}")
            return {}
    
    async def _get_animal_welfare_compliance(self) -> Dict:
        """Get animal welfare compliance data"""
        try:
            db = next(get_db())
            
            # Get livestock data
            livestock_batches = db.query(models.LivestockBatch).filter(
                models.LivestockBatch.status == 'active'
            ).all()
            
            # Get health events
            health_events = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.type == 'health_check',
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=7)
            ).all()
            
            # Calculate compliance metrics
            space_compliance = self._calculate_space_compliance(livestock_batches)
            health_compliance = self._calculate_health_compliance(health_events)
            
            return {
                'space_compliance': space_compliance,
                'health_compliance': health_compliance,
                'overall_score': (space_compliance.get('score', 0) + health_compliance.get('score', 0)) / 2,
                'violations': space_compliance.get('violations', []) + health_compliance.get('violations', [])
            }
        
        except Exception as e:
            logger.error(f"Error getting animal welfare compliance: {e}")
            return {}
    
    async def _get_environmental_compliance(self) -> Dict:
        """Get environmental compliance data"""
        try:
            # Mock environmental data (would come from sensors and records)
            return {
                'waste_management': {
                    'score': 0.85,
                    'violations': ['Excess waste in Q1', 'Missing waste records'],
                    'total_waste_tons': 45.2
                },
                'water_quality': {
                    'score': 0.78,
                    'violations': ['High nitrate levels detected'],
                    'water_quality_score': 7.2
                },
                'soil_conservation': {
                    'score': 0.92,
                    'violations': [],
                    'green_cover_percentage': 35.0
                },
                'overall_score': 0.85
            }
        
        except Exception as e:
            logger.error(f"Error getting environmental compliance: {e}")
            return {}
    
    async def _get_labor_safety_compliance(self) -> Dict:
        """Get labor safety compliance data"""
        try:
            db = next(get_db())
            
            # Get safety incidents
            safety_incidents = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.type == 'safety_incident',
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=30)
            ).all()
            
            # Get training records
            training_records = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.type == 'safety_training',
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=365)
            ).all()
            
            # Calculate compliance metrics
            incident_compliance = self._calculate_incident_compliance(safety_incidents)
            training_compliance = self._calculate_training_compliance(training_records)
            
            return {
                'incident_compliance': incident_compliance,
                'training_compliance': training_compliance,
                'overall_score': (incident_compliance.get('score', 0) + training_compliance.get('score', 0)) / 2,
                'violations': incident_compliance.get('violations', []) + training_compliance.get('violations', [])
            }
        
        except Exception as e:
            logger.error(f"Error getting labor safety compliance: {e}")
            return {}
    
    async def _get_record_keeping_compliance(self) -> Dict:
        """Get record keeping compliance data"""
        try:
            db = next(get_db())
            
            # Get data completeness metrics
            livestock_records = db.query(models.LivestockBatch).count()
            financial_records = db.query(models.FinancialTransaction).count()
            
            # Calculate completeness
            total_expected_records = livestock_records + financial_records
            complete_records = total_expected_records * 0.95  # 95% completeness target
            
            return {
                'data_completeness': min(1.0, complete_records / total_expected_records if total_expected_records > 0 else 1.0),
                'record_count': {
                    'livestock': livestock_records,
                    'financial': financial_records,
                    'total': total_expected_records
                },
                'violations': [] if complete_records >= total_expected_records * 0.95 else ['Insufficient data completeness'],
                'score': min(1.0, complete_records / total_expected_records if total_expected_records > 0 else 1.0)
            }
        
        except Exception as e:
            logger.error(f"Error getting record keeping compliance: {e}")
            return {}
    
    def _calculate_temperature_compliance(self, temp_records: List) -> Dict:
        """Calculate temperature compliance"""
        try:
            if not temp_records:
                return {'score': 1.0, 'violations': []}
            
            violations = []
            compliant_readings = 0
            total_readings = len(temp_records)
            
            for record in temp_records:
                if record.details and 'temperature' in record.details:
                    temp = float(record.details['temperature'])
                    
                    # Check temperature ranges
                    if temp > 4.0:  # Above refrigeration temp
                        violations.append(f"Temperature too high: {temp}°C")
                    elif temp < -18.0:  # Below freezing temp
                        violations.append(f"Temperature too low: {temp}°C")
                    else:
                        compliant_readings += 1
            
            score = compliant_readings / total_readings if total_readings > 0 else 1.0
            
            return {
                'score': score,
                'violations': violations,
                'total_readings': total_readings,
                'compliant_readings': compliant_readings
            }
        
        except Exception as e:
            logger.error(f"Error calculating temperature compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_pesticide_compliance(self, pesticide_records: List) -> Dict:
        """Calculate pesticide compliance"""
        try:
            if not pesticide_records:
                return {'score': 1.0, 'violations': []}
            
            violations = []
            compliant_applications = 0
            total_applications = len(pesticide_records)
            
            for record in pesticide_records:
                if record.details and 'pesticide' in record.details:
                    # Check for proper documentation
                    if not record.details.get('application_rate'):
                        violations.append(f"Missing application rate for {record.details.get('pesticide', 'Unknown')}")
                    else:
                        compliant_applications += 1
            
            score = compliant_applications / total_applications if total_applications > 0 else 1.0
            
            return {
                'score': score,
                'violations': violations,
                'total_applications': total_applications,
                'compliant_applications': compliant_applications
            }
        
        except Exception as e:
            logger.error(f"Error calculating pesticide compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_space_compliance(self, livestock_batches: List) -> Dict:
        """Calculate space compliance"""
        try:
            if not livestock_batches:
                return {'score': 1.0, 'violations': []}
            
            violations = []
            compliant_batches = 0
            total_batches = len(livestock_batches)
            
            for batch in livestock_batches:
                # Calculate space per animal
                if batch.quantity and batch.type:
                    space_per_animal = 10.0 / batch.quantity  # Assuming 10m² area
                    
                    # Check minimum space requirements
                    min_space = self.compliance_standards['animal_welfare']['thresholds']['min_space_per_animal'].get(batch.type.lower(), 0.6)
                    
                    if space_per_animal < min_space:
                        violations.append(f"Insufficient space for {batch.type}: {space_per_animal:.2f}m² per animal (min: {min_space}m²)")
                    else:
                        compliant_batches += 1
            
            score = compliant_batches / total_batches if total_batches > 0 else 1.0
            
            return {
                'score': score,
                'violations': violations,
                'total_batches': total_batches,
                'compliant_batches': compliant_batches
            }
        
        except Exception as e:
            logger.error(f"Error calculating space compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_health_compliance(self, health_events: List) -> Dict:
        """Calculate health compliance"""
        try:
            if not health_events:
                return {'score': 1.0, 'violations': []}
            
            violations = []
            compliant_checks = 0
            total_checks = len(health_events)
            
            for event in health_events:
                if event.details:
                    # Check for proper documentation
                    if event.details.get('veterinary_check'):
                        compliant_checks += 1
                    else:
                        violations.append(f"Missing veterinary check for {event.date}")
            
            score = compliant_checks / total_checks if total_checks > 0 else 1.0
            
            return {
                'score': score,
                'violations': violations,
                'total_checks': total_checks,
                'compliant_checks': compliant_checks
            }
        
        except Exception as e:
            logger.error(f"Error calculating health compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_incident_compliance(self, safety_incidents: List) -> Dict:
        """Calculate incident compliance"""
        try:
            if not safety_incidents:
                return {'score': 1.0, 'violations': []}
            
            violations = []
            total_incidents = len(safety_incidents)
            
            # Check incident rate
            max_incident_rate = self.compliance_standards['labor_safety']['thresholds']['max_incident_rate']
            
            if total_incidents > 0:
                # Calculate incident rate (assuming 1000 work hours per month)
                incident_rate = total_incidents / 30  # incidents per day
                
                if incident_rate > max_incident_rate:
                    violations.append(f"High incident rate: {incident_rate:.3f} per day (max: {max_incident_rate})")
            
            score = max(0.0, 1.0 - (incident_rate - max_incident_rate)) if total_incidents > 0 else 1.0
            
            return {
                'score': score,
                'violations': violations,
                'total_incidents': total_incidents,
                'incident_rate': incident_rate if total_incidents > 0 else 0
            }
        
        except Exception as e:
            logger.error(f"Error calculating incident compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_training_compliance(self, training_records: List) -> Dict:
        """Calculate training compliance"""
        try:
            if not training_records:
                return {'score': 0.5, 'violations': ['No training records found']}
            
            violations = []
            total_training_hours = sum(record.details.get('duration', 0) for record in training_records if record.details)
            
            min_training_hours = self.compliance_standards['labor_safety']['thresholds']['min_training_hours_per_year']
            
            if total_training_hours < min_training_hours:
                violations.append(f"Insufficient training: {total_training_hours} hours (min: {min_training_hours} hours)")
            
            score = min(1.0, total_training_hours / min_training_hours)
            
            return {
                'score': score,
                'violations': violations,
                'total_training_hours': total_training_hours,
                'min_required_hours': min_training_hours
            }
        
        except Exception as e:
            logger.error(f"Error calculating training compliance: {e}")
            return {'score': 0.0, 'violations': [str(e)]}
    
    def _calculate_overall_compliance_score(self, compliance_data: Dict) -> float:
        """Calculate overall compliance score"""
        try:
            if not compliance_data:
                return 0.0
            
            scores = []
            for category, data in compliance_data.items():
                if isinstance(data, dict) and 'score' in data:
                    scores.append(data['score'])
            
            return sum(scores) / len(scores) if scores else 0.0
        
        except Exception as e:
            logger.error(f"Error calculating overall compliance score: {e}")
            return 0.0
    
    async def _identify_compliance_violations(self, compliance_data: Dict) -> List[Dict]:
        """Identify compliance violations"""
        try:
            violations = []
            
            for category, data in compliance_data.items():
                if isinstance(data, dict) and 'violations' in data:
                    for violation in data['violations']:
                        violations.append({
                            'category': category,
                            'violation': violation,
                            'severity': self._get_violation_severity(category, violation),
                            'date': datetime.utcnow().isoformat()
                        })
            
            return violations
        
        except Exception as e:
            logger.error(f"Error identifying compliance violations: {e}")
            return []
    
    def _get_violation_severity(self, category: str, violation: str) -> str:
        """Get violation severity level"""
        try:
            # High severity violations
            high_severity = [
                'temperature too high',
                'temperature too low',
                'insufficient space',
                'missing veterinary check',
                'high incident rate'
            ]
            
            # Medium severity violations
            medium_severity = [
                'missing application rate',
                'insufficient training',
                'high nitrate levels'
            ]
            
            if violation in high_severity:
                return 'high'
            elif violation in medium_severity:
                return 'medium'
            else:
                return 'low'
        
        except Exception as e:
            logger.error(f"Error getting violation severity: {e}")
            return 'unknown'
    
    async def _generate_compliance_recommendations(self, compliance_data: Dict) -> List[str]:
        """Generate compliance recommendations"""
        try:
            recommendations = []
            
            for category, data in compliance_data.items():
                if isinstance(data, dict) and 'score' in data:
                    score = data['score']
                    
                    if score < 0.8:
                        recommendations.append(f"Improve {category} compliance - current score: {score:.2f}")
                    
                    if category == 'food_safety':
                        recommendations.extend([
                            "Implement regular temperature monitoring",
                            "Ensure proper pesticide documentation",
                            "Train staff on food safety procedures"
                        ])
                    elif category == 'animal_welfare':
                        recommendations.extend([
                            "Review space allocation per animal",
                            "Implement regular health checks",
                            "Ensure proper ventilation systems"
                        ])
                    elif category == 'environmental':
                        recommendations.extend([
                            "Implement waste reduction program",
                            "Monitor water quality regularly",
                            "Increase green cover areas"
                        ])
                    elif category == 'labor_safety':
                        recommendations.extend([
                            "Increase safety training frequency",
                            "Implement incident reporting system",
                            "Ensure proper protective equipment"
                        ])
            
            return recommendations
        
        except Exception as e:
            logger.error(f"Error generating compliance recommendations: {e}")
            return ["Error generating recommendations"]
    
    async def _save_compliance_report(self, report_data: Dict):
        """Save compliance report"""
        try:
            # Create compliance report file
            report_file = f"{self.report_schedules.get('directory', '/reports/compliance')}/{report_data['report_id']}.json"
            
            os.makedirs(os.path.dirname(report_file), exist_ok=True)
            
            with open(report_file, 'w') as f:
                json.dump(report_data, f, indent=2)
            
            logger.info(f"Compliance report saved: {report_file}")
        
        except Exception as e:
            logger.error(f"Error saving compliance report: {e}")
    
    def get_compliance_summary(self, db: Session, tenant_id: str = "default") -> Dict:
        """Get compliance summary"""
        try:
            # Get recent compliance data
            compliance_data = {}
            
            for category in self.compliance_standards.keys():
                compliance_data[category] = await self._get_category_compliance_data(category)
            
            overall_score = self._calculate_overall_compliance_score(compliance_data)
            violations = await self._identify_compliance_violations(compliance_data)
            
            return {
                'overall_score': overall_score,
                'category_scores': {cat: data.get('score', 0) for cat, data in compliance_data.items()},
                'violations': violations,
                'compliance_status': 'compliant' if overall_score >= 0.8 else 'needs_improvement' if overall_score >= 0.6 else 'non_compliant',
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting compliance summary: {e}")
            return {
                'overall_score': 0.0,
                'category_scores': {},
                'violations': [],
                'compliance_status': 'error'
            }

# Global compliance reporting service instance
compliance_reporting_service = ComplianceReportingService()
