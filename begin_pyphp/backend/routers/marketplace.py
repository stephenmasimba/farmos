from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
from sqlalchemy.orm import Session
from ..common.dependencies import get_current_user
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["marketplace"])

# --- Models ---

class ListingBase(BaseModel):
    title: str = Field(..., min_length=3, description="Listing title")
    description: str = Field(..., description="Detailed description")
    category: str = Field(..., description="Crops, Livestock, Equipment, Inputs")
    price: float = Field(..., gt=0, description="Price per unit")
    unit: str = Field(..., description="Unit (kg, head, liter)")
    quantity: float = Field(..., gt=0, description="Available quantity")
    location: str = Field(..., description="Location of the item")

class ListingCreate(ListingBase):
    pass

class Listing(ListingBase):
    id: int
    seller_id: int
    status: str = "active" # active, sold, suspended
    created_at: str

    class Config:
        from_attributes = True

class OrderCreate(BaseModel):
    listing_id: int
    quantity: float = Field(..., gt=0)

class Order(BaseModel):
    id: int
    listing_id: int
    buyer_id: int
    quantity: float
    total_price: float
    status: str = "pending" # pending, accepted, completed, cancelled
    created_at: str

    class Config:
        from_attributes = True

class Customer(BaseModel):
    id: int
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None

    class Config:
        from_attributes = True

class CustomerCreate(BaseModel):
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None

# --- Endpoints ---

@router.get("/listings", response_model=List[Listing])
async def get_listings(category: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.Listing).filter(models.Listing.status == "active")
    if category:
        query = query.filter(models.Listing.category == category)
    return query.all()

@router.post("/listings", response_model=Listing, status_code=status.HTTP_201_CREATED)
async def create_listing(listing: ListingCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    new_listing = models.Listing(**listing.dict())
    new_listing.seller_id = current_user["id"]
    new_listing.status = "active"
    new_listing.created_at = datetime.now().isoformat()
    # new_listing.tenant_id = current_user.get("tenant_id", "default")
    
    db.add(new_listing)
    db.commit()
    db.refresh(new_listing)
    return new_listing

@router.post("/orders", response_model=Order, status_code=status.HTTP_201_CREATED)
async def create_order(order: OrderCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    listing = db.query(models.Listing).filter(models.Listing.id == order.listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    if listing.quantity < order.quantity:
        raise HTTPException(status_code=400, detail="Insufficient quantity")
        
    new_order = models.Order(
        listing_id=order.listing_id,
        buyer_id=current_user["id"],
        quantity=order.quantity,
        total_price=order.quantity * listing.price,
        status="pending",
        created_at=datetime.now().isoformat()
    )
    # new_order.tenant_id = current_user.get("tenant_id", "default")
    
    # Update listing quantity logic? Or reserve it? 
    # For now, let's just deduct it to prevent overselling immediately, or keep it simple.
    # A robust system would reserve stock. Here we might just deduct.
    listing.quantity -= order.quantity
    if listing.quantity == 0:
        listing.status = "sold"

    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order

@router.get("/customers", response_model=List[Customer])
async def get_customers(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return db.query(models.Customer).all()

@router.post("/customers", response_model=Customer, status_code=status.HTTP_201_CREATED)
async def create_customer(customer: CustomerCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    new_customer = models.Customer(**customer.dict())
    # new_customer.tenant_id = current_user.get("tenant_id", "default")
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer
