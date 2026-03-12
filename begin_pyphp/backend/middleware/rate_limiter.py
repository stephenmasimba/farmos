"""
FarmOS API Rate Limiting Middleware
Implements request throttling and abuse prevention
"""

import time
import redis
from typing import Dict, Optional
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from ..common.config import settings
import logging

logger = logging.getLogger(__name__)

class RateLimiter:
    """Rate limiting implementation using Redis"""
    
    def __init__(self, redis_client=None):
        self.redis_client = redis_client or self._get_redis_client()
        self.requests = {}
        
    def _get_redis_client(self):
        """Get Redis client or fallback to in-memory"""
        try:
            return redis.Redis(
                host=settings.REDIS_HOST or 'localhost',
                port=int(settings.REDIS_PORT or 6379),
                password=settings.REDIS_PASSWORD,
                db=int(settings.REDIS_DB or 0),
                decode_responses=True
            )
        except Exception as e:
            logger.warning(f"Redis not available, using in-memory rate limiting: {e}")
            return None
    
    def is_allowed(self, key: str, limit: int, window: int) -> tuple[bool, Dict]:
        """Check if request is allowed based on rate limit"""
        if self.redis_client:
            return self._redis_is_allowed(key, limit, window)
        else:
            return self._memory_is_allowed(key, limit, window)
    
    def _redis_is_allowed(self, key: str, limit: int, window: int) -> tuple[bool, Dict]:
        """Redis-based rate limiting"""
        try:
            current_time = int(time.time())
            window_start = current_time - window
            
            # Clean old entries
            self.redis_client.zremrangebyscore(key, 0, window_start)
            
            # Count current requests
            current_requests = self.redis_client.zcard(key)
            
            if current_requests >= limit:
                # Get expiry time of oldest request
                oldest_request = self.redis_client.zrange(key, 0, 0, withscores=True)
                if oldest_request:
                    reset_time = int(oldest_request[0][1]) + window
                    return False, {
                        'limit': limit,
                        'remaining': 0,
                        'reset_time': reset_time,
                        'retry_after': reset_time - current_time
                    }
                
                return False, {
                    'limit': limit,
                    'remaining': 0,
                    'reset_time': current_time + window,
                    'retry_after': window
                }
            
            # Add this request
            self.redis_client.zadd(key, {str(current_time): current_time})
            self.redis_client.expire(key, window)
            
            return True, {
                'limit': limit,
                'remaining': limit - current_requests - 1,
                'reset_time': current_time + window,
                'retry_after': 0
            }
            
        except Exception as e:
            logger.error(f"Redis rate limiting error: {e}")
            return self._memory_is_allowed(key, limit, window)
    
    def _memory_is_allowed(self, key: str, limit: int, window: int) -> tuple[bool, Dict]:
        """In-memory rate limiting fallback"""
        current_time = int(time.time())
        
        if key not in self.requests:
            self.requests[key] = []
        
        # Clean old requests
        self.requests[key] = [
            req_time for req_time in self.requests[key]
            if req_time > current_time - window
        ]
        
        if len(self.requests[key]) >= limit:
            return False, {
                'limit': limit,
                'remaining': 0,
                'reset_time': current_time + window,
                'retry_after': window
            }
        
        # Add this request
        self.requests[key].append(current_time)
        
        return True, {
            'limit': limit,
            'remaining': limit - len(self.requests[key]),
            'reset_time': current_time + window,
            'retry_after': 0
        }

class RateLimitMiddleware(BaseHTTPMiddleware):
    """FastAPI middleware for rate limiting"""
    
    def __init__(self, app, rate_limiter=None):
        super().__init__(app)
        self.rate_limiter = rate_limiter or RateLimiter()
        
        # Default rate limits (requests per window)
        self.default_limits = {
            'global': {'limit': 1000, 'window': 3600},  # 1000 requests per hour
            'auth': {'limit': 10, 'window': 60},       # 10 login attempts per minute
            'api': {'limit': 100, 'window': 60},        # 100 API requests per minute
            'upload': {'limit': 5, 'window': 60},         # 5 uploads per minute
            'export': {'limit': 3, 'window': 60},         # 3 exports per minute
        }
    
    async def dispatch(self, request: Request, call_next):
        """Process request with rate limiting"""
        
        # Get client identifier
        client_id = self._get_client_id(request)
        
        # Determine rate limit based on endpoint
        rate_config = self._get_rate_config(request)
        
        # Check rate limit
        key = f"rate_limit:{client_id}:{rate_config['type']}"
        allowed, info = self.rate_limiter.is_allowed(
            key, 
            rate_config['limit'], 
            rate_config['window']
        )
        
        # Add rate limit headers
        response = await call_next(request)
        response.headers['X-RateLimit-Limit'] = str(info['limit'])
        response.headers['X-RateLimit-Remaining'] = str(info['remaining'])
        response.headers['X-RateLimit-Reset'] = str(info['reset_time'])
        response.headers['X-RateLimit-RetryAfter'] = str(info['retry_after'])
        
        if not allowed:
            logger.warning(f"Rate limit exceeded for {client_id}: {rate_config['type']}")
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={
                    'error': 'Rate limit exceeded',
                    'message': f"Too many requests. Limit: {info['limit']} per {rate_config['window']} seconds",
                    'limit': info['limit'],
                    'remaining': info['remaining'],
                    'reset_time': info['reset_time'],
                    'retry_after': info['retry_after']
                },
                headers={
                    'X-RateLimit-Limit': str(info['limit']),
                    'X-RateLimit-Remaining': str(info['remaining']),
                    'X-RateLimit-Reset': str(info['reset_time']),
                    'X-RateLimit-RetryAfter': str(info['retry_after']),
                    'Retry-After': str(info['retry_after'])
                }
            )
        
        return response
    
    def _get_client_id(self, request: Request) -> str:
        """Get client identifier for rate limiting"""
        # Try to get user ID from JWT
        if hasattr(request.state, 'user') and request.state.user:
            return f"user:{request.state.user.id}"
        
        # Fallback to IP address
        forwarded_for = request.headers.get('X-Forwarded-For')
        if forwarded_for:
            return f"ip:{forwarded_for.split(',')[0].strip()}"
        
        real_ip = request.headers.get('X-Real-IP')
        if real_ip:
            return f"ip:{real_ip}"
        
        return f"ip:{request.client.host}"
    
    def _get_rate_config(self, request: Request) -> Dict:
        """Get rate limit configuration based on endpoint"""
        path = request.url.path.lower()
        
        # Authentication endpoints
        if '/auth/' in path or '/login' in path:
            return self.default_limits['auth']
        
        # File upload endpoints
        if any(word in path for word in ['/upload', '/import', '/export']):
            if '/export' in path:
                return self.default_limits['export']
            else:
                return self.default_limits['upload']
        
        # API endpoints
        if '/api/' in path:
            return self.default_limits['api']
        
        # Default global limit
        return self.default_limits['global']

# Global rate limiter instance
rate_limiter = RateLimiter()
