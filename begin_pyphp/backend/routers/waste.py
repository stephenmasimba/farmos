from fastapi import APIRouter, Depends, status
from typing import List, Optional
from pydantic import BaseModel, Field
from ..common.dependencies import get_current_user

router = APIRouter(tags=["waste"])

# --- Models ---

class BiogasLog(BaseModel):
    id: int
    date: str
    feedstock_input_kg: float
    estimated_gas_output_m3: float
    notes: Optional[str] = None

class BiogasLogCreate(BaseModel):
    date: str
    feedstock_input_kg: float
    estimated_gas_output_m3: float
    notes: Optional[str] = None

class CompostPile(BaseModel):
    id: int
    location: str
    start_date: str
    status: str = Field(..., description="active, maturing, ready")
    last_turned_date: Optional[str] = None
    temperature_c: Optional[float] = None

class CompostPileCreate(BaseModel):
    location: str
    start_date: str
    status: str = "active"

class ManureCollection(BaseModel):
    id: int
    date: str
    source: str = Field(..., description="Piggery, Poultry, etc.")
    quantity_kg: float
    destination: str = Field(..., description="Biogas, Compost, Field")

class ManureCollectionCreate(BaseModel):
    date: str
    source: str
    quantity_kg: float
    destination: str

# --- Mock Data ---

biogas_logs_db = [
    {"id": 1, "date": "2026-01-12", "feedstock_input_kg": 50.0, "estimated_gas_output_m3": 2.5, "notes": "Standard mix"},
]

compost_piles_db = [
    {"id": 1, "location": "Sector A", "start_date": "2025-12-01", "status": "maturing", "last_turned_date": "2026-01-05", "temperature_c": 55.0},
]

manure_db = [
    {"id": 1, "date": "2026-01-12", "source": "Piggery", "quantity_kg": 100.0, "destination": "Biogas"},
]

# --- Endpoints ---

@router.get("/biogas", response_model=List[BiogasLog])
async def get_biogas_logs(current_user: dict = Depends(get_current_user)):
    return biogas_logs_db

@router.post("/biogas", response_model=BiogasLog, status_code=status.HTTP_201_CREATED)
async def log_biogas(log: BiogasLogCreate, current_user: dict = Depends(get_current_user)):
    new_id = max([row["id"] for row in biogas_logs_db], default=0) + 1
    new_log = log.dict()
    new_log["id"] = new_id
    biogas_logs_db.append(new_log)
    return new_log

@router.get("/compost", response_model=List[CompostPile])
async def get_compost_piles(current_user: dict = Depends(get_current_user)):
    return compost_piles_db

@router.post("/compost", response_model=CompostPile, status_code=status.HTTP_201_CREATED)
async def create_compost_pile(pile: CompostPileCreate, current_user: dict = Depends(get_current_user)):
    new_id = max([p["id"] for p in compost_piles_db], default=0) + 1
    new_pile = pile.dict()
    new_pile["id"] = new_id
    compost_piles_db.append(new_pile)
    return new_pile

@router.get("/manure", response_model=List[ManureCollection])
async def get_manure_logs(current_user: dict = Depends(get_current_user)):
    return manure_db

@router.post("/manure", response_model=ManureCollection, status_code=status.HTTP_201_CREATED)
async def log_manure(log: ManureCollectionCreate, current_user: dict = Depends(get_current_user)):
    new_id = max([m["id"] for m in manure_db], default=0) + 1
    new_log = log.dict()
    new_log["id"] = new_id
    manure_db.append(new_log)
    return new_log
