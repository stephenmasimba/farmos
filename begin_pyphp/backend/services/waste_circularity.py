"""
Waste & Circularity Service - Phase 5 Feature
Handles Compost Monitoring, Carbon Credit Estimation, and BSF Tracking
Derived from Begin Reference System
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models

logger = logging.getLogger(__name__)

class WasteCircularityService:
    """Waste and circularity service for sustainable farming"""
    
    def __init__(self, db: Session):
        self.db = db

    def get_compost_status(self, tenant_id: str = "default"):
        """Get status of active compost piles from database"""
        try:
            piles = self.db.query(models.CompostPile).filter(
                models.CompostPile.tenant_id == tenant_id
            ).all()

            if not piles:
                return self._get_mock_compost_status()

            result = []
            for pile in piles:
                # Basic status logic
                status = "OPTIMAL"
                if pile.temperature < 45 or pile.temperature > 65:
                    status = "SUBOPTIMAL"
                if pile.moisture < 40 or pile.moisture > 65:
                    status = "CHECK MOISTURE"

                result.append({
                    "id": pile.id,
                    "pile_name": pile.name,
                    "type": pile.pile_type,
                    "temperature_c": pile.temperature,
                    "moisture_pct": pile.moisture,
                    "ph": pile.ph,
                    "status": status,
                    "pathogen_kill": "ACTIVE" if pile.temperature >= 55 else "INACTIVE",
                    "days_active": (datetime.utcnow() - pile.start_date).days if pile.start_date else 0,
                    "last_turned": pile.last_turned.isoformat() if pile.last_turned else None
                })
            return result
        except Exception as e:
            logger.error(f"Error fetching compost status: {e}")
            return self._get_mock_compost_status()

    def _get_mock_compost_status(self):
        """Mock data fallback"""
        return [
            {
                "id": 1, "pile_name": "Primary Aerobic Pile (Mock)", "type": "Hot Compost",
                "temperature_c": 58.5, "moisture_pct": 55, "ph": 6.8,
                "status": "OPTIMAL", "pathogen_kill": "ACTIVE",
                "days_active": 12, "last_turned": (datetime.utcnow() - timedelta(days=3)).isoformat()
            }
        ]

    def get_carbon_metrics(self, tenant_id: str = "default"):
        """Estimate carbon credits and CO2e avoided from database data"""
        try:
            # Simple calculation based on compost piles as a proxy for waste diversion
            # 1 tonne of organic waste diverted = ~0.5 tonnes CO2e avoided
            piles = self.db.query(models.CompostPile).filter(models.CompostPile.tenant_id == tenant_id).all()
            
            # Mock some metrics if no real data
            if not piles:
                return self._get_mock_carbon_metrics()

            total_waste_kg = sum([500 for _ in piles]) # Assume 500kg per pile for now
            co2e_avoided = (total_waste_kg / 1000) * 0.5
            
            return {
                "monthly_co2e_avoided_tonnes": round(co2e_avoided, 2),
                "yearly_projection": round(co2e_avoided * 12, 2),
                "potential_credit_value_usd": round(co2e_avoided * 12 * 15.0, 2), # At $15/tonne
                "breakdown": {
                    "biogas_methane_capture": 0.0,
                    "waste_diversion": round(co2e_avoided * 0.7, 2),
                    "compost_soil_sequestration": round(co2e_avoided * 0.3, 2)
                },
                "calculation_period": "Real-time from Active Piles"
            }
        except Exception as e:
            logger.error(f"Error calculating carbon metrics: {e}")
            return self._get_mock_carbon_metrics()

    def _get_mock_carbon_metrics(self):
        """Mock carbon metrics fallback"""
        return {
            "monthly_co2e_avoided_tonnes": 4.2,
            "yearly_projection": 50.4,
            "potential_credit_value_usd": 756.0,
            "breakdown": {"biogas_methane_capture": 2.8, "waste_diversion": 0.9, "compost_soil_sequestration": 0.5},
            "calculation_period": "Last 30 days (Mock)"
        }

    def get_bsf_tracking(self, tenant_id: str = "default"):
        """Track Black Soldier Fly larvae production from database"""
        try:
            cycles = self.db.query(models.BSFCycle).filter(
                models.BSFCycle.tenant_id == tenant_id
            ).all()

            if not cycles:
                return self._get_mock_bsf_tracking()

            result = []
            for c in cycles:
                # Calculate days remaining (assuming 14 day cycle standard for BSF)
                days_active = (datetime.utcnow() - c.start_date).days
                days_remaining = max(0, 14 - days_active)
                
                # Calculate conversion ratio
                ratio = 0.0
                if c.actual_yield_kg and c.waste_input_kg > 0:
                    ratio = c.actual_yield_kg / c.waste_input_kg
                elif c.expected_yield_kg and c.waste_input_kg > 0:
                    ratio = c.expected_yield_kg / c.waste_input_kg

                result.append({
                    "id": c.id,
                    "cycle_name": c.cycle_name,
                    "start_date": c.start_date.isoformat(),
                    "waste_input_kg": c.waste_input_kg,
                    "expected_yield_kg": c.expected_yield_kg,
                    "status": c.status,
                    "conversion_ratio": round(ratio, 2),
                    "days_remaining": days_remaining
                })
            return result
        except Exception as e:
            logger.error(f"Error fetching BSF tracking: {e}")
            return self._get_mock_bsf_tracking()

    def _get_mock_bsf_tracking(self):
        """Mock fallback"""
        return [
            {
                "id": 1, "cycle_name": "Cycle-2026-02-A (Mock)", "start_date": "2026-02-01",
                "waste_input_kg": 250, "expected_yield_kg": 50, "status": "active",
                "conversion_ratio": 0.2, "days_remaining": 5
            }
        ]

    def create_bsf_cycle(self, cycle_data: Dict[str, Any], tenant_id: str = "default"):
        """Create a new BSF cycle"""
        try:
            new_cycle = models.BSFCycle(
                tenant_id=tenant_id,
                cycle_name=cycle_data.get("cycle_name"),
                start_date=datetime.utcnow(),
                waste_input_kg=cycle_data.get("waste_input_kg", 0.0),
                expected_yield_kg=cycle_data.get("expected_yield_kg", 0.0),
                status="active"
            )
            
            self.db.add(new_cycle)
            self.db.commit()
            self.db.refresh(new_cycle)
            
            return {
                "success": True,
                "message": "BSF Cycle created successfully",
                "id": new_cycle.id
            }
        except Exception as e:
            logger.error(f"Error creating BSF cycle: {e}")
            self.db.rollback()
            return {"success": False, "error": str(e)}
