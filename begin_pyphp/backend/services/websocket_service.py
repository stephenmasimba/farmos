#!/usr/bin/env python3
"""
FarmOS WebSocket Server for Real-time Updates
Handles real-time data streaming for dashboard, notifications, and live updates
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Dict, List, Set
from fastapi import WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ConnectionManager:
    """Manages WebSocket connections and broadcasts"""
    
    def __init__(self):
        # Store active connections by user and tenant
        self.active_connections: Dict[str, List[WebSocket]] = {}
        self.tenant_connections: Dict[str, Set[str]] = {}
        
    async def connect(self, websocket: WebSocket, user_id: str, tenant_id: str):
        """Accept and store WebSocket connection"""
        await websocket.accept()
        
        # Add to user connections
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
        
        # Add to tenant tracking
        if tenant_id not in self.tenant_connections:
            self.tenant_connections[tenant_id] = set()
        self.tenant_connections[tenant_id].add(user_id)
        
        logger.info(f"User {user_id} connected to tenant {tenant_id}")
        
        # Send welcome message
        await websocket.send_json({
            "type": "connection",
            "message": "Connected to FarmOS real-time updates",
            "timestamp": datetime.utcnow().isoformat(),
            "user_id": user_id,
            "tenant_id": tenant_id
        })
    
    def disconnect(self, websocket: WebSocket, user_id: str, tenant_id: str):
        """Remove WebSocket connection"""
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        
        if tenant_id in self.tenant_connections:
            self.tenant_connections[tenant_id].discard(user_id)
            if not self.tenant_connections[tenant_id]:
                del self.tenant_connections[tenant_id]
        
        logger.info(f"User {user_id} disconnected from tenant {tenant_id}")
    
    async def send_personal_message(self, message: dict, user_id: str):
        """Send message to specific user"""
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending message to user {user_id}: {e}")
    
    async def broadcast_to_tenant(self, message: dict, tenant_id: str):
        """Broadcast message to all users in tenant"""
        if tenant_id in self.tenant_connections:
            for user_id in self.tenant_connections[tenant_id]:
                await self.send_personal_message(message, user_id)
    
    async def broadcast_dashboard_update(self, tenant_id: str, data: dict):
        """Send dashboard updates to all tenant users"""
        message = {
            "type": "dashboard_update",
            "data": data,
            "timestamp": datetime.utcnow().isoformat()
        }
        await self.broadcast_to_tenant(message, tenant_id)
    
    async def broadcast_notification(self, tenant_id: str, notification: dict):
        """Send notification to specific users or all tenant users"""
        message = {
            "type": "notification",
            "notification": notification,
            "timestamp": datetime.utcnow().isoformat()
        }
        
        if notification.get("user_id"):
            # Send to specific user
            await self.send_personal_message(message, notification["user_id"])
        else:
            # Send to all tenant users
            await self.broadcast_to_tenant(message, tenant_id)
    
    async def broadcast_livestock_update(self, tenant_id: str, livestock_data: dict):
        """Send livestock updates to dashboard"""
        message = {
            "type": "livestock_update",
            "data": livestock_data,
            "timestamp": datetime.utcnow().isoformat()
        }
        await self.broadcast_to_tenant(message, tenant_id)
    
    async def broadcast_inventory_alert(self, tenant_id: str, alert_data: dict):
        """Send inventory alerts to relevant users"""
        message = {
            "type": "inventory_alert",
            "alert": alert_data,
            "timestamp": datetime.utcnow().isoformat()
        }
        await self.broadcast_to_tenant(message, tenant_id)

# Global connection manager
manager = ConnectionManager()

class WebSocketService:
    """WebSocket service for real-time updates"""
    
    def __init__(self):
        self.manager = manager
    
    async def handle_websocket(self, websocket: WebSocket, user_id: str, tenant_id: str):
        """Handle WebSocket connection lifecycle"""
        try:
            await self.manager.connect(websocket, user_id, tenant_id)
            
            while True:
                # Receive message from client
                data = await websocket.receive_text()
                message = json.loads(data)
                
                # Handle different message types
                await self.handle_client_message(message, user_id, tenant_id)
                
        except WebSocketDisconnect:
            self.manager.disconnect(websocket, user_id, tenant_id)
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            self.manager.disconnect(websocket, user_id, tenant_id)
    
    async def handle_client_message(self, message: dict, user_id: str, tenant_id: str):
        """Handle incoming messages from clients"""
        message_type = message.get("type")
        
        if message_type == "ping":
            # Respond to ping
            await self.manager.send_personal_message({
                "type": "pong",
                "timestamp": datetime.utcnow().isoformat()
            }, user_id)
        
        elif message_type == "subscribe":
            # Handle subscription to specific data types
            subscription = message.get("subscription")
            await self.handle_subscription(subscription, user_id, tenant_id)
        
        elif message_type == "get_dashboard":
            # Send current dashboard data
            await self.send_dashboard_data(user_id, tenant_id)
    
    async def handle_subscription(self, subscription: str, user_id: str, tenant_id: str):
        """Handle client subscriptions"""
        # Store subscription preferences (could be enhanced with database storage)
        await self.manager.send_personal_message({
            "type": "subscription_confirmed",
            "subscription": subscription,
            "timestamp": datetime.utcnow().isoformat()
        }, user_id)
    
    async def send_dashboard_data(self, user_id: str, tenant_id: str):
        """Send current dashboard data"""
        try:
            # Get dashboard data from database
            dashboard_data = await self.get_dashboard_summary(tenant_id)
            
            await self.manager.send_personal_message({
                "type": "dashboard_data",
                "data": dashboard_data,
                "timestamp": datetime.utcnow().isoformat()
            }, user_id)
            
        except Exception as e:
            logger.error(f"Error sending dashboard data: {e}")
    
    async def get_dashboard_summary(self, tenant_id: str) -> dict:
        """Get dashboard summary data"""
        # This would typically query the database
        # For now, return mock data
        return {
            "alerts": 5,
            "tasks_due": 12,
            "livestock_batches": 8,
            "inventory_low": 3,
            "last_updated": datetime.utcnow().isoformat()
        }
    
    # Public methods for other services to call
    async def notify_dashboard_update(self, tenant_id: str, data: dict):
        """Public method to notify dashboard updates"""
        await self.manager.broadcast_dashboard_update(tenant_id, data)
    
    async def send_notification(self, tenant_id: str, notification: dict):
        """Public method to send notifications"""
        await self.manager.broadcast_notification(tenant_id, notification)
    
    async def notify_livestock_update(self, tenant_id: str, livestock_data: dict):
        """Public method to notify livestock updates"""
        await self.manager.broadcast_livestock_update(tenant_id, livestock_data)
    
    async def notify_inventory_alert(self, tenant_id: str, alert_data: dict):
        """Public method to notify inventory alerts"""
        await self.manager.broadcast_inventory_alert(tenant_id, alert_data)

# Global WebSocket service instance
websocket_service = WebSocketService()
