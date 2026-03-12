"""
FarmOS WebSocket Router
Handles WebSocket connections for real-time updates
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from typing import Optional
from ..services.websocket_service import websocket_service, manager
from ..common.security import get_current_user_websocket
from ..common.database import get_db
import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(
    websocket: WebSocket, 
    user_id: str,
    token: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    WebSocket endpoint for real-time updates
    Usage: ws://localhost:8001/ws/user_id?token=jwt_token
    """
    
    try:
        # Validate token and get user info
        if not token:
            await websocket.close(code=4001, reason="Authentication token required")
            return
        
        # Get user from token (you'll need to implement this)
        user = await get_current_user_websocket(token, db)
        if not user:
            await websocket.close(code=4001, reason="Invalid authentication token")
            return
        
        tenant_id = user.tenant_id or "default"
        
        # Handle WebSocket connection
        await websocket_service.handle_websocket(websocket, user_id, tenant_id)
        
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for user {user_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        await websocket.close(code=4000, reason="Internal server error")

@router.get("/ws/status")
async def websocket_status():
    """Get WebSocket server status"""
    return {
        "status": "active",
        "connections": len(manager.active_connections),
        "tenants": len(manager.tenant_connections),
        "timestamp": "2025-01-13T18:52:00Z"
    }

@router.post("/broadcast/{tenant_id}")
async def broadcast_message(
    tenant_id: str,
    message: dict,
    # Add authentication dependency
):
    """
    Broadcast message to all users in a tenant
    For system notifications and updates
    """
    try:
        await websocket_service.broadcast_to_tenant({
            "type": "system_broadcast",
            "data": message,
            "timestamp": "2025-01-13T18:52:00Z"
        }, tenant_id)
        
        return {"status": "success", "message": "Broadcast sent"}
    except Exception as e:
        logger.error(f"Broadcast error: {e}")
        return {"status": "error", "message": str(e)}
