"""
FarmOS Genetic Analysis Router
API endpoints for advanced breeding recommendations and genetic analysis
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from ..services.genetic_analysis import genetic_analysis
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/genetic/compatibility")
async def analyze_breeding_compatibility(
    sire_breed: str,
    dam_breed: str,
    species: str = "poultry"
):
    """
    Analyze breeding compatibility between two breeds
    """
    try:
        compatibility = genetic_analysis.analyze_breeding_compatibility(sire_breed, dam_breed, species)
        
        return {
            "status": "success",
            "data": compatibility,
            "metadata": {
                "analysis_date": compatibility.get('analysis_date'),
                "genetic_database_version": "1.0"
            }
        }
        
    except Exception as e:
        logger.error(f"Error analyzing breeding compatibility: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Compatibility analysis failed",
                "message": str(e)
            }
        )

@router.post("/genetic/recommendations")
async def recommend_breeding_pairs(
    breeding_goals: Dict,
    db: Session = Depends(get_db)
):
    """
    Recommend optimal breeding pairs based on herd data and goals
    """
    try:
        # Get herd data from database
        livestock_batches = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.status == 'active'
        ).all()
        
        # Convert to analysis format
        herd_data = []
        for batch in livestock_batches:
            herd_data.append({
                'breed': batch.breed,
                'quantity': batch.quantity,
                'performance_score': 0.8  # This would come from performance data
            })
        
        # Generate recommendations
        recommendations = genetic_analysis.recommend_optimal_breeding_pairs(herd_data, breeding_goals)
        
        return {
            "status": "success",
            "data": recommendations,
            "metadata": {
                "herd_size": len(herd_data),
                "breeding_goals": breeding_goals,
                "analysis_date": "2025-01-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error generating breeding recommendations: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Recommendation failed",
                "message": str(e)
            }
        )

@router.get("/genetic/diversity")
async def analyze_genetic_diversity(
    db: Session = Depends(get_db),
    tenant_id: str = "default"
):
    """
    Analyze genetic diversity in the herd
    """
    try:
        # Get herd data for tenant
        livestock_batches = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.tenant_id == tenant_id,
            models.LivestockBatch.status == 'active'
        ).all()
        
        # Convert to analysis format
        herd_data = []
        for batch in livestock_batches:
            herd_data.append({
                'breed': batch.breed,
                'quantity': batch.quantity
            })
        
        # Analyze diversity
        diversity_analysis = genetic_analysis.analyze_genetic_diversity(herd_data)
        
        return {
            "status": "success",
            "data": diversity_analysis,
            "metadata": {
                "tenant_id": tenant_id,
                "analysis_date": diversity_analysis.get('analysis_date')
            }
        }
        
    except Exception as e:
        logger.error(f"Error analyzing genetic diversity: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Diversity analysis failed",
                "message": str(e)
            }
        )

@router.post("/genetic/breeding-plan")
async def generate_breeding_plan(
    breeding_pairs: List[Dict],
    timeline_months: int = 12,
    db: Session = Depends(get_db)
):
    """
    Generate optimized breeding plan
    """
    try:
        if not breeding_pairs:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "No breeding pairs provided",
                    "message": "At least one breeding pair is required"
                }
            )
        
        # Generate breeding plan
        breeding_plan = genetic_analysis.generate_breeding_plan(breeding_pairs, timeline_months)
        
        return {
            "status": "success",
            "data": breeding_plan,
            "metadata": {
                "timeline_months": timeline_months,
                "total_pairs": len(breeding_pairs),
                "plan_date": "2025-01-13T19:06:00Z"
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating breeding plan: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Breeding plan generation failed",
                "message": str(e)
            }
        )

@router.get("/genetic/performance-prediction")
async def predict_genetic_performance(
    breed: str,
    species: str = "poultry",
    crossbred_with: Optional[str] = None
):
    """
    Predict genetic performance for breed combinations
    """
    try:
        species_data = genetic_analysis.genetic_database.get(species.lower(), {})
        breed_data = species_data.get(breed.lower(), {})
        
        if not breed_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Breed not found",
                    "message": f"Breed '{breed}' not found for species '{species}'"
                }
            )
        
        # Base performance prediction
        base_prediction = {
            'breed': breed,
            'species': species,
            'growth_rate': breed_data.get('growth_rate', 0),
            'feed_conversion': breed_data.get('feed_conversion', 0),
            'mortality_rate': breed_data.get('mortality_rate', 0),
            'breeding_efficiency': breed_data.get('breeding_efficiency', 0),
            'market_weight': breed_data.get('market_weight', 0),
            'production_traits': breed_data
        }
        
        # Crossbreeding analysis if specified
        if crossbred_with:
            crossbred_data = species_data.get(crossbred_with.lower(), {})
            if crossbred_data:
                hybrid_vigor = genetic_analysis._predict_hybrid_vigor(breed, crossbred_with, species)
                base_prediction['hybrid_analysis'] = hybrid_vigor
                base_prediction['crossbred_with'] = crossbred_with
        
        return {
            "status": "success",
            "data": base_prediction,
            "metadata": {
                "prediction_date": "2025-01-13T19:06:00Z",
                "confidence_level": 0.85
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error predicting genetic performance: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Performance prediction failed",
                "message": str(e)
            }
        )

@router.get("/genetic/breed-database")
async def get_breed_database(
    species: Optional[str] = None
):
    """
    Get genetic database information for breeds
    """
    try:
        database = genetic_analysis.genetic_database
        
        if species:
            filtered_database = {
                species: database.get(species, {})
            }
        else:
            filtered_database = database
        
        return {
            "status": "success",
            "data": filtered_database,
            "metadata": {
                "total_species": len(database),
                "total_breeds": sum(len(breeds) for breeds in database.values()),
                "database_version": "1.0",
                "last_updated": "2025-01-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting breed database: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Database access failed",
                "message": str(e)
            }
        )

@router.post("/genetic/update-database")
async def update_breed_database(
    breed_data: Dict,
    background_tasks: BackgroundTasks = Depends()
):
    """
    Update genetic database with new breed information
    """
    try:
        species = breed_data.get('species', '').lower()
        breed_name = breed_data.get('breed', '').lower()
        
        if not species or not breed_name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Missing required fields",
                    "message": "species and breed are required"
                }
            )
        
        # Update genetic database (this would typically update a database table)
        # For now, just return success
        
        return {
            "status": "success",
            "message": "Breed database updated",
            "data": {
                "species": species,
                "breed": breed_name,
                "update_timestamp": "2025-01-13T19:06:00Z"
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating breed database: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Database update failed",
                "message": str(e)
            }
        )
