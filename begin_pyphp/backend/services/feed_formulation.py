"""
Feed Formulation Engine - Phase 3 Feature
Advanced feed formulation with nutritional analysis, cost optimization, and inventory integration
Derived from Begin Reference System
"""

import logging
import asyncio
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from datetime import datetime, timedelta
import json

logger = logging.getLogger(__name__)

from ..common import models

class FeedFormulationService:
    """Advanced livestock feed formulation and cost optimization engine"""
    
    def __init__(self, db: Session):
        self.db = db
        self.nutrient_constraints = {
            'broiler': {
                'protein_min': 20.0, 'protein_max': 24.0,
                'energy_min': 2800, 'energy_max': 3200,
                'lysine_min': 1.2, 'methionine_min': 0.5
            },
            'layer': {
                'protein_min': 16.0, 'protein_max': 18.0,
                'energy_min': 2700, 'energy_max': 2900,
                'calcium_min': 3.5, 'calcium_max': 4.5
            },
            'pig': {
                'protein_min': 14.0, 'protein_max': 16.0,
                'energy_min': 3200, 'energy_max': 3400,
                'lysine_min': 0.8, 'fiber_max': 5.0
            },
            'cattle': {
                'protein_min': 12.0, 'protein_max': 14.0,
                'energy_min': 2400, 'energy_max': 2600,
                'fiber_min': 15.0, 'fiber_max': 25.0
            }
        }

    def calculate_pearson_square(self, ingredient_1_id: int, ingredient_2_id: int, target_protein: float, tenant_id: str = "default"):
        """Pearson Square Algorithm using database ingredients"""
        try:
            # Fetch ingredients from DB
            ing1 = self.db.query(models.FeedIngredient).filter(models.FeedIngredient.id == ingredient_1_id).first()
            ing2 = self.db.query(models.FeedIngredient).filter(models.FeedIngredient.id == ingredient_2_id).first()

            if not ing1 or not ing2:
                return {"error": "One or both ingredients not found in database"}

            # Convert to dict format expected by logic
            i1 = {"name": ing1.name, "protein": ing1.protein, "cost_per_kg": ing1.cost_per_kg}
            i2 = {"name": ing2.name, "protein": ing2.protein, "cost_per_kg": ing2.cost_per_kg}

            # Validate inputs
            if i1['protein'] >= target_protein and i2['protein'] >= target_protein:
                return {"error": f"At least one ingredient must have protein below target ({target_protein}%)"}
            if i1['protein'] <= target_protein and i2['protein'] <= target_protein:
                return {"error": f"At least one ingredient must have protein above target ({target_protein}%)"}

            # Calculate differences
            high = i1 if i1['protein'] > i2['protein'] else i2
            low = i2 if i1['protein'] > i2['protein'] else i1
            
            high_parts = target_protein - low['protein']
            low_parts = high['protein'] - target_protein
            total_parts = high_parts + low_parts
            
            high_pct = (high_parts / total_parts) * 100
            low_pct = (low_parts / total_parts) * 100
            
            cost = ((high['cost_per_kg'] * high_pct) + (low['cost_per_kg'] * low_pct)) / 100
            
            return {
                "method": "Pearson Square",
                "target_protein": target_protein,
                "ingredients": [
                    {**high, "percentage": round(high_pct, 2), "parts": round(high_parts, 2)},
                    {**low, "percentage": round(low_pct, 2), "parts": round(low_parts, 2)}
                ],
                "analysis": {
                    "final_protein": target_protein,
                    "cost_per_kg": round(cost, 2),
                    "total_parts": round(total_parts, 2)
                }
            }
        except Exception as e:
            logger.error(f"Error in Pearson Square calculation: {e}")
            return {"error": "Internal calculation error"}

    def get_common_ingredients(self, tenant_id: str = "default"):
        """Return list of feed ingredients from database"""
        try:
            ingredients = self.db.query(models.FeedIngredient).filter(
                models.FeedIngredient.tenant_id == tenant_id
            ).all()
            
            if not ingredients:
                return self._get_mock_ingredients()
                
            return [
                {
                    "id": ing.id, 
                    "name": ing.name, 
                    "protein": ing.protein, 
                    "cost_per_kg": ing.cost_per_kg, 
                    "type": ing.ingredient_type
                } for ing in ingredients
            ]
        except Exception as e:
            logger.error(f"Error fetching ingredients: {e}")
            return self._get_mock_ingredients()

    def _get_mock_ingredients(self):
        """Mock fallback for ingredients"""
        return [
            {"id": 1, "name": "Maize Meal (Mock)", "protein": 9.0, "cost_per_kg": 0.45, "type": "energy", "available_quantity": 1000},
            {"id": 2, "name": "Soya Bean Meal (Mock)", "protein": 44.0, "cost_per_kg": 0.85, "type": "protein", "available_quantity": 500},
            {"id": 3, "name": "Sunflower Cake (Mock)", "protein": 36.0, "cost_per_kg": 0.65, "type": "protein", "available_quantity": 300},
            {"id": 4, "name": "Limestone (Mock)", "protein": 0.0, "cost_per_kg": 0.15, "type": "mineral", "available_quantity": 200},
            {"id": 5, "name": "Vitamin Premix (Mock)", "protein": 0.0, "cost_per_kg": 5.50, "type": "additive", "available_quantity": 50}
        ]

    def add_ingredient(self, ingredient_data: Dict[str, Any], tenant_id: str = "default"):
        """Add a new feed ingredient to the database"""
        try:
            new_ingredient = models.FeedIngredient(
                tenant_id=tenant_id,
                name=ingredient_data.get("name"),
                protein=ingredient_data.get("protein", 0.0),
                energy=ingredient_data.get("energy", 0.0),
                cost_per_kg=ingredient_data.get("cost_per_kg", 0.0),
                ingredient_type=ingredient_data.get("type", "other"),
                available_quantity=ingredient_data.get("available_quantity", 0.0),
                lysine=ingredient_data.get("lysine", 0.0),
                methionine=ingredient_data.get("methionine", 0.0),
                calcium=ingredient_data.get("calcium", 0.0),
                fiber=ingredient_data.get("fiber", 0.0)
            )
            self.db.add(new_ingredient)
            self.db.commit()
            self.db.refresh(new_ingredient)
            return {"success": True, "id": new_ingredient.id, "message": "Ingredient added successfully"}
        except Exception as e:
            logger.error(f"Error adding ingredient: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_recent_formulations(self, tenant_id: str = "default"):
        """Return history of calculated formulations"""
        try:
            formulations = self.db.query(models.FeedFormulation).filter(
                models.FeedFormulation.tenant_id == tenant_id
            ).order_by(models.FeedFormulation.created_at.desc()).limit(10).all()
            
            return [
                {
                    "id": f.id,
                    "name": f.name,
                    "date": f.created_at.strftime("%Y-%m-%d"),
                    "target_protein": f.target_protein,
                    "cost_per_kg": f.cost_per_kg,
                    "status": f.status,
                    "animal_type": f.animal_type
                } for f in formulations
            ]
        except Exception as e:
            logger.error(f"Error fetching formulations: {e}")
            return self._get_mock_formulations()

    def _get_mock_formulations(self):
        """Mock fallback for formulations"""
        return [
            {
                "id": 101, "name": "Broiler Starter", "date": "2026-02-05", 
                "target_protein": 22.0, "cost_per_kg": 0.68, "status": "active", "animal_type": "broiler"
            },
            {
                "id": 102, "name": "Layer Grower", "date": "2026-02-03", 
                "target_protein": 17.0, "cost_per_kg": 0.62, "status": "active", "animal_type": "layer"
            }
        ]

    async def optimize_formulation(self, animal_type: str, target_weight: float, 
                                 budget_constraint: Optional[float] = None,
                                 tenant_id: str = "default") -> Dict[str, Any]:
        """Advanced feed formulation optimization using linear programming concepts"""
        try:
            constraints = self.nutrient_constraints.get(animal_type, {})
            if not constraints:
                return {"error": f"Unsupported animal type: {animal_type}"}

            # Get available ingredients with inventory
            ingredients = await self._get_available_ingredients(tenant_id)
            if len(ingredients) < 2:
                return {"error": "Insufficient ingredients available"}

            # Multi-objective optimization: minimize cost while meeting nutritional constraints
            best_formulation = None
            best_score = float('inf')
            
            # Try different combinations of ingredients
            for i in range(len(ingredients)):
                for j in range(i + 1, len(ingredients)):
                    formulation = await self._evaluate_combination(
                        ingredients[i], ingredients[j], constraints, budget_constraint
                    )
                    
                    if formulation and formulation.get('score', float('inf')) < best_score:
                        best_score = formulation['score']
                        best_formulation = formulation

            if best_formulation:
                # Save formulation to database
                await self._save_formulation(best_formulation, animal_type, tenant_id)
                return best_formulation
            
            return {"error": "Could not find optimal formulation within constraints"}
            
        except Exception as e:
            logger.error(f"Error in formulation optimization: {e}")
            return {"error": "Optimization failed"}

    async def _get_available_ingredients(self, tenant_id: str) -> List[Dict]:
        """Get ingredients with available inventory"""
        try:
            ingredients = self.db.query(models.FeedIngredient).filter(
                and_(
                    models.FeedIngredient.tenant_id == tenant_id,
                    models.FeedIngredient.available_quantity > 0
                )
            ).all()
            
            return [
                {
                    "id": ing.id,
                    "name": ing.name,
                    "protein": ing.protein,
                    "energy": ing.energy or 3000,
                    "cost_per_kg": ing.cost_per_kg,
                    "type": ing.ingredient_type,
                    "available_quantity": ing.available_quantity,
                    "lysine": ing.lysine or 0,
                    "methionine": ing.methionine or 0,
                    "calcium": ing.calcium or 0,
                    "fiber": ing.fiber or 0
                } for ing in ingredients
            ]
        except Exception as e:
            logger.error(f"Error fetching available ingredients: {e}")
            return self._get_mock_ingredients()

    async def _evaluate_combination(self, ing1: Dict, ing2: Dict, 
                                 constraints: Dict, budget_constraint: Optional[float]) -> Optional[Dict]:
        """Evaluate a two-ingredient combination"""
        try:
            # Use Pearson Square as base calculation
            target_protein = (constraints.get('protein_min', 20) + constraints.get('protein_max', 24)) / 2
            
            if ing1['protein'] == ing2['protein']:
                return None
                
            high = ing1 if ing1['protein'] > ing2['protein'] else ing2
            low = ing2 if ing1['protein'] > ing2['protein'] else ing1
            
            high_parts = target_protein - low['protein']
            low_parts = high['protein'] - target_protein
            total_parts = high_parts + low_parts
            
            high_pct = (high_parts / total_parts) * 100
            low_pct = (low_parts / total_parts) * 100
            
            # Calculate nutritional profile
            formulation = {
                'ingredients': [
                    {**high, "percentage": round(high_pct, 2)},
                    {**low, "percentage": round(low_pct, 2)}
                ],
                'analysis': {}
            }
            
            # Calculate all nutrients
            for nutrient in ['protein', 'energy', 'lysine', 'methionine', 'calcium', 'fiber']:
                value = (high[nutrient] * high_pct + low[nutrient] * low_pct) / 100
                formulation['analysis'][nutrient] = round(value, 2)
            
            # Calculate cost
            cost_per_kg = (high['cost_per_kg'] * high_pct + low['cost_per_kg'] * low_pct) / 100
            formulation['analysis']['cost_per_kg'] = round(cost_per_kg, 2)
            
            # Check constraints
            violations = 0
            for nutrient, limits in constraints.items():
                if nutrient.endswith('_min'):
                    base_nutrient = nutrient.replace('_min', '')
                    if formulation['analysis'].get(base_nutrient, 0) < limits:
                        violations += 1
                elif nutrient.endswith('_max'):
                    base_nutrient = nutrient.replace('_max', '')
                    if formulation['analysis'].get(base_nutrient, 0) > limits:
                        violations += 1
            
            # Check budget constraint
            if budget_constraint and cost_per_kg > budget_constraint:
                violations += 1
            
            # Calculate score (lower is better)
            formulation['score'] = violations * 1000 + cost_per_kg
            formulation['violations'] = violations
            
            return formulation if violations <= 2 else None
            
        except Exception as e:
            logger.error(f"Error evaluating combination: {e}")
            return None

    async def _save_formulation(self, formulation: Dict, animal_type: str, tenant_id: str):
        """Save formulation to database"""
        try:
            new_formulation = models.FeedFormulation(
                name=f"{animal_type.title()} Feed {datetime.now().strftime('%Y%m%d')}",
                animal_type=animal_type,
                target_protein=formulation['analysis']['protein'],
                cost_per_kg=formulation['analysis']['cost_per_kg'],
                ingredients_json=json.dumps(formulation['ingredients']),
                analysis_json=json.dumps(formulation['analysis']),
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(new_formulation)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error saving formulation: {e}")
            self.db.rollback()

    def get_nutritional_analysis(self, formulation_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Get detailed nutritional analysis of a formulation"""
        try:
            formulation = self.db.query(models.FeedFormulation).filter(
                and_(
                    models.FeedFormulation.id == formulation_id,
                    models.FeedFormulation.tenant_id == tenant_id
                )
            ).first()
            
            if not formulation:
                return {"error": "Formulation not found"}
            
            analysis = json.loads(formulation.analysis_json) if formulation.analysis_json else {}
            constraints = self.nutrient_constraints.get(formulation.animal_type, {})
            
            # Compare against constraints
            compliance = {}
            for nutrient, value in analysis.items():
                if nutrient in ['protein', 'energy', 'lysine', 'methionine', 'calcium', 'fiber']:
                    min_key = f"{nutrient}_min"
                    max_key = f"{nutrient}_max"
                    
                    compliance[nutrient] = {
                        'value': value,
                        'min_required': constraints.get(min_key),
                        'max_allowed': constraints.get(max_key),
                        'status': 'within_range'
                    }
                    
                    if constraints.get(min_key) and value < constraints[min_key]:
                        compliance[nutrient]['status'] = 'below_minimum'
                    elif constraints.get(max_key) and value > constraints[max_key]:
                        compliance[nutrient]['status'] = 'above_maximum'
            
            return {
                'formulation': {
                    'id': formulation.id,
                    'name': formulation.name,
                    'animal_type': formulation.animal_type,
                    'created_at': formulation.created_at.isoformat()
                },
                'nutritional_analysis': analysis,
                'compliance': compliance,
                'cost_per_kg': formulation.cost_per_kg
            }
            
        except Exception as e:
            logger.error(f"Error getting nutritional analysis: {e}")
            return {"error": "Analysis failed"}

    async def update_inventory_from_formulation(self, formulation_id: int, 
                                              batch_size_kg: float, tenant_id: str = "default") -> Dict[str, Any]:
        """Update ingredient inventory based on formulation usage"""
        try:
            formulation = self.db.query(models.FeedFormulation).filter(
                and_(
                    models.FeedFormulation.id == formulation_id,
                    models.FeedFormulation.tenant_id == tenant_id
                )
            ).first()
            
            if not formulation:
                return {"error": "Formulation not found"}
            
            ingredients = json.loads(formulation.ingredients_json) if formulation.ingredients_json else []
            inventory_updates = []
            
            for ing in ingredients:
                # Calculate quantity needed
                quantity_needed = (ing['percentage'] / 100) * batch_size_kg
                
                # Update inventory
                ingredient = self.db.query(models.FeedIngredient).filter(
                    models.FeedIngredient.id == ing['id']
                ).first()
                
                if ingredient:
                    if ingredient.available_quantity >= quantity_needed:
                        ingredient.available_quantity -= quantity_needed
                        inventory_updates.append({
                            'ingredient_name': ing['name'],
                            'quantity_used': round(quantity_needed, 2),
                            'remaining': round(ingredient.available_quantity, 2)
                        })
                    else:
                        return {
                            "error": f"Insufficient inventory for {ing['name']}. Required: {quantity_needed}kg, Available: {ingredient.available_quantity}kg"
                        }
            
            self.db.commit()
            
            return {
                "success": True,
                "batch_size_kg": batch_size_kg,
                "formulation": formulation.name,
                "inventory_updates": inventory_updates
            }
            
        except Exception as e:
            logger.error(f"Error updating inventory: {e}")
            self.db.rollback()
            return {"error": "Inventory update failed"}
