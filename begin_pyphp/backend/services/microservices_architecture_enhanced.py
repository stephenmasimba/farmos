"""
Enhanced Microservices Architecture - Phase 4 Feature
Advanced microservices implementation with service discovery, load balancing, and inter-service communication
Derived from Begin Reference System
"""

import logging
import asyncio
import json
import aiohttp
from typing import Dict, List, Optional, Any, Callable
from datetime import datetime, timedelta
from collections import defaultdict
import uuid
import hashlib
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)

class ServiceStatus(Enum):
    HEALTHY = "healthy"
    UNHEALTHY = "unhealthy"
    DEGRADED = "degraded"
    MAINTENANCE = "maintenance"

@dataclass
class ServiceInstance:
    service_id: str
    service_name: str
    host: str
    port: int
    version: str
    status: ServiceStatus
    last_heartbeat: datetime
    metadata: Dict[str, Any]

class ServiceRegistry:
    """Service registry for microservices discovery and management"""
    
    def __init__(self):
        self.services: Dict[str, List[ServiceInstance]] = defaultdict(list)
        self.service_health_checks: Dict[str, Callable] = {}
        self.load_balancers: Dict[str, LoadBalancer] = {}
        
    async def register_service(self, service_data: Dict[str, Any]) -> Dict[str, Any]:
        """Register a new microservice"""
        try:
            service_instance = ServiceInstance(
                service_id=service_data['service_id'],
                service_name=service_data['service_name'],
                host=service_data['host'],
                port=service_data['port'],
                version=service_data.get('version', '1.0.0'),
                status=ServiceStatus.HEALTHY,
                last_heartbeat=datetime.utcnow(),
                metadata=service_data.get('metadata', {})
            )
            
            # Add to registry
            self.services[service_instance.service_name].append(service_instance)
            
            # Initialize load balancer for service
            if service_instance.service_name not in self.load_balancers:
                self.load_balancers[service_instance.service_name] = LoadBalancer(
                    algorithm='round_robin'
                )
            
            # Start health check
            await self._start_health_check(service_instance)
            
            return {
                "success": True,
                "service_id": service_instance.service_id,
                "service_name": service_instance.service_name,
                "registered_at": datetime.utcnow().isoformat(),
                "message": "Service registered successfully"
            }
            
        except Exception as e:
            logger.error(f"Error registering service: {e}")
            return {"error": "Service registration failed"}
    
    async def discover_service(self, service_name: str) -> Optional[ServiceInstance]:
        """Discover a healthy service instance"""
        try:
            instances = self.services.get(service_name, [])
            healthy_instances = [
                inst for inst in instances 
                if inst.status == ServiceStatus.HEALTHY
            ]
            
            if not healthy_instances:
                return None
            
            # Use load balancer to select instance
            load_balancer = self.load_balancers.get(service_name)
            if load_balancer:
                return load_balancer.select_instance(healthy_instances)
            
            return healthy_instances[0]
            
        except Exception as e:
            logger.error(f"Error discovering service: {e}")
            return None
    
    async def deregister_service(self, service_id: str) -> Dict[str, Any]:
        """Deregister a service instance"""
        try:
            for service_name, instances in self.services.items():
                for i, instance in enumerate(instances):
                    if instance.service_id == service_id:
                        instances.pop(i)
                        break
            
            return {
                "success": True,
                "service_id": service_id,
                "deregistered_at": datetime.utcnow().isoformat(),
                "message": "Service deregistered successfully"
            }
            
        except Exception as e:
            logger.error(f"Error deregistering service: {e}")
            return {"error": "Service deregistration failed"}
    
    async def get_service_health(self, service_name: str) -> Dict[str, Any]:
        """Get health status of all instances of a service"""
        try:
            instances = self.services.get(service_name, [])
            
            health_summary = {
                "service_name": service_name,
                "total_instances": len(instances),
                "healthy_instances": len([i for i in instances if i.status == ServiceStatus.HEALTHY]),
                "unhealthy_instances": len([i for i in instances if i.status == ServiceStatus.UNHEALTHY]),
                "degraded_instances": len([i for i in instances if i.status == ServiceStatus.DEGRADED]),
                "instances": []
            }
            
            for instance in instances:
                health_summary["instances"].append({
                    "service_id": instance.service_id,
                    "host": f"{instance.host}:{instance.port}",
                    "status": instance.status.value,
                    "last_heartbeat": instance.last_heartbeat.isoformat(),
                    "version": instance.version
                })
            
            return health_summary
            
        except Exception as e:
            logger.error(f"Error getting service health: {e}")
            return {"error": "Health check failed"}
    
    async def _start_health_check(self, instance: ServiceInstance):
        """Start health checking for service instance"""
        try:
            # This would start periodic health checks
            logger.info(f"Started health check for {instance.service_id}")
        except Exception as e:
            logger.error(f"Error starting health check: {e}")

