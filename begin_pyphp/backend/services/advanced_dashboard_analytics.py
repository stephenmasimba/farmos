"""
Advanced Dashboard Analytics - Phase 4 Feature
Comprehensive analytics dashboard with real-time insights and KPI tracking
Derived from Begin Reference System
"""

import logging
import asyncio
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
import json
from decimal import Decimal
from collections import defaultdict

logger = logging.getLogger(__name__)

from ..common import models

class AdvancedDashboardAnalyticsService:
    """Advanced analytics dashboard with real-time KPIs and insights"""
    
    def __init__(self, db: Session):
        self.db = db
        self.kpi_categories = [
            'production', 'financial', 'operational', 
            'environmental', 'quality', 'efficiency'
        ]

    async def get_executive_dashboard(self, filters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Get executive-level dashboard with key metrics"""
        try:
            # Time period
            period = filters.get('period', '30d')
            start_date, end_date = await self._parse_period(period)
            
            # Get core KPIs
            production_kpis = await self._get_production_kpis(start_date, end_date, tenant_id)
            financial_kpis = await self._get_financial_kpis(start_date, end_date, tenant_id)
            operational_kpis = await self._get_operational_kpis(start_date, end_date, tenant_id)
            
            # Get trends
            trends = await self._get_executive_trends(start_date, end_date, tenant_id)
            
            # Get alerts and notifications
            alerts = await self._get_critical_alerts(tenant_id)
            
            # Get performance score
            performance_score = await self._calculate_overall_performance_score(
                production_kpis, financial_kpis, operational_kpis
            )
            
            return {
                "dashboard_type": "executive",
                "period": period,
                "performance_score": performance_score,
                "kpis": {
                    "production": production_kpis,
                    "financial": financial_kpis,
                    "operational": operational_kpis
                },
                "trends": trends,
                "alerts": alerts,
                "last_updated": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting executive dashboard: {e}")
            return {"error": "Executive dashboard failed"}

    async def get_production_dashboard(self, filters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Get production-focused dashboard"""
        try:
            period = filters.get('period', '30d')
            start_date, end_date = await self._parse_period(period)
            
            # Crop production metrics
            crop_metrics = await self._get_crop_production_metrics(start_date, end_date, tenant_id)
            
            # Livestock production metrics
            livestock_metrics = await self._get_livestock_production_metrics(start_date, end_date, tenant_id)
            
            # Resource utilization
            resource_utilization = await self._get_resource_utilization(start_date, end_date, tenant_id)
            
            # Production efficiency
            efficiency_metrics = await self._get_production_efficiency(start_date, end_date, tenant_id)
            
            # Yield analysis
            yield_analysis = await self._get_yield_analysis(start_date, end_date, tenant_id)
            
            return {
                "dashboard_type": "production",
                "period": period,
                "crop_metrics": crop_metrics,
                "livestock_metrics": livestock_metrics,
                "resource_utilization": resource_utilization,
                "efficiency_metrics": efficiency_metrics,
                "yield_analysis": yield_analysis,
                "last_updated": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting production dashboard: {e}")
            return {"error": "Production dashboard failed"}

    async def get_financial_dashboard(self, filters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Get financial dashboard"""
        try:
            period = filters.get('period', '30d')
            start_date, end_date = await self._parse_period(period)
            
            # Revenue analysis
            revenue_analysis = await self._get_revenue_analysis(start_date, end_date, tenant_id)
            
            # Cost analysis
            cost_analysis = await self._get_cost_analysis(start_date, end_date, tenant_id)
            
            # Profitability metrics
            profitability = await self._get_profitability_metrics(start_date, end_date, tenant_id)
            
            # Cash flow
            cash_flow = await self._get_cash_flow_analysis(start_date, end_date, tenant_id)
            
            # Financial ratios
            financial_ratios = await self._calculate_financial_ratios(start_date, end_date, tenant_id)
            
            return {
                "dashboard_type": "financial",
                "period": period,
                "revenue_analysis": revenue_analysis,
                "cost_analysis": cost_analysis,
                "profitability": profitability,
                "cash_flow": cash_flow,
                "financial_ratios": financial_ratios,
                "last_updated": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting financial dashboard: {e}")
            return {"error": "Financial dashboard failed"}

    async def get_sustainability_dashboard(self, filters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Get sustainability and environmental dashboard"""
        try:
            period = filters.get('period', '30d')
            start_date, end_date = await self._parse_period(period)
            
            # Environmental metrics
            environmental_metrics = await self._get_environmental_metrics(start_date, end_date, tenant_id)
            
            # Waste management
            waste_metrics = await self._get_waste_management_metrics(start_date, end_date, tenant_id)
            
            # Resource efficiency
            resource_efficiency = await self._get_resource_efficiency_metrics(start_date, end_date, tenant_id)
            
            # Carbon footprint
            carbon_footprint = await self._calculate_carbon_footprint(start_date, end_date, tenant_id)
            
            # Sustainability score
            sustainability_score = await self._calculate_sustainability_score(
                environmental_metrics, waste_metrics, resource_efficiency
            )
            
            return {
                "dashboard_type": "sustainability",
                "period": period,
                "environmental_metrics": environmental_metrics,
                "waste_metrics": waste_metrics,
                "resource_efficiency": resource_efficiency,
                "carbon_footprint": carbon_footprint,
                "sustainability_score": sustainability_score,
                "last_updated": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting sustainability dashboard: {e}")
            return {"error": "Sustainability dashboard failed"}

    async def get_real_time_metrics(self, tenant_id: str = "default") -> Dict[str, Any]:
        """Get real-time operational metrics"""
        try:
            # Current production status
            production_status = await self._get_current_production_status(tenant_id)
            
            # Inventory levels
            inventory_status = await self._get_current_inventory_status(tenant_id)
            
            # Equipment status
            equipment_status = await self._get_equipment_status(tenant_id)
            
            # Weather conditions
            weather_conditions = await self._get_current_weather_conditions(tenant_id)
            
            # Active alerts
            active_alerts = await self._get_active_alerts(tenant_id)
            
            # Labor status
            labor_status = await self._get_labor_status(tenant_id)
            
            return {
                "dashboard_type": "real_time",
                "timestamp": datetime.utcnow().isoformat(),
                "production_status": production_status,
                "inventory_status": inventory_status,
                "equipment_status": equipment_status,
                "weather_conditions": weather_conditions,
                "active_alerts": active_alerts,
                "labor_status": labor_status
            }
            
        except Exception as e:
            logger.error(f"Error getting real-time metrics: {e}")
            return {"error": "Real-time metrics failed"}

    async def generate_custom_report(self, report_config: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Generate custom analytics report"""
        try:
            report_type = report_config.get('report_type')
            metrics = report_config.get('metrics', [])
            filters = report_config.get('filters', {})
            format_type = report_config.get('format', 'json')
            
            # Generate report data based on type
            if report_type == 'production':
                report_data = await self._generate_production_report(metrics, filters, tenant_id)
            elif report_type == 'financial':
                report_data = await self._generate_financial_report(metrics, filters, tenant_id)
            elif report_type == 'sustainability':
                report_data = await self._generate_sustainability_report(metrics, filters, tenant_id)
            else:
                report_data = await self._generate_comprehensive_report(metrics, filters, tenant_id)
            
            # Save report record
            report = models.CustomReport(
                report_name=report_config.get('report_name'),
                report_type=report_type,
                report_config=json.dumps(report_config),
                report_data=json.dumps(report_data),
                generated_at=datetime.utcnow(),
                format_type=format_type,
                status='completed',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(report)
            self.db.commit()
            
            return {
                "success": True,
                "report_id": report.id,
                "report_type": report_type,
                "data": report_data,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error generating custom report: {e}")
            return {"error": "Custom report generation failed"}

    # Helper methods
    async def _parse_period(self, period: str) -> Tuple[datetime, datetime]:
        """Parse time period string"""
        end_date = datetime.utcnow()
        
        if period == '7d':
            start_date = end_date - timedelta(days=7)
        elif period == '30d':
            start_date = end_date - timedelta(days=30)
        elif period == '90d':
            start_date = end_date - timedelta(days=90)
        elif period == '1y':
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=30)
        
        return start_date, end_date

    async def _get_production_kpis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get production KPIs"""
        try:
            # Crop yields
            crop_cycles = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.planting_date >= start_date.date(),
                    models.CropCycle.planting_date <= end_date.date(),
                    models.CropCycle.tenant_id == tenant_id
                )
            ).all()
            
            total_yield = sum(c.actual_yield or 0 for c in crop_cycles)
            total_area = sum(c.area_hectares or 0 for c in crop_cycles)
            avg_yield_per_hectare = total_yield / total_area if total_area > 0 else 0
            
            # Livestock production
            livestock_batches = self.db.query(models.LivestockBatch).filter(
                and_(
                    models.LivestockBatch.start_date >= start_date.date(),
                    models.LivestockBatch.start_date <= end_date.date(),
                    models.LivestockBatch.tenant_id == tenant_id
                )
            ).all()
            
            total_livestock = sum(l.quantity or 0 for l in livestock_batches)
            
            return {
                "total_crop_yield": total_yield,
                "total_cultivated_area": total_area,
                "average_yield_per_hectare": avg_yield_per_hectare,
                "total_livestock_production": total_livestock,
                "active_crop_cycles": len([c for c in crop_cycles if c.status == 'growing']),
                "harvested_cycles": len([c for c in crop_cycles if c.status == 'harvested'])
            }
            
        except Exception as e:
            logger.error(f"Error getting production KPIs: {e}")
            return {}

    async def _get_financial_kpis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get financial KPIs"""
        try:
            # Revenue from sales
            sales_orders = self.db.query(models.SalesOrder).filter(
                and_(
                    models.SalesOrder.order_date >= start_date.date(),
                    models.SalesOrder.order_date <= end_date.date(),
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).all()
            
            total_revenue = sum(s.total_amount or 0 for s in sales_orders)
            
            # Costs from transactions
            expenses = self.db.query(models.FinancialTransaction).filter(
                and_(
                    models.FinancialTransaction.transaction_date >= start_date.date(),
                    models.FinancialTransaction.transaction_date <= end_date.date(),
                    models.FinancialTransaction.transaction_type == 'expense',
                    models.FinancialTransaction.tenant_id == tenant_id
                )
            ).all()
            
            total_expenses = sum(e.amount or 0 for e in expenses)
            
            # Profitability
            gross_profit = total_revenue - total_expenses
            profit_margin = (gross_profit / total_revenue * 100) if total_revenue > 0 else 0
            
            return {
                "total_revenue": total_revenue,
                "total_expenses": total_expenses,
                "gross_profit": gross_profit,
                "profit_margin": profit_margin,
                "total_orders": len(sales_orders),
                "average_order_value": total_revenue / len(sales_orders) if sales_orders else 0
            }
            
        except Exception as e:
            logger.error(f"Error getting financial KPIs: {e}")
            return {}

    async def _get_operational_kpis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get operational KPIs"""
        try:
            # Inventory turnover
            inventory_items = self.db.query(models.InventoryItem).filter(
                models.InventoryItem.tenant_id == tenant_id
            ).all()
            
            total_inventory_value = sum(i.quantity * i.unit_cost for i in inventory_items if i.quantity and i.unit_cost)
            
            # Equipment utilization
            equipment = self.db.query(models.Equipment).filter(
                models.Equipment.tenant_id == tenant_id
            ).all()
            
            active_equipment = len([e for e in equipment if e.status == 'active'])
            
            # Labor productivity
            employees = self.db.query(models.Employee).filter(
                models.Employee.tenant_id == tenant_id
            ).all()
            
            total_employees = len(employees)
            
            return {
                "total_inventory_value": total_inventory_value,
                "inventory_items_count": len(inventory_items),
                "active_equipment": active_equipment,
                "total_equipment": len(equipment),
                "total_employees": total_employees,
                "equipment_utilization": (active_equipment / len(equipment) * 100) if equipment else 0
            }
            
        except Exception as e:
            logger.error(f"Error getting operational KPIs: {e}")
            return {}

    async def _get_executive_trends(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get executive-level trends"""
        try:
            # Monthly revenue trend
            monthly_revenue = defaultdict(float)
            current_date = start_date
            
            while current_date <= end_date:
                month_key = current_date.strftime('%Y-%m')
                
                month_revenue = self.db.query(func.sum(models.SalesOrder.total_amount)).filter(
                    and_(
                        func.extract('year', models.SalesOrder.order_date) == current_date.year,
                        func.extract('month', models.SalesOrder.order_date) == current_date.month,
                        models.SalesOrder.tenant_id == tenant_id
                    )
                ).scalar() or 0
                
                monthly_revenue[month_key] = month_revenue
                current_date = current_date.replace(day=1) + timedelta(days=32)
                current_date = current_date.replace(day=1)
            
            return {
                "monthly_revenue": dict(monthly_revenue),
                "revenue_trend": await self._calculate_trend(list(monthly_revenue.values())),
                "period_comparison": await self._get_period_comparison(start_date, end_date, tenant_id)
            }
            
        except Exception as e:
            logger.error(f"Error getting executive trends: {e}")
            return {}

    async def _calculate_trend(self, values: List[float]) -> str:
        """Calculate trend direction"""
        if len(values) < 2:
            return "stable"
        
        recent_avg = sum(values[-3:]) / min(3, len(values))
        earlier_avg = sum(values[:3]) / min(3, len(values))
        
        if recent_avg > earlier_avg * 1.05:
            return "increasing"
        elif recent_avg < earlier_avg * 0.95:
            return "decreasing"
        else:
            return "stable"

    async def _get_period_comparison(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Compare current period with previous period"""
        try:
            period_length = (end_date - start_date).days
            previous_start = start_date - timedelta(days=period_length)
            previous_end = start_date - timedelta(days=1)
            
            # Current period revenue
            current_revenue = self.db.query(func.sum(models.SalesOrder.total_amount)).filter(
                and_(
                    models.SalesOrder.order_date >= start_date.date(),
                    models.SalesOrder.order_date <= end_date.date(),
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).scalar() or 0
            
            # Previous period revenue
            previous_revenue = self.db.query(func.sum(models.SalesOrder.total_amount)).filter(
                and_(
                    models.SalesOrder.order_date >= previous_start.date(),
                    models.SalesOrder.order_date <= previous_end.date(),
                    models.SalesOrder.tenant_id == tenant_id
                )
            ).scalar() or 0
            
            change_percentage = ((current_revenue - previous_revenue) / previous_revenue * 100) if previous_revenue > 0 else 0
            
            return {
                "current_period_revenue": current_revenue,
                "previous_period_revenue": previous_revenue,
                "change_percentage": change_percentage,
                "trend": "up" if change_percentage > 0 else "down" if change_percentage < 0 else "stable"
            }
            
        except Exception as e:
            logger.error(f"Error getting period comparison: {e}")
            return {}

    async def _get_critical_alerts(self, tenant_id: str) -> List[Dict]:
        """Get critical alerts for dashboard"""
        try:
            alerts = self.db.query(models.Alert).filter(
                and_(
                    models.Alert.tenant_id == tenant_id,
                    models.Alert.severity == 'critical',
                    models.Alert.status == 'active'
                )
            ).order_by(desc(models.Alert.created_at)).limit(10).all()
            
            return [
                {
                    "id": alert.id,
                    "alert_type": alert.alert_type,
                    "message": alert.message,
                    "created_at": alert.created_at.isoformat()
                }
                for alert in alerts
            ]
            
        except Exception as e:
            logger.error(f"Error getting critical alerts: {e}")
            return []

    async def _calculate_overall_performance_score(self, production_kpis: Dict, 
                                                  financial_kpis: Dict, operational_kpis: Dict) -> Dict:
        """Calculate overall performance score"""
        try:
            # Production score (40% weight)
            production_score = min(100, (
                (production_kpis.get('average_yield_per_hectare', 0) / 10) * 50 +  # Yield score
                (production_kpis.get('harvested_cycles', 0) / max(1, production_kpis.get('active_crop_cycles', 1)) * 50)  # Harvest rate
            ))
            
            # Financial score (40% weight)
            financial_score = min(100, (
                (financial_kpis.get('profit_margin', 0) / 20) * 50 +  # Profit margin score
                (financial_kpis.get('total_revenue', 0) / 100000) * 50  # Revenue score
            ))
            
            # Operational score (20% weight)
            operational_score = min(100, (
                (operational_kpis.get('equipment_utilization', 0)) * 50 +  # Equipment utilization
                50  # Base operational score
            ))
            
            # Weighted overall score
            overall_score = (production_score * 0.4) + (financial_score * 0.4) + (operational_score * 0.2)
            
            return {
                "overall_score": round(overall_score, 2),
                "production_score": round(production_score, 2),
                "financial_score": round(financial_score, 2),
                "operational_score": round(operational_score, 2),
                "grade": await self._get_performance_grade(overall_score)
            }
            
        except Exception as e:
            logger.error(f"Error calculating performance score: {e}")
            return {"overall_score": 0, "grade": "F"}

    async def _get_performance_grade(self, score: float) -> str:
        """Get performance grade from score"""
        if score >= 90:
            return "A+"
        elif score >= 80:
            return "A"
        elif score >= 70:
            return "B"
        elif score >= 60:
            return "C"
        elif score >= 50:
            return "D"
        else:
            return "F"

    # Additional dashboard methods would continue here...
    async def _get_crop_production_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get crop production metrics"""
        # Implementation for crop metrics
        return {}

    async def _get_livestock_production_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get livestock production metrics"""
        # Implementation for livestock metrics
        return {}

    async def _get_resource_utilization(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get resource utilization metrics"""
        # Implementation for resource utilization
        return {}

    async def _get_production_efficiency(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get production efficiency metrics"""
        # Implementation for production efficiency
        return {}

    async def _get_yield_analysis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get yield analysis"""
        # Implementation for yield analysis
        return {}

    async def _get_revenue_analysis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get revenue analysis"""
        # Implementation for revenue analysis
        return {}

    async def _get_cost_analysis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get cost analysis"""
        # Implementation for cost analysis
        return {}

    async def _get_profitability_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get profitability metrics"""
        # Implementation for profitability metrics
        return {}

    async def _get_cash_flow_analysis(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get cash flow analysis"""
        # Implementation for cash flow analysis
        return {}

    async def _calculate_financial_ratios(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Calculate financial ratios"""
        # Implementation for financial ratios
        return {}

    async def _get_environmental_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get environmental metrics"""
        # Implementation for environmental metrics
        return {}

    async def _get_waste_management_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get waste management metrics"""
        # Implementation for waste management metrics
        return {}

    async def _get_resource_efficiency_metrics(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Get resource efficiency metrics"""
        # Implementation for resource efficiency metrics
        return {}

    async def _calculate_carbon_footprint(self, start_date: datetime, end_date: datetime, tenant_id: str) -> Dict:
        """Calculate carbon footprint"""
        # Implementation for carbon footprint calculation
        return {}

    async def _calculate_sustainability_score(self, environmental: Dict, waste: Dict, efficiency: Dict) -> Dict:
        """Calculate sustainability score"""
        # Implementation for sustainability score calculation
        return {}

    async def _get_current_production_status(self, tenant_id: str) -> Dict:
        """Get current production status"""
        # Implementation for current production status
        return {}

    async def _get_current_inventory_status(self, tenant_id: str) -> Dict:
        """Get current inventory status"""
        # Implementation for current inventory status
        return {}

    async def _get_equipment_status(self, tenant_id: str) -> Dict:
        """Get equipment status"""
        # Implementation for equipment status
        return {}

    async def _get_current_weather_conditions(self, tenant_id: str) -> Dict:
        """Get current weather conditions"""
        # Implementation for weather conditions
        return {}

    async def _get_active_alerts(self, tenant_id: str) -> List[Dict]:
        """Get active alerts"""
        # Implementation for active alerts
        return []

    async def _get_labor_status(self, tenant_id: str) -> Dict:
        """Get labor status"""
        # Implementation for labor status
        return {}

    async def _generate_production_report(self, metrics: List[str], filters: Dict, tenant_id: str) -> Dict:
        """Generate production report"""
        # Implementation for production report generation
        return {}

    async def _generate_financial_report(self, metrics: List[str], filters: Dict, tenant_id: str) -> Dict:
        """Generate financial report"""
        # Implementation for financial report generation
        return {}

    async def _generate_sustainability_report(self, metrics: List[str], filters: Dict, tenant_id: str) -> Dict:
        """Generate sustainability report"""
        # Implementation for sustainability report generation
        return {}

    async def _generate_comprehensive_report(self, metrics: List[str], filters: Dict, tenant_id: str) -> Dict:
        """Generate comprehensive report"""
        # Implementation for comprehensive report generation
        return {}
