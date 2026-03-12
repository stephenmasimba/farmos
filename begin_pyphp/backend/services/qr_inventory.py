"""
QR Inventory Service - Enhanced Version
Handles QR code generation and mobile scanning logic
Aligned with Begin Reference System (Node.js)
"""

import logging
import json
import base64
import io
import qrcode
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..common import models

logger = logging.getLogger(__name__)

class QRInventoryService:
    """QR-based inventory and asset tracking"""
    
    def __init__(self, db: Session, tenant_id: str = "default"):
        self.db = db
        self.tenant_id = tenant_id

    def generate_qr_code(self, item_id: int, item_type: str = 'inventory', user_id: int = 1):
        """Generate QR code and save to database"""
        try:
            qr_data = {}
            
            if item_type == 'inventory':
                item = self.db.query(models.InventoryItem).filter(
                    models.InventoryItem.id == item_id,
                    models.InventoryItem.tenant_id == self.tenant_id
                ).first()
                if not item:
                    raise Exception("Inventory item not found")
                
                qr_data = {
                    "type": "inventory",
                    "id": item.id,
                    "name": item.name,
                    "category": item.category,
                    "timestamp": datetime.utcnow().isoformat()
                }
            elif item_type == 'equipment':
                equipment = self.db.query(models.Equipment).filter(
                    models.Equipment.id == item_id,
                    models.Equipment.tenant_id == self.tenant_id
                ).first()
                if not equipment:
                    raise Exception("Equipment not found")
                
                qr_data = {
                    "type": "equipment",
                    "id": equipment.id,
                    "name": equipment.name,
                    "location": equipment.location,
                    "timestamp": datetime.utcnow().isoformat()
                }
            elif item_type == 'livestock':
                batch = self.db.query(models.LivestockBatch).filter(
                    models.LivestockBatch.id == item_id,
                    models.LivestockBatch.tenant_id == self.tenant_id
                ).first()
                if not batch:
                    raise Exception("Livestock batch not found")
                
                qr_data = {
                    "type": "livestock",
                    "id": batch.id,
                    "name": batch.name,
                    "animal_type": batch.type,
                    "timestamp": datetime.utcnow().isoformat()
                }
            else:
                raise Exception("Invalid item type")

            # Generate QR Image
            qr = qrcode.QRCode(
                version=1,
                error_correction=qrcode.constants.ERROR_CORRECT_H,
                box_size=10,
                border=4,
            )
            qr.add_data(json.dumps(qr_data))
            qr.make(fit=True)

            img = qr.make_image(fill_color="black", back_color="white")
            
            # Convert to base64
            buffered = io.BytesIO()
            img.save(buffered, format="PNG")
            img_str = base64.b64encode(buffered.getvalue()).decode()
            data_url = f"data:image/png;base64,{img_str}"

            # Save to database
            qr_entry = models.QRInventoryItem(
                tenant_id=self.tenant_id,
                item_id=item_id,
                item_type=item_type,
                qr_data=json.dumps(qr_data),
                qr_image_url=data_url,
                generated_by=user_id
            )
            self.db.add(qr_entry)
            self.db.commit()

            return {
                "success": True,
                "qr_code_url": data_url,
                "qr_data": qr_data,
                "item_type": item_type
            }

        except Exception as e:
            logger.error(f"Error generating QR code: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def scan_qr_code(self, qr_json_data: str, user_id: int, scan_type: str = 'inventory_update'):
        """Process a QR code scan"""
        try:
            parsed_data = json.loads(qr_json_data)
            
            # Log the scan
            scan_log = models.QRScan(
                tenant_id=self.tenant_id,
                item_id=parsed_data.get('id'),
                item_type=parsed_data.get('type', 'unknown'),
                scan_type=scan_type,
                scanned_by=user_id,
                scan_data=qr_json_data,
                scan_timestamp=datetime.utcnow()
            )
            self.db.add(scan_log)
            self.db.commit()
            self.db.refresh(scan_log)

            # Process based on type
            result = {"success": True, "scan_id": scan_log.id, "item_type": parsed_data.get('type')}
            
            if parsed_data.get('type') == 'inventory':
                item = self.db.query(models.InventoryItem).filter(
                    models.InventoryItem.id == parsed_data.get('id'),
                    models.InventoryItem.tenant_id == self.tenant_id
                ).first()
                if item:
                    result["item_data"] = {
                        "id": item.id,
                        "name": item.name,
                        "quantity": item.quantity,
                        "unit": item.unit,
                        "category": item.category
                    }
                    result["action_required"] = "update_inventory"
            
            elif parsed_data.get('type') == 'equipment':
                equipment = self.db.query(models.Equipment).filter(
                    models.Equipment.id == parsed_data.get('id'),
                    models.Equipment.tenant_id == self.tenant_id
                ).first()
                if equipment:
                    result["equipment_data"] = {
                        "id": equipment.id,
                        "name": equipment.name,
                        "status": equipment.status,
                        "location": equipment.location
                    }
                    result["action_required"] = "equipment_check"

            return result

        except Exception as e:
            logger.error(f"Error processing QR scan: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_scan_history(self, limit: int = 50):
        """Get recent scan history for the tenant"""
        scans = self.db.query(models.QRScan).filter(
            models.QRScan.tenant_id == self.tenant_id
        ).order_by(desc(models.QRScan.scan_timestamp)).limit(limit).all()
        
        return [
            {
                "id": s.id,
                "item_id": s.item_id,
                "item_type": s.item_type,
                "scan_type": s.scan_type,
                "timestamp": s.scan_timestamp.isoformat(),
                "user_id": s.scanned_by
            } for s in scans
        ]
