from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel, Field
from ..common.dependencies import get_current_user
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models

router = APIRouter(tags=["feed"])

# --- Models ---

class FeedIngredient(BaseModel):
    id: int
    name: str
    protein_content: float = Field(..., gt=0, le=100, description="Protein percentage")
    quantity_kg: float = Field(..., ge=0, description="Current stock in kg")
    cost_per_kg: float = Field(..., ge=0)

class FeedIngredientCreate(BaseModel):
    name: str
    protein_content: float
    quantity_kg: float
    cost_per_kg: float

class FormulationRequest(BaseModel):
    target_protein: float = Field(..., gt=0, le=100)
    total_quantity_kg: float = Field(..., gt=0)
    ingredient_1_id: int
    ingredient_2_id: int

class FormulationResult(BaseModel):
    ingredient_1_kg: float
    ingredient_2_kg: float
    total_cost: float
    notes: str

class MillingLog(BaseModel):
    id: int
    date: str
    batch_name: str
    ingredients: str
    total_output_kg: float
    notes: Optional[str] = None

class MillingLogCreate(BaseModel):
    date: str
    batch_name: str
    ingredients: str
    total_output_kg: float
    notes: Optional[str] = None

# --- Mock Data (milling only, ingredients now persisted) ---
milling_logs_db = [
    {"id": 1, "date": "2026-01-10", "batch_name": "Broiler Starter", "ingredients": "Maize, Soya", "total_output_kg": 100.0, "notes": "Good consistency"},
]

# --- Endpoints ---

@router.get("/ingredients", response_model=List[FeedIngredient])
async def get_ingredients(current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.query(models.FeedIngredient).all()
    return [
        {
            "id": r.id,
            "name": r.name,
            "protein_content": r.protein_content,
            "quantity_kg": r.quantity_kg,
            "cost_per_kg": r.cost_per_kg,
        }
        for r in rows
    ]

@router.post("/ingredients", response_model=FeedIngredient, status_code=status.HTTP_201_CREATED)
async def create_ingredient(item: FeedIngredientCreate, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    rec = models.FeedIngredient(
        tenant_id=str(current_user.get("tenant_id", "default")) if isinstance(current_user, dict) else "default",
        name=item.name,
        protein_content=item.protein_content,
        quantity_kg=item.quantity_kg,
        cost_per_kg=item.cost_per_kg,
    )
    db.add(rec)
    db.commit()
    db.refresh(rec)
    return {
        "id": rec.id,
        "name": rec.name,
        "protein_content": rec.protein_content,
        "quantity_kg": rec.quantity_kg,
        "cost_per_kg": rec.cost_per_kg,
    }

@router.post("/calculate-pearson", response_model=FormulationResult)
async def calculate_pearson(request: FormulationRequest, current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    ing1 = db.query(models.FeedIngredient).filter(models.FeedIngredient.id == request.ingredient_1_id).first()
    ing2 = db.query(models.FeedIngredient).filter(models.FeedIngredient.id == request.ingredient_2_id).first()
    
    if not ing1 or not ing2:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    
    p1 = ing1.protein_content
    p2 = ing2.protein_content
    target = request.target_protein
    
    # Pearson Square Logic
    #   A (p1)      (target - p2) = parts of A
    #        \     /
    #         Target
    #        /     \
    #   B (p2)      (target - p1) = parts of B
    #
    # Absolute differences are used.
    
    diff1 = abs(target - p2)
    diff2 = abs(target - p1)
    total_parts = diff1 + diff2
    
    if total_parts == 0:
        raise HTTPException(status_code=400, detail="Invalid protein values for calculation")
    
    perc1 = diff1 / total_parts
    perc2 = diff2 / total_parts
    
    qty1 = perc1 * request.total_quantity_kg
    qty2 = perc2 * request.total_quantity_kg
    
    cost = (qty1 * ing1.cost_per_kg) + (qty2 * ing2.cost_per_kg)
    
    return {
        "ingredient_1_kg": round(qty1, 2),
        "ingredient_2_kg": round(qty2, 2),
        "total_cost": round(cost, 2),
        "notes": f"Mix {round(qty1, 2)}kg of {ing1.name} and {round(qty2, 2)}kg of {ing2.name} to get {request.total_quantity_kg}kg at {target}% protein."
    }

@router.get("/milling-logs", response_model=List[MillingLog])
async def get_milling_logs(current_user: dict = Depends(get_current_user)):
    return milling_logs_db

@router.post("/milling-logs", response_model=MillingLog, status_code=status.HTTP_201_CREATED)
async def create_milling_log(log: MillingLogCreate, current_user: dict = Depends(get_current_user)):
    new_id = max([row["id"] for row in milling_logs_db], default=0) + 1
    new_log = log.dict()
    new_log["id"] = new_id
    milling_logs_db.append(new_log)
    return new_log
