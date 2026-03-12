"""
Enhanced CRM System - Phase 3 Feature
Advanced customer relationship management with lead scoring, sales forecasting, and churn prediction
Derived from Begin Reference System
"""

import logging
import asyncio
import numpy as np
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
from decimal import Decimal
import json
from collections import defaultdict

logger = logging.getLogger(__name__)

from ..common import models

class EnhancedCRMService:
    """Advanced CRM system with AI-powered features"""
    
    def __init__(self, db: Session):
        self.db = db
        self.lead_scoring_model = {
            'industry_weights': {
                'agriculture': 1.0,
                'food_processing': 0.9,
                'retail': 0.7,
                'other': 0.5
            },
            'size_weights': {
                'large': 1.0,
                'medium': 0.8,
                'small': 0.6,
                'startup': 0.4
            },
            'activity_weights': {
                'website_visit': 0.1,
                'email_open': 0.2,
                'demo_request': 0.4,
                'proposal_request': 0.6,
                'contract_review': 0.8
            }
        }
        self.churn_risk_factors = {
            'low_activity': 0.3,
            'support_tickets': 0.2,
            'payment_delays': 0.3,
            'competitor_engagement': 0.2
        }

    async def score_lead(self, lead_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Score lead using AI-powered algorithm"""
        try:
            # Create lead record
            lead = models.Lead(
                lead_id=lead_data['lead_id'],
                company_name=lead_data['company_name'],
                industry=lead_data.get('industry'),
                company_size=lead_data.get('company_size'),
                contact_name=lead_data.get('contact_name'),
                email=lead_data.get('email'),
                phone=lead_data.get('phone'),
                location=lead_data.get('location'),
                source=lead_data.get('source'),
                description=lead_data.get('description'),
                status='new',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(lead)
            self.db.flush()
            
            # Calculate lead score
            lead_score = await self._calculate_lead_score(lead_data)
            
            # Determine lead grade
            lead_grade = await self._determine_lead_grade(lead_score)
            
            # Predict conversion probability
            conversion_probability = await self._predict_conversion_probability(lead_data, lead_score)
            
            # Update lead with scoring results
            lead.lead_score = lead_score
            lead.lead_grade = lead_grade
            lead.conversion_probability = conversion_probability
            lead.scoring_data_json = json.dumps({
                'score_components': await self._get_score_components(lead_data),
                'scoring_timestamp': datetime.utcnow().isoformat()
            })
            
            self.db.commit()
            
            # Create follow-up tasks based on score
            await self._create_follow_up_tasks(lead, lead_score, tenant_id)
            
            return {
                "success": True,
                "lead_id": lead.lead_id,
                "company_name": lead.company_name,
                "lead_score": lead_score,
                "lead_grade": lead_grade,
                "conversion_probability": conversion_probability,
                "score_components": await self._get_score_components(lead_data),
                "recommended_actions": await self._get_recommended_actions(lead_score, lead_grade),
                "message": "Lead scored successfully"
            }
            
        except Exception as e:
            logger.error(f"Error scoring lead: {e}")
            self.db.rollback()
            return {"error": "Lead scoring failed"}

    async def forecast_sales_pipeline(self, forecast_months: int = 6, 
                                   tenant_id: str = "default") -> Dict[str, Any]:
        """Forecast sales pipeline using historical data and ML"""
        try:
            # Get historical sales data
            historical_sales = await self._get_historical_sales_data(tenant_id)
            
            # Get current pipeline
            current_pipeline = await self._get_current_pipeline(tenant_id)
            
            # Calculate conversion rates by stage
            conversion_rates = await self._calculate_stage_conversion_rates(tenant_id)
            
            # Forecast using time series analysis
            forecast = await self._generate_sales_forecast(historical_sales, forecast_months)
            
            # Pipeline value projection
            pipeline_projection = await self._project_pipeline_value(
                current_pipeline, conversion_rates, forecast_months
            )
            
            # Risk assessment
            risk_assessment = await self._assess_pipeline_risks(current_pipeline, tenant_id)
            
            return {
                "success": True,
                "forecast_period_months": forecast_months,
                "historical_analysis": {
                    "total_deals": len(historical_sales),
                    "average_deal_size": np.mean([s['value'] for s in historical_sales]) if historical_sales else 0,
                    "sales_cycle_days": np.mean([s['cycle_days'] for s in historical_sales]) if historical_sales else 0
                },
                "sales_forecast": forecast,
                "pipeline_projection": pipeline_projection,
                "conversion_rates": conversion_rates,
                "risk_assessment": risk_assessment,
                "recommendations": await self._get_forecast_recommendations(forecast, risk_assessment)
            }
            
        except Exception as e:
            logger.error(f"Error forecasting sales pipeline: {e}")
            return {"error": "Sales forecasting failed"}

    async def predict_customer_churn(self, customer_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Predict customer churn probability"""
        try:
            # Get customer data
            customer = self.db.query(models.Customer).filter(
                and_(
                    models.Customer.id == customer_id,
                    models.Customer.tenant_id == tenant_id
                )
            ).first()
            
            if not customer:
                return {"error": "Customer not found"}
            
            # Get customer activity data
            activity_data = await self._get_customer_activity_data(customer_id, tenant_id)
            
            # Get support ticket history
            support_data = await self._get_support_data(customer_id, tenant_id)
            
            # Get payment history
            payment_data = await self._get_payment_data(customer_id, tenant_id)
            
            # Calculate churn risk factors
            churn_factors = await self._calculate_churn_factors(activity_data, support_data, payment_data)
            
            # Predict churn probability using ML model
            churn_probability = await self._predict_churn_probability(churn_factors)
            
            # Determine risk category
            risk_category = await self._determine_risk_category(churn_probability)
            
            # Generate retention recommendations
            retention_actions = await self._generate_retention_actions(churn_factors, churn_probability)
            
            # Save churn prediction
            churn_prediction = models.ChurnPrediction(
                customer_id=customer_id,
                churn_probability=churn_probability,
                risk_category=risk_category,
                risk_factors_json=json.dumps(churn_factors),
                retention_actions_json=json.dumps(retention_actions),
                prediction_date=datetime.utcnow().date(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(churn_prediction)
            self.db.commit()
            
            return {
                "success": True,
                "customer_id": customer_id,
                "customer_name": customer.company_name,
                "churn_probability": churn_probability,
                "risk_category": risk_category,
                "risk_factors": churn_factors,
                "retention_actions": retention_actions,
                "prediction_date": datetime.utcnow().strftime('%Y-%m-%d'),
                "message": "Churn prediction completed"
            }
            
        except Exception as e:
            logger.error(f"Error predicting customer churn: {e}")
            return {"error": "Churn prediction failed"}

    async def analyze_customer_lifecycle(self, customer_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Analyze customer lifecycle and journey"""
        try:
            # Get customer information
            customer = self.db.query(models.Customer).filter(
                and_(
                    models.Customer.id == customer_id,
                    models.Customer.tenant_id == tenant_id
                )
            ).first()
            
            if not customer:
                return {"error": "Customer not found"}
            
            # Get customer journey stages
            journey_stages = await self._get_customer_journey(customer_id, tenant_id)
            
            # Calculate lifecycle metrics
            lifecycle_metrics = await self._calculate_lifecycle_metrics(customer_id, tenant_id)
            
            # Analyze touchpoints
            touchpoint_analysis = await self._analyze_touchpoints(customer_id, tenant_id)
            
            # Calculate customer lifetime value
            clv_analysis = await self._calculate_customer_lifetime_value(customer_id, tenant_id)
            
            # Identify upsell opportunities
            upsell_opportunities = await self._identify_upsell_opportunities(customer_id, tenant_id)
            
            return {
                "success": True,
                "customer_id": customer_id,
                "customer_name": customer.company_name,
                "journey_stages": journey_stages,
                "lifecycle_metrics": lifecycle_metrics,
                "touchpoint_analysis": touchpoint_analysis,
                "customer_lifetime_value": clv_analysis,
                "upsell_opportunities": upsell_opportunities,
                "recommendations": await self._get_lifecycle_recommendations(lifecycle_metrics, clv_analysis)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing customer lifecycle: {e}")
            return {"error": "Lifecycle analysis failed"}

    async def gamify_performance(self, period: str = "monthly", tenant_id: str = "default") -> Dict[str, Any]:
        """Implement performance gamification"""
        try:
            # Get sales team performance
            team_performance = await self._get_team_performance(period, tenant_id)
            
            # Calculate gamification metrics
            gamification_metrics = await self._calculate_gamification_metrics(team_performance)
            
            # Award badges and achievements
            achievements = await self._award_achievements(team_performance, tenant_id)
            
            # Create leaderboard
            leaderboard = await self._create_leaderboard(gamification_metrics, tenant_id)
            
            # Generate performance insights
            insights = await self._generate_performance_insights(team_performance, gamification_metrics)
            
            return {
                "success": True,
                "period": period,
                "team_performance": team_performance,
                "gamification_metrics": gamification_metrics,
                "achievements": achievements,
                "leaderboard": leaderboard,
                "performance_insights": insights
            }
            
        except Exception as e:
            logger.error(f"Error in performance gamification: {e}")
            return {"error": "Gamification failed"}

    # Helper Methods
    async def _calculate_lead_score(self, lead_data: Dict[str, Any]) -> float:
        """Calculate lead score using weighted factors"""
        try:
            score = 0
            
            # Industry score
            industry = lead_data.get('industry', 'other').lower()
            industry_score = self.lead_scoring_model['industry_weights'].get(industry, 0.5)
            score += industry_score * 25
            
            # Company size score
            size = lead_data.get('company_size', 'small').lower()
            size_score = self.lead_scoring_model['size_weights'].get(size, 0.6)
            score += size_score * 20
            
            # Activity score (based on recent interactions)
            activities = lead_data.get('activities', [])
            activity_score = 0
            for activity in activities:
                activity_type = activity.get('type', 'website_visit')
                weight = self.lead_scoring_model['activity_weights'].get(activity_type, 0.1)
                activity_score += weight
            
            activity_score = min(activity_score, 30)  # Cap at 30 points
            score += activity_score
            
            # Budget score
            budget = lead_data.get('budget', 0)
            if budget > 100000:
                budget_score = 15
            elif budget > 50000:
                budget_score = 10
            elif budget > 10000:
                budget_score = 5
            else:
                budget_score = 0
            score += budget_score
            
            # Timeline score
            timeline = lead_data.get('timeline', '').lower()
            if 'urgent' in timeline or 'immediate' in timeline:
                timeline_score = 10
            elif 'month' in timeline:
                timeline_score = 7
            elif 'quarter' in timeline:
                timeline_score = 5
            else:
                timeline_score = 2
            score += timeline_score
            
            return min(score, 100)  # Cap at 100
            
        except Exception as e:
            logger.error(f"Error calculating lead score: {e}")
            return 50

    async def _determine_lead_grade(self, score: float) -> str:
        """Determine lead grade based on score"""
        if score >= 80:
            return 'A'
        elif score >= 60:
            return 'B'
        elif score >= 40:
            return 'C'
        else:
            return 'D'

    async def _predict_conversion_probability(self, lead_data: Dict, score: float) -> float:
        """Predict conversion probability using ML model"""
        try:
            # Simple logistic regression approximation
            # In production, this would use a trained ML model
            
            # Base probability from score
            base_probability = score / 100
            
            # Adjust based on historical conversion rates
            historical_rate = 0.25  # 25% average conversion rate
            
            # Combine factors
            conversion_probability = (base_probability * 0.7) + (historical_rate * 0.3)
            
            # Apply sigmoid function for realistic probability
            import math
            sigmoid_prob = 1 / (1 + math.exp(-10 * (conversion_probability - 0.5)))
            
            return round(sigmoid_prob, 3)
            
        except Exception as e:
            logger.error(f"Error predicting conversion probability: {e}")
            return 0.25

    async def _get_score_components(self, lead_data: Dict) -> Dict[str, float]:
        """Get detailed score components"""
        try:
            components = {}
            
            # Industry component
            industry = lead_data.get('industry', 'other').lower()
            components['industry'] = self.lead_scoring_model['industry_weights'].get(industry, 0.5) * 25
            
            # Size component
            size = lead_data.get('company_size', 'small').lower()
            components['company_size'] = self.lead_scoring_model['size_weights'].get(size, 0.6) * 20
            
            # Activity component
            activities = lead_data.get('activities', [])
            activity_score = 0
            for activity in activities:
                activity_type = activity.get('type', 'website_visit')
                weight = self.lead_scoring_model['activity_weights'].get(activity_type, 0.1)
                activity_score += weight
            components['activity'] = min(activity_score, 30)
            
            # Budget component
            budget = lead_data.get('budget', 0)
            if budget > 100000:
                components['budget'] = 15
            elif budget > 50000:
                components['budget'] = 10
            elif budget > 10000:
                components['budget'] = 5
            else:
                components['budget'] = 0
            
            # Timeline component
            timeline = lead_data.get('timeline', '').lower()
            if 'urgent' in timeline or 'immediate' in timeline:
                components['timeline'] = 10
            elif 'month' in timeline:
                components['timeline'] = 7
            elif 'quarter' in timeline:
                components['timeline'] = 5
            else:
                components['timeline'] = 2
            
            return components
            
        except Exception as e:
            logger.error(f"Error getting score components: {e}")
            return {}

    async def _create_follow_up_tasks(self, lead: models.Lead, score: float, tenant_id: str):
        """Create follow-up tasks based on lead score"""
        try:
            tasks = []
            
            if score >= 80:
                # High priority leads
                tasks.append({
                    'title': f'Immediate follow-up with {lead.company_name}',
                    'description': 'High-value lead requires immediate contact',
                    'priority': 'high',
                    'due_date': datetime.utcnow() + timedelta(hours=24)
                })
                tasks.append({
                    'title': f'Schedule demo with {lead.company_name}',
                    'description': 'Book product demonstration',
                    'priority': 'high',
                    'due_date': datetime.utcnow() + timedelta(days=3)
                })
            elif score >= 60:
                # Medium priority leads
                tasks.append({
                    'title': f'Follow up with {lead.company_name}',
                    'description': 'Medium-value lead follow-up',
                    'priority': 'medium',
                    'due_date': datetime.utcnow() + timedelta(days=2)
                })
            else:
                # Low priority leads
                tasks.append({
                    'title': f'Nurture campaign for {lead.company_name}',
                    'description': 'Add to email nurture sequence',
                    'priority': 'low',
                    'due_date': datetime.utcnow() + timedelta(days=7)
                })
            
            # Create tasks in database
            for task_data in tasks:
                task = models.CRMTask(
                    lead_id=lead.lead_id,
                    title=task_data['title'],
                    description=task_data['description'],
                    priority=task_data['priority'],
                    status='pending',
                    due_date=task_data['due_date'],
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                self.db.add(task)
            
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error creating follow-up tasks: {e}")

    async def _get_historical_sales_data(self, tenant_id: str) -> List[Dict]:
        """Get historical sales data for forecasting"""
        try:
            sales = self.db.query(models.SalesOrder).filter(
                models.SalesOrder.tenant_id == tenant_id
            ).order_by(models.SalesOrder.order_date.desc()).limit(100).all()
            
            return [
                {
                    'order_date': sale.order_date,
                    'value': sale.total_amount,
                    'cycle_days': (sale.order_date - sale.created_at.date()).days if sale.created_at else 30
                }
                for sale in sales
            ]
            
        except Exception as e:
            logger.error(f"Error getting historical sales data: {e}")
            return []

    async def _get_current_pipeline(self, tenant_id: str) -> List[Dict]:
        """Get current sales pipeline"""
        try:
            leads = self.db.query(models.Lead).filter(
                and_(
                    models.Lead.status.in_(['new', 'contacted', 'qualified', 'proposal']),
                    models.Lead.tenant_id == tenant_id
                )
            ).all()
            
            return [
                {
                    'lead_id': lead.lead_id,
                    'company_name': lead.company_name,
                    'status': lead.status,
                    'lead_score': lead.lead_score,
                    'estimated_value': lead.estimated_value,
                    'created_at': lead.created_at
                }
                for lead in leads
            ]
            
        except Exception as e:
            logger.error(f"Error getting current pipeline: {e}")
            return []

    async def _calculate_stage_conversion_rates(self, tenant_id: str) -> Dict[str, float]:
        """Calculate conversion rates by pipeline stage"""
        try:
            # This would analyze historical conversion data
            # For now, return industry-standard rates
            return {
                'new_to_contacted': 0.6,
                'contacted_to_qualified': 0.4,
                'qualified_to_proposal': 0.7,
                'proposal_to_closed': 0.3
            }
            
        except Exception as e:
            logger.error(f"Error calculating conversion rates: {e}")
            return {}

    async def _generate_sales_forecast(self, historical_data: List[Dict], months: int) -> Dict[str, Any]:
        """Generate sales forecast using time series analysis"""
        try:
            if not historical_data:
                return {"forecast": [], "confidence": 0}
            
            # Simple linear trend forecast
            # In production, this would use ARIMA or Prophet models
            
            monthly_sales = defaultdict(float)
            for sale in historical_data:
                month_key = sale['order_date'].strftime('%Y-%m')
                monthly_sales[month_key] += sale['value']
            
            # Calculate trend
            months_list = list(monthly_sales.keys())
            values_list = list(monthly_sales.values())
            
            if len(values_list) >= 3:
                # Simple linear regression
                x = np.arange(len(values_list))
                coefficients = np.polyfit(x, values_list, 1)
                trend = coefficients[0]
                
                # Generate forecast
                forecast = []
                for i in range(months):
                    future_value = values_list[-1] + (trend * (i + 1))
                    forecast.append({
                        'month': (datetime.utcnow() + timedelta(days=30 * (i + 1))).strftime('%Y-%m'),
                        'forecast_value': max(0, future_value),
                        'confidence': max(0.5, 0.9 - (i * 0.1))  # Decreasing confidence
                    })
                
                return {
                    "forecast": forecast,
                    "trend": "increasing" if trend > 0 else "decreasing",
                    "confidence": 0.75
                }
            
            return {"forecast": [], "confidence": 0}
            
        except Exception as e:
            logger.error(f"Error generating sales forecast: {e}")
            return {"forecast": [], "confidence": 0}

    async def _project_pipeline_value(self, pipeline: List[Dict], conversion_rates: Dict, months: int) -> Dict[str, Any]:
        """Project pipeline value based on conversion rates"""
        try:
            projection = {
                'total_pipeline_value': 0,
                'weighted_pipeline_value': 0,
                'stage_breakdown': defaultdict(float),
                'monthly_projection': []
            }
            
            for lead in pipeline:
                estimated_value = lead.get('estimated_value', 0)
                projection['total_pipeline_value'] += estimated_value
                
                # Apply stage-specific conversion rates
                stage = lead['status']
                if stage == 'new':
                    rate = conversion_rates.get('new_to_contacted', 0.6) * \
                          conversion_rates.get('contacted_to_qualified', 0.4) * \
                          conversion_rates.get('qualified_to_proposal', 0.7) * \
                          conversion_rates.get('proposal_to_closed', 0.3)
                elif stage == 'contacted':
                    rate = conversion_rates.get('contacted_to_qualified', 0.4) * \
                          conversion_rates.get('qualified_to_proposal', 0.7) * \
                          conversion_rates.get('proposal_to_closed', 0.3)
                elif stage == 'qualified':
                    rate = conversion_rates.get('qualified_to_proposal', 0.7) * \
                          conversion_rates.get('proposal_to_closed', 0.3)
                elif stage == 'proposal':
                    rate = conversion_rates.get('proposal_to_closed', 0.3)
                else:
                    rate = 0
                
                weighted_value = estimated_value * rate
                projection['weighted_pipeline_value'] += weighted_value
                projection['stage_breakdown'][stage] += weighted_value
            
            return projection
            
        except Exception as e:
            logger.error(f"Error projecting pipeline value: {e}")
            return {}

    async def _assess_pipeline_risks(self, pipeline: List[Dict], tenant_id: str) -> Dict[str, Any]:
        """Assess pipeline risks"""
        try:
            risks = {
                'stalled_deals': 0,
                'low_scoring_leads': 0,
                'aging_leads': 0,
                'concentration_risk': 0
            }
            
            total_value = 0
            customer_concentration = defaultdict(float)
            
            for lead in pipeline:
                value = lead.get('estimated_value', 0)
                total_value += value
                
                # Check for stalled deals (old leads)
                days_old = (datetime.utcnow() - lead['created_at']).days
                if days_old > 60:
                    risks['aging_leads'] += 1
                
                # Check for low-scoring leads
                if lead.get('lead_score', 0) < 40:
                    risks['low_scoring_leads'] += 1
                
                # Check customer concentration
                customer_concentration[lead['company_name']] += value
            
            # Calculate concentration risk
            max_concentration = max(customer_concentration.values()) if customer_concentration else 0
            if total_value > 0:
                risks['concentration_risk'] = (max_concentration / total_value) * 100
            
            return risks
            
        except Exception as e:
            logger.error(f"Error assessing pipeline risks: {e}")
            return {}

    async def _get_forecast_recommendations(self, forecast: Dict, risks: Dict) -> List[str]:
        """Generate forecast-based recommendations"""
        try:
            recommendations = []
            
            if forecast.get('trend') == 'decreasing':
                recommendations.append("Sales trend is declining. Consider lead generation campaigns.")
            
            if risks.get('aging_leads', 0) > 5:
                recommendations.append("Many leads are aging. Follow up on old opportunities.")
            
            if risks.get('low_scoring_leads', 0) > 10:
                recommendations.append("Focus on improving lead quality and scoring.")
            
            if risks.get('concentration_risk', 0) > 30:
                recommendations.append("High customer concentration risk. Diversify customer base.")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error getting forecast recommendations: {e}")
            return []

    async def _get_customer_activity_data(self, customer_id: int, tenant_id: str) -> Dict:
        """Get customer activity data"""
        try:
            # Get recent orders
            recent_orders = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.customer_id == customer_id,
                    models.SalesOrder.tenant_id == tenant_id,
                    models.SalesOrder.order_date >= datetime.utcnow() - timedelta(days=90)
                )
            ).all()
            
            # Get website visits (mock data)
            website_visits = 15  # Would come from analytics
            
            # Get email interactions
            email_opens = 8  # Would come from email platform
            
            return {
                'recent_orders': len(recent_orders),
                'order_frequency': len(recent_orders) / 3,  # Per month
                'website_visits': website_visits,
                'email_opens': email_opens,
                'last_order_date': max([o.order_date for o in recent_orders]).isoformat() if recent_orders else None
            }
            
        except Exception as e:
            logger.error(f"Error getting customer activity data: {e}")
            return {}

    async def _calculate_churn_factors(self, activity_data: Dict, support_data: Dict, payment_data: Dict) -> Dict[str, float]:
        """Calculate churn risk factors"""
        try:
            factors = {}
            
            # Low activity factor
            if activity_data.get('order_frequency', 0) < 0.5:
                factors['low_activity'] = 0.8
            elif activity_data.get('order_frequency', 0) < 1:
                factors['low_activity'] = 0.5
            else:
                factors['low_activity'] = 0.1
            
            # Support tickets factor
            if support_data.get('open_tickets', 0) > 5:
                factors['support_tickets'] = 0.7
            elif support_data.get('open_tickets', 0) > 2:
                factors['support_tickets'] = 0.4
            else:
                factors['support_tickets'] = 0.1
            
            # Payment delays factor
            if payment_data.get('late_payments', 0) > 3:
                factors['payment_delays'] = 0.8
            elif payment_data.get('late_payments', 0) > 1:
                factors['payment_delays'] = 0.5
            else:
                factors['payment_delays'] = 0.1
            
            # Competitor engagement (mock data)
            factors['competitor_engagement'] = 0.2  # Would come from market intelligence
            
            return factors
            
        except Exception as e:
            logger.error(f"Error calculating churn factors: {e}")
            return {}

    async def _predict_churn_probability(self, factors: Dict[str, float]) -> float:
        """Predict churn probability using ML model"""
        try:
            # Weighted sum of factors
            weights = self.churn_risk_factors
            
            churn_score = 0
            for factor, value in factors.items():
                weight = weights.get(factor, 0.1)
                churn_score += value * weight
            
            # Normalize to 0-1 range
            churn_probability = min(churn_score, 1.0)
            
            return round(churn_probability, 3)
            
        except Exception as e:
            logger.error(f"Error predicting churn probability: {e}")
            return 0.1

    async def _determine_risk_category(self, probability: float) -> str:
        """Determine churn risk category"""
        if probability >= 0.7:
            return 'high'
        elif probability >= 0.4:
            return 'medium'
        else:
            return 'low'

    async def _generate_retention_actions(self, factors: Dict, probability: float) -> List[Dict]:
        """Generate retention actions"""
        try:
            actions = []
            
            if factors.get('low_activity', 0) > 0.5:
                actions.append({
                    'action': 'Re-engagement campaign',
                    'priority': 'high',
                    'description': 'Launch targeted re-engagement campaign'
                })
            
            if factors.get('support_tickets', 0) > 0.5:
                actions.append({
                    'action': 'Proactive support outreach',
                    'priority': 'high',
                    'description': 'Assign dedicated support representative'
                })
            
            if factors.get('payment_delays', 0) > 0.5:
                actions.append({
                    'action': 'Payment terms review',
                    'priority': 'medium',
                    'description': 'Review and adjust payment terms'
                })
            
            if probability > 0.7:
                actions.append({
                    'action': 'Executive outreach',
                    'priority': 'high',
                    'description': 'Schedule executive check-in call'
                })
            
            return actions
            
        except Exception as e:
            logger.error(f"Error generating retention actions: {e}")
            return []

    async def _get_recommended_actions(self, score: float, grade: str) -> List[str]:
        """Get recommended actions based on lead score"""
        try:
            actions = []
            
            if grade == 'A':
                actions.extend([
                    "Immediate follow-up call",
                    "Schedule product demo",
                    "Send personalized proposal",
                    "Assign senior sales representative"
                ])
            elif grade == 'B':
                actions.extend([
                    "Follow up within 24 hours",
                    "Send product information",
                    "Schedule discovery call",
                    "Add to high-priority nurture sequence"
                ])
            elif grade == 'C':
                actions.extend([
                    "Add to standard nurture sequence",
                    "Send educational content",
                    "Monthly follow-up",
                    "Monitor engagement"
                ])
            else:
                actions.extend([
                    "Add to long-term nurture",
                    "Quarterly check-in",
                    "Low-priority follow-up",
                    "Monitor for trigger events"
                ])
            
            return actions
            
        except Exception as e:
            logger.error(f"Error getting recommended actions: {e}")
            return []
