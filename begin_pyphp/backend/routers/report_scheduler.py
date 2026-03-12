"""
FarmOS Automated Reports Router
API endpoints for automated report generation and scheduling
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
from ..services.report_scheduler import report_scheduler
from ..common.database import get_db
from ..common import models
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/scheduler/status")
async def get_scheduler_status():
    """
    Get current scheduler status
    """
    try:
        return {
            "status": "success",
            "data": {
                "is_running": report_scheduler.is_running,
                "scheduled_reports": len(report_scheduler.scheduled_reports),
                "last_update": report_scheduler.last_update.isoformat() if report_scheduler.last_update else None,
                "active_tasks": 1 if report_scheduler.scheduler_task and not report_scheduler.scheduler_task.done() else 0
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting scheduler status: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get scheduler status",
                "message": str(e)
            }
        )

@router.post("/scheduler/start")
async def start_scheduler(
    background_tasks: BackgroundTasks = Depends()
):
    """
    Start the automated report scheduler
    """
    try:
        result = await report_scheduler.start_scheduler()
        return result
        
    except Exception as e:
        logger.error(f"Error starting scheduler: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to start scheduler",
                "message": str(e)
            }
        )

@router.post("/scheduler/stop")
async def stop_scheduler():
    """
    Stop the automated report scheduler
    """
    try:
        result = await report_scheduler.stop_scheduler()
        return result
        
    except Exception as e:
        logger.error(f"Error stopping scheduler: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to stop scheduler",
                "message": str(e)
            }
        )

@router.get("/reports/scheduled")
async def get_scheduled_reports(
    db: Session = Depends(get_db),
    tenant_id: str = "default"
):
    """
    Get list of scheduled reports
    """
    try:
        return {
            "status": "success",
            "data": {
                "scheduled_reports": report_scheduler.scheduled_reports,
                "report_templates": report_scheduler.report_templates,
                "delivery_methods": report_scheduler.delivery_methods,
                "tenant_id": tenant_id
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting scheduled reports: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get scheduled reports",
                "message": str(e)
            }
        )

@router.post("/reports/schedule")
async def schedule_report(
    report_config: Dict,
    db: Session = Depends(get_db)
):
    """
    Schedule a new automated report
    """
    try:
        # Validate report configuration
        required_fields = ['name', 'template', 'schedule', 'recipients', 'format']
        for field in required_fields:
            if field not in report_config:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail={
                        "error": f"Missing required field: {field}",
                        "message": f"Field '{field}' is required"
                    }
                )
        
        # Validate template exists
        template_name = report_config.get('template')
        if template_name not in report_scheduler.report_templates:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": f"Unknown template: {template_name}",
                    "message": f"Template '{template_name}' is not available"
                }
            )
        
        # Validate recipients
        recipients = report_config.get('recipients', [])
        if not recipients or not isinstance(recipients, list):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Invalid recipients format",
                    "message": "Recipients must be a list of email addresses"
                }
        
        # Generate unique report ID
        report_id = f"report_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
        
        # Add to scheduled reports
        report_scheduler.scheduled_reports[report_id] = {
            **report_config,
            'id': report_id,
            'created_at': datetime.utcnow(),
            'last_generated': None,
            'active': True
        }
        
        return {
            "status": "success",
            "message": f"Report '{report_config.get('name')}' scheduled successfully",
            "data": {
                "report_id": report_id,
                "report_config": report_config
            }
        }
        
    except Exception as e:
        logger.error(f"Error scheduling report: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to schedule report",
                "message": str(e)
            }
        )

@router.get("/reports/{report_id}")
async def get_scheduled_report(
    report_id: str
):
    """
    Get details of a scheduled report
    """
    try:
        if report_id not in report_scheduler.scheduled_reports:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Report not found",
                    "message": f"Report '{report_id}' is not scheduled"
                }
            )
        
        report_config = report_scheduler.scheduled_reports[report_id]
        
        return {
            "status": "success",
            "data": {
                "report_id": report_id,
                "report_config": report_config,
                "last_generated": report_config.get('last_generated'),
                "active": report_config.get('active', False)
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting scheduled report: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get report details",
                "message": str(e)
            }
        )

@router.post("/reports/{report_id}/generate")
async def generate_report_now(
    report_id: str,
    db: Session = Depends(get_db)
):
    """
    Generate a scheduled report immediately
    """
    try:
        if report_id not in report_scheduler.scheduled_reports:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Report not found",
                    "message": f"Report '{report_id}' is not scheduled"
                }
            )
        
        report_config = report_scheduler.scheduled_reports[report_id]
        
        # Generate and deliver report
        report_data = await report_scheduler._generate_report_data(report_config)
        report_file = await report_scheduler._generate_report_file(report_id, report_data, report_config)
        delivery_results = await report_scheduler._deliver_report(report_id, report_file, report_config)
        
        # Update last generated time
        report_config['last_generated'] = datetime.utcnow()
        
        return {
            "status": "success",
            "message": f"Report '{report_config.get('name')}' generated and delivered",
            "data": {
                "report_id": report_id,
                "report_file": report_file,
                "delivery_results": delivery_results,
                "report_data": report_data
            }
        }
        
    except Exception as e:
            logger.error(f"Error generating report now: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={
                    "error": "Failed to generate report",
                    "message": str(e)
                }
        )

@router.delete("/reports/{report_id}")
async def cancel_scheduled_report(
    report_id: str,
    db: Session = Depends(get_db)
):
    """
    Cancel a scheduled report
    """
    try:
        if report_id in report_scheduler.scheduled_reports:
            del report_scheduler.scheduled_reports[report_id]
            
            return {
                "status": "success",
                "message": f"Report '{report_id}' cancelled"
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Report not found",
                    "message": f"Report '{report_id}' is not scheduled"
                }
            }
        
    except Exception as e:
        logger.error(f"Error cancelling report: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={
                    "error": "Failed to cancel report",
                    "message": str(e)
                }
        )

@router.get("/reports/history")
async def get_report_history(
    db: Session = Depends(get_db),
    tenant_id: str = "default",
    limit: int = 50
):
    """
    Get history of generated reports
    """
    try:
        # Get report generation logs
        # This would query a report logs table
        # For now, return mock data
        
        history = []
        for i in range(min(limit, 10)):
            report_id = f"report_2025_01_{i:02d}_{i:02d}_{i:02d}s"
            history.append({
                'report_id': report_id,
                'report_name': f'Daily Financial Report',
                'generated_at': '2025-01-13T19:06:00Z',
                'status': 'delivered',
                'file_size': 245760,
                'delivery_method': 'email'
            })
        
        return {
            "status": "success",
            "data": {
                "history": history,
                "total_count": len(history),
                "limit": limit
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting report history: {e}")
            raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={
                    "error": "Failed to get report history",
                    "message": str(e)
                }
        )

@router.get("/reports/templates")
async def get_report_templates():
    """
    Get available report templates
    """
    try:
        return {
            "status": "success",
            "data": {
                "templates": report_scheduler.report_templates,
                "metadata": {
                    "total_templates": len(report_scheduler.report_templates),
                    "last_updated": "2025-01-13T19:06:00Z"
                }
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting report templates: {e}")
            raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "Failed to get report templates",
                "message": str(e)
            }
        )

@router.post("/reports/templates/{template_name}")
async def get_template_details(
    template_name: str
):
    """
    Get details of a specific report template
    """
    try:
        if template_name not in report_scheduler.report_templates:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "Template not found",
                    "message": f"Template '{template_name}' is not available"
                }
            )
        
        template = report_scheduler.report_templates[template_name]
        
        return {
            "status": "success",
            "data": template
        }
        
    except Exception as e:
            logger.error(f"Error getting template details: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={
                    "error": "Failed to get template details",
                    "message": str(e)
                }
        )
