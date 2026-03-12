from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import List, Optional
from ..common.dependencies import get_current_user

router = APIRouter(tags=["suppliers"])

class SupplierBase(BaseModel):
    name: str = Field(..., min_length=1)
    contact_person: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    category: str = Field(..., description="e.g. Seeds, Fertilizers, Equipment")

class SupplierCreate(SupplierBase):
    pass

class Supplier(SupplierBase):
    id: int

# Mock Data
suppliers_db = [
    {"id": 1, "name": "AgriInputs Ltd", "contact_person": "Sarah Jones", "email": "sales@agriinputs.com", "phone": "+263777123456", "address": "123 Farm Rd, Harare", "category": "Inputs"},
    {"id": 2, "name": "FarmMech Solutions", "contact_person": "Mike Smith", "email": "mike@farmmech.co.zw", "phone": "+263777654321", "address": "45 Industrial Ave, Bulawayo", "category": "Equipment"},
]

@router.get("/", response_model=List[Supplier])
async def get_suppliers(current_user: dict = Depends(get_current_user)):
    return suppliers_db

@router.post("/", response_model=Supplier, status_code=status.HTTP_201_CREATED)
async def create_supplier(supplier: SupplierCreate, current_user: dict = Depends(get_current_user)):
    new_id = max([s["id"] for s in suppliers_db], default=0) + 1
    new_supplier = supplier.dict()
    new_supplier["id"] = new_id
    suppliers_db.append(new_supplier)
    return new_supplier

@router.put("/{id}", response_model=Supplier)
async def update_supplier(id: int, supplier: SupplierCreate, current_user: dict = Depends(get_current_user)):
    supp = next((s for s in suppliers_db if s["id"] == id), None)
    if not supp:
        raise HTTPException(status_code=404, detail="Supplier not found")
    supp.update(supplier.dict())
    return supp

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_supplier(id: int, current_user: dict = Depends(get_current_user)):
    global suppliers_db
    suppliers_db = [s for s in suppliers_db if s["id"] != id]
    return
