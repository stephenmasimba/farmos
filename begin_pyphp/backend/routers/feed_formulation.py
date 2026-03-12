from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.feed_formulation import FeedFormulationService
from ..common.dependencies import get_tenant_id
from typing import Optional, List, Dict

router = APIRouter()

@router.get("/ingredients")
async def get_ingredients(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get common feed ingredients from database"""
    service = FeedFormulationService(db)
    return service.get_common_ingredients(tenant_id)

@router.post("/ingredients")
async def add_ingredient(data: Dict, db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Add a new feed ingredient to the database"""
    service = FeedFormulationService(db)
    result = service.add_ingredient(data, tenant_id)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result.get("error"))
    return result

@router.post("/calculate")
async def calculate_formulation(data: Dict, db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Calculate feed formulation using Pearson Square with database ingredients"""
    service = FeedFormulationService(db)
    
    # Check if we are passing IDs or full objects (compatibility layer)
    ing1 = data.get('ingredient_1')
    ing2 = data.get('ingredient_2')
    target = data.get('target_protein')
    
    # If they passed IDs, use the new DB-driven method
    if isinstance(ing1, int) and isinstance(ing2, int):
        return service.calculate_pearson_square(ing1, ing2, target, tenant_id)
    
    # Fallback/Legacy: If they passed full objects, we'd need the old method or to find them in DB
    # For now, let's assume the frontend will be updated to pass IDs.
    # If they are dicts, try to find by name or just error
    return {"error": "Please provide ingredient IDs (integers) for calculation"}

@router.get("/recent")
async def get_recent(db: Session = Depends(get_db), tenant_id: str = Depends(get_tenant_id)):
    """Get recent formulations"""
    service = FeedFormulationService(db)
    return service.get_recent_formulations(tenant_id)
