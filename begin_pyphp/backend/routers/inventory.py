from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import date
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user, get_tenant_id
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["inventory"])

# --- Models ---

class InventoryItemBase(BaseModel):
    name: str = Field(..., min_length=1, description="Item name")
    category: str = Field(..., description="Category (e.g. Chemicals, Fuel, Seeds)")
    quantity: float = Field(..., ge=0, description="Current stock quantity")
    unit: str = Field(..., description="Unit of measurement (e.g. kg, L)")
    location: str = Field(..., description="Storage location")
    low_stock_threshold: float = Field(10.0, description="Threshold for low stock alert")
    qr_code: Optional[str] = None

class InventoryItemCreate(InventoryItemBase):
    pass

class InventoryItemUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    quantity: Optional[float] = Field(None, ge=0)
    unit: Optional[str] = None
    location: Optional[str] = None
    low_stock_threshold: Optional[float] = None
    qr_code: Optional[str] = None

class InventoryItem(InventoryItemBase):
    id: int
    tenant_id: str
    
    class Config:
        from_attributes = True

class InventoryTransactionBase(BaseModel):
    item_id: int
    type: str = Field(..., pattern="^(in|out|adjustment)$", description="Transaction type: in, out, adjustment")
    quantity: float = Field(..., gt=0, description="Quantity changed")
    reason: str
    date: str # Changed to str for simplicity and consistency with other models

class InventoryTransactionCreate(InventoryTransactionBase):
    pass

class InventoryTransaction(InventoryTransactionBase):
    id: int
    tenant_id: str
    
    class Config:
        from_attributes = True

# --- Endpoints ---

@router.get("/items", response_model=List[InventoryItem])
async def get_all_items(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.InventoryItem).filter(models.InventoryItem.tenant_id == tenant_id).all()

@router.get("/items/{id}", response_model=InventoryItem)
async def get_item_by_id(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item = db.query(models.InventoryItem).filter(
        models.InventoryItem.id == id,
        models.InventoryItem.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@router.get("/items/scan/{qr_code}", response_model=InventoryItem)
async def scan_item(
    qr_code: str, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item = db.query(models.InventoryItem).filter(
        models.InventoryItem.qr_code == qr_code,
        models.InventoryItem.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found with this QR code")
    return item

@router.post("/items", response_model=InventoryItem, status_code=status.HTTP_201_CREATED)
async def create_item(
    item: InventoryItemCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item_data = item.model_dump()
    db_item = models.InventoryItem(**item_data, tenant_id=tenant_id)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    
    # Generate QR code if not provided
    if not db_item.qr_code:
        db_item.qr_code = f"INV-{db_item.id:06d}"
        db.commit()
        db.refresh(db_item)
        
    return db_item

@router.put("/items/{id}", response_model=InventoryItem)
async def update_item(
    id: int, 
    item_update: InventoryItemUpdate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item = db.query(models.InventoryItem).filter(
        models.InventoryItem.id == id,
        models.InventoryItem.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    
    update_data = item_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(item, key, value)
    
    db.commit()
    db.refresh(item)
    return item

@router.delete("/items/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    item = db.query(models.InventoryItem).filter(
        models.InventoryItem.id == id,
        models.InventoryItem.tenant_id == tenant_id
    ).first()
    if item:
        db.delete(item)
        db.commit()
    return

@router.get("/transactions", response_model=List[InventoryTransaction])
async def get_transactions(
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    return db.query(models.InventoryTransaction).filter(models.InventoryTransaction.tenant_id == tenant_id).all()

@router.post("/transactions", response_model=InventoryTransaction, status_code=status.HTTP_201_CREATED)
async def add_transaction(
    txn: InventoryTransactionCreate, 
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id)
):
    # Verify item exists for this tenant
    item = db.query(models.InventoryItem).filter(
        models.InventoryItem.id == txn.item_id,
        models.InventoryItem.tenant_id == tenant_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
        
    # Logic to update stock
    if txn.type == "in":
        item.quantity += txn.quantity
    elif txn.type == "out":
        if item.quantity < txn.quantity:
            raise HTTPException(status_code=400, detail="Insufficient stock")
        item.quantity -= txn.quantity
    elif txn.type == "adjustment":
         item.quantity += txn.quantity 

    # Record transaction
    db_txn = models.InventoryTransaction(**txn.model_dump(), tenant_id=tenant_id)
    db.add(db_txn)
    
    db.commit()
    db.refresh(db_txn)
    return db_txn
