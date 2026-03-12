"""
FarmOS Advanced Analytics Service - Clean Version
Business intelligence and trend analysis for farm operations with multi-tenant support
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
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
    
    def _analyze_livestock_trends(self, data: List[Dict]) -> Dict:
        """Analyze livestock production trends"""
        if not data:
            return {'trend': 'no_data', 'insights': []}
        
        # Convert to DataFrame for analysis
        df = pd.DataFrame(data)
        
        # Calculate trends
        trends = {
            'total_batches': len(df),
            'total_animals': df['quantity'].sum(),
            'batch_types': df['type'].value_counts().to_dict(),
            'status_distribution': df['status'].value_counts().to_dict(),
            'breed_distribution': df['breed'].value_counts().to_dict(),
            'average_batch_size': df['quantity'].mean(),
            'trend_direction': self._calculate_trend_direction(df),
            'insights': self._generate_livestock_insights(df)
        }
        
        return trends
    
    def _analyze_crop_trends(self, data: List[Dict]) -> Dict:
        """Analyze crop production trends"""
        if not data:
            return {'trend': 'no_data', 'insights': []}
        
        df = pd.DataFrame(data)
        
        trends = {
            'total_crops': len(df),
            'crop_varieties': df['name'].value_counts().to_dict(),
            'status_distribution': df['status'].value_counts().to_dict(),
            'average_yield': df['yield'].mean() if 'yield' in df.columns else 0,
            'trend_direction': self._calculate_trend_direction(df),
            'insights': self._generate_crop_insights(df)
        }
        
        return trends
    
    def _analyze_financial_trends(self, data: List[Dict]) -> Dict:
        """Analyze financial trends"""
        if not data:
            return {'trend': 'no_data', 'insights': []}
        
        df = pd.DataFrame(data)
        
        # Calculate financial metrics
        income_data = df[df['type'] == 'INCOME']
        expense_data = df[df['type'] == 'EXPENSE']
        
        trends = {
            'total_transactions': len(df),
            'total_income': income_data['amount'].sum() if not income_data.empty else 0,
            'total_expenses': expense_data['amount'].sum() if not expense_data.empty else 0,
            'net_profit': (income_data['amount'].sum() if not income_data.empty else 0) - 
                        (expense_data['amount'].sum() if not expense_data.empty else 0),
            'transaction_categories': df['category'].value_counts().to_dict(),
            'average_transaction': df['amount'].mean(),
            'trend_direction': self._calculate_trend_direction(df),
            'insights': self._generate_financial_insights(df)
        }
        
        return trends
    
    def _calculate_trend_direction(self, df: pd.DataFrame) -> str:
        """Calculate trend direction based on data"""
        if len(df) < 2:
            return 'insufficient_data'
        
        # Simple trend calculation based on recent vs older data
        mid_point = len(df) // 2
        recent_data = df.iloc[mid_point:]
        older_data = df.iloc[:mid_point]
        
        if 'quantity' in df.columns:
            recent_avg = recent_data['quantity'].mean()
            older_avg = older_data['quantity'].mean()
            if recent_avg > older_avg * 1.1:
                return 'increasing'
            elif recent_avg < older_avg * 0.9:
                return 'decreasing'
            else:
                return 'stable'
        
        return 'stable'
    
    def _generate_livestock_insights(self, df: pd.DataFrame) -> List[str]:
        """Generate insights from livestock data"""
        insights = []
        
        if len(df) > 0:
            most_common_type = df['type'].mode().iloc[0] if not df['type'].mode().empty else 'unknown'
            insights.append(f"Most common livestock type: {most_common_type}")
            
            if df['quantity'].mean() > 100:
                insights.append("Large scale operation detected")
            elif df['quantity'].mean() < 50:
                insights.append("Small scale operation detected")
            
            active_batches = len(df[df['status'] == 'active'])
            insights.append(f"Active batches: {active_batches}")
        
        return insights
    
    def _generate_crop_insights(self, df: pd.DataFrame) -> List[str]:
        """Generate insights from crop data"""
        insights = []
        
        if len(df) > 0:
            most_common_crop = df['name'].mode().iloc[0] if not df['name'].mode().empty else 'unknown'
            insights.append(f"Most common crop: {most_common_crop}")
            
            if 'yield' in df.columns and df['yield'].mean() > 0:
                insights.append(f"Average yield: {df['yield'].mean():.2f}")
        
        return insights
    
    def _generate_financial_insights(self, df: pd.DataFrame) -> List[str]:
        """Generate insights from financial data"""
        insights = []
        
        if len(df) > 0:
            income_count = len(df[df['type'] == 'INCOME'])
            expense_count = len(df[df['type'] == 'EXPENSE'])
            
            insights.append(f"Income transactions: {income_count}")
            insights.append(f"Expense transactions: {expense_count}")
            
            if income_count > 0 and expense_count > 0:
                income_total = df[df['type'] == 'INCOME']['amount'].sum()
                expense_total = df[df['type'] == 'EXPENSE']['amount'].sum()
                
                if income_total > expense_total:
                    insights.append("Positive cash flow detected")
                else:
                    insights.append("Negative cash flow detected")
        
        return insights
    
    def _calculate_overall_efficiency(self, trends: Dict) -> Dict:
        """Calculate overall efficiency metrics"""
        efficiency = {
            'livestock_efficiency': 0,
            'crop_efficiency': 0,
            'financial_efficiency': 0,
            'overall_score': 0
        }
        
        # Calculate efficiency scores (simplified)
        if trends.get('livestock', {}).get('total_batches', 0) > 0:
            efficiency['livestock_efficiency'] = min(100, trends['livestock']['total_batches'] * 10)
        
        if trends.get('crops', {}).get('total_crops', 0) > 0:
            efficiency['crop_efficiency'] = min(100, trends['crops']['total_crops'] * 15)
        
        if trends.get('financial', {}).get('total_transactions', 0) > 0:
            efficiency['financial_efficiency'] = min(100, trends['financial']['total_transactions'] * 5)
        
        # Calculate overall score
        scores = [efficiency['livestock_efficiency'], efficiency['crop_efficiency'], efficiency['financial_efficiency']]
        efficiency['overall_score'] = sum(scores) / len(scores) if scores else 0
        
        return efficiency
    
    def get_dashboard_analytics(self) -> Dict:
        """Get comprehensive dashboard analytics"""
        try:
            # Get recent data (last 30 days)
            recent_trends = self.analyze_production_trends(days=30)
            
            # Get key metrics
            metrics = {
                'livestock_count': self._get_livestock_count(),
                'crop_count': self._get_crop_count(),
                'financial_summary': self._get_financial_summary(),
                'efficiency_score': recent_trends.get('overall_efficiency', {}).get('overall_score', 0),
                'recent_trends': recent_trends
            }
            
            return metrics
            
        except Exception as e:
            logger.error(f"Error getting dashboard analytics: {e}")
            return {}
    
    def _get_livestock_count(self) -> int:
        """Get total livestock count"""
        try:
            return self.db.query(models.LivestockBatch).filter(
                models.LivestockBatch.tenant_id == self.tenant_id,
                models.LivestockBatch.status == 'active'
            ).count()
        except Exception as e:
            logger.error(f"Error getting livestock count: {e}")
            return 0
    
    def _get_crop_count(self) -> int:
        """Get total crop count"""
        try:
            return self.db.query(models.Crop).filter(
                models.Crop.tenant_id == self.tenant_id,
                models.Crop.status == 'active'
            ).count()
        except Exception as e:
            logger.error(f"Error getting crop count: {e}")
            return 0
    
    def _get_financial_summary(self) -> Dict:
        """Get financial summary"""
        try:
            # Get recent transactions
            start_date = datetime.utcnow() - timedelta(days=30)
            
            transactions = self.db.query(models.FinancialTransaction).filter(
                models.FinancialTransaction.tenant_id == self.tenant_id,
                models.FinancialTransaction.date >= start_date
            ).all()
            
            income = sum(t.amount for t in transactions if t.type == 'INCOME')
            expenses = sum(t.amount for t in transactions if t.type == 'EXPENSE')
            
            return {
                'total_income': income,
                'total_expenses': expenses,
                'net_profit': income - expenses,
                'transaction_count': len(transactions)
            }
            
        except Exception as e:
            logger.error(f"Error getting financial summary: {e}")
            return {'total_income': 0, 'total_expenses': 0, 'net_profit': 0, 'transaction_count': 0}
