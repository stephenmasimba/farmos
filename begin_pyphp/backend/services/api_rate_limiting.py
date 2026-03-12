"""
API Rate Limiting - Phase 1 Feature
Advanced rate limiting and throttling system for API protection
Derived from Begin Reference System
"""

import logging
import asyncio
import time
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from collections import defaultdict, deque
import redis.asyncio as redis
from fastapi import HTTPException, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

logger = logging.getLogger(__name__)

security = HTTPBearer()

class RateLimitService:
    """Advanced rate limiting service with multiple strategies"""
    
    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.redis_url = redis_url
        self.redis_client = None
        self.rate_limits = {
            'default': {'requests': 100, 'window': 60},  # 100 requests per minute
            'authenticated': {'requests': 1000, 'window': 60},  # 1000 requests per minute
            'premium': {'requests': 5000, 'window': 60},  # 5000 requests per minute
            'admin': {'requests': 10000, 'window': 60},  # 10000 requests per minute
            'upload': {'requests': 10, 'window': 60},  # 10 uploads per minute
            'export': {'requests': 5, 'window': 300},  # 5 exports per 5 minutes
            'report': {'requests': 20, 'window': 3600},  # 20 reports per hour
        }
        self.local_cache = defaultdict(lambda: deque())
    
    async def connect(self):
        """Initialize Redis connection"""
        try:
            self.redis_client = redis.from_url(
                self.redis_url,
                encoding="utf-8",
                decode_responses=True
            )
            await self.redis_client.ping()
            logger.info("Rate limiter Redis connection established")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Redis for rate limiting: {e}")
            return False
    
    async def is_allowed(self, key: str, limit_type: str = 'default') -> Tuple[bool, Dict]:
        """Check if request is allowed based on rate limits"""
        try:
            if not self.redis_client:
                await self.connect()
            
            limit_config = self.rate_limits.get(limit_type, self.rate_limits['default'])
            max_requests = limit_config['requests']
            window_seconds = limit_config['window']
            
            # Use Redis sliding window algorithm
            current_time = int(time.time())
            window_start = current_time - window_seconds
            
            # Remove old entries
            await self.redis_client.zremrangebyscore(key, 0, window_start)
            
            # Count current requests
            current_requests = await self.redis_client.zcard(key)
            
            if current_requests >= max_requests:
                # Get oldest request time for retry calculation
                oldest_request = await self.redis_client.zrange(key, 0, 0, withscores=True)
                retry_after = 0
                if oldest_request:
                    retry_after = int(oldest_request[0][1]) + window_seconds - current_time
                
                return False, {
                    'allowed': False,
                    'limit': max_requests,
                    'remaining': 0,
                    'reset_time': current_time + window_seconds,
                    'retry_after': max(retry_after, 1)
                }
            
            # Add current request
            await self.redis_client.zadd(key, {str(current_time): current_time})
            await self.redis_client.expire(key, window_seconds)
            
            return True, {
                'allowed': True,
                'limit': max_requests,
                'remaining': max_requests - current_requests - 1,
                'reset_time': current_time + window_seconds,
                'retry_after': 0
            }
            
        except Exception as e:
            logger.error(f"Rate limiting error: {e}")
            # Fail open - allow request if rate limiting fails
            return True, {'allowed': True, 'error': 'Rate limiting unavailable'}
    
    async def get_rate_limit_status(self, key: str, limit_type: str = 'default') -> Dict:
        """Get current rate limit status"""
        try:
            if not self.redis_client:
                await self.connect()
            
            limit_config = self.rate_limits.get(limit_type, self.rate_limits['default'])
            max_requests = limit_config['requests']
            window_seconds = limit_config['window']
            
            current_time = int(time.time())
            window_start = current_time - window_seconds
            
            # Count current requests
            current_requests = await self.redis_client.zcard(key)
            
            return {
                'limit': max_requests,
                'remaining': max(0, max_requests - current_requests),
                'reset_time': current_time + window_seconds,
                'window': window_seconds
            }
            
        except Exception as e:
            logger.error(f"Rate limit status error: {e}")
            return {'error': 'Unable to get rate limit status'}
    
    async def reset_rate_limit(self, key: str):
        """Reset rate limit for a specific key"""
        try:
            if not self.redis_client:
                await self.connect()
            
            await self.redis_client.delete(key)
            logger.info(f"Rate limit reset for key: {key}")
            
        except Exception as e:
            logger.error(f"Rate limit reset error: {e}")

