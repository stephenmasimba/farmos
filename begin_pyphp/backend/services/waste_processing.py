"""
Waste Processing System - Phase 3 Feature
Comprehensive waste management with recycling, composting, and biogas production
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

class WasteProcessingService:
    """Advanced waste processing and circular economy management system"""
    
    def __init__(self, db: Session):
        self.db = db
        self.waste_types = {
            'animal_manure': {
                'processing_methods': ['composting', 'biogas', 'drying'],
                'nutrient_content': {'nitrogen': 2.5, 'phosphorus': 1.5, 'potassium': 2.0},
                'biogas_potential': 60,  # m3 per ton
                'composting_time': 90,  # days
                'carbon_footprint_reduction': 0.8
            },
            'crop_residue': {
                'processing_methods': ['composting', 'biochar', 'animal_feed'],
                'nutrient_content': {'nitrogen': 1.2, 'phosphorus': 0.8, 'potassium': 1.5},
                'biogas_potential': 40,
                'composting_time': 60,
                'carbon_footprint_reduction': 0.6
            },
            'food_waste': {
                'processing_methods': ['composting', 'biogas', 'animal_feed'],
                'nutrient_content': {'nitrogen': 2.0, 'phosphorus': 1.0, 'potassium': 1.2},
                'biogas_potential': 80,
                'composting_time': 45,
                'carbon_footprint_reduction': 0.9
            },
            'green_waste': {
                'processing_methods': ['composting', 'mulching', 'biochar'],
                'nutrient_content': {'nitrogen': 1.8, 'phosphorus': 0.6, 'potassium': 1.0},
                'biogas_potential': 35,
                'composting_time': 75,
                'carbon_footprint_reduction': 0.7
            }
        }

    async def record_waste_generation(self, waste_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Record waste generation from various farm sources"""
        try:
            waste_type = waste_data.get('waste_type')
            if waste_type not in self.waste_types:
                return {"error": f"Unsupported waste type: {waste_type}"}
            
            # Create waste generation record
            waste_record = models.WasteGeneration(
                waste_type=waste_type,
                source_type=waste_data['source_type'],  # animal_housing, crop_production, food_processing
                source_id=waste_data.get('source_id'),
                quantity_kg=waste_data['quantity_kg'],
                moisture_content=waste_data.get('moisture_content', 60),
                collection_date=datetime.strptime(waste_data['collection_date'], '%Y-%m-%d').date() if isinstance(waste_data.get('collection_date'), str) else waste_data.get('collection_date'),
                storage_location=waste_data.get('storage_location'),
                contamination_level=waste_data.get('contamination_level', 'low'),
                notes=waste_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(waste_record)
            self.db.commit()
            
            # Check if processing is needed
            await self._check_processing_needs(waste_record.id, tenant_id)
            
            return {
                "success": True,
                "waste_id": waste_record.id,
                "message": "Waste generation recorded successfully"
            }
            
        except Exception as e:
            logger.error(f"Error recording waste generation: {e}")
            self.db.rollback()
            return {"error": "Waste recording failed"}

    async def initiate_waste_processing(self, processing_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Initiate waste processing batch"""
        try:
            waste_type = processing_data.get('waste_type')
            processing_method = processing_data['processing_method']
            
            # Validate processing method
            if waste_type not in self.waste_types:
                return {"error": f"Unsupported waste type: {waste_type}"}
            
            if processing_method not in self.waste_types[waste_type]['processing_methods']:
                return {"error": f"Processing method {processing_method} not suitable for {waste_type}"}
            
            # Calculate processing parameters
            waste_characteristics = self.waste_types[waste_type]
            processing_time = waste_characteristics.get('composting_time', 60) if processing_method == 'composting' else 30
            
            # Create processing batch record
            processing_batch = models.WasteProcessingBatch(
                batch_name=processing_data.get('batch_name', f"{waste_type}_{processing_method}_{datetime.utcnow().strftime('%Y%m%d')}"),
                waste_type=waste_type,
                processing_method=processing_method,
                start_date=datetime.utcnow().date(),
                expected_completion_date=datetime.utcnow().date() + timedelta(days=processing_time),
                input_quantity=processing_data['input_quantity'],
                status='processing',
                facility_id=processing_data.get('facility_id'),
                operator_id=processing_data.get('operator_id'),
                temperature_target=processing_data.get('temperature_target'),
                moisture_target=processing_data.get('moisture_target'),
                ph_target=processing_data.get('ph_target'),
                aeration_schedule=processing_data.get('aeration_schedule'),
                notes=processing_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(processing_batch)
            self.db.commit()
            
            # Link waste sources to this batch
            if 'waste_source_ids' in processing_data:
                for source_id in processing_data['waste_source_ids']:
                    link = models.WasteBatchLink(
                        batch_id=processing_batch.id,
                        waste_generation_id=source_id,
                        quantity_used=0,  # Will be updated when actual usage is recorded
                        tenant_id=tenant_id,
                        created_at=datetime.utcnow()
                    )
                    self.db.add(link)
            
            # Create initial monitoring record
            await self._create_processing_monitoring(processing_batch.id, tenant_id)
            
            return {
                "success": True,
                "batch_id": processing_batch.id,
                "batch_name": processing_batch.batch_name,
                "expected_completion": processing_batch.expected_completion_date.strftime('%Y-%m-%d'),
                "message": "Waste processing batch initiated successfully"
            }
            
        except Exception as e:
            logger.error(f"Error initiating waste processing: {e}")
            self.db.rollback()
            return {"error": "Processing initiation failed"}

    async def record_processing_monitoring(self, batch_id: int, monitoring_data: Dict[str, Any], 
                                         tenant_id: str = "default") -> Dict[str, Any]:
        """Record processing parameters and quality metrics"""
        try:
            batch = self.db.query(models.WasteProcessingBatch).filter(
                and_(
                    models.WasteProcessingBatch.id == batch_id,
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            ).first()
            
            if not batch:
                return {"error": "Processing batch not found"}
            
            # Create monitoring record
            monitoring = models.WasteProcessingMonitoring(
                batch_id=batch_id,
                monitoring_date=datetime.strptime(monitoring_data['monitoring_date'], '%Y-%m-%d').date() if isinstance(monitoring_data.get('monitoring_date'), str) else monitoring_data.get('monitoring_date'),
                temperature=monitoring_data.get('temperature'),
                moisture_content=monitoring_data.get('moisture_content'),
                ph_level=monitoring_data.get('ph_level'),
                oxygen_level=monitoring_data.get('oxygen_level'),
                co2_level=monitoring_data.get('co2_level'),
                odor_level=monitoring_data.get('odor_level'),
                visual_quality=monitoring_data.get('visual_quality', 'good'),
                pathogen_test_result=monitoring_data.get('pathogen_test_result'),
                nutrient_analysis=json.dumps(monitoring_data.get('nutrient_analysis', {})),
                notes=monitoring_data.get('notes'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(monitoring)
            
            # Check for alerts based on monitoring data
            await self._check_processing_alerts(batch_id, monitoring_data, tenant_id)
            
            # Update batch status if completion criteria met
            if await self._check_processing_completion(batch_id, tenant_id):
                batch.status = 'completed'
                batch.actual_completion_date = datetime.utcnow().date()
                await self._generate_processing_outputs(batch_id, tenant_id)
            
            batch.updated_at = datetime.utcnow()
            self.db.commit()
            
            return {
                "success": True,
                "message": "Processing monitoring recorded successfully",
                "monitoring_id": monitoring.id
            }
            
        except Exception as e:
            logger.error(f"Error recording processing monitoring: {e}")
            self.db.rollback()
            return {"error": "Monitoring recording failed"}

    async def record_processing_output(self, batch_id: int, output_data: Dict[str, Any], 
                                    tenant_id: str = "default") -> Dict[str, Any]:
        """Record final processing outputs and products"""
        try:
            batch = self.db.query(models.WasteProcessingBatch).filter(
                and_(
                    models.WasteProcessingBatch.id == batch_id,
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            ).first()
            
            if not batch:
                return {"error": "Processing batch not found"}
            
            # Create output record
            output = models.WasteProcessingOutput(
                batch_id=batch_id,
                product_type=output_data['product_type'],  # compost, biogas, biochar, fertilizer
                quantity=output_data['quantity'],
                quality_grade=output_data.get('quality_grade', 'standard'),
                nutrient_content=json.dumps(output_data.get('nutrient_content', {})),
                moisture_content=output_data.get('moisture_content'),
                carbon_content=output_data.get('carbon_content'),
                pathogen_free=output_data.get('pathogen_free', True),
                storage_location=output_data.get('storage_location'),
                market_value=output_data.get('market_value'),
                intended_use=output_data.get('intended_use'),
                certification_details=json.dumps(output_data.get('certification_details', {})),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(output)
            
            # Update batch status
            batch.status = 'completed'
            batch.actual_completion_date = datetime.utcnow().date()
            
            # Calculate processing efficiency
            efficiency = await self._calculate_processing_efficiency(batch_id, output_data['quantity'], tenant_id)
            batch.processing_efficiency = efficiency
            
            self.db.commit()
            
            return {
                "success": True,
                "output_id": output.id,
                "processing_efficiency": efficiency,
                "message": "Processing output recorded successfully"
            }
            
        except Exception as e:
            logger.error(f"Error recording processing output: {e}")
            self.db.rollback()
            return {"error": "Output recording failed"}

    async def get_waste_analytics(self, start_date: Optional[str] = None, end_date: Optional[str] = None,
                                waste_type: Optional[str] = None, tenant_id: str = "default") -> Dict[str, Any]:
        """Get comprehensive waste management analytics"""
        try:
            if not start_date:
                start_date = (datetime.utcnow() - timedelta(days=30)).strftime('%Y-%m-%d')
            if not end_date:
                end_date = datetime.utcnow().strftime('%Y-%m-%d')
            
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Get waste generation data
            waste_query = self.db.query(models.WasteGeneration).filter(
                and_(
                    models.WasteGeneration.collection_date >= start_dt.date(),
                    models.WasteGeneration.collection_date <= end_dt.date(),
                    models.WasteGeneration.tenant_id == tenant_id
                )
            )
            
            if waste_type:
                waste_query = waste_query.filter(models.WasteGeneration.waste_type == waste_type)
            
            waste_records = waste_query.all()
            
            # Get processing data
            processing_query = self.db.query(models.WasteProcessingBatch).filter(
                and_(
                    models.WasteProcessingBatch.start_date >= start_dt.date(),
                    models.WasteProcessingBatch.start_date <= end_dt.date(),
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            )
            
            if waste_type:
                processing_query = processing_query.filter(models.WasteProcessingBatch.waste_type == waste_type)
            
            processing_batches = processing_query.all()
            
            # Get output data
            outputs = self.db.query(models.WasteProcessingOutput).join(models.WasteProcessingBatch).filter(
                and_(
                    models.WasteProcessingBatch.start_date >= start_dt.date(),
                    models.WasteProcessingBatch.start_date <= end_dt.date(),
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            ).all()
            
            # Calculate analytics
            analytics = await self._calculate_waste_analytics(waste_records, processing_batches, outputs)
            
            return {
                "period": {
                    "start_date": start_date,
                    "end_date": end_date,
                    "waste_type": waste_type or "all"
                },
                "waste_generation": {
                    "total_waste_kg": sum(w.quantity_kg for w in waste_records),
                    "by_type": await self._group_waste_by_type(waste_records),
                    "by_source": await self._group_waste_by_source(waste_records),
                    "daily_average": sum(w.quantity_kg for w in waste_records) / ((end_dt - start_dt).days + 1)
                },
                "processing_summary": {
                    "total_batches": len(processing_batches),
                    "completed_batches": len([b for b in processing_batches if b.status == 'completed']),
                    "average_efficiency": sum(b.processing_efficiency or 0 for b in processing_batches) / len(processing_batches) if processing_batches else 0,
                    "by_method": await self._group_processing_by_method(processing_batches)
                },
                "outputs": {
                    "total_products": len(outputs),
                    "by_product_type": await self._group_outputs_by_type(outputs),
                    "total_market_value": sum(o.market_value or 0 for o in outputs),
                    "nutrient_recovery": await self._calculate_nutrient_recovery(outputs)
                },
                "environmental_impact": {
                    "carbon_footprint_reduction": analytics['carbon_reduction'],
                    "waste_diversion_rate": analytics['diversion_rate'],
                    "nutrient_recycling_rate": analytics['nutrient_recycling_rate']
                },
                "recommendations": await self._generate_waste_recommendations(waste_records, processing_batches, outputs)
            }
            
        except Exception as e:
            logger.error(f"Error getting waste analytics: {e}")
            return {"error": "Analytics generation failed"}

    async def get_circular_economy_metrics(self, tenant_id: str = "default") -> Dict[str, Any]:
        """Calculate circular economy performance metrics"""
        try:
            # Get data for the last 12 months
            twelve_months_ago = datetime.utcnow() - timedelta(days=365)
            
            waste_generated = self.db.query(func.sum(models.WasteGeneration.quantity_kg)).filter(
                and_(
                    models.WasteGeneration.collection_date >= twelve_months_ago.date(),
                    models.WasteGeneration.tenant_id == tenant_id
                )
            ).scalar() or 0
            
            waste_processed = self.db.query(func.sum(models.WasteProcessingBatch.input_quantity)).filter(
                and_(
                    models.WasteProcessingBatch.start_date >= twelve_months_ago.date(),
                    models.WasteProcessingBatch.status == 'completed',
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            ).scalar() or 0
            
            outputs = self.db.query(models.WasteProcessingOutput).join(models.WasteProcessingBatch).filter(
                and_(
                    models.WasteProcessingBatch.start_date >= twelve_months_ago.date(),
                    models.WasteProcessingBatch.tenant_id == tenant_id
                )
            ).all()
            
            total_output_quantity = sum(o.quantity for o in outputs)
            total_market_value = sum(o.market_value or 0 for o in outputs)
            
            # Calculate circular economy metrics
            circularity_rate = (waste_processed / waste_generated * 100) if waste_generated > 0 else 0
            resource_recovery_rate = (total_output_quantity / waste_processed * 100) if waste_processed > 0 else 0
            
            # Calculate carbon footprint reduction
            carbon_reduction = 0
            for output in outputs:
                if output.product_type in ['compost', 'biochar']:
                    carbon_reduction += output.quantity * 0.5  # Simplified calculation
            
            return {
                "period": "last_12_months",
                "circularity_metrics": {
                    "waste_generated_kg": waste_generated,
                    "waste_processed_kg": waste_processed,
                    "circularity_rate": round(circularity_rate, 2),
                    "resource_recovery_rate": round(resource_recovery_rate, 2)
                },
                "economic_metrics": {
                    "total_products_generated": total_output_quantity,
                    "total_market_value": total_market_value,
                    "value_per_ton": round((total_market_value / total_output_quantity * 1000) if total_output_quantity > 0 else 0, 2)
                },
                "environmental_metrics": {
                    "carbon_footprint_reduction_tons": round(carbon_reduction / 1000, 2),
                    "landfill_diversion_tons": round(waste_processed / 1000, 2),
                    "nutrient_recycling_efficiency": await self._calculate_nutrient_efficiency(outputs)
                },
                "product_breakdown": {
                    product_type: len([o for o in outputs if o.product_type == product_type])
                    for product_type in set(o.product_type for o in outputs)
                }
            }
            
        except Exception as e:
            logger.error(f"Error calculating circular economy metrics: {e}")
            return {"error": "Metrics calculation failed"}

    # Helper methods
    async def _check_processing_needs(self, waste_id: int, tenant_id: str):
        """Check if waste needs processing and create alerts"""
        try:
            waste = self.db.query(models.WasteGeneration).filter(models.WasteGeneration.id == waste_id).first()
            if not waste:
                return
            
            # Check if quantity exceeds threshold for processing
            processing_threshold = 1000  # kg
            
            if waste.quantity_kg >= processing_threshold:
                alert = models.WasteProcessingAlert(
                    waste_generation_id=waste_id,
                    alert_type='processing_needed',
                    message=f"Waste quantity ({waste.quantity_kg}kg) exceeds processing threshold",
                    severity='medium',
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(alert)
                self.db.commit()
                
        except Exception as e:
            logger.error(f"Error checking processing needs: {e}")

    async def _create_processing_monitoring(self, batch_id: int, tenant_id: str):
        """Create initial monitoring record for processing batch"""
        try:
            monitoring = models.WasteProcessingMonitoring(
                batch_id=batch_id,
                monitoring_date=datetime.utcnow().date(),
                visual_quality='good',
                notes='Processing batch initiated',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(monitoring)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating processing monitoring: {e}")

    async def _check_processing_alerts(self, batch_id: int, monitoring_data: Dict[str, Any], tenant_id: str):
        """Check for processing alerts based on monitoring data"""
        try:
            alerts = []
            
            # Temperature alerts
            if monitoring_data.get('temperature'):
                temp = monitoring_data['temperature']
                if temp < 20 or temp > 70:
                    alerts.append({
                        'alert_type': 'temperature',
                        'message': f"Temperature out of optimal range: {temp}°C",
                        'severity': 'high'
                    })
            
            # Moisture alerts
            if monitoring_data.get('moisture_content'):
                moisture = monitoring_data['moisture_content']
                if moisture < 40 or moisture > 70:
                    alerts.append({
                        'alert_type': 'moisture',
                        'message': f"Moisture content out of optimal range: {moisture}%",
                        'severity': 'medium'
                    })
            
            # pH alerts
            if monitoring_data.get('ph_level'):
                ph = monitoring_data['ph_level']
                if ph < 6.0 or ph > 8.0:
                    alerts.append({
                        'alert_type': 'ph_level',
                        'message': f"pH level out of optimal range: {ph}",
                        'severity': 'medium'
                    })
            
            # Create alert records
            for alert in alerts:
                alert_record = models.WasteProcessingAlert(
                    batch_id=batch_id,
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
            logger.error(f"Error checking processing alerts: {e}")

    async def _check_processing_completion(self, batch_id: int, tenant_id: str) -> bool:
        """Check if processing batch meets completion criteria"""
        try:
            # Get recent monitoring data
            recent_monitoring = self.db.query(models.WasteProcessingMonitoring).filter(
                and_(
                    models.WasteProcessingMonitoring.batch_id == batch_id,
                    models.WasteProcessingMonitoring.tenant_id == tenant_id
                )
            ).order_by(desc(models.WasteProcessingMonitoring.monitoring_date)).limit(3).all()
            
            if len(recent_monitoring) < 3:
                return False
            
            # Check if stable conditions maintained for 3 consecutive readings
            temp_stable = all(abs(m.temperature - recent_monitoring[0].temperature) < 5 for m in recent_monitoring if m.temperature)
            moisture_stable = all(abs(m.moisture_content - recent_monitoring[0].moisture_content) < 10 for m in recent_monitoring if m.moisture_content)
            
            return temp_stable and moisture_stable
            
        except Exception as e:
            logger.error(f"Error checking processing completion: {e}")
            return False

    async def _generate_processing_outputs(self, batch_id: int, tenant_id: str):
        """Generate default processing outputs based on batch characteristics"""
        try:
            batch = self.db.query(models.WasteProcessingBatch).filter(models.WasteProcessingBatch.id == batch_id).first()
            if not batch:
                return
            
            # Generate output based on processing method
            if batch.processing_method == 'composting':
                product_type = 'compost'
                estimated_quantity = batch.input_quantity * 0.7  # 70% yield
            elif batch.processing_method == 'biogas':
                product_type = 'biogas'
                # Biogas volume calculation
                waste_char = self.waste_types.get(batch.waste_type, {})
                biogas_potential = waste_char.get('biogas_potential', 50)
                estimated_quantity = (batch.input_quantity / 1000) * biogas_potential  # Convert to m3
            elif batch.processing_method == 'biochar':
                product_type = 'biochar'
                estimated_quantity = batch.input_quantity * 0.3  # 30% yield
            else:
                product_type = 'fertilizer'
                estimated_quantity = batch.input_quantity * 0.8
            
            # Create output record
            output = models.WasteProcessingOutput(
                batch_id=batch_id,
                product_type=product_type,
                quantity=estimated_quantity,
                quality_grade='standard',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(output)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error generating processing outputs: {e}")

    async def _calculate_processing_efficiency(self, batch_id: int, output_quantity: float, tenant_id: str) -> float:
        """Calculate processing efficiency"""
        try:
            batch = self.db.query(models.WasteProcessingBatch).filter(models.WasteProcessingBatch.id == batch_id).first()
            if not batch or batch.input_quantity == 0:
                return 0
            
            # Basic efficiency calculation
            efficiency = (output_quantity / batch.input_quantity) * 100
            
            # Adjust for processing method
            if batch.processing_method == 'composting':
                target_efficiency = 70  # 70% is good for composting
            elif batch.processing_method == 'biogas':
                target_efficiency = 85  # 85% is good for biogas
            else:
                target_efficiency = 75
            
            # Normalize to 0-100 scale
            normalized_efficiency = min(100, (efficiency / target_efficiency) * 100)
            
            return round(normalized_efficiency, 2)
            
        except Exception as e:
            logger.error(f"Error calculating processing efficiency: {e}")
            return 0

    async def _calculate_waste_analytics(self, waste_records: List, processing_batches: List, outputs: List) -> Dict:
        """Calculate comprehensive waste analytics"""
        try:
            total_waste = sum(w.quantity_kg for w in waste_records)
            total_processed = sum(b.input_quantity for b in processing_batches if b.status == 'completed')
            total_output = sum(o.quantity for o in outputs)
            
            # Calculate diversion rate
            diversion_rate = (total_processed / total_waste * 100) if total_waste > 0 else 0
            
            # Calculate carbon reduction
            carbon_reduction = 0
            for output in outputs:
                if output.product_type in ['compost', 'biochar']:
                    carbon_reduction += output.quantity * 0.5
            
            # Calculate nutrient recycling rate
            nutrient_recycling_rate = (total_output / total_processed * 100) if total_processed > 0 else 0
            
            return {
                'carbon_reduction': carbon_reduction,
                'diversion_rate': round(diversion_rate, 2),
                'nutrient_recycling_rate': round(nutrient_recycling_rate, 2)
            }
            
        except Exception as e:
            logger.error(f"Error calculating waste analytics: {e}")
            return {}

    async def _group_waste_by_type(self, waste_records: List) -> Dict:
        """Group waste records by type"""
        try:
            grouped = {}
            for record in waste_records:
                if record.waste_type not in grouped:
                    grouped[record.waste_type] = 0
                grouped[record.waste_type] += record.quantity_kg
            return grouped
        except Exception as e:
            logger.error(f"Error grouping waste by type: {e}")
            return {}

    async def _group_waste_by_source(self, waste_records: List) -> Dict:
        """Group waste records by source"""
        try:
            grouped = {}
            for record in waste_records:
                if record.source_type not in grouped:
                    grouped[record.source_type] = 0
                grouped[record.source_type] += record.quantity_kg
            return grouped
        except Exception as e:
            logger.error(f"Error grouping waste by source: {e}")
            return {}

    async def _group_processing_by_method(self, processing_batches: List) -> Dict:
        """Group processing batches by method"""
        try:
            grouped = {}
            for batch in processing_batches:
                if batch.processing_method not in grouped:
                    grouped[batch.processing_method] = {'count': 0, 'total_input': 0}
                grouped[batch.processing_method]['count'] += 1
                grouped[batch.processing_method]['total_input'] += batch.input_quantity
            return grouped
        except Exception as e:
            logger.error(f"Error grouping processing by method: {e}")
            return {}

    async def _group_outputs_by_type(self, outputs: List) -> Dict:
        """Group outputs by product type"""
        try:
            grouped = {}
            for output in outputs:
                if output.product_type not in grouped:
                    grouped[output.product_type] = {'count': 0, 'total_quantity': 0}
                grouped[output.product_type]['count'] += 1
                grouped[output.product_type]['total_quantity'] += output.quantity
            return grouped
        except Exception as e:
            logger.error(f"Error grouping outputs by type: {e}")
            return {}

    async def _calculate_nutrient_recovery(self, outputs: List) -> Dict:
        """Calculate nutrient recovery from outputs"""
        try:
            nutrients = {'nitrogen': 0, 'phosphorus': 0, 'potassium': 0}
            
            for output in outputs:
                if output.nutrient_content:
                    try:
                        nutrient_data = json.loads(output.nutrient_content)
                        for nutrient in nutrients:
                            nutrients[nutrient] += nutrient_data.get(nutrient, 0) * output.quantity
                    except:
                        continue
            
            return nutrients
        except Exception as e:
            logger.error(f"Error calculating nutrient recovery: {e}")
            return {}

    async def _calculate_nutrient_efficiency(self, outputs: List) -> float:
        """Calculate nutrient recycling efficiency"""
        try:
            total_nutrients = 0
            for output in outputs:
                if output.nutrient_content:
                    try:
                        nutrient_data = json.loads(output.nutrient_content)
                        total_nutrients += sum(nutrient_data.values()) * output.quantity
                    except:
                        continue
            
            # Simplified efficiency calculation
            return round(total_nutrients / 1000, 2)  # Convert to kg
            
        except Exception as e:
            logger.error(f"Error calculating nutrient efficiency: {e}")
            return 0

    async def _generate_waste_recommendations(self, waste_records: List, processing_batches: List, outputs: List) -> List[str]:
        """Generate waste management recommendations"""
        try:
            recommendations = []
            
            # Waste generation recommendations
            if waste_records:
                avg_waste_per_day = sum(w.quantity_kg for w in waste_records) / 30
                if avg_waste_per_day > 500:
                    recommendations.append("Consider waste reduction strategies to lower daily generation")
            
            # Processing recommendations
            completed_batches = [b for b in processing_batches if b.status == 'completed']
            if completed_batches:
                avg_efficiency = sum(b.processing_efficiency or 0 for b in completed_batches) / len(completed_batches)
                if avg_efficiency < 70:
                    recommendations.append("Review processing parameters to improve efficiency")
            
            # Output utilization recommendations
            if outputs:
                unused_outputs = len([o for o in outputs if not o.intended_use])
                if unused_outputs > len(outputs) * 0.3:
                    recommendations.append("Develop markets for waste-derived products to improve circularity")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating waste recommendations: {e}")
            return []
