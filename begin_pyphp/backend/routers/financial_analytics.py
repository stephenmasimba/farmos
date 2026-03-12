from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..services.financial_analytics import FinancialAnalyticsService
from typing import Optional, List

router = APIRouter()

@router.get("/forecast")
async def get_forecast(months: int = 12, db: Session = Depends(get_db)):
    """Get cash flow forecast"""
    service = FinancialAnalyticsService(db)
    return service.get_cash_flow_forecast(months)

@router.get("/assets")
async def get_assets(db: Session = Depends(get_db)):
    """Get asset depreciation schedule"""
    service = FinancialAnalyticsService(db)
    return service.get_asset_depreciation()

@router.get("/roi")
async def get_roi(db: Session = Depends(get_db)):
    """Get ROI analysis"""
    service = FinancialAnalyticsService(db)
    return service.get_roi_analysis()
