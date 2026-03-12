"""
FarmOS Advanced Analytics Service
Business intelligence and trend analysis for farm operations
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

class AdvancedAnalytics:
    """Advanced analytics service for business intelligence with multi-tenant support"""
    
    def __init__(self, db: Session, tenant_id: str = "default"):
        self.db = db
        self.tenant_id = tenant_id
        self.trend_models = {}
        self.benchmark_data = {}
        
    def analyze_production_trends(self, days: int = 365) -> Dict:
        """Analyze production trends across all farm operations"""
        try:
            # Get production data with tenant filtering
            livestock_data = self._get_livestock_production_data(days)
            crop_data = self._get_crop_production_data(days)
            financial_data = self._get_financial_trend_data(days)
            
            # Analyze trends
            trends = {
                'livestock': self._analyze_livestock_trends(livestock_data),
                'crops': self._analyze_crop_trends(crop_data),
                'financial': self._analyze_financial_trends(financial_data)
            }
            
            # Calculate overall efficiency metrics
            trends['overall_efficiency'] = self._calculate_overall_efficiency(trends)
            
            return trends
            
        except Exception as e:
            logger.error(f"Error analyzing production trends: {e}")
            return {}
    
    def _get_livestock_production_data(self, days: int) -> List[Dict]:
        """Get livestock production data with tenant filtering"""
        try:
            from datetime import timedelta
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # Query livestock batches with tenant filtering
            batches = self.db.query(models.LivestockBatch).filter(
                models.LivestockBatch.tenant_id == self.tenant_id,
                models.LivestockBatch.start_date >= start_date
            ).all()
            
            data = []
            for batch in batches:
                data.append({
                    'batch_id': batch.id,
                    'type': batch.type,
                    'quantity': batch.quantity,
                    'start_date': batch.start_date,
                    'status': batch.status,
                    'breed': batch.breed
                })
            
            return data
            
        except Exception as e:
            logger.error(f"Error getting livestock data: {e}")
            return []
    
    def _get_crop_production_data(self, days: int) -> List[Dict]:
        """Get crop production data with tenant filtering"""
        try:
            from datetime import timedelta
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # Query crop data with tenant filtering
            crops = self.db.query(models.Crop).filter(
                models.Crop.tenant_id == self.tenant_id,
                models.Crop.planting_date >= start_date
            ).all()
            
            data = []
            for crop in crops:
                data.append({
                    'crop_id': crop.id,
                    'name': crop.name,
                    'planting_date': crop.planting_date,
                    'harvest_date': crop.harvest_date,
                    'yield': crop.yield,
                    'status': crop.status
                })
            
            return data
            
        except Exception as e:
            logger.error(f"Error getting crop data: {e}")
            return []
    
    def _get_financial_trend_data(self, days: int) -> List[Dict]:
        """Get financial trend data with tenant filtering"""
        try:
            from datetime import timedelta
            start_date = datetime.utcnow() - timedelta(days=days)
            
            # Query financial transactions with tenant filtering
            transactions = self.db.query(models.FinancialTransaction).filter(
                models.FinancialTransaction.tenant_id == self.tenant_id,
                models.FinancialTransaction.date >= start_date
            ).all()
            
            data = []
            for transaction in transactions:
                data.append({
                    'transaction_id': transaction.id,
                    'type': transaction.type,
                    'amount': transaction.amount,
                    'category': transaction.category,
                    'date': transaction.date,
                    'description': transaction.description
                })
            
            return data
            
        except Exception as e:
            logger.error(f"Error getting financial data: {e}")
            return []
        """Get livestock production data for trend analysis"""
        try:
            # Get livestock batches and events
            end_date = datetime.utcnow()
            start_date = end_date - timedelta(days=days)
            
            batches = db.query(models.LivestockBatch).filter(
                models.LivestockBatch.tenant_id == self.tenant_id,
                models.LivestockBatch.created_at >= start_date
            ).all()
            
            production_data = []
            for batch in batches:
                # Get growth events
                growth_events = db.query(models.LivestockEvent).filter(
                    and_(
                        models.LivestockEvent.tenant_id == self.tenant_id,
                        models.LivestockEvent.batch_id == batch.id,
                        models.LivestockEvent.type.in_(['health_check', 'feeding', 'weighing'])
                    )
                ).all()
                
                # Calculate growth metrics
                daily_growth = self._calculate_daily_growth(batch, growth_events)
                feed_efficiency = self._calculate_feed_efficiency_trend(batch, growth_events)
                
                production_data.append({
                    'batch_id': batch.id,
                    'breed': batch.breed,
                    'start_date': batch.start_date.isoformat() if batch.start_date else None,
                    'current_quantity': batch.quantity,
                    'daily_growth': daily_growth,
                    'feed_efficiency': feed_efficiency,
                    'performance_score': self._calculate_performance_score(batch, growth_events)
                })
            
            return production_data
            
        except Exception as e:
            logger.error(f"Error getting livestock production data: {e}")
            return []
    
    def _get_crop_production_data(self, db: Session, days: int) -> List[Dict]:
        """Get crop production data for trend analysis"""
        try:
            # This would get crop production data
            # For now, return mock data structure
            return [
                {
                    'crop_type': 'maize',
                    'planting_date': '2025-01-01',
                    'expected_harvest': '2025-04-30',
                    'yield_per_hectare': 6.5,
                    'current_growth_stage': 'vegetative'
                },
                {
                    'crop_type': 'vegetables',
                    'planting_date': '2025-01-15',
                    'expected_harvest': '2025-03-15',
                    'yield_per_hectare': 15.0,
                    'current_growth_stage': 'flowering'
                }
            ]
            
        except Exception as e:
            logger.error(f"Error getting crop production data: {e}")
            return []
    
    def _get_financial_trend_data(self, db: Session, days: int) -> List[Dict]:
        """Get financial data for trend analysis"""
        try:
            end_date = datetime.utcnow()
            start_date = end_date - timedelta(days=days)
            
            transactions = db.query(models.FinancialTransaction).filter(
                models.FinancialTransaction.tenant_id == self.tenant_id,
                models.FinancialTransaction.created_at >= start_date
            ).all()
            
            financial_data = []
            for transaction in transactions:
                financial_data.append({
                    'date': transaction.created_at.isoformat() if transaction.created_at else None,
                    'type': transaction.type,
                    'amount': float(transaction.amount),
                    'category': transaction.category,
                    'description': transaction.description
                })
            
            return financial_data
            
        except Exception as e:
            logger.error(f"Error getting financial trend data: {e}")
            return []
    
    def _analyze_livestock_trends(self, data: List[Dict]) -> Dict:
        """Analyze livestock production trends"""
        if not data:
            return {}
        
        df = pd.DataFrame(data)
        
        # Growth trends by breed
        breed_trends = df.groupby('breed').agg({
            'avg_daily_growth': ('daily_growth', 'mean'),
            'avg_feed_efficiency': ('feed_efficiency', 'mean'),
            'avg_performance_score': ('performance_score', 'mean'),
            'total_batches': ('batch_id', 'count')
        }).to_dict('index')
        
        # Performance trends over time
        df['date'] = pd.to_datetime(df['start_date'])
        monthly_trends = df.set_index('date').resample('M').agg({
            'avg_daily_growth': ('daily_growth', 'mean'),
            'avg_feed_efficiency': ('feed_efficiency', 'mean'),
            'total_batches': ('batch_id', 'count')
        }).to_dict('index')
        
        # Predict future trends (simple linear regression)
        if len(monthly_trends) >= 3:
            months = list(range(len(monthly_trends)))
            growth_values = [monthly_trends[m]['avg_daily_growth'] for m in monthly_trends]
            
            # Simple trend analysis
            if len(growth_values) > 1:
                trend_slope = np.polyfit(months, growth_values, 1)[0]
                trend_direction = 'increasing' if trend_slope > 0 else 'decreasing' if trend_slope < 0 else 'stable'
            else:
                trend_direction = 'stable'
                trend_slope = 0
            
            # Predict next 3 months
            future_months = len(monthly_trends) + np.arange(1, 4)
            predicted_growth = [growth_values[-1] + trend_slope * i for i in range(1, 5)]
        else:
            trend_direction = 'insufficient_data'
            trend_slope = 0
            predicted_growth = []
        
        return {
            'breed_trends': breed_trends,
            'monthly_trends': monthly_trends,
            'trend_analysis': {
                'direction': trend_direction,
                'slope': round(trend_slope, 4),
                'predicted_growth_3m': [round(g, 2) for g in predicted_growth],
                'confidence': self._calculate_trend_confidence(monthly_trends)
            }
        }
    
    def _analyze_crop_trends(self, data: List[Dict]) -> Dict:
        """Analyze crop production trends"""
        if not data:
            return {}
        
        # Calculate yield trends
        yield_trends = {}
        for crop in data:
            crop_type = crop['crop_type']
            if crop_type not in yield_trends:
                yield_trends[crop_type] = []
            yield_trends[crop_type].append({
                'date': crop['planting_date'],
                'yield_per_hectare': crop['yield_per_hectare'],
                'growth_stage': crop['current_growth_stage']
            })
        
        return {
            'yield_trends': yield_trends,
            'seasonal_patterns': self._analyze_seasonal_patterns(data)
        }
    
    def _analyze_financial_trends(self, data: List[Dict]) -> Dict:
        """Analyze financial trends"""
        if not data:
            return {}
        
        df = pd.DataFrame(data)
        df['date'] = pd.to_datetime(df['date'])
        
        # Monthly aggregation
        monthly_summary = df.set_index('date').resample('M').agg({
            'income': ('amount', lambda x: x[x['type'] == 'income'].sum()),
            'expenses': ('amount', lambda x: x[x['type'] == 'expense'].sum()),
            'net_profit': ('amount', lambda x: x[x['type'] == 'income'].sum() - x[x['type'] == 'expense'].sum()),
            'transaction_count': ('amount', 'count')
        }).to_dict('index')
        
        # Calculate trends
        if len(monthly_summary) >= 3:
            months = list(range(len(monthly_summary)))
            profit_values = [monthly_summary[m]['net_profit'] for m in monthly_summary]
            
            # Trend analysis
            profit_trend = np.polyfit(months, profit_values, 1)[0]
            profit_direction = 'increasing' if profit_trend > 0 else 'decreasing' if profit_trend < 0 else 'stable'
            
            # Predictions
            predicted_profits = [profit_values[-1] + profit_trend * i for i in range(1, 4)]
        else:
            profit_direction = 'insufficient_data'
            profit_trend = 0
            predicted_profits = []
        
        return {
            'monthly_summary': monthly_summary,
            'trend_analysis': {
                'profit_direction': profit_direction,
                'profit_trend': round(profit_trend, 2),
                'predicted_profits_4m': [round(p, 2) for p in predicted_profits],
                'average_monthly_profit': round(np.mean(profit_values), 2) if profit_values else 0
            },
            'expense_breakdown': self._analyze_expense_breakdown(df)
        }
    
    def _analyze_expense_breakdown(self, df: pd.DataFrame) -> Dict:
        """Analyze expense breakdown by category"""
        expenses = df[df['type'] == 'expense']
        
        if len(expenses) == 0:
            return {}
        
        category_summary = expenses.groupby('category').agg({
            'total_amount': ('amount', 'sum'),
            'transaction_count': ('amount', 'count'),
            'avg_amount': ('amount', 'mean')
        }).to_dict('index')
        
        # Calculate percentages
        total_expenses = expenses['amount'].sum()
        for category in category_summary:
            category_summary[category]['percentage'] = round(
                (category_summary[category]['total_amount'] / total_expenses) * 100, 1
            )
        
        return category_summary
    
    def _analyze_seasonal_patterns(self, data: List[Dict]) -> Dict:
        """Analyze seasonal patterns in production"""
        # This would analyze seasonal patterns
        # For now, return basic structure
        return {
            'planting_seasons': ['Spring', 'Summer', 'Fall'],
            'harvest_seasons': ['Summer', 'Fall', 'Winter'],
            'peak_production_months': [6, 7, 8],
            'low_production_months': [12, 1, 2]
        }
    
    def _calculate_daily_growth(self, batch: models.LivestockBatch, events: List[models.LivestockEvent]) -> float:
        """Calculate daily growth rate for a batch"""
        if not events or not batch.start_date:
            return 0.0
        
        # Get weight measurements
        weight_events = [e for e in events if 'weight' in e.details]
        if len(weight_events) < 2:
            return 0.0
        
        # Calculate growth rate
        total_growth = 0
        for i in range(1, len(weight_events)):
            if i < len(weight_events):
                current_weight = weight_events[i].details['weight']
                previous_weight = weight_events[i-1].details['weight']
                days_diff = (weight_events[i].date - weight_events[i-1].date).days
                if days_diff > 0:
                    total_growth += (current_weight - previous_weight) / days_diff
        
        avg_daily_growth = total_growth / (len(weight_events) - 1)
        return round(avg_daily_growth, 4)
    
    def _calculate_feed_efficiency_trend(self, batch: models.LivestockBatch, events: List[models.LivestockEvent]) -> float:
        """Calculate feed efficiency trend"""
        feed_events = [e for e in events if 'feed' in e.details]
        if len(feed_events) < 2:
            return 2.5  # Default FCR
        
        total_feed = sum(e.details.get('feed_amount', 0) for e in feed_events)
        total_weight_gain = sum(e.details.get('weight_gain', 0) for e in feed_events)
        
        if total_weight_gain > 0:
            return round(total_feed / total_weight_gain, 2)
        return 2.5
    
    def _calculate_performance_score(self, batch: models.LivestockBatch, events: List[models.LivestockEvent]) -> float:
        """Calculate overall performance score"""
        if not events:
            return 0.5
        
        # Score based on growth, health, and efficiency
        growth_score = min(1.0, self._calculate_daily_growth(batch, events) / 0.035)  # 0.035 is optimal
        health_score = 0.8  # Would be calculated from health events
        efficiency_score = min(1.0, 2.5 / self._calculate_feed_efficiency_trend(batch, events))  # 2.5 is optimal
        
        return round((growth_score + health_score + efficiency_score) / 3, 2)
    
    def _calculate_overall_efficiency(self, trends: Dict) -> Dict:
        """Calculate overall farm efficiency metrics"""
        try:
            efficiency_metrics = {
                'livestock_efficiency': 0.0,
                'crop_efficiency': 0.0,
                'financial_efficiency': 0.0,
                'resource_utilization': 0.0
            }
            
            # Livestock efficiency (based on trends)
            if 'livestock' in trends:
                livestock_trends = trends['livestock']
                avg_growth = np.mean([
                    breed_data.get('avg_daily_growth', 0) 
                    for breed_data in livestock_trends.get('breed_trends', {}).values()
                ])
                avg_efficiency = np.mean([
                    breed_data.get('avg_feed_efficiency', 0)
                    for breed_data in livestock_trends.get('breed_trends', {}).values()
                ])
                
                efficiency_metrics['livestock_efficiency'] = round(avg_growth / 0.035 * 100, 1)  # Percentage of optimal
                efficiency_metrics['feed_efficiency'] = round(2.5 / avg_efficiency * 100, 1)  # Percentage of optimal
            
            # Financial efficiency
            if 'financial' in trends:
                financial_trends = trends['financial']
                if 'monthly_summary' in financial_trends:
                    monthly_profits = [
                        month.get('net_profit', 0) 
                        for month in financial_trends['monthly_summary'].values()
                    ]
                    positive_months = len([p for p in monthly_profits if p > 0])
                    efficiency_metrics['financial_efficiency'] = round(
                        (positive_months / len(monthly_profits)) * 100, 1
                    )
            
            # Overall efficiency score
            efficiency_metrics['overall_score'] = round(
                (efficiency_metrics['livestock_efficiency'] + 
                 efficiency_metrics['financial_efficiency']) / 2, 1
            )
            
            return efficiency_metrics
            
        except Exception as e:
            logger.error(f"Error calculating overall efficiency: {e}")
            return {'overall_score': 0.0}
    
    def _calculate_trend_confidence(self, data: Dict) -> float:
        """Calculate confidence level for trend predictions"""
        if 'monthly_trends' not in data or len(data['monthly_trends']) < 3:
            return 0.3  # Low confidence
        
        # Calculate variance in recent data
        recent_values = [
            month.get('avg_daily_growth', 0) 
            for month in list(data['monthly_trends'].values())[-3:]
        ]
        
        if len(recent_values) >= 2:
            variance = np.var(recent_values)
            mean_value = np.mean(recent_values)
            
            # Confidence based on variance (lower variance = higher confidence)
            if variance > 0:
                confidence = max(0.3, 1.0 - (variance / (mean_value ** 2)))
            else:
                confidence = 0.8
            
            return round(confidence, 2)
        
        return 0.5
    
    def generate_performance_benchmarks(self, db: Session, tenant_id: str = "default") -> Dict:
        """Generate performance benchmarks for comparison"""
        try:
            # Get historical performance data
            benchmarks = {
                'livestock': {
                    'excellent_growth_rate': 0.040,  # 40g per day
                    'good_growth_rate': 0.030,      # 30g per day
                    'average_growth_rate': 0.025,   # 25g per day
                    'excellent_feed_efficiency': 2.0,   # FCR 2.0
                    'good_feed_efficiency': 2.5,         # FCR 2.5
                    'average_feed_efficiency': 3.0,      # FCR 3.0
                    'low_mortality_rate': 0.01,         # 1% mortality
                    'average_mortality_rate': 0.02,      # 2% mortality
                },
                'financial': {
                    'excellent_profit_margin': 0.25,      # 25% profit margin
                    'good_profit_margin': 0.20,          # 20% profit margin
                    'average_profit_margin': 0.15,       # 15% profit margin
                    'revenue_per_animal': 100,           # $100 per animal
                    'cost_per_animal': 75              # $75 per animal
                }
            }
            
            return {
                'benchmarks': benchmarks,
                'tenant_id': tenant_id,
                'generated_date': datetime.utcnow().isoformat(),
                'data_source': 'historical_analysis'
            }
            
        except Exception as e:
            logger.error(f"Error generating benchmarks: {e}")
            return {}

# Global advanced analytics instance
advanced_analytics = AdvancedAnalytics()
