"""
Sales & CRM Service - Enhanced Version
Handles lead scoring, pipeline forecasting, and customer relationship management
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..common import models
import math

logger = logging.getLogger(__name__)

class SalesCRMService:
    """Sales and CRM service for managing leads and pipeline"""
    
    def __init__(self, db: Session, tenant_id: str = "default"):
        self.db = db
        self.tenant_id = tenant_id

    def get_lead_scoring(self, lead_id: Optional[int] = None, status: Optional[str] = None, limit: int = 50):
        """Get leads with dynamic scoring and recommendations"""
        query = self.db.query(models.Customer).filter(models.Customer.tenant_id == self.tenant_id)
        if lead_id:
            query = query.filter(models.Customer.id == lead_id)
        if status:
            query = query.filter(models.Customer.status == status)
        
        customers = query.limit(limit).all()
        
        enriched_leads = []
        for c in customers:
            # For now, we'll use base scores, but in a real system these would be calculated
            # from engagement logs, order history, etc.
            # We'll use the 'notes' field to store/derive some of this for the demo
            
            # Default scores if not present in metadata/notes
            qualification_score = 60 
            engagement_score = 50
            
            lead_data = {
                "id": c.id,
                "name": c.name,
                "email": c.email,
                "phone": c.phone,
                "qualification_score": qualification_score,
                "engagement_score": engagement_score,
                "lead_status": c.status or "active"
            }
            
            # Lead temperature
            if lead_data["qualification_score"] >= 80: lead_data["lead_temperature"] = "HOT_LEAD"
            elif lead_data["qualification_score"] >= 60: lead_data["lead_temperature"] = "WARM_LEAD"
            elif lead_data["qualification_score"] >= 40: lead_data["lead_temperature"] = "COOL_LEAD"
            else: lead_data["lead_temperature"] = "COLD_LEAD"
            
            # Engagement level
            if lead_data["engagement_score"] >= 70: lead_data["engagement_level"] = "HIGH_ENGAGEMENT"
            elif lead_data["engagement_score"] >= 40: lead_data["engagement_level"] = "MEDIUM_ENGAGEMENT"
            else: lead_data["engagement_level"] = "LOW_ENGAGEMENT"
            
            # Add calculated fields
            lead_data["conversion_probability"] = round((lead_data["qualification_score"] * 0.7 + lead_data["engagement_score"] * 0.3), 1)
            lead_data["recommended_action"] = "Schedule demo immediately" if lead_data["lead_temperature"] == "HOT_LEAD" else "Send follow-up email"
            
            enriched_leads.append(lead_data)
            
        return enriched_leads

    def create_customer(self, customer_data: Dict[str, Any]):
        """Create a new customer"""
        try:
            customer = models.Customer(
                tenant_id=self.tenant_id,
                name=customer_data.get("name"),
                email=customer_data.get("email"),
                phone=customer_data.get("phone"),
                company=customer_data.get("company"),
                address=customer_data.get("address"),
                notes=customer_data.get("notes"),
                status="active"
            )
            self.db.add(customer)
            self.db.commit()
            self.db.refresh(customer)
            
            return {
                "success": True,
                "customer": {
                    "id": customer.id,
                    "name": customer.name,
                    "email": customer.email,
                    "status": customer.status
                }
            }
        except Exception as e:
            logger.error(f"Error creating customer: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_customers(self, customer_id: Optional[int] = None, status: Optional[str] = None, limit: int = 50):
        """Get customers list"""
        query = self.db.query(models.Customer).filter(models.Customer.tenant_id == self.tenant_id)
        if customer_id:
            query = query.filter(models.Customer.id == customer_id)
        if status:
            query = query.filter(models.Customer.status == status)
        
        customers = query.limit(limit).all()
        
        return [
            {
                "id": c.id,
                "name": c.name,
                "email": c.email,
                "phone": c.phone,
                "company": c.company,
                "status": c.status,
                "created_at": c.created_at.isoformat() if c.created_at else None
            }
            for c in customers
        ]

    def update_customer(self, customer_id: int, update_data: Dict[str, Any]):
        """Update customer information"""
        try:
            customer = self.db.query(models.Customer).filter(
                models.Customer.id == customer_id,
                models.Customer.tenant_id == self.tenant_id
            ).first()
            
            if not customer:
                return {"success": False, "error": "Customer not found"}
            
            for field, value in update_data.items():
                if hasattr(customer, field):
                    setattr(customer, field, value)
            
            self.db.commit()
            
            return {"success": True, "customer": {"id": customer.id, "name": customer.name}}
        except Exception as e:
            logger.error(f"Error updating customer: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def delete_customer(self, customer_id: int):
        """Delete a customer"""
        try:
            customer = self.db.query(models.Customer).filter(
                models.Customer.id == customer_id,
                models.Customer.tenant_id == self.tenant_id
            ).first()
            
            if not customer:
                return {"success": False, "error": "Customer not found"}
            
            self.db.delete(customer)
            self.db.commit()
            
            return {"success": True}
        except Exception as e:
            logger.error(f"Error deleting customer: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}

    def get_pipeline_stages(self, stage: Optional[str] = None, limit: int = 50):
        """Get sales pipeline by stages"""
        # Map listings to pipeline stages
        listings = self.db.query(models.Listing).filter(
            models.Listing.tenant_id == self.tenant_id
        )
        
        if stage:
            listings = listings.filter(models.Listing.category == stage)
        
        listings = listings.limit(limit).all()
        
        pipeline = {}
        for listing in listings:
            stage_name = listing.category or "general"
            if stage_name not in pipeline:
                pipeline[stage_name] = []
            
            pipeline[stage_name].append({
                "id": listing.id,
                "title": listing.title,
                "price": listing.price,
                "quantity": listing.quantity,
                "status": listing.status,
                "created_at": listing.created_at
            })
        
        return pipeline

    def get_sales_analytics(self, period_days: int = 30):
        """Get sales analytics and metrics"""
        from datetime import timedelta
        
        start_date = datetime.utcnow() - timedelta(days=period_days)
        
        # Get orders in the period
        orders = self.db.query(models.Order).filter(
            models.Order.tenant_id == self.tenant_id,
            models.Order.created_at >= start_date
        ).all()
        
        total_revenue = sum(order.total_amount or 0 for order in orders)
        total_orders = len(orders)
        
        # Get listings
        listings = self.db.query(models.Listing).filter(
            models.Listing.tenant_id == self.tenant_id,
            models.Listing.created_at >= start_date
        ).all()
        
        total_listings = len(listings)
        
        return {
            "period_days": period_days,
            "total_revenue": total_revenue,
            "total_orders": total_orders,
            "total_listings": total_listings,
            "average_order_value": total_revenue / total_orders if total_orders > 0 else 0,
            "conversion_rate": (total_orders / total_listings * 100) if total_listings > 0 else 0
        }

    def log_activity(self, activity_data: Dict[str, Any]):
        """Log customer activity"""
        try:
            # For now, we'll use a simple approach - in a real system, this would go to an activities table
            activity = {
                "customer_id": activity_data.get("customer_id"),
                "activity_type": activity_data.get("activity_type"),
                "description": activity_data.get("description"),
                "timestamp": datetime.utcnow().isoformat(),
                "tenant_id": self.tenant_id
            }
            
            # For demo purposes, we'll just return success
            # In a real implementation, this would save to a customer_activities table
            return {"success": True, "activity": activity}
        except Exception as e:
            logger.error(f"Error logging activity: {e}")
            return {"success": False, "error": str(e)}

    def get_activities(self, customer_id: Optional[int] = None, activity_type: Optional[str] = None, limit: int = 50):
        """Get customer activities"""
        # For demo purposes, return empty list
        # In a real implementation, this would query customer_activities table
        return []

    def get_dashboard_summary(self):
        """Get CRM dashboard summary"""
        total_customers = self.db.query(models.Customer).filter(
            models.Customer.tenant_id == self.tenant_id
        ).count()
        
        active_listings = self.db.query(models.Listing).filter(
            models.Listing.tenant_id == self.tenant_id,
            models.Listing.status == "active"
        ).count()
        
        recent_orders = self.db.query(models.Order).filter(
            models.Order.tenant_id == self.tenant_id
        ).count()
        
        return {
            "total_customers": total_customers,
            "active_listings": active_listings,
            "total_orders": recent_orders,
            "pipeline_value": 0  # Would calculate from listings
        }

    def get_pipeline_forecast(self, period_days: int = 90):
        """Forecast sales pipeline based on deal stages and probabilities"""
        # In this system, 'Listing' and 'Order' represent the pipeline
        # Listings are potential deals, Orders are closed/pending deals
        
        listings = self.db.query(models.Listing).filter(
            models.Listing.tenant_id == self.tenant_id,
            models.Listing.status == "active"
        ).all()
        
        forecast_metrics = {
            "total_deals_value": 0,
            "total_weighted_value": 0,
            "deal_count": len(listings),
            "deals": []
        }
        
        for l in listings:
            # Estimate probability based on listing age or other factors
            # For demo, we'll use a default 50%
            probability = 50
            deal_value = l.price * l.quantity
            weighted_value = deal_value * (probability / 100)
            
            deal_data = {
                "id": l.id,
                "deal_name": l.title,
                "deal_stage": "listing",
                "deal_value": deal_value,
                "probability_percentage": probability,
                "weighted_value": weighted_value,
                "expected_close_date": (datetime.utcnow() + timedelta(days=14)).isoformat(),
                "category": l.category
            }
            
            forecast_metrics["total_deals_value"] += deal_value
            forecast_metrics["total_weighted_value"] += weighted_value
            forecast_metrics["deals"].append(deal_data)
            
        return forecast_metrics
