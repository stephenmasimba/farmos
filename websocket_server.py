"""
FarmOS WebSocket Server
Standalone WebSocket server for real-time updates
"""

import asyncio
import websockets
import json
import logging
from datetime import datetime
from typing import Dict, Set
import jwt
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FarmOSWebSocketServer:
    """Standalone WebSocket server for FarmOS"""
    
    def __init__(self):
        self.active_connections: Dict[str, Set] = {}  # tenant_id -> set of connections
        self.user_connections: Dict[str, websockets.WebSocketServerProtocol] = {}  # user_id -> connection
        self.tenant_users: Dict[str, Set[str]] = {}  # tenant_id -> set of user_ids
        
    async def register_connection(self, websocket, path: str):
        """Register new WebSocket connection"""
        try:
            # Extract user_id and token from path
            # Expected path: /ws/{user_id}?token={jwt_token}
            parts = path.split('/')
            if len(parts) < 3:
                await websocket.close(code=4001, reason="Invalid path format")
                return
            
            user_id = parts[2]
            
            # Parse query parameters for token
            query_params = {}
            if '?' in path:
                query_string = path.split('?', 1)[1]
                for param in query_string.split('&'):
                    if '=' in param:
                        key, value = param.split('=', 1)
                        query_params[key] = value
            
            token = query_params.get('token')
            if not token:
                await websocket.close(code=4001, reason="Authentication token required")
                return
            
            # Validate JWT token
            user_info = self.validate_token(token)
            if not user_info:
                await websocket.close(code=4001, reason="Invalid authentication token")
                return
            
            tenant_id = user_info.get('tenant_id', 'default')
            
            # Store connection
            self.user_connections[user_id] = websocket
            
            if tenant_id not in self.active_connections:
                self.active_connections[tenant_id] = set()
            self.active_connections[tenant_id].add(websocket)
            
            if tenant_id not in self.tenant_users:
                self.tenant_users[tenant_id] = set()
            self.tenant_users[tenant_id].add(user_id)
            
            logger.info(f"User {user_id} connected to tenant {tenant_id}")
            
            # Send welcome message
            await websocket.send(json.dumps({
                "type": "connection",
                "message": "Connected to FarmOS real-time updates",
                "timestamp": datetime.utcnow().isoformat(),
                "user_id": user_id,
                "tenant_id": tenant_id
            }))
            
            # Keep connection alive
            await self.handle_connection(websocket, user_id, tenant_id)
            
        except Exception as e:
            logger.error(f"Connection registration error: {e}")
            await websocket.close(code=4000, reason="Internal server error")
    
    def validate_token(self, token: str) -> dict:
        """Validate JWT token and return user info"""
        try:
            # This is a simplified validation
            # In production, you'd validate against your database
            secret = os.getenv('SECRET_KEY', 'fallback_secret')
            payload = jwt.decode(token, secret, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            logger.warning("Token expired")
            return None
        except jwt.InvalidTokenError:
            logger.warning("Invalid token")
            return None
        except Exception as e:
            logger.error(f"Token validation error: {e}")
            return None
    
    async def handle_connection(self, websocket, user_id: str, tenant_id: str):
        """Handle ongoing WebSocket connection"""
        try:
            async for message in websocket:
                data = json.loads(message)
                await self.handle_message(websocket, data, user_id, tenant_id)
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Connection closed for user {user_id}")
        except Exception as e:
            logger.error(f"Connection handling error: {e}")
        finally:
            await self.unregister_connection(websocket, user_id, tenant_id)
    
    async def unregister_connection(self, websocket, user_id: str, tenant_id: str):
        """Unregister WebSocket connection"""
        # Remove from user connections
        if user_id in self.user_connections:
            del self.user_connections[user_id]
        
        # Remove from tenant connections
        if tenant_id in self.active_connections:
            self.active_connections[tenant_id].discard(websocket)
            if not self.active_connections[tenant_id]:
                del self.active_connections[tenant_id]
        
        # Remove from tenant users
        if tenant_id in self.tenant_users:
            self.tenant_users[tenant_id].discard(user_id)
            if not self.tenant_users[tenant_id]:
                del self.tenant_users[tenant_id]
        
        logger.info(f"User {user_id} disconnected from tenant {tenant_id}")
    
    async def handle_message(self, websocket, data: dict, user_id: str, tenant_id: str):
        """Handle incoming WebSocket messages"""
        message_type = data.get("type")
        
        if message_type == "ping":
            await websocket.send(json.dumps({
                "type": "pong",
                "timestamp": datetime.utcnow().isoformat()
            }))
        
        elif message_type == "subscribe":
            subscription = data.get("subscription")
            await websocket.send(json.dumps({
                "type": "subscription_confirmed",
                "subscription": subscription,
                "timestamp": datetime.utcnow().isoformat()
            }))
        
        elif message_type == "get_dashboard":
            # Send current dashboard data
            dashboard_data = await self.get_dashboard_data(tenant_id)
            await websocket.send(json.dumps({
                "type": "dashboard_data",
                "data": dashboard_data,
                "timestamp": datetime.utcnow().isoformat()
            }))
    
    async def get_dashboard_data(self, tenant_id: str) -> dict:
        """Get dashboard data for tenant"""
        # This would typically query your database
        return {
            "alerts": 5,
            "tasks_due": 12,
            "livestock_batches": 8,
            "inventory_low": 3,
            "last_updated": datetime.utcnow().isoformat()
        }
    
    async def broadcast_to_tenant(self, tenant_id: str, message: dict):
        """Broadcast message to all users in tenant"""
        if tenant_id in self.active_connections:
            message_str = json.dumps({
                **message,
                "timestamp": datetime.utcnow().isoformat()
            })
            
            # Send to all connections in tenant
            disconnected = set()
            for connection in self.active_connections[tenant_id]:
                try:
                    await connection.send(message_str)
                except websockets.exceptions.ConnectionClosed:
                    disconnected.add(connection)
                except Exception as e:
                    logger.error(f"Broadcast error: {e}")
                    disconnected.add(connection)
            
            # Clean up disconnected connections
            for connection in disconnected:
                self.active_connections[tenant_id].discard(connection)
    
    async def send_notification(self, tenant_id: str, notification: dict):
        """Send notification to tenant"""
        await self.broadcast_to_tenant(tenant_id, {
            "type": "notification",
            "notification": notification
        })
    
    async def send_dashboard_update(self, tenant_id: str, data: dict):
        """Send dashboard update to tenant"""
        await self.broadcast_to_tenant(tenant_id, {
            "type": "dashboard_update",
            "data": data
        })

# Global server instance
ws_server = FarmOSWebSocketServer()

async def main():
    """Main WebSocket server function"""
    # Create WebSocket server
    server = await websockets.serve(
        ws_server.register_connection,
        "localhost",
        8001,
        path="/ws"
    )
    
    logger.info("FarmOS WebSocket server started on ws://localhost:8001/ws")
    logger.info("WebSocket endpoint: ws://localhost:8001/ws/{user_id}?token={jwt_token}")
    
    # Keep server running
    await server.wait_closed()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("WebSocket server stopped by user")
    except Exception as e:
        logger.error(f"WebSocket server error: {e}")