class RateLimitMiddleware:
    """FastAPI middleware for rate limiting"""
    
    def __init__(self, rate_limit_service: RateLimitService):
        self.rate_limit_service = rate_limit_service
    
    async def __call__(self, request: Request, call_next):
        """Middleware implementation"""
        try:
            # Extract client identifier
            client_ip = self._get_client_ip(request)
            user_id = self._get_user_id(request)
            tenant_id = self._get_tenant_id(request)
            
            # Determine rate limit type based on endpoint and user
            limit_type = self._determine_limit_type(request, user_id)
            
            # Create rate limit key
            rate_limit_key = f"rate_limit:{limit_type}:{client_ip}"
            if user_id:
                rate_limit_key = f"rate_limit:{limit_type}:user:{user_id}"
            if tenant_id:
                rate_limit_key = f"rate_limit:{limit_type}:tenant:{tenant_id}"
            
            # Check rate limit
            allowed, limit_info = await self.rate_limit_service.is_allowed(rate_limit_key, limit_type)
            
            if not allowed:
                raise HTTPException(
                    status_code=429,
                    detail={
                        "error": "Rate limit exceeded",
                        "limit": limit_info['limit'],
                        "window": self.rate_limit_service.rate_limits[limit_type]['window'],
                        "retry_after": limit_info['retry_after']
                    },
                    headers={
                        "X-RateLimit-Limit": str(limit_info['limit']),
                        "X-RateLimit-Remaining": str(limit_info['remaining']),
                        "X-RateLimit-Reset": str(limit_info['reset_time']),
                        "Retry-After": str(limit_info['retry_after'])
                    }
                )
            
            # Process request
            response = await call_next(request)
            
            # Add rate limit headers
            response.headers["X-RateLimit-Limit"] = str(limit_info['limit'])
            response.headers["X-RateLimit-Remaining"] = str(limit_info['remaining'])
            response.headers["X-RateLimit-Reset"] = str(limit_info['reset_time'])
            
            return response
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Rate limiting middleware error: {e}")
            # Continue processing if rate limiting fails
            return await call_next(request)
    
    def _get_client_ip(self, request: Request) -> str:
        """Extract client IP address"""
        # Check for forwarded headers
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()
        
        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip
        
        return request.client.host if request.client else "unknown"
    
    def _get_user_id(self, request: Request) -> Optional[str]:
        """Extract user ID from request"""
        # Check JWT token
        authorization = request.headers.get("Authorization")
        if authorization:
            try:
                # This would decode JWT and extract user ID
                # For now, return None
                pass
            except:
                pass
        
        return None
    
    def _get_tenant_id(self, request: Request) -> Optional[str]:
        """Extract tenant ID from request"""
        # Check headers or JWT
        tenant_id = request.headers.get("X-Tenant-ID")
        if tenant_id:
            return tenant_id
        
        return None
    
    def _determine_limit_type(self, request: Request, user_id: Optional[str]) -> str:
        """Determine rate limit type based on request"""
        path = request.url.path.lower()
        method = request.method.upper()
        
        # Admin endpoints
        if path.startswith('/admin'):
            return 'admin'
        
        # Upload endpoints
        if method in ['POST', 'PUT'] and any(keyword in path for keyword in ['upload', 'import']):
            return 'upload'
        
        # Export endpoints
        if 'export' in path:
            return 'export'
        
        # Report endpoints
        if 'report' in path:
            return 'report'
        
        # Authenticated users
        if user_id:
            # Check user role (would be determined from JWT)
            # For now, assume authenticated
            return 'authenticated'
        
        # Default
        return 'default'

