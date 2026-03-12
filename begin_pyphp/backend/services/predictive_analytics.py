"""
Predictive Analytics Engine - Phase 4 Feature
Advanced machine learning and statistical analysis for farm optimization
Derived from Begin Reference System
"""

import logging
import asyncio
import numpy as np
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
from decimal import Decimal
from collections import defaultdict

logger = logging.getLogger(__name__)

from ..common import models

class PredictiveAnalyticsService:
    """Advanced predictive analytics and machine learning engine"""
    
    def __init__(self, db: Session):
        self.db = db
        self.prediction_models = {
            'crop_yield': {
                'features': ['temperature', 'rainfall', 'soil_moisture', 'nitrogen', 'phosphorus', 'potassium'],
                'target': 'yield',
                'algorithm': 'linear_regression'
            },
            'livestock_growth': {
                'features': ['feed_intake', 'temperature', 'humidity', 'weight', 'age'],
                'target': 'weight_gain',
                'algorithm': 'polynomial_regression'
            },
            'disease_outbreak': {
                'features': ['temperature', 'humidity', 'animal_density', 'symptoms_score'],
                'target': 'disease_probability',
                'algorithm': 'logistic_regression'
            },
            'market_price': {
                'features': ['supply', 'demand', 'season', 'weather_index'],
                'target': 'price',
                'algorithm': 'time_series'
            }
        }
        
    def load_historical_data(self, db: Session, days: int = 365) -> Dict:
        """Load historical data for training models"""
        try:
            # Load livestock data
            livestock_data = db.query(models.LivestockBatch).all()
            
            # Load financial data
            financial_data = db.query(models.FinancialTransaction).filter(
                models.FinancialTransaction.created_at >= datetime.utcnow() - timedelta(days=days)
            ).all()
            
            # Load inventory data
            inventory_data = db.query(models.InventoryItem).all()
            
            # Load weather data (if available)
            weather_data = db.query(models.WeatherData).filter(
                models.WeatherData.timestamp >= datetime.utcnow() - timedelta(days=days)
            ).all() if hasattr(models, 'WeatherData') else []
            
            return {
                'livestock': [self._serialize_livestock(l) for l in livestock_data],
                'financial': [self._serialize_financial(f) for f in financial_data],
                'inventory': [self._serialize_inventory(i) for i in inventory_data],
                'weather': [self._serialize_weather(w) for w in weather_data]
            }
            
        except Exception as e:
            logger.error(f"Error loading historical data: {e}")
            return {}
    
    def _serialize_livestock(self, livestock) -> Dict:
        """Serialize livestock data for analysis"""
        return {
            'id': livestock.id,
            'type': livestock.type,
            'quantity': livestock.quantity,
            'start_date': livestock.start_date.isoformat() if livestock.start_date else None,
            'status': livestock.status,
            'breed': livestock.breed,
            'location': livestock.location
        }
    
    def _serialize_financial(self, transaction) -> Dict:
        """Serialize financial transaction for analysis"""
        return {
            'id': transaction.id,
            'type': transaction.type,
            'amount': float(transaction.amount),
            'category': transaction.category,
            'created_at': transaction.created_at.isoformat() if transaction.created_at else None,
            'description': transaction.description
        }
    
    def _serialize_inventory(self, item) -> Dict:
        """Serialize inventory item for analysis"""
        return {
            'id': item.id,
            'name': item.name,
            'quantity': item.quantity,
            'low_stock_threshold': item.low_stock_threshold,
            'unit_cost': float(item.unit_cost) if hasattr(item, 'unit_cost') else 0,
            'last_updated': item.updated_at.isoformat() if hasattr(item, 'updated_at') and item.updated_at else None
        }
    
    def _serialize_weather(self, weather) -> Dict:
        """Serialize weather data for analysis"""
        return {
            'timestamp': weather.timestamp.isoformat() if weather.timestamp else None,
            'temperature': float(weather.temperature) if hasattr(weather, 'temperature') else 0,
            'humidity': float(weather.humidity) if hasattr(weather, 'humidity') else 0,
            'rainfall': float(weather.rainfall) if hasattr(weather, 'rainfall') else 0
        }
    
    def predict_feed_requirements(self, livestock_data: List[Dict]) -> Dict:
        """Predict feed requirements based on livestock data"""
        try:
            if not livestock_data:
                return {}
            
            # Convert to DataFrame
            df = pd.DataFrame(livestock_data)
            
            # Group by livestock type and calculate total quantities
            livestock_summary = df.groupby('type').agg({
                'quantity': 'sum',
                'breed': lambda x: x.mode()[0] if not x.mode().empty else 'mixed'
            }).to_dict('index')
            
            # Feed requirement formulas (kg per animal per day)
            feed_requirements = {
                'poultry': 0.15,    # 150g per day
                'pig': 2.5,        # 2.5kg per day
                'cattle': 15.0,      # 15kg per day
                'fish': 0.02        # 2% of body weight per day
            }
            
            predictions = {}
            for livestock_type, summary in livestock_summary.items():
                daily_requirement = feed_requirements.get(livestock_type.lower(), 1.0)
                total_daily = summary['quantity'] * daily_requirement
                monthly_requirement = total_daily * 30
                
                predictions[livestock_type] = {
                    'current_quantity': summary['quantity'],
                    'daily_feed_kg': round(total_daily, 2),
                    'monthly_feed_kg': round(monthly_requirement, 2),
                    'recommended_breed': summary['breed'],
                    'feed_efficiency': self._calculate_feed_efficiency(livestock_type, summary['breed']),
                    'cost_projection': self._project_feed_cost(monthly_requirement)
                }
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error predicting feed requirements: {e}")
            return {}
    
    def _calculate_feed_efficiency(self, livestock_type: str, breed: str) -> float:
        """Calculate feed efficiency score"""
        efficiency_scores = {
            'poultry': {
                'broiler': 0.85,
                'layer': 0.75,
                'indigenous': 0.65
            },
            'pig': {
                'large_white': 0.80,
                'landrace': 0.75,
                'crossbred': 0.70
            },
            'cattle': {
                'holstein': 0.85,
                'angus': 0.75,
                'indigenous': 0.65
            }
        }
        
        return efficiency_scores.get(livestock_type.lower(), {}).get(breed.lower(), 0.70)
    
    def _project_feed_cost(self, monthly_feed_kg: float) -> Dict:
        """Project monthly feed costs"""
        # Average feed costs per kg (can be made configurable)
        feed_costs = {
            'poultry_feed': 0.45,    # $0.45 per kg
            'pig_feed': 0.35,        # $0.35 per kg
            'cattle_feed': 0.25,       # $0.25 per kg
            'fish_feed': 1.20,         # $1.20 per kg
            'supplements': 2.50          # $2.50 per kg
        }
        
        # Calculate projected costs
        total_cost = monthly_feed_kg * 0.40  # Average feed cost
        supplement_cost = monthly_feed_kg * 0.05  # 5% for supplements
        
        return {
            'total_monthly_cost': round(total_cost + supplement_cost, 2),
            'cost_per_kg': round((total_cost + supplement_cost) / monthly_feed_kg, 2),
            'supplement_budget': round(supplement_cost, 2)
        }
    
    def predict_revenue(self, financial_data: List[Dict], livestock_data: List[Dict]) -> Dict:
        """Predict revenue based on historical data and livestock trends"""
        try:
            if not financial_data:
                return {}
            
            # Convert to DataFrames
            financial_df = pd.DataFrame(financial_data)
            livestock_df = pd.DataFrame(livestock_data)
            
            # Calculate historical revenue trends
            financial_df['created_at'] = pd.to_datetime(financial_df['created_at'])
            monthly_revenue = financial_df[financial_df['type'] == 'income'].groupby(
                pd.Grouper(key=financial_df['created_at'].dt.to_period('M'))
            )['amount'].sum()
            
            # Calculate livestock growth trends
            current_livestock = livestock_df.groupby('type')['quantity'].sum()
            
            # Simple linear regression for trend prediction
            if len(monthly_revenue) >= 3:
                x = np.arange(len(monthly_revenue))
                y = monthly_revenue.values
                
                # Calculate trend
                slope, intercept = np.polyfit(x, y, 1)
                trend = slope
                
                # Predict next 3 months
                future_months = 3
                predicted_revenue = []
                
                for i in range(1, future_months + 1):
                    next_value = intercept + (len(monthly_revenue) + i) * trend
                    predicted_revenue.append(max(0, next_value))
                
                # Calculate confidence based on historical variance
                variance = np.var(y)
                confidence_interval = 1.96 * np.sqrt(variance)  # 95% confidence
                
                return {
                    'historical_trend': 'increasing' if trend > 0 else 'decreasing' if trend < 0 else 'stable',
                    'predicted_revenue_3m': [round(r, 2) for r in predicted_revenue],
                    'confidence_interval': round(confidence_interval, 2),
                    'current_livestock_value': current_livestock.to_dict(),
                    'revenue_growth_rate': round((trend / np.mean(y)) * 100, 2) if np.mean(y) > 0 else 0
                }
            
            return {}
            
        except Exception as e:
            logger.error(f"Error predicting revenue: {e}")
            return {}
    
    def predict_inventory_needs(self, inventory_data: List[Dict], historical_usage: List[Dict] = None) -> Dict:
        """Predict inventory needs and reorder points"""
        try:
            if not inventory_data:
                return {}
            
            df = pd.DataFrame(inventory_data)
            
            predictions = {}
            for _, item in df.iterrows():
                item_name = item['name']
                current_quantity = item['quantity']
                threshold = item['low_stock_threshold']
                
                # Calculate daily usage rate if historical data available
                daily_usage = self._calculate_daily_usage(item_name, historical_usage)
                
                if daily_usage > 0:
                    # Predict when stock will run out
                    days_until_empty = (current_quantity - threshold) / daily_usage
                    
                    if days_until_empty <= 7:  # Alert if less than 7 days
                        urgency = 'high'
                    elif days_until_empty <= 14:  # Warning if less than 14 days
                        urgency = 'medium'
                    else:
                        urgency = 'low'
                    
                    # Calculate recommended order quantity
                    recommended_order = max(
                        threshold * 2,  # Order enough for 2 cycles
                        daily_usage * 30   # Or 30 days supply
                    )
                    
                    predictions[item_name] = {
                        'current_quantity': current_quantity,
                        'daily_usage': round(daily_usage, 2),
                        'days_until_empty': max(0, round(days_until_empty, 1)),
                        'urgency': urgency,
                        'recommended_order_quantity': round(recommended_order, 0),
                        'estimated_cost': round(recommended_order * item.get('unit_cost', 1), 2),
                        'reorder_point': threshold
                    }
                else:
                    predictions[item_name] = {
                        'current_quantity': current_quantity,
                        'status': 'adequate',
                        'next_check_date': (datetime.utcnow() + timedelta(days=30)).isoformat()
                    }
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error predicting inventory needs: {e}")
            return {}
    
    def _calculate_daily_usage(self, item_name: str, historical_usage: List[Dict]) -> float:
        """Calculate daily usage rate for an item"""
        if not historical_usage:
            return 0
        
        # Simple calculation: total usage / number of days
        total_usage = sum(item.get('quantity_used', 0) for item in historical_usage)
        days = len(historical_usage)
        
        return total_usage / max(1, days)
    
    def predict_optimal_harvest_time(self, crop_data: List[Dict], weather_data: List[Dict] = None) -> Dict:
        """Predict optimal harvest times based on crop data and weather patterns"""
        try:
            if not crop_data:
                return {}
            
            df = pd.DataFrame(crop_data)
            
            predictions = {}
            for _, crop in df.iterrows():
                crop_type = crop['type']
                planting_date = crop.get('planting_date')
                
                if planting_date:
                    # Standard growth periods (days)
                    growth_periods = {
                        'maize': 120,
                        'wheat': 110,
                        'vegetables': 60,
                        'tobacco': 90,
                        'sorghum': 100
                    }
                    
                    growth_period = growth_periods.get(crop_type.lower(), 90)
                    
                    # Predict harvest date
                    planting_dt = datetime.fromisoformat(planting_date) if isinstance(planting_date, str) else planting_date
                    predicted_harvest = planting_dt + timedelta(days=growth_period)
                    
                    # Adjust based on weather patterns if available
                    weather_adjustment = self._calculate_weather_adjustment(weather_data, crop_type)
                    adjusted_harvest = predicted_harvest + timedelta(days=weather_adjustment)
                    
                    predictions[crop['name']] = {
                        'planting_date': planting_date,
                        'predicted_harvest_date': adjusted_harvest.isoformat(),
                        'growth_period_days': growth_period,
                        'weather_adjustment': weather_adjustment,
                        'optimal_yield': self._predict_yield(crop_type, growth_period),
                        'readiness_indicators': self._get_readiness_indicators(planting_dt, adjusted_harvest)
                    }
            
            return predictions
            
        except Exception as e:
            logger.error(f"Error predicting harvest time: {e}")
            return {}
    
    def _calculate_weather_adjustment(self, weather_data: List[Dict], crop_type: str) -> int:
        """Calculate weather adjustment for harvest prediction"""
        if not weather_data:
            return 0
        
        # Simple weather adjustment based on rainfall and temperature
        avg_rainfall = np.mean([w.get('rainfall', 0) for w in weather_data])
        avg_temp = np.mean([w.get('temperature', 20) for w in weather_data])
        
        # Adjustment factors
        if crop_type.lower() in ['maize', 'wheat', 'sorghum']:
            if avg_rainfall < 50:  # Low rainfall
                return 7  # Add 7 days
            elif avg_rainfall > 150:  # High rainfall
                return -5  # Subtract 5 days
        
        return 0
    
    def _predict_yield(self, crop_type: str, growth_period: int) -> Dict:
        """Predict optimal yield based on crop type and growth period"""
        # Base yield predictions (tons per hectare)
        yield_predictions = {
            'maize': {'min': 4.0, 'max': 8.0, 'optimal': 6.0},
            'wheat': {'min': 3.0, 'max': 6.0, 'optimal': 4.5},
            'vegetables': {'min': 10.0, 'max': 25.0, 'optimal': 18.0},
            'tobacco': {'min': 2.0, 'max': 4.0, 'optimal': 3.0},
            'sorghum': {'min': 2.5, 'max': 5.0, 'optimal': 3.8}
        }
        
        return yield_predictions.get(crop_type.lower(), {'min': 0, 'max': 0, 'optimal': 0})
    
    def _get_readiness_indicators(self, planting_date: datetime, harvest_date: datetime) -> List[Dict]:
        """Get readiness indicators for crop growth"""
        total_days = (harvest_date - planting_date).days
        indicators = []
        
        # Key growth stages (percentage of total growth)
        stages = [0.2, 0.4, 0.6, 0.8, 1.0]  # 20%, 40%, 60%, 80%, 100%
        
        for stage in stages:
            stage_date = planting_date + timedelta(days=int(total_days * stage))
            indicators.append({
                'date': stage_date.isoformat(),
                'stage': f"{int(stage * 100)}%",
                'description': self._get_growth_description(int(stage * 100))
            })
        
        return indicators
    
    def _get_growth_description(self, percentage: int) -> str:
        """Get description for growth stage"""
        descriptions = {
            20: "Germination",
            40: "Vegetative Growth",
            60: "Flowering",
            80: "Fruit Development",
            100: "Harvest Ready"
        }
        return descriptions.get(percentage, "Growing")

# Global analytics instance
predictive_analytics = PredictiveAnalytics()
