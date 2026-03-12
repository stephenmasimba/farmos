from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from ..common.database import get_db
from ..common.dependencies import get_current_user, get_tenant_id
from ..common import models

router = APIRouter()

@router.get("/summary")
async def summary(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
    tenant_id: str = Depends(get_tenant_id),
):
    """
    Get dashboard summary statistics
    Returns counts for alerts, tasks, livestock batches, and low inventory items
    """
    try:
        inventory_low_query = db.query(models.InventoryItem).filter(
            and_(
                models.InventoryItem.quantity < models.InventoryItem.low_stock_threshold,
                models.InventoryItem.quantity > 0,
                models.InventoryItem.tenant_id == tenant_id,
            )
        )
        inventory_low_count = inventory_low_query.count()
        
        # Get actual low stock items for display
        low_stock_items = []
        for item in inventory_low_query.limit(10).all():
            low_stock_items.append({
                'name': item.name,
                'quantity': item.quantity,
                'unit': item.unit or 'units',
                'location': item.location or 'Main Store'
            })
        
        # Tasks Due: Pending or In Progress tasks
        tasks_due_count = db.query(models.Task).filter(
            models.Task.tenant_id == tenant_id,
            models.Task.status.in_(["pending", "in_progress"]),
        ).count()
        
        # Active Livestock Batches
        livestock_count = db.query(models.LivestockBatch).filter(
            models.LivestockBatch.tenant_id == tenant_id,
            models.LivestockBatch.status == "active",
        ).count()

        income = db.query(func.sum(models.FinancialTransaction.amount)).filter(
            models.FinancialTransaction.tenant_id == tenant_id,
            models.FinancialTransaction.type == "income",
        ).scalar() or 0.0

        expense = db.query(func.sum(models.FinancialTransaction.amount)).filter(
            models.FinancialTransaction.tenant_id == tenant_id,
            models.FinancialTransaction.type == "expense",
        ).scalar() or 0.0

        financial_summary = {
            "total_income": float(income),
            "total_expense": float(expense),
            "net_profit": float(income - expense),
        }
        
        # Alerts: Combine critical issues
        alerts_count = inventory_low_count  # Base alerts from low stock
        
        # Add more alert sources as needed
        # For example: overdue tasks, health issues, equipment failures
        
        return {
            "alerts": alerts_count,
            "tasks_due": tasks_due_count,
            "livestock_batches": livestock_count,
            "inventory_low": inventory_low_count,
            "low_stock_items": low_stock_items,
            "financial": financial_summary,
            "last_updated": datetime.utcnow().isoformat(),
        }
        
    except Exception as e:
        return {
            "alerts": 0,
            "tasks_due": 0,
            "livestock_batches": 0,
            "inventory_low": 0,
            "low_stock_items": [],
            "financial": {
                "total_income": 0.0,
                "total_expense": 0.0,
                "net_profit": 0.0,
            },
            "error": str(e),
            "last_updated": None
        }
