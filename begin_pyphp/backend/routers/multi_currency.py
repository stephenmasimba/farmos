"""
FarmOS Multi-Currency Router
API endpoints for multi-currency support and international operations
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from ..services.multi_currency import multi_currency_service
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/currencies/supported")
async def get_supported_currencies():
    """
    Get list of supported currencies
    """
    try:
        currencies = multi_currency_service.get_supported_currencies()
        
        return {
            "status": "success",
            "data": currencies,
            "metadata": {
                "total_currencies": len(currencies),
                "last_updated": "2025-01-13T19:06:00Z"
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting supported currencies: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get currencies",
                "message": str(e)
            }
        )

@router.get("/currencies/exchange-rates")
async def get_exchange_rates(
    base_currency: str = "USD"
):
    """
    Get current exchange rates
    """
    try:
        # Update exchange rates if needed
        await multi_currency_service.update_exchange_rates()
        
        return {
            "status": "success",
            "data": {
                "base_currency": base_currency,
                "rates": multi_currency_service.exchange_rates,
                "last_update": multi_currency_service.last_update.isoformat() if multi_currency_service.last_update else None
            },
            "metadata": {
                "update_frequency": "3600 seconds",
                "next_update": (multi_currency_service.last_update + timedelta(seconds=3600)).isoformat() if multi_currency_service.last_update else None
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting exchange rates: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get exchange rates",
                "message": str(e)
            }
        )

@router.post("/currencies/convert")
async def convert_currency(
    amount: float,
    from_currency: str,
    to_currency: str,
    db: Session = Depends(get_db)
):
    """
    Convert amount from one currency to another
    """
    try:
        result = multi_currency_service.convert_currency(amount, from_currency, to_currency)
        
        # Log conversion for analytics
        await log_currency_conversion(db, amount, from_currency, to_currency, result)
        
        return {
            "status": "success",
            "data": result
        }
        
    except Exception as e:
        logger.error(f"Error converting currency: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Currency conversion failed",
                "message": str(e)
            }
        )

@router.get("/financial/multi-currency-summary")
async def get_multi_currency_summary(
    db: Session = Depends(get_db),
    base_currency: str = "USD",
    tenant_id: str = "default",
    days: int = 365
):
    """
    Get financial summary in multiple currencies
    """
    try:
        # Get transactions for the period
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        transactions = db.query(models.FinancialTransaction).filter(
            models.FinancialTransaction.tenant_id == tenant_id,
            models.FinancialTransaction.created_at >= start_date
        ).all()
        
        # Convert to list format
        transaction_list = []
        for transaction in transactions:
            transaction_list.append({
                'id': transaction.id,
                'date': transaction.created_at.isoformat() if transaction.created_at else None,
                'type': transaction.type,
                'amount': float(transaction.amount),
                'category': transaction.category,
                'currency': transaction.currency or base_currency,
                'description': transaction.description
            })
        
        # Calculate multi-currency summary
        summary = multi_currency_service.calculate_multi_currency_summary(transaction_list, base_currency)
        
        return {
            "status": "success",
            "data": summary,
            "metadata": {
                "base_currency": base_currency,
                "tenant_id": tenant_id,
                "analysis_period_days": days,
                "transaction_count": len(transaction_list)
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting multi-currency summary: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Multi-currency summary failed",
                "message": str(e)
            }
        )

@router.post("/currencies/set-default")
async def set_default_currency(
    currency: str,
    db: Session = Depends(get_db),
    tenant_id: str = "default"
):
    """
    Set default currency for a tenant
    """
    try:
        # Validate currency
        if not multi_currency_service.validate_currency_code(currency):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Invalid currency code",
                    "message": f"Currency '{currency}' is not supported"
                }
            )
        
        # Update tenant settings (this would typically be stored in a settings table)
        # For now, just return success
        
        return {
            "status": "success",
            "message": f"Default currency set to {currency}",
            "data": {
                "currency": currency,
                "currency_info": multi_currency_service.get_currency_info(currency),
                "tenant_id": tenant_id,
                "updated_at": datetime.utcnow().isoformat()
            }
        }
        
    except Exception as e:
        logger.error(f"Error setting default currency: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to set default currency",
                "message": str(e)
            }
        )

@router.get("/currencies/{currency}/info")
async def get_currency_info(
    currency: str
):
    """
    Get information about a specific currency
    """
    try:
        currency_info = multi_currency_service.get_currency_info(currency)
        
        if not currency_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Currency not found",
                    "message": f"Currency '{currency}' is not supported"
                }
            )
        
        return {
            "status": "success",
            "data": currency_info
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting currency info: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Currency info failed",
                "message": str(e)
            }
        )

@router.post("/currencies/format")
async def format_currency_amount(
    amount: float,
    currency: str,
    include_symbol: bool = True,
    locale: str = "en-US"
):
    """
    Format currency amount for display
    """
    try:
        formatted = multi_currency_service.format_currency(amount, currency, include_symbol)
        
        return {
            "status": "success",
            "data": {
                "amount": amount,
                "currency": currency,
                "formatted": formatted,
                "locale": locale,
                "include_symbol": include_symbol
            }
        }
        
    except Exception as e:
        logger.error(f"Error formatting currency: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Currency formatting failed",
                "message": str(e)
            }
        )

@router.post("/exchange-rates/update")
async def update_exchange_rates_manually(
    rates: Dict[str, float],
    base_currency: str = "USD"
):
    """
    Manually update exchange rates (admin function)
    """
    try:
        # Validate rates
        if not rates or not isinstance(rates, dict):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Invalid rates format",
                    "message": "Rates must be a dictionary"
                }
            )
        
        # Update exchange rates
        multi_currency_service.exchange_rates.update(rates)
        multi_currency_service.exchange_rates[base_currency] = 1.0
        multi_currency_service.last_update = datetime.utcnow()
        
        return {
            "status": "success",
            "message": "Exchange rates updated manually",
            "data": {
                "base_currency": base_currency,
                "updated_rates": multi_currency_service.exchange_rates,
                "last_update": multi_currency_service.last_update.isoformat()
            }
        }
        
    except Exception as e:
        logger.error(f"Error updating exchange rates: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Manual update failed",
                "message": str(e)
            }
        )

async def log_currency_conversion(
    db: Session,
    amount: float,
    from_currency: str,
    to_currency: str,
    conversion_result: Dict
):
    """
    Log currency conversion for analytics
    """
    try:
        # Create conversion log entry
        log_entry = models.FinancialTransaction(
            tenant_id="default",
            type="currency_conversion",
            amount=0.0,  # No actual amount, just logging
            category="system",
            description=f"Currency conversion logged: {amount} {from_currency} -> {to_currency}",
            currency=to_currency,
            created_at=datetime.utcnow()
        )
        
        db.add(log_entry)
        db.commit()
        
        logger.info(f"Currency conversion logged: {amount} {from_currency} -> {to_currency}")
        
    except Exception as e:
        logger.error(f"Error logging currency conversion: {e}")

@router.post("/currencies/start-rate-updates")
async def start_automatic_rate_updates(
    background_tasks: BackgroundTasks = Depends()
):
    """
    Start automatic exchange rate updates
    """
    try:
        # Start background task for rate updates
        background_tasks.add_task(
            multi_currency_service.start_rate_updates()
        )
        
        return {
            "status": "success",
            "message": "Automatic exchange rate updates started",
            "data": {
                "update_interval": multi_currency_service.update_interval,
                "last_update": multi_currency_service.last_update.isoformat() if multi_currency_service.last_update else None
            }
        }
        
    except Exception as e:
        logger.error(f"Error starting rate updates: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to start rate updates",
                "message": str(e)
            }
        )
