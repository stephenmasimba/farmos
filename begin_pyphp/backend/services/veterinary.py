"""
Veterinary Service - Enhanced Version
Handles veterinary medical logs, vaccination scheduling, and withdrawal periods
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from sqlalchemy import desc
from ..common import models

logger = logging.getLogger(__name__)

class VeterinaryService:
    """Animal health management and medical logs"""
    
    def __init__(self, db: Session, tenant_id: str = "default"):
        self.db = db
        self.tenant_id = tenant_id

    def get_medical_logs(self, batch_id: Optional[int] = None):
        """Get history of veterinary treatments from LivestockEvents"""
        query = self.db.query(models.LivestockEvent).filter(
            models.LivestockEvent.tenant_id == self.tenant_id,
            models.LivestockEvent.type.in_(['health_check', 'vaccination', 'treatment'])
        )
        
        if batch_id:
            query = query.filter(models.LivestockEvent.batch_id == batch_id)
            
        events = query.order_by(desc(models.LivestockEvent.date)).all()
        
        results = []
        for e in events:
            # Derive withdrawal info from details if present (or use defaults for demo)
            # In a full system, these would be separate columns or linked to a Medications table
            withdrawal_days = 0
            if "withdrawal" in (e.details or "").lower():
                try:
                    # Simple extraction for demo
                    withdrawal_days = 7
                except:
                    pass
            
            withdrawal_end = e.date + timedelta(days=withdrawal_days)
            status = "IN_WITHDRAWAL" if datetime.utcnow() < withdrawal_end else "CLEARED"
            
            results.append({
                "id": e.id,
                "batch_id": e.batch_id,
                "animal_id": f"Batch #{e.batch_id}" if e.batch_id is not None else "Unknown",
                "animal_type": "Livestock",
                "treatment_type": e.type,
                "medication": (e.details or "")[:50],
                "dosage": "",
                "treatment_date": e.date.isoformat(),
                "withdrawal_period_days": withdrawal_days,
                "withdrawal_end_date": withdrawal_end.isoformat(),
                "status": status,
                "cost": e.cost,
                "performed_by": e.performed_by
            })
            
        return results

    def get_vaccination_schedule(self):
        """Get upcoming vaccinations from Tasks and LivestockEvents"""
        # Tasks with 'vaccination' in title or description
        tasks = self.db.query(models.Task).filter(
            models.Task.tenant_id == self.tenant_id,
            models.Task.status != "completed",
            (models.Task.title.ilike('%vaccin%') | models.Task.description.ilike('%vaccin%'))
        ).all()
        
        schedule = []
        for t in tasks:
            schedule.append({
                "id": t.id,
                "title": t.title,
                "scheduled_date": t.due_date,
                "priority": t.priority,
                "status": "DUE_SOON" if t.priority == "high" else "SCHEDULED"
            })
            
        return schedule

    def get_withdrawal_alerts(self):
        """Get active withdrawal alerts from recent medical events"""
        recent_events = self.db.query(models.LivestockEvent).filter(
            models.LivestockEvent.tenant_id == self.tenant_id,
            models.LivestockEvent.type.in_(['treatment', 'vaccination']),
            models.LivestockEvent.date >= datetime.utcnow() - timedelta(days=30)
        ).all()
        
        alerts = []
        now = datetime.utcnow()
        for e in recent_events:
            # Demo logic: if 'withdrawal' mentioned, calculate alert
            if "withdrawal" in (e.details or "").lower():
                withdrawal_days = 7 # Default
                end_date = e.date + timedelta(days=withdrawal_days)
                if now < end_date:
                    days_remaining = (end_date - now).days
                    alerts.append({
                        "event_id": e.id,
                        "batch_id": e.batch_id,
                        "type": "TREATMENT",
                        "end_date": end_date.isoformat(),
                        "days_remaining": max(0, days_remaining),
                        "severity": "CRITICAL" if days_remaining < 2 else "WARNING"
                    })
                    
        return alerts
