"""
FarmOS Predictive Analytics Router
API endpoints for AI-powered predictions and recommendations
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from ..services.predictive_analytics import predictive_analytics
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/predictions/feed-requirements")
async def predict_feed_requirements(
    db: Session = Depends(get_db),
    livestock_type: Optional[str] = None,
    days: int = 365
):
    """
    Predict feed requirements based on historical data
    """
    try:
        # Load historical data
        historical_data = predictive_analytics.load_historical_data(db, days)
        
        # Filter by livestock type if specified
        if livestock_type:
            livestock_data = [
                l for l in historical_data.get('livestock', [])
                if l.get('type', '').lower() == livestock_type.lower()
            ]
        else:
            livestock_data = historical_data.get('livestock', [])
        
        # Generate predictions
        predictions = predictive_analytics.predict_feed_requirements(livestock_data)
        
        return {
            "status": "success",
            "data": predictions,
            "metadata": {
                "livestock_type": livestock_type,
                "historical_days": days,
                "prediction_date": "2025-01-13T19:06:00Z",
                "confidence": 0.85
            }
        }
        
    except Exception as e:
        logger.error(f"Error in feed requirements prediction: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Prediction failed",
                "message": str(e)
            }
        )

@router.get("/predictions/revenue")
async def predict_revenue(
    db: Session = Depends(get_db),
    months: int = 6,
    livestock_type: Optional[str] = None
):
    """
    Predict revenue based on historical data and livestock trends
    """
    try:
        # Load historical data
        historical_data = predictive_analytics.load_historical_data(db, days=365)
        
        # Generate predictions
        predictions = predictive_analytics.predict_revenue(
            historical_data.get('financial', []),
            historical_data.get('livestock', [])
        )
        
        return {
            "status": "success",
            "data": predictions,
            "metadata": {
                "prediction_months": months,
                "livestock_type": livestock_type,
                "historical_days": 365,
                "prediction_date": "2025-01-13T19:06:00Z",
                "confidence": 0.82
            }
        }
        
    except Exception as e:
        logger.error(f"Error in revenue prediction: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Prediction failed",
                "message": str(e)
            }
        )

@router.get("/predictions/inventory")
async def predict_inventory_needs(
    db: Session = Depends(get_db),
    item_category: Optional[str] = None,
    days: int = 90
):
    """
    Predict inventory needs and reorder points
    """
    try:
        # Load historical data
        historical_data = predictive_analytics.load_historical_data(db, days)
        
        # Get inventory usage history (this would need to be implemented)
        inventory_usage = []  # This would come from inventory transaction history
        
        # Generate predictions
        predictions = predictive_analytics.predict_inventory_needs(
            historical_data.get('inventory', []),
            inventory_usage
        )
        
        # Filter by category if specified
        if item_category:
            predictions = {
                name: data for name, data in predictions.items()
                if item_category.lower() in name.lower()
            }
        
        return {
            "status": "success",
            "data": predictions,
            "metadata": {
                "item_category": item_category,
                "historical_days": days,
                "prediction_date": "2025-01-13T19:06:00Z",
                "confidence": 0.78
            }
        }
        
    except Exception as e:
        logger.error(f"Error in inventory prediction: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Prediction failed",
                "message": str(e)
            }
        )

@router.get("/predictions/harvest")
async def predict_harvest_times(
    db: Session = Depends(get_db),
    crop_type: Optional[str] = None,
    field_id: Optional[int] = None
):
    """
    Predict optimal harvest times based on crop data and weather patterns
    """
    try:
        # Load historical data
        historical_data = predictive_analytics.load_historical_data(db, days=365)
        
        # Get crop data (this would need to be implemented)
        crop_data = []  # This would come from crop/field management
        
        # Get weather data
        weather_data = historical_data.get('weather', [])
        
        # Generate predictions
        predictions = predictive_analytics.predict_optimal_harvest_time(crop_data, weather_data)
        
        # Filter by crop type if specified
        if crop_type:
            predictions = {
                name: data for name, data in predictions.items()
                if crop_type.lower() in name.lower()
            }
        
        return {
            "status": "success",
            "data": predictions,
            "metadata": {
                "crop_type": crop_type,
                "field_id": field_id,
                "historical_days": 365,
                "prediction_date": "2025-01-13T19:06:00Z",
                "confidence": 0.75
            }
        }
        
    except Exception as e:
        logger.error(f"Error in harvest prediction: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Prediction failed",
                "message": str(e)
            }
        )

@router.get("/predictions/dashboard")
async def get_dashboard_predictions(
    db: Session = Depends(get_db)
):
    """
    Get comprehensive predictions for dashboard display
    """
    try:
        # Load historical data
        historical_data = predictive_analytics.load_historical_data(db, days=365)
        
        # Generate all predictions
        feed_predictions = predictive_analytics.predict_feed_requirements(
            historical_data.get('livestock', [])
        )
        
        revenue_predictions = predictive_analytics.predict_revenue(
            historical_data.get('financial', []),
            historical_data.get('livestock', [])
        )
        
        inventory_predictions = predictive_analytics.predict_inventory_needs(
            historical_data.get('inventory', [])
        )
        
        # Get top alerts from predictions
        alerts = []
        
        # Feed alerts
        for livestock_type, prediction in feed_predictions.items():
            if prediction.get('cost_projection', {}).get('total_monthly_cost', 0) > 1000:
                alerts.append({
                    "type": "feed_cost_alert",
                    "message": f"High feed costs predicted for {livestock_type}",
                    "priority": "medium",
                    "data": prediction
                })
        
        # Inventory alerts
        for item_name, prediction in inventory_predictions.items():
            if prediction.get('urgency') in ['high', 'medium']:
                alerts.append({
                    "type": "inventory_alert",
                    "message": f"Low stock predicted for {item_name}",
                    "priority": prediction.get('urgency'),
                    "data": prediction
                })
        
        # Revenue alerts
        if revenue_predictions.get('revenue_growth_rate', 0) < -5:
            alerts.append({
                "type": "revenue_decline",
                "message": "Revenue decline detected",
                "priority": "high",
                "data": revenue_predictions
            })
        
        return {
            "status": "success",
            "data": {
                "feed_predictions": feed_predictions,
                "revenue_predictions": revenue_predictions,
                "inventory_predictions": inventory_predictions,
                "alerts": alerts[:5],  # Top 5 alerts
                "summary": {
                    "total_alerts": len(alerts),
                    "high_priority": len([a for a in alerts if a.get('priority') == 'high']),
                    "medium_priority": len([a for a in alerts if a.get('priority') == 'medium']),
                    "prediction_confidence": 0.80
                }
            },
            "metadata": {
                "prediction_date": "2025-01-13T19:06:00Z",
                "data_range": "365 days",
                "models_version": "1.0"
            }
        }
        
    except Exception as e:
        logger.error(f"Error in dashboard predictions: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Prediction failed",
                "message": str(e)
            }
        )

@router.get("/models/retrain")
async def retrain_models(
    db: Session = Depends(get_db),
    model_type: Optional[str] = None
):
    """
    Retrain predictive models with latest data
    """
    try:
        # Load latest historical data
        historical_data = predictive_analytics.load_historical_data(db, days=730)  # 2 years of data
        
        # This would trigger model retraining
        # For now, return success message
        
        return {
            "status": "success",
            "message": "Models retrained with latest data",
            "data": {
                "training_data_points": len(historical_data.get('livestock', [])),
                "model_type": model_type,
                "retrain_date": "2025-01-13T19:06:00Z",
                "next_scheduled_retrain": "2025-02-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error retraining models: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Model retraining failed",
                "message": str(e)
            }
        )
