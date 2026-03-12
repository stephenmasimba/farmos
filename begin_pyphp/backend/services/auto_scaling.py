"""
FarmOS Auto-scaling Service
Auto-scaling capabilities for dynamic resource management
"""

import asyncio
import psutil
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class AutoScalingService:
    """Auto-scaling service for dynamic resource management"""
    
    def __init__(self):
        self.scaling_policies = {}
        self.current_metrics = {}
        self.scaling_history = []
        self.is_running = False
        self.scaling_actions = []
        
        # Initialize scaling policies
        self._initialize_scaling_policies()
        
    def _initialize_scaling_policies(self):
        """Initialize auto-scaling policies"""
        self.scaling_policies = {
            'cpu_scaling': {
                'name': 'CPU Auto-scaling',
                'enabled': True,
                'min_instances': 1,
                'max_instances': 10,
                'scale_up_threshold': 80,  # CPU usage %
                'scale_down_threshold': 20,  # CPU usage %
                'cooldown_period': 300,  # seconds
                'scale_up_increment': 2,
                'scale_down_decrement': 1
            },
            'memory_scaling': {
                'name': 'Memory Auto-scaling',
                'enabled': True,
                'min_instances': 1,
                'max_instances': 8,
                'scale_up_threshold': 85,  # Memory usage %
                'scale_down_threshold': 30,  # Memory usage %
                'cooldown_period': 300,
                'scale_up_increment': 2,
                'scale_down_decrement': 1
            },
            'api_scaling': {
                'name': 'API Response Time Scaling',
                'enabled': True,
                'min_instances': 1,
                'max_instances': 6,
                'scale_up_threshold': 2.0,  # Average response time in seconds
                'scale_down_threshold': 0.5,  # Average response time in seconds
                'cooldown_period': 600,
                'scale_up_increment': 1,
                'scale_down_decrement': 1
            },
            'database_scaling': {
                'name': 'Database Connection Scaling',
                'enabled': True,
                'min_connections': 5,
                'max_connections': 50,
                'scale_up_threshold': 80,  # Connection pool usage %
                'scale_down_threshold': 20,  # Connection pool usage %
                'cooldown_period': 300,
                'scale_up_increment': 10,
                'scale_down_decrement': 5
            },
            'load_balancing': {
                'name': 'Load Balancing',
                'enabled': True,
                'algorithm': 'round_robin',
                'health_check_interval': 30,  # seconds
                'unhealthy_threshold': 3,  # consecutive failures
                'backends': [
                    'http://127.0.0.1:8001',
                    'http://127.0.0.1:8002',
                    'http://127.0.0.1:8003'
                ]
            }
        }
    
    async def start_auto_scaling(self):
        """Start auto-scaling service"""
        try:
            if self.is_running:
                logger.warning("Auto-scaling service is already running")
                return
            
            self.is_running = True
            logger.info("Starting auto-scaling service")
            
            # Start scaling loop
            self.scaling_task = asyncio.create_task(self._auto_scaling_loop())
            
            return {
                "status": "success",
                "message": "Auto-scaling service started",
                "started_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error starting auto-scaling: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_auto_scaling(self):
        """Stop auto-scaling service"""
        try:
            self.is_running = False
            
            if self.scaling_task:
                self.scaling_task.cancel()
                self.scaling_task = None
            
            logger.info("Auto-scaling service stopped")
            
            return {
                "status": "success",
                "message": "Auto-scaling service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping auto-scaling: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _auto_scaling_loop(self):
        """Main auto-scaling loop"""
        while self.is_running:
            try:
                # Collect current metrics
                await self._collect_system_metrics()
                
                # Check scaling policies
                for policy_id, policy in self.scaling_policies.items():
                    if policy.get('enabled', False):
                        continue
                    
                    if policy_id == 'cpu_scaling':
                        await self._check_cpu_scaling(policy)
                    elif policy_id == 'memory_scaling':
                        await self._check_memory_scaling(policy)
                    elif policy_id == 'api_scaling':
                        await self._check_api_scaling(policy)
                    elif policy_id == 'database_scaling':
                        await self._check_database_scaling(policy)
                    elif policy_id == 'load_balancing':
                        await self._check_load_balancing(policy)
                
                # Wait for next check (30 seconds)
                await asyncio.sleep(30)
                
        except Exception as e:
            logger.error(f"Error in auto-scaling loop: {e}")
            await asyncio.sleep(30)
    
    async def _collect_system_metrics(self):
        """Collect current system metrics"""
        try:
            # CPU metrics
            cpu_percent = psutil.cpu_percent(interval=1)
            cpu_count = psutil.cpu_count()
            cpu_freq = psutil.cpu_freq()
            
            # Memory metrics
            memory = psutil.virtual_memory()
            memory_percent = memory.percent
            memory_available = memory.available / (1024**3)  # GB
            memory_used = memory.used / (1024**3)  # GB
            
            # Disk metrics
            disk = psutil.disk_usage('/')
            disk_percent = disk.percent
            disk_free = disk.free / (1024**3)  # GB
            
            # Network metrics
            network = psutil.net_io_counters()
            network_bytes_sent = network.bytes_sent
            network_bytes_recv = network.bytes_recv
            
            # Database connection metrics
            db_connections = await self._get_database_connections()
            
            # API metrics
            api_metrics = await self._get_api_metrics()
            
            self.current_metrics = {
                'timestamp': datetime.utcnow(),
                'cpu': {
                    'usage_percent': cpu_percent,
                    'count': cpu_count,
                    'frequency': cpu_freq,
                    'load_average': sum(cpu_percent) / cpu_count
                },
                'memory': {
                    'usage_percent': memory_percent,
                    'used_gb': memory_used,
                    'available_gb': memory_available,
                    'total_gb': memory.total / (1024**3)
                },
                'disk': {
                    'usage_percent': disk_percent,
                    'free_gb': disk_free,
                    'used_gb': disk.used / (1024**3),
                    'total_gb': disk.total / (1024**3)
                },
                'network': {
                    'bytes_sent': network_bytes_sent,
                    'bytes_recv': network_bytes_recv
                },
                'database': {
                    'active_connections': db_connections.get('active', 0),
                    'pool_usage': db_connections.get('pool_usage', 0),
                    'total_connections': db_connections.get('total', 0)
                },
                'api': api_metrics
            }
            
            logger.info(f"System metrics collected: CPU: {cpu_percent}%, Memory: {memory_percent}%")
        
        except Exception as e:
            logger.error(f"Error collecting system metrics: {e}")
    
    async def _get_database_connections(self) -> Dict:
        """Get database connection metrics"""
        try:
            # Mock database connection metrics
            # In production, this would query the database connection pool
            return {
                'active': 5,
                'pool_usage': 65,  # Percentage of pool in use
                'total': 8  # Total pool size
            }
        
        except Exception as e:
            logger.error(f"Error getting database connections: {e}")
            return {'active': 0, 'pool_usage': 0, 'total': 1}
    
    async def _get_api_metrics(self) -> Dict:
        """Get API performance metrics"""
        try:
            # Mock API metrics
            # In production, this would query API performance monitoring
            return {
                'avg_response_time': 1.2,  # seconds
                'requests_per_second': 25,
                'error_rate': 2.5,  # percentage
                'active_connections': 50
                'throughput_mbps': 10.5
            }
        
        except Exception as e:
            logger.error(f"Error getting API metrics: {e}")
            return {
                'avg_response_time': 0,
                'requests_per_second': 0,
                'error_rate': 0,
                'active_connections': 0,
                'throughput_mbps': 0
            }
    
    async def _check_cpu_scaling(self, policy: Dict):
        """Check and execute CPU scaling"""
        try:
            cpu_usage = self.current_metrics['cpu']['usage_percent']
            threshold = policy.get('scale_up_threshold', 80)
            
            # Check if scaling is needed
            if cpu_usage > threshold:
                await self._scale_up('cpu', policy)
            elif cpu_usage < policy.get('scale_down_threshold', 20):
                await self._scale_down('cpu', policy)
        
        except Exception as e:
            logger.error(f"Error in CPU scaling check: {e}")
    
    async def _check_memory_scaling(self, policy: Dict):
        """Check and execute memory scaling"""
        try:
            memory_usage = self.current_metrics['memory']['usage_percent']
            threshold = policy.get('scale_up_threshold', 85)
            
            # Check if scaling is needed
            if memory_usage > threshold:
                await self._scale_up('memory', policy)
            elif memory_usage < policy.get('scale_down_threshold', 30):
                await self._scale_down('memory', policy)
        
        except Exception as e:
            logger.error(f"Error in memory scaling check: {e}")
    
    async def _check_api_scaling(self, policy: Dict):
        """Check and execute API scaling based on response time"""
        try:
            avg_response_time = self.current_metrics['api']['avg_response_time']
            scale_up_threshold = policy.get('scale_up_threshold', 2.0)
            
            # Check if scaling is needed
            if avg_response_time > scale_up_threshold:
                await self._scale_up('api', policy)
            elif avg_response_time < policy.get('scale_down_threshold', 0.5):
                await self._scale_down('api', policy)
        
        except Exception as e:
            logger.error(f"Error in API scaling check: {e}")
    
    async def _check_database_scaling(self, policy: Dict):
        """Check and execute database connection scaling"""
        try:
            pool_usage = self.current_metrics['database']['pool_usage']
            threshold = policy.get('scale_up_threshold', 80)
            
            # Check if scaling is needed
            if pool_usage > threshold:
                await self._scale_up('database', policy)
            elif pool_usage < policy.get('scale_down_threshold', 20):
                await self._scale_down('database', policy)
        
        except Exception as e:
            logger.error(f"Error in database scaling check: {e}")
    
    async def _check_load_balancing(self, policy: Dict):
        """Check load balancer health and failover"""
        try:
            backends = policy.get('backends', [])
            health_check_interval = policy.get('health_check_interval', 30)
            
            # Check backend health
            unhealthy_backends = []
            for i, backend in enumerate(backends):
                try:
                    import aiohttp
                    
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=5)) as session:
                        async with session.get(f"{backend}/health") as response:
                            if response.status != 200:
                                unhealthy_backends.append({
                                    'backend': backend,
                                    'status': 'unhealthy',
                                    'response_time': time.time(),
                                    'error': await response.text()
                                })
                except Exception as e:
                    unhealthy_backends.append({
                        'backend': backend,
                        'status': 'error',
                        'error': str(e),
                        'response_time': time.time()
                    })
            
            # Update load balancer configuration if needed
            if len(unhealthy_backends) >= policy.get('unhealthy_threshold', 3):
                await self._update_load_balancer(policy, unhealthy_backends)
        
        except Exception as e:
            logger.error(f"Error in load balancing check: {e}")
    
    async def _scale_up(self, resource_type: str, policy: Dict):
        """Scale up resources"""
        try:
            increment = policy.get('scale_up_increment', 1)
            cooldown = policy.get('cooldown_period', 300)
            
            # Check cooldown
            last_scale = self._get_last_scaling_action(resource_type)
            if last_scale:
                time_since_last = (datetime.utcnow() - last_scale['timestamp']).total_seconds()
                if time_since_last < cooldown:
                    logger.info(f"Scaling up {resource_type} skipped due to cooldown")
                    return
            
            # Execute scaling action
            if resource_type == 'cpu':
                await self._scale_up_cpu(increment)
            elif resource_type == 'memory':
                await self._scale_up_memory(increment)
            elif resource_type == 'api':
                await self._scale_up_api(increment)
            elif resource_type == 'database':
                await self._scale_up_database(increment)
        
        except Exception as e:
            logger.error(f"Error scaling up {resource_type}: {e}")
    
    async def _scale_down(self, resource_type: str, policy: Dict):
        """Scale down resources"""
        try:
            decrement = policy.get('scale_down_decrement', 1)
            cooldown = policy.get('cooldown_period', 300)
            
            # Check cooldown
            last_scale = self._get_last_scaling_action(resource_type)
            if last_scale:
                time_since_last = (datetime.utcnow() - last_scale['timestamp']).total_seconds()
                if time_since_last < cooldown:
                    logger.info(f"Scaling down {resource_type} skipped due to cooldown")
                    return
            
            # Execute scaling action
            if resource_type == 'cpu':
                await self._scale_down_cpu(decrement)
            elif resource_type == 'memory':
                await self._scale_down_memory(decrement)
            elif resource_type == 'api':
                await self._scale_down_api(decrement)
            elif resource_type == 'database':
                await self._scale_down_database(decrement)
        
        except Exception as e:
            logger.error(f"Error scaling down {resource_type}: {e}")
    
    async def _scale_up_cpu(self, increment: int):
        """Scale up CPU resources"""
        try:
            # Log scaling action
            action = {
                'type': 'scale_up',
                'resource': 'cpu',
                'increment': increment,
                'timestamp': datetime.utcnow(),
                'reason': f"CPU usage above threshold",
                'metrics_before': self.current_metrics['cpu']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling up CPU by {increment} instances")
            
            # In production, this would actually scale up CPU resources
            # For now, just log the action
            
        except Exception as e:
            logger.error(f"Error scaling up CPU: {e}")
    
    async def _scale_up_memory(self, increment: int):
        """Scale up memory resources"""
        try:
            action = {
                'type': 'scale_up',
                'resource': 'memory',
                'increment': increment,
                'timestamp': datetime.utcnow(),
                'reason': f"Memory usage above threshold",
                'metrics_before': self.current_metrics['memory']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling up memory by {increment} GB")
        
        except Exception as e:
            logger.error(f"Error scaling up memory: {e}")
    
    async def _scale_up_api(self, increment: int):
        """Scale up API instances"""
        try:
            action = {
                'type': 'scale_up',
                'resource': 'api',
                'increment': increment,
                'timestamp': datetime.utcnow(),
                'reason': f"API response time above threshold",
                'metrics_before': self.current_metrics['api']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling up API by {increment} instances")
        
        except Exception as e:
            logger.error(f"Error scaling up API: {e}")
    
    async def _scale_up_database(self, increment: int):
        """Scale up database connections"""
        try:
            action = {
                'type': 'scale_up',
                'resource': 'database',
                'increment': increment,
                'timestamp': datetime.utcnow(),
                'reason': f"Database connection pool usage above threshold",
                'metrics_before': self.current_metrics['database']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling up database pool by {increment} connections")
        
        except Exception as e:
            logger.error(f"Error scaling up database: {e}")
    
    async def _scale_down_cpu(self, decrement: int):
        """Scale down CPU resources"""
        try:
            action = {
                'type': 'scale_down',
                'resource': 'cpu',
                'decrement': decrement,
                'timestamp': datetime.utcnow(),
                'reason': f"CPU usage below threshold",
                'metrics_before': self.current_metrics['cpu']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling down CPU by {decrement} instances")
        
        except Exception as e:
            logger.error(f"Error scaling down CPU: {e}")
    
    async def _scale_down_memory(self, decrement: int):
        """Scale down memory resources"""
        try:
            action = {
                'type': 'scale_down',
                'resource': 'memory',
                'decrement': decrement,
                'timestamp': datetime.utcnow(),
                'reason': f"Memory usage below threshold",
                'metrics_before': self.current_metrics['memory']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling down memory by {decrement} GB")
        
        except Exception as e:
            logger.error(f"Error scaling down memory: {e}")
    
    async def _scale_down_api(self, decrement: int):
        """Scale down API instances"""
        try:
            action = {
                'type': 'scale_down',
                'resource': 'api',
                'decrement': decrement,
                'timestamp': datetime.utcnow(),
                'reason': f"API response time below threshold",
                'metrics_before': self.current_metrics['api']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling down API by {decrement} instances")
        
        except Exception as e:
            logger.error(f"Error scaling down API: {e}")
    
    async def _scale_down_database(self, decrement: int):
        """Scale down database connections"""
        try:
            action = {
                'type': 'scale_down',
                'resource': 'database',
                'decrement': decrement,
                'timestamp': datetime.utcnow(),
                'reason': f"Database connection pool usage below threshold",
                'metrics_before': self.current_metrics['database']
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Scaling down database pool by {decrement} connections")
        
        except Exception as e:
            logger.error(f"Error scaling down database: {e}")
    
    def _get_last_scaling_action(self, resource_type: str) -> Optional[Dict]:
        """Get last scaling action for a resource"""
        try:
            # Get last scaling action for resource type
            resource_actions = [action for action in self.scaling_actions if action.get('resource') == resource_type]
            
            if not resource_actions:
                return None
            
            # Return most recent action
            return max(resource_actions, key=lambda x: x['timestamp'])
        
        except Exception as e:
            logger.error(f"Error getting last scaling action: {e}")
            return None
    
    async def _update_load_balancer(self, policy: Dict, unhealthy_backends: List[Dict]):
        """Update load balancer configuration"""
        try:
            # Log load balancer update
            action = {
                'type': 'update_load_balancer',
                'timestamp': datetime.utcnow(),
                'unhealthy_backends': unhealthy_backends,
                'policy': policy.get('algorithm', 'round_robin'),
                'total_backends': len(policy.get('backends', [])),
                'healthy_backends': len(policy.get('backends', [])) - len(unhealthy_backends)
            }
            
            self.scaling_actions.append(action)
            logger.info(f"Updated load balancer: {len(unhealthy_backends)} unhealthy backends")
            
            # In production, this would actually update the load balancer configuration
            # For now, just log the action
        
        except Exception as e:
            logger.error(f"Error updating load balancer: {e}")
    
    def get_scaling_status(self) -> Dict:
        """Get current auto-scaling status"""
        return {
            'is_running': self.is_running,
            'current_metrics': self.current_metrics,
            'scaling_policies': self.scaling_policies,
            'recent_actions': self.scaling_actions[-10:],  # Last 10 actions
            'total_actions': len(self.scaling_actions),
            'last_updated': datetime.utcnow().isoformat()
        }
    
    def get_scaling_history(self, limit: int = 50) -> List[Dict]:
        """Get scaling history"""
        return self.scaling_actions[-limit:]
    
    def get_scaling_recommendations(self) -> List[str]:
        """Get scaling recommendations based on current metrics"""
        try:
            recommendations = []
            
            # CPU recommendations
            cpu_usage = self.current_metrics['cpu']['usage_percent']
            if cpu_usage > 70:
                recommendations.append("Consider CPU scaling up")
            elif cpu_usage < 30:
                recommendations.append("Consider CPU scaling down")
            
            # Memory recommendations
            memory_usage = self.current_metrics['memory']['usage_percent']
            if memory_usage > 75:
                recommendations.append("Consider memory scaling up")
            elif memory_usage < 25:
                recommendations.append("Consider memory scaling down")
            
            # API recommendations
            avg_response_time = self.current_metrics['api']['avg_response_time']
            if avg_response_time > 1.5:
                recommendations.append("Consider API scaling up")
            elif avg_response_time < 0.5:
                recommendations.append("Consider API scaling down")
            
            # Database recommendations
            pool_usage = self.current_metrics['database']['pool_usage']
            if pool_usage > 75:
                recommendations.append("Consider database connection scaling up")
            elif pool_usage < 25:
                recommendations.append("Consider database connection scaling down")
            
            return recommendations
        
        except Exception as e:
            logger.error(f"Error getting scaling recommendations: {e}")
            return ["Error generating recommendations"]

# Global auto-scaling service instance
auto_scaling_service = AutoScalingService()
