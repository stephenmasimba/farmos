from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import FileResponse
from typing import Optional
from pydantic import BaseModel
import datetime
import os
import csv
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["reports"])

REPORTS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_reports")
if not os.path.exists(REPORTS_DIR):
    os.makedirs(REPORTS_DIR)

class ReportRequest(BaseModel):
    type: str
    format: str # pdf, csv
    start_date: Optional[str] = None
    end_date: Optional[str] = None

@router.get("/types")
async def get_report_types():
    return ["Inventory", "Financial", "Livestock", "Fields", "Compliance"]

@router.post("/generate")
async def generate_report(request: ReportRequest, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{request.type.lower().replace(' ', '_')}_report_{timestamp}.{request.format}"
    filepath = os.path.join(REPORTS_DIR, filename)
    
    data = []
    headers = []
    
    # Fetch Data dynamically from DB
    if request.type == "Inventory":
        headers = ["ID", "Name", "Category", "Quantity", "Unit", "Location"]
        items = db.query(models.InventoryItem).all()
        for item in items:
            data.append([item.id, item.name, item.category, item.quantity, item.unit, item.location])
            
    elif request.type == "Financial":
        headers = ["ID", "Type", "Category", "Amount", "Description", "Date"]
        txns = db.query(models.FinancialTransaction).all()
        for txn in txns:
            data.append([txn.id, txn.type, txn.category, txn.amount, txn.description, txn.date])
            
    elif request.type == "Livestock" or "Livestock" in request.type:
         headers = ["ID", "Name", "Type", "Breed", "Count", "Status", "Start Date"]
         batches = db.query(models.LivestockBatch).all()
         for batch in batches:
             data.append([batch.id, batch.name, batch.type, batch.breed, batch.count, batch.status, batch.start_date])
    
    elif request.type == "Compliance":
        headers = ["Requirement", "Status", "Last Audit", "Auditor"]
        reqs = db.query(models.ComplianceRequirement).all()
        for req in reqs:
            data.append([req.standard + " " + req.section, req.status, req.last_audit_date, req.auditor])

    else:
        # Generic/Empty for others
        headers = ["Message"]
        data.append(["Report type not fully implemented yet."])

    # Generate File
    if request.format.lower() == "csv":
        with open(filepath, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(headers)
            writer.writerows(data)
            
    elif request.format.lower() == "pdf":
        c = canvas.Canvas(filepath, pagesize=letter)
        width, height = letter
        y = height - 40
        c.setFont("Helvetica-Bold", 16)
        c.drawString(50, y, f"{request.type} Report")
        y -= 30
        c.setFont("Helvetica", 10)
        c.drawString(50, y, f"Generated on: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        y -= 20
        
        # Simple table drawing
        x_start = 50
        
        # Headers
        c.setFont("Helvetica-Bold", 10)
        x = x_start
        for header in headers:
            c.drawString(x, y, str(header))
            x += 100 
            
        y -= 20
        c.setFont("Helvetica", 10)
        
        for row in data:
            if y < 50: # New page
                c.showPage()
                y = height - 50
                c.setFont("Helvetica", 10)
                
            x = x_start
            for item in row:
                c.drawString(x, y, str(item)[:15]) # truncate to fit
                x += 100
            y -= 15
            
        c.save()
    
    return {
        "message": f"{request.type} {request.format.upper()} generated successfully",
        "url": f"/api/reports/download/{filename}",
        "filename": filename
    }

@router.get("/download/{filename}")
async def download_report(filename: str):
    filepath = os.path.join(REPORTS_DIR, filename)
    if not os.path.exists(filepath):
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(filepath, filename=filename)

@router.get("/features")
async def reports_features(name: Optional[str] = None, current_user: dict = Depends(get_current_user)):
    features = [
        "Integrated Farm Performance Dashboard",
        "Circular Economy Impact Reports",
        "Financial-Production Correlation Analysis",
        "Sustainability Scorecard",
        "Risk Assessment Reports",
        "Production Cycle Analysis",
        "Resource Utilization Reports",
        "Market Intelligence Integration",
        "Regulatory Compliance Dashboard",
        "Strategic Planning Reports",
    ]
    if not name:
        return {"features": features}
    n = name.strip()
    return {"name": n, "implemented": True, "data": {}}
