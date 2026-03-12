from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Body
from sqlalchemy.orm import Session
from typing import Dict
import csv
import io

from ..common.database import get_db
from ..common import models
from .auth import get_current_user

router = APIRouter(tags=["Import"])

SUPPORTED_TYPES = {"livestock", "inventory"}

@router.get("/{type}/template")
async def get_template(type: str, current_user: Dict = Depends(get_current_user)):
    if type not in SUPPORTED_TYPES:
        raise HTTPException(status_code=400, detail="Invalid template type")
    if type == "livestock":
        content = "type,breed,quantity,location,status,batch_name,start_date,notes\nCattle,Brahman,10,Pasture A,active,Batch A,2025-06-01,Imported"
    else:
        content = "name,category,quantity,unit,low_stock_threshold,location,qr_code\nBroiler Starter,Feed,500,kg,100,Feed Store,BR-START-001"
    return content

@router.post("/{type}")
async def import_data(
    type: str,
    file: UploadFile = File(None),
    data: dict = Body(None),
    current_user: Dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if type not in SUPPORTED_TYPES:
        raise HTTPException(status_code=400, detail=f"Import type '{type}' not supported")
    reader = None
    if file:
        if not file.filename.lower().endswith(".csv"):
            raise HTTPException(status_code=400, detail="Only CSV files are supported")
        content = await file.read()
        text = content.decode("utf-8", errors="ignore")
        reader = csv.DictReader(io.StringIO(text))
    elif data and isinstance(data, dict) and "rows" in data and isinstance(data["rows"], list):
        # Accept JSON body: { rows: [ { ... }, ... ] }
        reader = data["rows"]
    else:
        raise HTTPException(status_code=400, detail="Provide a CSV file or JSON body with 'rows'")

    result = {"success": 0, "failed": 0, "errors": []}
    tenant_id = str(current_user.get("tenant_id", "default")) if isinstance(current_user, dict) else "default"

    if type == "livestock":
        required = ["type", "breed", "quantity", "location"]
        rows = reader if isinstance(reader, list) else list(reader)
        for idx, row in enumerate(rows, start=1):
            try:
                for r in required:
                    if not row.get(r):
                        raise ValueError(f"Missing required field '{r}'")
                name = row.get("batch_name") or f"{row['type']}_{idx}"
                status = row.get("status") or "active"
                start_date = row.get("start_date") or ""
                rec = models.LivestockBatch(
                    tenant_id=tenant_id,
                    type=row["type"],
                    name=name,
                    breed=row.get("breed"),
                    location=row.get("location"),
                    quantity=int(float(row.get("quantity", "0"))),
                    count=int(float(row.get("quantity", "0"))),
                    status=status,
                    start_date=start_date,
                )
                db.add(rec)
                db.commit()
                result["success"] += 1
            except Exception as e:
                db.rollback()
                result["failed"] += 1
                result["errors"].append(f"Row {idx}: {str(e)}")
    else:
        required = ["name", "category", "quantity", "unit"]
        rows = reader if isinstance(reader, list) else list(reader)
        for idx, row in enumerate(rows, start=1):
            try:
                for r in required:
                    if not row.get(r):
                        raise ValueError(f"Missing required field '{r}'")
                qr_code = row.get("qr_code")
                rec = models.InventoryItem(
                    tenant_id=tenant_id,
                    name=row["name"],
                    category=row["category"],
                    quantity=float(row["quantity"]),
                    unit=row["unit"],
                    location=row.get("location") or "General Storage",
                    low_stock_threshold=float(row.get("low_stock_threshold") or 10.0),
                    qr_code=qr_code if qr_code else None,
                )
                db.add(rec)
                db.commit()
                result["success"] += 1
            except Exception as e:
                db.rollback()
                result["failed"] += 1
                result["errors"].append(f"Row {idx}: {str(e)}")

    return {"status": "success", "data": result}
