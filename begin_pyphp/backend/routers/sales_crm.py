"""
Sales CRM Router - Customer Relationship Management
Handles leads, customers, pipeline, and sales forecasting
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.sales_crm import SalesCRMService
from ..common.dependencies import get_tenant_id
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class CustomerCreate(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None
    company: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None

class CustomerUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    company: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None
    status: Optional[str] = None

class LeadCreate(BaseModel):
    customer_id: int
    source: str
    status: str = "new"
    value: Optional[float] = None
    expected_close_date: Optional[str] = None
    notes: Optional[str] = None

@router.get("/leads")
async def get_leads(
    lead_id: Optional[int] = None, 
    status: Optional[str] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get leads with dynamic scoring and recommendations"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_lead_scoring(lead_id, status, limit)

@router.post("/customers")
async def create_customer(
    customer_data: CustomerCreate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Create a new customer"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    result = service.create_customer(customer_data.dict())
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/customers")
async def get_customers(
    customer_id: Optional[int] = None,
    status: Optional[str] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get customers list"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_customers(customer_id, status, limit)

@router.put("/customers/{customer_id}")
async def update_customer(
    customer_id: int,
    customer_data: CustomerUpdate,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Update customer information"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    result = service.update_customer(customer_id, customer_data.dict(exclude_unset=True))
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.delete("/customers/{customer_id}")
async def delete_customer(
    customer_id: int,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Delete a customer"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    result = service.delete_customer(customer_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/forecast")
async def get_forecast(
    period_days: int = 90, 
    category: Optional[str] = None,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get sales pipeline forecast"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_pipeline_forecast(period_days, category)

@router.get("/pipeline")
async def get_pipeline(
    stage: Optional[str] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get sales pipeline by stages"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_pipeline_stages(stage, limit)

@router.get("/analytics")
async def get_analytics(
    period_days: int = 30,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get sales analytics and metrics"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_sales_analytics(period_days)

@router.post("/activities")
async def log_activity(
    activity_data: Dict[str, Any],
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Log customer activity"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    result = service.log_activity(activity_data)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.get("/activities")
async def get_activities(
    customer_id: Optional[int] = None,
    activity_type: Optional[str] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get customer activities"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_activities(customer_id, activity_type, limit)

@router.get("/dashboard")
async def get_crm_dashboard(
    db: Session = Depends(get_db),
    tenant_id: str = Depends(get_tenant_id)
):
    """Get CRM dashboard summary"""
    service = SalesCRMService(db, tenant_id=tenant_id)
    return service.get_dashboard_summary()
