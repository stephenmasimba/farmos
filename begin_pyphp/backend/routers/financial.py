from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import date
from sqlalchemy.orm import Session
from sqlalchemy import func
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["financial"])

# --- Models ---

class FinancialTransactionBase(BaseModel):
    type: str = Field(..., pattern="^(income|expense)$", description="income or expense")
    category: str = Field(..., min_length=1)
    amount: float = Field(..., gt=0)
    description: str
    date: str # Changed to str

class FinancialTransactionCreate(FinancialTransactionBase):
    pass

class FinancialTransactionUpdate(BaseModel):
    type: Optional[str] = Field(None, pattern="^(income|expense)$")
    category: Optional[str] = None
    amount: Optional[float] = Field(None, gt=0)
    description: Optional[str] = None
    date: Optional[str] = None

class FinancialTransaction(FinancialTransactionBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

class FinancialSummary(BaseModel):
    total_income: float
    total_expense: float
    net_profit: float

class BudgetBase(BaseModel):
    category: str = Field(..., min_length=1)
    limit: float = Field(..., gt=0)
    period: str = Field(..., pattern="^(monthly|yearly)$")
    year: int

class BudgetCreate(BudgetBase):
    pass

class Budget(BudgetBase):
    id: int
    tenant_id: str
    spent: float = 0.0

    class Config:
        from_attributes = True

class InvoiceBase(BaseModel):
    customer_name: str
    amount: float = Field(..., gt=0)
    status: str = Field("unpaid", pattern="^(unpaid|paid|overdue)$")
    due_date: str # Changed to str
    items: str = Field(..., description="JSON string or comma-separated list of items")

class InvoiceCreate(InvoiceBase):
    pass

class Invoice(InvoiceBase):
    id: int
    tenant_id: str
    invoice_number: str

    class Config:
        from_attributes = True

class CostCenterBase(BaseModel):
    name: str
    description: Optional[str] = None

class CostCenterCreate(CostCenterBase):
    pass

class CostCenter(CostCenterBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

class CostAllocationBase(BaseModel):
    transaction_id: int
    cost_center_id: int
    amount: float
    percentage: float

class CostAllocation(CostAllocationBase):
    id: int
    tenant_id: str

    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/transactions", response_model=List[FinancialTransaction])
async def get_all_transactions(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.FinancialTransaction).filter(models.FinancialTransaction.tenant_id == tenant_id).all()

@router.get("/transactions/{id}", response_model=FinancialTransaction)
async def get_transaction_by_id(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    txn = db.query(models.FinancialTransaction).filter(
        models.FinancialTransaction.id == id,
        models.FinancialTransaction.tenant_id == tenant_id
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return txn

@router.post("/transactions", response_model=FinancialTransaction, status_code=status.HTTP_201_CREATED)
async def create_transaction(
    txn: FinancialTransactionCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    db_txn = models.FinancialTransaction(**txn.model_dump(), tenant_id=tenant_id)
    db.add(db_txn)
    db.commit()
    db.refresh(db_txn)
    return db_txn

@router.get("/summary", response_model=FinancialSummary)
async def get_financial_summary(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    income = db.query(func.sum(models.FinancialTransaction.amount)).filter(
        models.FinancialTransaction.tenant_id == tenant_id,
        models.FinancialTransaction.type == "income"
    ).scalar() or 0.0
    
    expense = db.query(func.sum(models.FinancialTransaction.amount)).filter(
        models.FinancialTransaction.tenant_id == tenant_id,
        models.FinancialTransaction.type == "expense"
    ).scalar() or 0.0
    
    return FinancialSummary(
        total_income=income,
        total_expense=expense,
        net_profit=income - expense
    )

@router.get("/budgets", response_model=List[Budget])
async def get_all_budgets(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.Budget).filter(models.Budget.tenant_id == tenant_id).all()

@router.post("/budgets", response_model=Budget, status_code=status.HTTP_201_CREATED)
async def create_budget(
    budget: BudgetCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    db_budget = models.Budget(**budget.model_dump(), tenant_id=tenant_id)
    db.add(db_budget)
    db.commit()
    db.refresh(db_budget)
    return db_budget

@router.get("/invoices", response_model=List[Invoice])
async def get_all_invoices(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.Invoice).filter(models.Invoice.tenant_id == tenant_id).all()

@router.post("/invoices", response_model=Invoice, status_code=status.HTTP_201_CREATED)
async def create_invoice(
    invoice: InvoiceCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Generate invoice number
    last_invoice = db.query(models.Invoice).order_by(models.Invoice.id.desc()).first()
    next_id = (last_invoice.id + 1) if last_invoice else 1
    invoice_number = f"INV-{date.today().year}-{next_id:05d}"
    
    db_invoice = models.Invoice(
        **invoice.model_dump(), 
        tenant_id=tenant_id,
        invoice_number=invoice_number
    )
    db.add(db_invoice)
    db.commit()
    db.refresh(db_invoice)
    return db_invoice

@router.get("/cost-centers", response_model=List[CostCenter])
async def get_all_cost_centers(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.CostCenter).filter(models.CostCenter.tenant_id == tenant_id).all()

@router.post("/cost-centers", response_model=CostCenter, status_code=status.HTTP_201_CREATED)
async def create_cost_center(
    center: CostCenterCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    db_center = models.CostCenter(**center.model_dump(), tenant_id=tenant_id)
    db.add(db_center)
    db.commit()
    db.refresh(db_center)
    return db_center