class LoadBalancer:
    """Load balancer for distributing requests across service instances"""
    
    def __init__(self, algorithm: str = 'round_robin'):
        self.algorithm = algorithm
        self.current_index = 0
        self.instance_weights: Dict[str, int] = {}
        
    def select_instance(self, instances: List[ServiceInstance]) -> ServiceInstance:
        """Select instance based on load balancing algorithm"""
        try:
            if not instances:
                raise ValueError("No healthy instances available")
            
            if self.algorithm == 'round_robin':
                return self._round_robin_select(instances)
            elif self.algorithm == 'least_connections':
                return self._least_connections_select(instances)
            elif self.algorithm == 'weighted':
                return self._weighted_select(instances)
            else:
                return instances[0]
                
        except Exception as e:
            logger.error(f"Error selecting instance: {e}")
            return instances[0]
    
    def _round_robin_select(self, instances: List[ServiceInstance]) -> ServiceInstance:
        """Round-robin selection"""
        instance = instances[self.current_index % len(instances)]
        self.current_index += 1
        return instance
    
    def _least_connections_select(self, instances: List[ServiceInstance]) -> ServiceInstance:
        """Select instance with least connections"""
        # This would track actual connections
        return min(instances, key=lambda x: 0)  # Simplified
    
    def _weighted_select(self, instances: List[ServiceInstance]) -> ServiceInstance:
        """Weighted selection based on instance capacity"""
        # This would use actual weights
        return instances[0]  # Simplified

class APIGateway:
    """API Gateway for routing requests to microservices"""
    
    def __init__(self, service_registry: ServiceRegistry):
        self.service_registry = service_registry
        self.routes: Dict[str, Dict] = {}
        self.middleware_stack: List[Callable] = []
        
    async def add_route(self, path: str, service_name: str, methods: List[str]) -> Dict[str, Any]:
        """Add route to service"""
        try:
            route_config = {
                "path": path,
                "service_name": service_name,
                "methods": methods,
                "created_at": datetime.utcnow().isoformat()
            }
            
            self.routes[path] = route_config
            
            return {
                "success": True,
                "route": route_config,
                "message": "Route added successfully"
            }
            
        except Exception as e:
            logger.error(f"Error adding route: {e}")
            return {"error": "Route addition failed"}
    
    async def route_request(self, path: str, method: str, headers: Dict, 
                          body: Optional[Dict] = None) -> Dict[str, Any]:
        """Route request to appropriate microservice"""
        try:
            # Find matching route
            route = self._find_route(path, method)
            if not route:
                return {"error": "Route not found", "status_code": 404}
            
            # Discover service instance
            instance = await self.service_registry.discover_service(route['service_name'])
            if not instance:
                return {"error": "Service unavailable", "status_code": 503}
            
            # Forward request
            response = await self._forward_request(
                instance, path, method, headers, body
            )
            
            return response
            
        except Exception as e:
            logger.error(f"Error routing request: {e}")
            return {"error": "Request routing failed", "status_code": 500}
    
    def _find_route(self, path: str, method: str) -> Optional[Dict]:
        """Find matching route for path and method"""
        for route_path, route_config in self.routes.items():
            if self._path_matches(path, route_path) and method in route_config['methods']:
                return route_config
        return None
    
    def _path_matches(self, request_path: str, route_path: str) -> bool:
        """Check if request path matches route path"""
        # Simple path matching (could be enhanced with regex)
        if route_path.endswith('*'):
            return request_path.startswith(route_path[:-1])
        return request_path == route_path
    
    async def _forward_request(self, instance: ServiceInstance, path: str, 
                             method: str, headers: Dict, body: Optional[Dict]) -> Dict[str, Any]:
        """Forward request to service instance"""
        try:
            url = f"http://{instance.host}:{instance.port}{path}"
            
            async with aiohttp.ClientSession() as session:
                if method.upper() == 'GET':
                    async with session.get(url, headers=headers) as response:
                        return await self._format_response(response)
                elif method.upper() == 'POST':
                    async with session.post(url, headers=headers, json=body) as response:
                        return await self._format_response(response)
                elif method.upper() == 'PUT':
                    async with session.put(url, headers=headers, json=body) as response:
                        return await self._format_response(response)
                elif method.upper() == 'DELETE':
                    async with session.delete(url, headers=headers) as response:
                        return await self._format_response(response)
                else:
                    return {"error": "Unsupported method", "status_code": 405}
                    
        except Exception as e:
            logger.error(f"Error forwarding request: {e}")
            return {"error": "Request forwarding failed", "status_code": 502}
    
    async def _format_response(self, response: aiohttp.ClientResponse) -> Dict[str, Any]:
        """Format response from microservice"""
        try:
            content = await response.json()
            return {
                "status_code": response.status,
                "headers": dict(response.headers),
                "content": content
            }
        except:
            text = await response.text()
            return {
                "status_code": response.status,
                "headers": dict(response.headers),
                "content": text
            }

