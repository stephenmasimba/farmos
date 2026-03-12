from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.qr_inventory import QRInventoryService
from ..common.dependencies import get_tenant_id
from typing import Optional, List, Dict, Any

router = APIRouter()

@router.post("/generate/{item_type}/{item_id}")
async def generate_qr_code(
    item_type: str, 
    item_id: int, 
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Generate QR code for an item"""
    service = QRInventoryService(db, tenant_id=tenant_id)
    result = service.generate_qr_code(item_id, item_type)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.post("/scan")
async def scan_qr_code(
    scan_data: Dict[str, Any],
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Process a QR code scan"""
    service = QRInventoryService(db, tenant_id=tenant_id)
    qr_json_data = scan_data.get("qr_data")
    user_id = scan_data.get("user_id", 1)
    scan_type = scan_data.get("scan_type", "inventory_update")
    
    if not qr_json_data:
        raise HTTPException(status_code=400, detail="QR data is required")
        
    result = service.scan_qr_code(qr_json_data, user_id, scan_type)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/history")
async def get_scan_history(
    limit: int = 50,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get history of QR scans"""
    service = QRInventoryService(db, tenant_id=tenant_id)
    return service.get_scan_history(limit=limit)