class AdvancedRateLimiter:
    """Advanced rate limiting with multiple algorithms"""
    
    def __init__(self, redis_client):
        self.redis_client = redis_client
    
    async def sliding_window_counter(self, key: str, max_requests: int, window_seconds: int) -> Tuple[bool, Dict]:
        """Sliding window counter algorithm"""
        current_time = int(time.time())
        window_start = current_time - window_seconds
        
        # Remove old entries
        await self.redis_client.zremrangebyscore(key, 0, window_start)
        
        # Count current requests
        current_requests = await self.redis_client.zcard(key)
        
        if current_requests >= max_requests:
            return False, {'requests': current_requests, 'limit': max_requests}
        
        # Add current request
        await self.redis_client.zadd(key, {str(current_time): current_time})
        await self.redis_client.expire(key, window_seconds)
        
        return True, {'requests': current_requests + 1, 'limit': max_requests}
    
    async def token_bucket(self, key: str, capacity: int, refill_rate: float) -> Tuple[bool, Dict]:
        """Token bucket algorithm"""
        current_time = time.time()
        
        # Get current bucket state
        bucket_data = await self.redis_client.hgetall(key)
        
        if not bucket_data:
            # Initialize bucket
            tokens = capacity
            last_refill = current_time
        else:
            tokens = float(bucket_data.get('tokens', capacity))
            last_refill = float(bucket_data.get('last_refill', current_time))
        
        # Refill tokens
        time_passed = current_time - last_refill
        tokens = min(capacity, tokens + time_passed * refill_rate)
        
        if tokens >= 1:
            # Consume one token
            tokens -= 1
            await self.redis_client.hset(key, {
                'tokens': tokens,
                'last_refill': current_time
            })
            await self.redis_client.expire(key, 3600)  # 1 hour expiry
            
            return True, {'tokens': tokens, 'capacity': capacity}
        else:
            return False, {'tokens': tokens, 'capacity': capacity}
    
    async def fixed_window_counter(self, key: str, max_requests: int, window_seconds: int) -> Tuple[bool, Dict]:
        """Fixed window counter algorithm"""
        current_time = int(time.time())
        window_start = current_time - (current_time % window_seconds)
        window_key = f"{key}:{window_start}"
        
        # Get current count
        current_count = await self.redis_client.incr(window_key)
        
        if current_count == 1:
            # Set expiry for the window
            await self.redis_client.expire(window_key, window_seconds)
        
        allowed = current_count <= max_requests
        return allowed, {'count': current_count, 'limit': max_requests}

class RateLimitAnalytics:
    """Analytics for rate limiting"""
    
    def __init__(self, redis_client):
        self.redis_client = redis_client
    
    async def log_rate_limit_event(self, event_type: str, key: str, details: Dict):
        """Log rate limiting events"""
        timestamp = int(time.time())
        event_data = {
            'timestamp': timestamp,
            'type': event_type,
            'key': key,
            'details': details
        }
        
        # Store in Redis list (keep last 10000 events)
        await self.redis_client.lpush('rate_limit_events', json.dumps(event_data))
        await self.redis_client.ltrim('rate_limit_events', 0, 9999)
    
    async def get_rate_limit_stats(self, hours: int = 24) -> Dict:
        """Get rate limiting statistics"""
        cutoff_time = int(time.time()) - (hours * 3600)
        
        # Get recent events
        events = await self.redis_client.lrange('rate_limit_events', 0, -1)
        
        stats = {
            'total_requests': 0,
            'blocked_requests': 0,
            'top_violators': defaultdict(int),
            'hourly_stats': defaultdict(int)
        }
        
        for event_str in events:
            try:
                event = json.loads(event_str)
                if event['timestamp'] < cutoff_time:
                    continue
                
                stats['total_requests'] += 1
                
                if event['type'] == 'blocked':
                    stats['blocked_requests'] += 1
                    stats['top_violators'][event['key']] += 1
                
                hour = datetime.fromtimestamp(event['timestamp']).hour
                stats['hourly_stats'][hour] += 1
                
            except json.JSONDecodeError:
                continue
        
        # Sort top violators
        stats['top_violators'] = dict(sorted(stats['top_violators'].items(), key=lambda x: x[1], reverse=True)[:10])
        
        return stats

# Global rate limiter instance
rate_limit_service = RateLimitService()
rate_limit_middleware = RateLimitMiddleware(rate_limit_service)

# Decorator for rate limiting
def rate_limit(limit_type: str = 'default'):
    """Decorator to apply rate limiting to functions"""
    def decorator(func):
        async def wrapper(*args, **kwargs):
            # This would extract context from request
            # For now, use a simple key
            key = f"function:{func.__name__}"
            
            allowed, info = await rate_limit_service.is_allowed(key, limit_type)
            
            if not allowed:
                raise HTTPException(
                    status_code=429,
                    detail="Rate limit exceeded",
                    headers={"Retry-After": str(info.get('retry_after', 60))}
                )
            
            return await func(*args, **kwargs)
        
        return wrapper
    return decorator
