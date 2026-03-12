"""
QR Traceability System - Phase 4 Feature
Comprehensive product traceability with QR codes and blockchain-like tracking
Derived from Begin Reference System
"""

import logging
import asyncio
import qrcode
import io
import base64
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
import hashlib
from decimal import Decimal

logger = logging.getLogger(__name__)

from ..common import models

class QRTraceabilityService:
    """Advanced QR code-based product traceability system"""
    
    def __init__(self, db: Session):
        self.db = db
        self.traceability_stages = [
            'planting', 'growing', 'harvesting', 'processing', 
            'packaging', 'storage', 'distribution', 'retail'
        ]

    async def generate_batch_qr_code(self, batch_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Generate QR code for product batch"""
        try:
            # Generate unique batch ID
            batch_id = await self._generate_batch_id(tenant_id)
            
            # Create traceability record
            traceability = models.ProductTraceability(
                batch_id=batch_id,
                product_type=batch_data['product_type'],
                product_name=batch_data['product_name'],
                variety=batch_data.get('variety'),
                origin_field_id=batch_data.get('field_id'),
                origin_location=batch_data.get('origin_location'),
                planting_date=datetime.strptime(batch_data['planting_date'], '%Y-%m-%d').date() if isinstance(batch_data.get('planting_date'), str) else batch_data.get('planting_date'),
                expected_harvest_date=datetime.strptime(batch_data['expected_harvest_date'], '%Y-%m-%d').date() if isinstance(batch_data.get('expected_harvest_date'), str) else batch_data.get('expected_harvest_date'),
                initial_quantity=batch_data.get('initial_quantity'),
                unit_of_measure=batch_data.get('unit_of_measure', 'kg'),
                certification_details=json.dumps(batch_data.get('certifications', [])),
                farming_practices=json.dumps(batch_data.get('farming_practices', {})),
                current_stage='planting',
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            
            self.db.add(traceability)
            self.db.flush()
            
            # Generate QR code data
            qr_data = await self._create_qr_data(batch_id, traceability, tenant_id)
            
            # Generate QR code image
            qr_image = await self._generate_qr_code_image(qr_data)
            
            # Create QR code record
            qr_record = models.QRCode(
                batch_id=batch_id,
                qr_data=qr_data,
                qr_image_base64=qr_image,
                qr_url=f"https://farmos.example.com/trace/{batch_id}",
                generated_at=datetime.utcnow(),
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(qr_record)
            self.db.commit()
            
            return {
                "success": True,
                "batch_id": batch_id,
                "qr_code": qr_image,
                "qr_url": qr_record.qr_url,
                "traceability_id": traceability.id,
                "message": "QR code generated successfully"
            }
            
        except Exception as e:
            logger.error(f"Error generating batch QR code: {e}")
            self.db.rollback()
            return {"error": "QR code generation failed"}

    async def update_traceability_stage(self, batch_id: str, stage_data: Dict[str, Any], 
                                     tenant_id: str = "default") -> Dict[str, Any]:
        """Update product traceability at different stages"""
        try:
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Batch not found"}
            
            new_stage = stage_data['stage']
            if new_stage not in self.traceability_stages:
                return {"error": f"Invalid stage: {new_stage}"}
            
            # Create stage history record
            stage_history = models.TraceabilityStageHistory(
                batch_id=batch_id,
                stage=new_stage,
                stage_date=datetime.strptime(stage_data['stage_date'], '%Y-%m-%d').date() if isinstance(stage_data.get('stage_date'), str) else datetime.utcnow().date(),
                location=stage_data.get('location'),
                temperature=stage_data.get('temperature'),
                humidity=stage_data.get('humidity'),
                operator_id=stage_data.get('operator_id'),
                equipment_used=stage_data.get('equipment_used'),
                quality_checks=json.dumps(stage_data.get('quality_checks', {})),
                measurements=json.dumps(stage_data.get('measurements', {})),
                notes=stage_data.get('notes'),
                photos=json.dumps(stage_data.get('photos', [])),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(stage_history)
            
            # Update current stage
            traceability.current_stage = new_stage
            traceability.updated_at = datetime.utcnow()
            
            # Update stage-specific data
            if new_stage == 'harvesting':
                traceability.actual_harvest_date = stage_data.get('stage_date', datetime.utcnow().date())
                traceability.harvest_quantity = stage_data.get('harvest_quantity')
                traceability.quality_grade = stage_data.get('quality_grade')
            elif new_stage == 'processing':
                traceability.processing_date = stage_data.get('stage_date', datetime.utcnow().date())
                traceability.processing_method = stage_data.get('processing_method')
            elif new_stage == 'packaging':
                traceability.packaging_date = stage_data.get('stage_date', datetime.utcnow().date())
                traceability.package_type = stage_data.get('package_type')
                traceability.package_size = stage_data.get('package_size')
            elif new_stage == 'distribution':
                traceability.distribution_date = stage_data.get('stage_date', datetime.utcnow().date())
                traceability.distributor = stage_data.get('distributor')
                traceability.transport_method = stage_data.get('transport_method')
            
            # Generate blockchain hash for this stage
            stage_hash = await self._generate_stage_hash(batch_id, new_stage, stage_data)
            stage_history.blockchain_hash = stage_hash
            
            self.db.commit()
            
            # Update QR code with new information
            await self._update_qr_code(batch_id, tenant_id)
            
            return {
                "success": True,
                "batch_id": batch_id,
                "new_stage": new_stage,
                "stage_hash": stage_hash,
                "message": "Traceability stage updated successfully"
            }
            
        except Exception as e:
            logger.error(f"Error updating traceability stage: {e}")
            self.db.rollback()
            return {"error": "Stage update failed"}

    async def create_product_unit_qr(self, batch_id: str, unit_data: Dict[str, Any], 
                                  tenant_id: str = "default") -> Dict[str, Any]:
        """Create individual unit QR codes from batch"""
        try:
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Batch not found"}
            
            unit_count = unit_data.get('unit_count', 1)
            created_units = []
            
            for i in range(unit_count):
                # Generate unique unit ID
                unit_id = await self._generate_unit_id(batch_id, i + 1, tenant_id)
                
                # Create unit record
                unit = models.ProductUnit(
                    unit_id=unit_id,
                    batch_id=batch_id,
                    unit_number=i + 1,
                    weight=unit_data.get('weight'),
                    best_before_date=datetime.strptime(unit_data['best_before_date'], '%Y-%m-%d').date() if isinstance(unit_data.get('best_before_date'), str) else unit_data.get('best_before_date'),
                    packaging_date=datetime.strptime(unit_data['packaging_date'], '%Y-%m-%d').date() if isinstance(unit_data.get('packaging_date'), str) else unit_data.get('packaging_date'),
                    quality_grade=unit_data.get('quality_grade', 'standard'),
                    storage_conditions=json.dumps(unit_data.get('storage_conditions', {})),
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(unit)
                self.db.flush()
                
                # Generate unit QR code
                unit_qr_data = await self._create_unit_qr_data(unit_id, unit, traceability, tenant_id)
                unit_qr_image = await self._generate_qr_code_image(unit_qr_data)
                
                unit_qr = models.UnitQRCode(
                    unit_id=unit_id,
                    qr_data=unit_qr_data,
                    qr_image_base64=unit_qr_image,
                    qr_url=f"https://farmos.example.com/unit/{unit_id}",
                    generated_at=datetime.utcnow(),
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(unit_qr)
                
                created_units.append({
                    "unit_id": unit_id,
                    "unit_number": i + 1,
                    "qr_code": unit_qr_image,
                    "qr_url": unit_qr.qr_url
                })
            
            self.db.commit()
            
            return {
                "success": True,
                "batch_id": batch_id,
                "units_created": len(created_units),
                "units": created_units,
                "message": f"Created {len(created_units)} unit QR codes successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating product unit QR codes: {e}")
            self.db.rollback()
            return {"error": "Unit QR creation failed"}

    async def trace_product(self, identifier: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Trace product by batch ID or unit ID"""
        try:
            # Determine if it's a batch or unit
            is_unit = len(identifier.split('-')) > 2  # Unit IDs have more segments
            
            if is_unit:
                return await self._trace_unit(identifier, tenant_id)
            else:
                return await self._trace_batch(identifier, tenant_id)
                
        except Exception as e:
            logger.error(f"Error tracing product: {e}")
            return {"error": "Product trace failed"}

    async def verify_authenticity(self, identifier: str, verification_data: Dict[str, Any], 
                                tenant_id: str = "default") -> Dict[str, Any]:
        """Verify product authenticity using blockchain hashes"""
        try:
            # Get traceability record
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == identifier,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Product not found"}
            
            # Get stage history
            stage_history = self.db.query(models.TraceabilityStageHistory).filter(
                and_(
                    models.TraceabilityStageHistory.batch_id == identifier,
                    models.TraceabilityStageHistory.tenant_id == tenant_id
                )
            ).order_by(models.TraceabilityStageHistory.created_at).all()
            
            # Verify blockchain hashes
            verification_results = []
            is_authentic = True
            
            for stage in stage_history:
                if stage.blockchain_hash:
                    # Recalculate hash and compare
                    expected_hash = await self._recalculate_stage_hash(identifier, stage.stage, stage)
                    
                    if expected_hash == stage.blockchain_hash:
                        verification_results.append({
                            "stage": stage.stage,
                            "status": "verified",
                            "hash": stage.blockchain_hash
                        })
                    else:
                        verification_results.append({
                            "stage": stage.stage,
                            "status": "tampered",
                            "expected_hash": expected_hash,
                            "recorded_hash": stage.blockchain_hash
                        })
                        is_authentic = False
                else:
                    verification_results.append({
                        "stage": stage.stage,
                        "status": "no_hash",
                        "message": "No blockchain hash available for this stage"
                    })
            
            # Create verification record
            verification = models.AuthenticityVerification(
                identifier=identifier,
                verification_type='blockchain',
                verification_result='authentic' if is_authentic else 'tampered',
                verification_details=json.dumps(verification_results),
                verified_by=verification_data.get('verified_by'),
                verification_location=verification_data.get('verification_location'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(verification)
            self.db.commit()
            
            return {
                "success": True,
                "identifier": identifier,
                "is_authentic": is_authentic,
                "verification_results": verification_results,
                "verification_id": verification.id,
                "verified_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error verifying authenticity: {e}")
            return {"error": "Authenticity verification failed"}

    async def get_traceability_report(self, batch_id: str, report_type: str = "full", 
                                    tenant_id: str = "default") -> Dict[str, Any]:
        """Generate comprehensive traceability report"""
        try:
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Batch not found"}
            
            # Get stage history
            stage_history = self.db.query(models.TraceabilityStageHistory).filter(
                and_(
                    models.TraceabilityStageHistory.batch_id == batch_id,
                    models.TraceabilityStageHistory.tenant_id == tenant_id
                )
            ).order_by(models.TraceabilityStageHistory.created_at).all()
            
            # Get units if available
            units = self.db.query(models.ProductUnit).filter(
                and_(
                    models.ProductUnit.batch_id == batch_id,
                    models.ProductUnit.tenant_id == tenant_id
                )
            ).all()
            
            # Get quality certifications
            certifications = json.loads(traceability.certification_details) if traceability.certification_details else []
            
            # Generate report based on type
            if report_type == "full":
                report_data = await self._generate_full_report(traceability, stage_history, units, certifications)
            elif report_type == "consumer":
                report_data = await self._generate_consumer_report(traceability, stage_history)
            elif report_type == "regulatory":
                report_data = await self._generate_regulatory_report(traceability, stage_history, units)
            else:
                return {"error": f"Unknown report type: {report_type}"}
            
            # Save report record
            report = models.TraceabilityReport(
                batch_id=batch_id,
                report_type=report_type,
                report_data=json.dumps(report_data),
                generated_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(report)
            self.db.commit()
            
            return {
                "success": True,
                "batch_id": batch_id,
                "report_type": report_type,
                "report_data": report_data,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error generating traceability report: {e}")
            return {"error": "Report generation failed"}

    async def recall_product(self, recall_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Initiate product recall with traceability tracking"""
        try:
            batch_id = recall_data['batch_id']
            recall_reason = recall_data['recall_reason']
            recall_severity = recall_data.get('severity', 'medium')
            
            # Verify batch exists
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Batch not found"}
            
            # Create recall record
            recall = models.ProductRecall(
                batch_id=batch_id,
                recall_reason=recall_reason,
                recall_severity=recall_severity,
                recall_date=datetime.utcnow().date(),
                recall_status='initiated',
                affected_units=recall_data.get('affected_units', 'all'),
                distribution_channels=json.dumps(recall_data.get('distribution_channels', [])),
                customer_notifications=json.dumps(recall_data.get('customer_notifications', [])),
                recall_instructions=recall_data.get('recall_instructions'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(recall)
            self.db.flush()
            
            # Get all units in batch
            units = self.db.query(models.ProductUnit).filter(
                and_(
                    models.ProductUnit.batch_id == batch_id,
                    models.ProductUnit.tenant_id == tenant_id
                )
            ).all()
            
            # Update unit statuses
            affected_count = 0
            for unit in units:
                unit.status = 'recalled'
                affected_count += 1
            
            # Update batch status
            traceability.status = 'recalled'
            
            # Track recall chain
            await self._track_recall_chain(batch_id, recall_data, tenant_id)
            
            self.db.commit()
            
            return {
                "success": True,
                "recall_id": recall.id,
                "batch_id": batch_id,
                "affected_units": affected_count,
                "recall_status": "initiated",
                "message": f"Product recall initiated for batch {batch_id}"
            }
            
        except Exception as e:
            logger.error(f"Error initiating product recall: {e}")
            self.db.rollback()
            return {"error": "Recall initiation failed"}

    # Helper methods
    async def _generate_batch_id(self, tenant_id: str) -> str:
        """Generate unique batch ID"""
        try:
            count = self.db.query(models.ProductTraceability).filter(models.ProductTraceability.tenant_id == tenant_id).count()
            timestamp = datetime.utcnow().strftime('%Y%m%d')
            return f"BATCH-{tenant_id.upper()}-{timestamp}-{count + 1:04d}"
        except:
            return f"BATCH-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    async def _generate_unit_id(self, batch_id: str, unit_number: int, tenant_id: str) -> str:
        """Generate unique unit ID"""
        return f"{batch_id}-UNIT-{unit_number:04d}"

    async def _create_qr_data(self, batch_id: str, traceability: models.ProductTraceability, tenant_id: str) -> str:
        """Create QR code data"""
        qr_data = {
            "type": "product_traceability",
            "batch_id": batch_id,
            "product_type": traceability.product_type,
            "product_name": traceability.product_name,
            "origin": traceability.origin_location,
            "planting_date": traceability.planting_date.strftime('%Y-%m-%d') if traceability.planting_date else None,
            "verification_url": f"https://farmos.example.com/trace/{batch_id}",
            "generated_at": datetime.utcnow().isoformat()
        }
        return json.dumps(qr_data)

    async def _create_unit_qr_data(self, unit_id: str, unit: models.ProductUnit, 
                                 traceability: models.ProductTraceability, tenant_id: str) -> str:
        """Create unit QR code data"""
        qr_data = {
            "type": "product_unit",
            "unit_id": unit_id,
            "batch_id": traceability.batch_id,
            "product_name": traceability.product_name,
            "weight": unit.weight,
            "best_before": unit.best_before_date.strftime('%Y-%m-%d') if unit.best_before_date else None,
            "quality_grade": unit.quality_grade,
            "verification_url": f"https://farmos.example.com/unit/{unit_id}",
            "generated_at": datetime.utcnow().isoformat()
        }
        return json.dumps(qr_data)

    async def _generate_qr_code_image(self, qr_data: str) -> str:
        """Generate QR code image as base64"""
        try:
            qr = qrcode.QRCode(
                version=1,
                error_correction=qrcode.constants.ERROR_CORRECT_L,
                box_size=10,
                border=4,
            )
            qr.add_data(qr_data)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            
            # Convert to base64
            buffer = io.BytesIO()
            img.save(buffer, format='PNG')
            img_str = base64.b64encode(buffer.getvalue()).decode()
            
            return img_str
            
        except Exception as e:
            logger.error(f"Error generating QR code image: {e}")
            return ""

    async def _generate_stage_hash(self, batch_id: str, stage: str, stage_data: Dict[str, Any]) -> str:
        """Generate blockchain hash for stage"""
        try:
            # Create hash string
            hash_string = f"{batch_id}-{stage}-{datetime.utcnow().isoformat()}-{json.dumps(stage_data, sort_keys=True)}"
            
            # Generate SHA-256 hash
            hash_object = hashlib.sha256(hash_string.encode())
            return hash_object.hexdigest()
            
        except Exception as e:
            logger.error(f"Error generating stage hash: {e}")
            return ""

    async def _recalculate_stage_hash(self, batch_id: str, stage: str, stage_record: models.TraceabilityStageHistory) -> str:
        """Recalculate stage hash for verification"""
        try:
            # Recreate hash string from stored data
            hash_data = {
                "stage": stage,
                "stage_date": stage_record.stage_date.strftime('%Y-%m-%d') if stage_record.stage_date else None,
                "location": stage_record.location,
                "temperature": stage_record.temperature,
                "humidity": stage_record.humidity,
                "measurements": json.loads(stage_record.measurements) if stage_record.measurements else {}
            }
            
            hash_string = f"{batch_id}-{stage}-{stage_record.created_at.isoformat()}-{json.dumps(hash_data, sort_keys=True)}"
            
            # Generate SHA-256 hash
            hash_object = hashlib.sha256(hash_string.encode())
            return hash_object.hexdigest()
            
        except Exception as e:
            logger.error(f"Error recalculating stage hash: {e}")
            return ""

    async def _update_qr_code(self, batch_id: str, tenant_id: str):
        """Update QR code with new information"""
        try:
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if traceability:
                qr_record = self.db.query(models.QRCode).filter(
                    and_(
                        models.QRCode.batch_id == batch_id,
                        models.QRCode.tenant_id == tenant_id
                    )
                ).first()
                
                if qr_record:
                    # Update QR data with current information
                    new_qr_data = await self._create_qr_data(batch_id, traceability, tenant_id)
                    qr_record.qr_data = new_qr_data
                    qr_record.updated_at = datetime.utcnow()
                    self.db.commit()
                    
        except Exception as e:
            logger.error(f"Error updating QR code: {e}")

    async def _trace_batch(self, batch_id: str, tenant_id: str) -> Dict[str, Any]:
        """Trace product by batch ID"""
        try:
            traceability = self.db.query(models.ProductTraceability).filter(
                and_(
                    models.ProductTraceability.batch_id == batch_id,
                    models.ProductTraceability.tenant_id == tenant_id
                )
            ).first()
            
            if not traceability:
                return {"error": "Batch not found"}
            
            # Get stage history
            stage_history = self.db.query(models.TraceabilityStageHistory).filter(
                and_(
                    models.TraceabilityStageHistory.batch_id == batch_id,
                    models.TraceabilityStageHistory.tenant_id == tenant_id
                )
            ).order_by(models.TraceabilityStageHistory.created_at).all()
            
            # Get units
            units = self.db.query(models.ProductUnit).filter(
                and_(
                    models.ProductUnit.batch_id == batch_id,
                    models.ProductUnit.tenant_id == tenant_id
                )
            ).all()
            
            return {
                "trace_type": "batch",
                "batch_info": {
                    "batch_id": batch_id,
                    "product_type": traceability.product_type,
                    "product_name": traceability.product_name,
                    "origin": traceability.origin_location,
                    "current_stage": traceability.current_stage,
                    "status": traceability.status
                },
                "stage_history": [
                    {
                        "stage": stage.stage,
                        "date": stage.stage_date.strftime('%Y-%m-%d') if stage.stage_date else None,
                        "location": stage.location,
                        "measurements": json.loads(stage.measurements) if stage.measurements else {}
                    }
                    for stage in stage_history
                ],
                "units": [
                    {
                        "unit_id": unit.unit_id,
                        "unit_number": unit.unit_number,
                        "weight": unit.weight,
                        "status": unit.status
                    }
                    for unit in units
                ]
            }
            
        except Exception as e:
            logger.error(f"Error tracing batch: {e}")
            return {"error": "Batch trace failed"}

    async def _trace_unit(self, unit_id: str, tenant_id: str) -> Dict[str, Any]:
        """Trace product by unit ID"""
        try:
            unit = self.db.query(models.ProductUnit).filter(
                and_(
                    models.ProductUnit.unit_id == unit_id,
                    models.ProductUnit.tenant_id == tenant_id
                )
            ).first()
            
            if not unit:
                return {"error": "Unit not found"}
            
            # Get batch information
            batch_info = await self._trace_batch(unit.batch_id, tenant_id)
            
            return {
                "trace_type": "unit",
                "unit_info": {
                    "unit_id": unit_id,
                    "unit_number": unit.unit_number,
                    "weight": unit.weight,
                    "best_before_date": unit.best_before_date.strftime('%Y-%m-%d') if unit.best_before_date else None,
                    "quality_grade": unit.quality_grade,
                    "status": unit.status
                },
                "batch_info": batch_info
            }
            
        except Exception as e:
            logger.error(f"Error tracing unit: {e}")
            return {"error": "Unit trace failed"}

    async def _generate_full_report(self, traceability: models.ProductTraceability, 
                                 stage_history: List, units: List, certifications: List) -> Dict:
        """Generate full traceability report"""
        return {
            "report_type": "full",
            "product_info": {
                "batch_id": traceability.batch_id,
                "product_type": traceability.product_type,
                "product_name": traceability.product_name,
                "variety": traceability.variety,
                "origin": traceability.origin_location
            },
            "certifications": certifications,
            "farming_practices": json.loads(traceability.farming_practices) if traceability.farming_practices else {},
            "stage_history": [
                {
                    "stage": stage.stage,
                    "date": stage.stage_date.strftime('%Y-%m-%d') if stage.stage_date else None,
                    "location": stage.location,
                    "operator": stage.operator_id,
                    "quality_checks": json.loads(stage.quality_checks) if stage.quality_checks else {}
                }
                for stage in stage_history
            ],
            "units_summary": {
                "total_units": len(units),
                "active_units": len([u for u in units if u.status == 'active']),
                "recalled_units": len([u for u in units if u.status == 'recalled'])
            }
        }

    async def _generate_consumer_report(self, traceability: models.ProductTraceability, 
                                      stage_history: List) -> Dict:
        """Generate consumer-friendly traceability report"""
        return {
            "report_type": "consumer",
            "product_name": traceability.product_name,
            "origin": traceability.origin_location,
            "planting_date": traceability.planting_date.strftime('%Y-%m-%d') if traceability.planting_date else None,
            "harvest_date": traceability.actual_harvest_date.strftime('%Y-%m-%d') if traceability.actual_harvest_date else None,
            "quality_grade": traceability.quality_grade,
            "journey": [
                {
                    "stage": stage.stage.replace('_', ' ').title(),
                    "date": stage.stage_date.strftime('%Y-%m-%d') if stage.stage_date else None,
                    "location": stage.location
                }
                for stage in stage_history
            ]
        }

    async def _generate_regulatory_report(self, traceability: models.ProductTraceability, 
                                        stage_history: List, units: List) -> Dict:
        """Generate regulatory compliance report"""
        return {
            "report_type": "regulatory",
            "compliance_data": {
                "batch_id": traceability.batch_id,
                "product_type": traceability.product_type,
                "origin_field_id": traceability.origin_field_id,
                "certifications": json.loads(traceability.certification_details) if traceability.certification_details else [],
                "farming_practices": json.loads(traceability.farming_practices) if traceability.farming_practices else {}
            },
            "chain_of_custody": [
                {
                    "stage": stage.stage,
                    "date": stage.stage_date.strftime('%Y-%m-%d') if stage.stage_date else None,
                    "location": stage.location,
                    "operator_id": stage.operator_id,
                    "blockchain_hash": stage.blockchain_hash
                }
                for stage in stage_history
            ],
            "unit_distribution": {
                "total_units": len(units),
                "status_breakdown": {
                    status: len([u for u in units if u.status == status])
                    for status in set(u.status for u in units)
                }
            }
        }

    async def _track_recall_chain(self, batch_id: str, recall_data: Dict[str, Any], tenant_id: str):
        """Track recall distribution chain"""
        try:
            # This would integrate with distribution system to track where products were sent
            # For now, create a basic tracking record
            tracking = models.RecallTracking(
                batch_id=batch_id,
                distribution_stage='initiated',
                tracking_data=json.dumps(recall_data),
                tracked_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(tracking)
            
        except Exception as e:
            logger.error(f"Error tracking recall chain: {e}")