class CircuitBreaker:
    """Circuit breaker pattern for fault tolerance"""
    
    def __init__(self, failure_threshold: int = 5, timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'closed'  # closed, open, half_open
        
    async def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker protection"""
        try:
            if self.state == 'open':
                if self._should_attempt_reset():
                    self.state = 'half_open'
                else:
                    raise Exception("Circuit breaker is open")
            
            result = await func(*args, **kwargs)
            
            if self.state == 'half_open':
                self._reset()
            
            return result
            
        except Exception as e:
            self._record_failure()
            raise e
    
    def _should_attempt_reset(self) -> bool:
        """Check if circuit breaker should attempt reset"""
        return (datetime.utcnow() - self.last_failure_time).total_seconds() > self.timeout
    
    def _record_failure(self):
        """Record a failure"""
        self.failure_count += 1
        self.last_failure_time = datetime.utcnow()
        
        if self.failure_count >= self.failure_threshold:
            self.state = 'open'
    
    def _reset(self):
        """Reset circuit breaker"""
        self.failure_count = 0
        self.state = 'closed'

class ServiceMesh:
    """Service mesh for inter-service communication"""
    
    def __init__(self):
        self.services: Dict[str, Dict] = {}
        self.communication_policies: Dict[str, Dict] = {}
        self.circuit_breakers: Dict[str, CircuitBreaker] = {}
        
    async def register_service_mesh(self, service_data: Dict[str, Any]) -> Dict[str, Any]:
        """Register service in mesh"""
        try:
            service_name = service_data['service_name']
            
            self.services[service_name] = {
                **service_data,
                "registered_at": datetime.utcnow().isoformat(),
                "endpoints": service_data.get('endpoints', [])
            }
            
            # Initialize circuit breaker
            self.circuit_breakers[service_name] = CircuitBreaker()
            
            return {
                "success": True,
                "service_name": service_name,
                "mesh_registered_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error registering service mesh: {e}")
            return {"error": "Service mesh registration failed"}
    
    async def communicate_with_service(self, from_service: str, to_service: str, 
                                    message: Dict[str, Any]) -> Dict[str, Any]:
        """Communicate between services with mesh protection"""
        try:
            # Check communication policy
            if not self._is_communication_allowed(from_service, to_service):
                return {"error": "Communication not allowed by policy"}
            
            # Get service endpoint
            target_service = self.services.get(to_service)
            if not target_service:
                return {"error": "Target service not found"}
            
            # Use circuit breaker
            circuit_breaker = self.circuit_breakers.get(to_service)
            if circuit_breaker:
                result = await circuit_breaker.call(
                    self._send_message, target_service, message
                )
            else:
                result = await self._send_message(target_service, message)
            
            return result
            
        except Exception as e:
            logger.error(f"Error in service communication: {e}")
            return {"error": "Service communication failed"}
    
    def _is_communication_allowed(self, from_service: str, to_service: str) -> bool:
        """Check if communication is allowed by policy"""
        policy = self.communication_policies.get(from_service, {})
        allowed_services = policy.get('allowed_services', [])
        
        # If no policy, allow all communication
        if not allowed_services:
            return True
        
        return to_service in allowed_services
    
    async def _send_message(self, target_service: Dict, message: Dict) -> Dict[str, Any]:
        """Send message to target service"""
        try:
            endpoints = target_service.get('endpoints', [])
            if not endpoints:
                return {"error": "No endpoints available"}
            
            # Try first endpoint
            endpoint = endpoints[0]
            url = f"http://{endpoint['host']}:{endpoint['port']}{endpoint.get('path', '/')}"
            
            async with aiohttp.ClientSession() as session:
                async with session.post(url, json=message) as response:
                    return await response.json()
                    
        except Exception as e:
            logger.error(f"Error sending message: {e}")
            return {"error": "Message sending failed"}

class DistributedTracing:
    """Distributed tracing for microservices"""
    
    def __init__(self):
        self.traces: Dict[str, Dict] = {}
        self.active_spans: Dict[str, Dict] = {}
        
    async def start_trace(self, trace_id: str, operation_name: str, 
                         parent_span_id: Optional[str] = None) -> Dict[str, Any]:
        """Start a new trace"""
        try:
            span_id = str(uuid.uuid4())
            
            span = {
                "trace_id": trace_id,
                "span_id": span_id,
                "parent_span_id": parent_span_id,
                "operation_name": operation_name,
                "start_time": datetime.utcnow(),
                "status": "running",
                "tags": {},
                "logs": []
            }
            
            self.active_spans[span_id] = span
            
            if trace_id not in self.traces:
                self.traces[trace_id] = {
                    "trace_id": trace_id,
                    "spans": [],
                    "started_at": datetime.utcnow()
                }
            
            return {
                "trace_id": trace_id,
                "span_id": span_id,
                "operation_name": operation_name
            }
            
        except Exception as e:
            logger.error(f"Error starting trace: {e}")
            return {"error": "Trace start failed"}
    
    async def finish_span(self, span_id: str, status: str = "completed") -> Dict[str, Any]:
        """Finish a span"""
        try:
            if span_id not in self.active_spans:
                return {"error": "Span not found"}
            
            span = self.active_spans[span_id]
            span["end_time"] = datetime.utcnow()
            span["status"] = status
            span["duration"] = (span["end_time"] - span["start_time"]).total_seconds()
            
            # Move to completed traces
            trace_id = span["trace_id"]
            self.traces[trace_id]["spans"].append(span)
            del self.active_spans[span_id]
            
            return {
                "trace_id": trace_id,
                "span_id": span_id,
                "duration": span["duration"],
                "status": status
            }
            
        except Exception as e:
            logger.error(f"Error finishing span: {e}")
            return {"error": "Span finish failed"}
    
    async def add_span_tag(self, span_id: str, key: str, value: Any) -> Dict[str, Any]:
        """Add tag to span"""
        try:
            if span_id in self.active_spans:
                self.active_spans[span_id]["tags"][key] = value
                return {"success": True}
            else:
                return {"error": "Span not found"}
                
        except Exception as e:
            logger.error(f"Error adding span tag: {e}")
            return {"error": "Tag addition failed"}
    
    async def get_trace(self, trace_id: str) -> Dict[str, Any]:
        """Get trace information"""
        try:
            trace = self.traces.get(trace_id)
            if not trace:
                return {"error": "Trace not found"}
            
            return {
                "trace_id": trace_id,
                "spans": trace["spans"],
                "started_at": trace["started_at"].isoformat(),
                "total_spans": len(trace["spans"]),
                "total_duration": sum(
                    span.get("duration", 0) for span in trace["spans"]
                )
            }
            
        except Exception as e:
            logger.error(f"Error getting trace: {e}")
            return {"error": "Trace retrieval failed"}

class EnhancedMicroservicesService:
    """Enhanced microservices architecture service"""
    
    def __init__(self):
        self.service_registry = ServiceRegistry()
        self.api_gateway = APIGateway(self.service_registry)
        self.service_mesh = ServiceMesh()
        self.distributed_tracing = DistributedTracing()
        
    async def deploy_microservice(self, service_config: Dict[str, Any]) -> Dict[str, Any]:
        """Deploy a new microservice"""
        try:
            # Register in service registry
            registry_result = await self.service_registry.register_service(service_config)
            
            # Register in service mesh
            mesh_result = await self.service_mesh.register_service_mesh(service_config)
            
            # Add routes to API gateway
            routes = service_config.get('routes', [])
            gateway_results = []
            
            for route in routes:
                gateway_result = await self.api_gateway.add_route(
                    route['path'], service_config['service_name'], route['methods']
                )
                gateway_results.append(gateway_result)
            
            return {
                "success": True,
                "service_id": service_config['service_id'],
                "service_name": service_config['service_name'],
                "registry_result": registry_result,
                "mesh_result": mesh_result,
                "gateway_results": gateway_results,
                "deployed_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error deploying microservice: {e}")
            return {"error": "Microservice deployment failed"}
    
    async def get_microservices_overview(self) -> Dict[str, Any]:
        """Get overview of all microservices"""
        try:
            # Get all registered services
            services = {}
            for service_name, instances in self.service_registry.services.items():
                health_info = await self.service_registry.get_service_health(service_name)
                services[service_name] = health_info
            
            # Get mesh information
            mesh_services = list(self.service_mesh.services.keys())
            
            # Get active traces
            active_traces = len(self.distributed_tracing.active_spans)
            completed_traces = len(self.distributed_tracing.traces)
            
            return {
                "total_services": len(services),
                "services": services,
                "mesh_services": mesh_services,
                "active_traces": active_traces,
                "completed_traces": completed_traces,
                "overview_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting microservices overview: {e}")
            return {"error": "Overview retrieval failed"}
    
    async def monitor_service_performance(self, service_name: str) -> Dict[str, Any]:
        """Monitor performance of specific service"""
        try:
            # Get service health
            health_info = await self.service_registry.get_service_health(service_name)
            
            # Get recent traces
            recent_traces = []
            for trace_id, trace in self.distributed_tracing.traces.items():
                service_spans = [
                    span for span in trace["spans"]
                    if span.get("operation_name") == service_name
                ]
                if service_spans:
                    recent_traces.append({
                        "trace_id": trace_id,
                        "spans": service_spans
                    })
            
            # Calculate performance metrics
            performance_metrics = await self._calculate_performance_metrics(recent_traces)
            
            return {
                "service_name": service_name,
                "health_info": health_info,
                "performance_metrics": performance_metrics,
                "recent_traces": recent_traces[-10:],  # Last 10 traces
                "monitoring_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error monitoring service performance: {e}")
            return {"error": "Performance monitoring failed"}
    
    async def _calculate_performance_metrics(self, traces: List[Dict]) -> Dict[str, Any]:
        """Calculate performance metrics from traces"""
        try:
            if not traces:
                return {
                    "average_response_time": 0,
                    "error_rate": 0,
                    "throughput": 0,
                    "p95_response_time": 0
                }
            
            # Extract span durations
            durations = []
            error_count = 0
            
            for trace in traces:
                for span in trace["spans"]:
                    if span.get("duration"):
                        durations.append(span["duration"])
                    if span.get("status") == "error":
                        error_count += 1
            
            if not durations:
                return {
                    "average_response_time": 0,
                    "error_rate": 0,
                    "throughput": 0,
                    "p95_response_time": 0
                }
            
            # Calculate metrics
            avg_response_time = sum(durations) / len(durations)
            error_rate = (error_count / len(durations)) * 100
            throughput = len(traces) / 60  # traces per minute (assuming 1 minute window)
            
            # Calculate 95th percentile
            sorted_durations = sorted(durations)
            p95_index = int(len(sorted_durations) * 0.95)
            p95_response_time = sorted_durations[p95_index] if p95_index < len(sorted_durations) else sorted_durations[-1]
            
            return {
                "average_response_time": avg_response_time,
                "error_rate": error_rate,
                "throughput": throughput,
                "p95_response_time": p95_response_time,
                "total_requests": len(durations)
            }
            
        except Exception as e:
            logger.error(f"Error calculating performance metrics: {e}")
            return {}

# Global microservices service instance
microservices_service = EnhancedMicroservicesService()
