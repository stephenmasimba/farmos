"""
Redis Caching Layer - Phase 1 Feature
Advanced caching system with Redis for performance optimization
Derived from Begin Reference System
"""

import logging
import asyncio
import json
import pickle
from typing import Dict, List, Optional, Any, Union
from datetime import datetime, timedelta
import redis.asyncio as redis
from functools import wraps

logger = logging.getLogger(__name__)

class RedisCacheService:
    """Advanced Redis caching service with intelligent cache management"""
    
    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.redis_url = redis_url
        self.redis_client = None
        self.default_ttl = 3600  # 1 hour
        self.cache_stats = {
            'hits': 0,
            'misses': 0,
            'sets': 0,
            'deletes': 0
        }
    
    async def connect(self):
        """Initialize Redis connection"""
        try:
            self.redis_client = redis.from_url(
                self.redis_url,
                encoding="utf-8",
                decode_responses=False
            )
            # Test connection
            await self.redis_client.ping()
            logger.info("Redis connection established successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            return False
    
    async def disconnect(self):
        """Close Redis connection"""
        if self.redis_client:
            await self.redis_client.close()
    
    async def get(self, key: str, deserialize: bool = True) -> Optional[Any]:
        """Get value from cache"""
        try:
            if not self.redis_client:
                await self.connect()
            
            value = await self.redis_client.get(key)
            
            if value is not None:
                self.cache_stats['hits'] += 1
                if deserialize:
                    return pickle.loads(value)
                else:
                    return value.decode('utf-8')
            else:
                self.cache_stats['misses'] += 1
                return None
                
        except Exception as e:
            logger.error(f"Cache get error for key {key}: {e}")
            self.cache_stats['misses'] += 1
            return None
    
    async def set(self, key: str, value: Any, ttl: Optional[int] = None, serialize: bool = True) -> bool:
        """Set value in cache"""
        try:
            if not self.redis_client:
                await self.connect()
            
            if ttl is None:
                ttl = self.default_ttl
            
            if serialize:
                serialized_value = pickle.dumps(value)
            else:
                serialized_value = value.encode('utf-8') if isinstance(value, str) else value
            
            result = await self.redis_client.setex(key, ttl, serialized_value)
            
            if result:
                self.cache_stats['sets'] += 1
                return True
            return False
            
        except Exception as e:
            logger.error(f"Cache set error for key {key}: {e}")
            return False
    
    async def delete(self, key: str) -> bool:
        """Delete key from cache"""
        try:
            if not self.redis_client:
                await self.connect()
            
            result = await self.redis_client.delete(key)
            
            if result:
                self.cache_stats['deletes'] += 1
                return True
            return False
            
        except Exception as e:
            logger.error(f"Cache delete error for key {key}: {e}")
            return False
    
    async def delete_pattern(self, pattern: str) -> int:
        """Delete keys matching pattern"""
        try:
            if not self.redis_client:
                await self.connect()
            
            keys = await self.redis_client.keys(pattern)
            if keys:
                result = await self.redis_client.delete(*keys)
                self.cache_stats['deletes'] += result
                return result
            return 0
            
        except Exception as e:
            logger.error(f"Cache delete pattern error for {pattern}: {e}")
            return 0
    
    async def exists(self, key: str) -> bool:
        """Check if key exists"""
        try:
            if not self.redis_client:
                await self.connect()
            
            return await self.redis_client.exists(key) > 0
            
        except Exception as e:
            logger.error(f"Cache exists error for key {key}: {e}")
            return False
    
    async def expire(self, key: str, ttl: int) -> bool:
        """Set expiration for existing key"""
        try:
            if not self.redis_client:
                await self.connect()
            
            return await self.redis_client.expire(key, ttl)
            
        except Exception as e:
            logger.error(f"Cache expire error for key {key}: {e}")
            return False
    
    async def ttl(self, key: str) -> int:
        """Get time to live for key"""
        try:
            if not self.redis_client:
                await self.connect()
            
            return await self.redis_client.ttl(key)
            
        except Exception as e:
            logger.error(f"Cache TTL error for key {key}: {e}")
            return -1
    
    async def increment(self, key: str, amount: int = 1) -> int:
        """Increment numeric value"""
        try:
            if not self.redis_client:
                await self.connect()
            
            return await self.redis_client.incrby(key, amount)
            
        except Exception as e:
            logger.error(f"Cache increment error for key {key}: {e}")
            return 0
    
    async def get_cache_stats(self) -> Dict[str, Any]:
        """Get cache performance statistics"""
        total_requests = self.cache_stats['hits'] + self.cache_stats['misses']
        hit_rate = (self.cache_stats['hits'] / total_requests * 100) if total_requests > 0 else 0
        
        return {
            **self.cache_stats,
            'hit_rate': round(hit_rate, 2),
            'total_requests': total_requests
        }
    
    async def clear_cache_stats(self):
        """Reset cache statistics"""
        self.cache_stats = {
            'hits': 0,
            'misses': 0,
            'sets': 0,
            'deletes': 0
        }

# Cache decorator for automatic caching
def cache_result(key_prefix: str, ttl: int = 3600):
    """Decorator to cache function results"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Generate cache key
            cache_key = f"{key_prefix}:{hash(str(args) + str(sorted(kwargs.items())))}"
            
            # Try to get from cache
            cache_service = RedisCacheService()
            cached_result = await cache_service.get(cache_key)
            
            if cached_result is not None:
                return cached_result
            
            # Execute function and cache result
            result = await func(*args, **kwargs)
            await cache_service.set(cache_key, result, ttl)
            
            return result
        
        return wrapper
    return decorator

# Cache manager for different data types
class CacheManager:
    """High-level cache manager for different data types"""
    
    def __init__(self):
        self.cache = RedisCacheService()
    
    async def cache_user_session(self, user_id: str, session_data: Dict, ttl: int = 86400):
        """Cache user session data"""
        key = f"session:user:{user_id}"
        await self.cache.set(key, session_data, ttl)
    
    async def get_user_session(self, user_id: str) -> Optional[Dict]:
        """Get cached user session"""
        key = f"session:user:{user_id}"
        return await self.cache.get(key)
    
    async def cache_api_response(self, endpoint: str, params: Dict, response: Any, ttl: int = 300):
        """Cache API response"""
        key = f"api:{endpoint}:{hash(str(sorted(params.items())))}"
        await self.cache.set(key, response, ttl)
    
    async def get_cached_api_response(self, endpoint: str, params: Dict) -> Optional[Any]:
        """Get cached API response"""
        key = f"api:{endpoint}:{hash(str(sorted(params.items())))}"
        return await self.cache.get(key)
    
    async def cache_database_query(self, query_hash: str, result: Any, ttl: int = 1800):
        """Cache database query result"""
        key = f"db:query:{query_hash}"
        await self.cache.set(key, result, ttl)
    
    async def get_cached_database_query(self, query_hash: str) -> Optional[Any]:
        """Get cached database query result"""
        key = f"db:query:{query_hash}"
        return await self.cache.get(key)
    
    async def cache_dashboard_data(self, tenant_id: str, dashboard_type: str, data: Any, ttl: int = 600):
        """Cache dashboard data"""
        key = f"dashboard:{tenant_id}:{dashboard_type}"
        await self.cache.set(key, data, ttl)
    
    async def get_cached_dashboard_data(self, tenant_id: str, dashboard_type: str) -> Optional[Any]:
        """Get cached dashboard data"""
        key = f"dashboard:{tenant_id}:{dashboard_type}"
        return await self.cache.get(key)
    
    async def invalidate_user_cache(self, user_id: str):
        """Invalidate all cache entries for a user"""
        pattern = f"*user:{user_id}*"
        await self.cache.delete_pattern(pattern)
    
    async def invalidate_tenant_cache(self, tenant_id: str):
        """Invalidate all cache entries for a tenant"""
        pattern = f"*{tenant_id}*"
        await self.cache.delete_pattern(pattern)
    
    async def cache_weather_data(self, location: str, weather_data: Dict, ttl: int = 1800):
        """Cache weather data"""
        key = f"weather:{location}"
        await self.cache.set(key, weather_data, ttl)
    
    async def get_cached_weather_data(self, location: str) -> Optional[Dict]:
        """Get cached weather data"""
        key = f"weather:{location}"
        return await self.cache.get(key)
    
    async def cache_market_prices(self, product_type: str, price_data: Dict, ttl: int = 3600):
        """Cache market price data"""
        key = f"market:price:{product_type}"
        await self.cache.set(key, price_data, ttl)
    
    async def get_cached_market_prices(self, product_type: str) -> Optional[Dict]:
        """Get cached market price data"""
        key = f"market:price:{product_type}"
        return await self.cache.get(key)

# Cache warming service
class CacheWarmer:
    """Service to pre-warm cache with frequently accessed data"""
    
    def __init__(self, cache_manager: CacheManager):
        self.cache_manager = cache_manager
    
    async def warm_common_data(self, tenant_id: str):
        """Pre-warm cache with commonly accessed data"""
        try:
            # Warm dashboard data
            dashboard_types = ['executive', 'production', 'financial', 'sustainability']
            for dashboard_type in dashboard_types:
                # This would call the actual dashboard service
                pass
            
            # Warm weather data for common locations
            common_locations = ['farm_location_1', 'farm_location_2']
            for location in common_locations:
                # This would call the weather service
                pass
            
            # Warm market prices
            common_products = ['maize', 'wheat', 'soybean', 'livestock']
            for product in common_products:
                # This would call the market price service
                pass
            
            logger.info(f"Cache warming completed for tenant {tenant_id}")
            
        except Exception as e:
            logger.error(f"Cache warming error: {e}")

# Cache invalidation service
class CacheInvalidationService:
    """Service to handle intelligent cache invalidation"""
    
    def __init__(self, cache_manager: CacheManager):
        self.cache_manager = cache_manager
    
    async def invalidate_on_data_change(self, data_type: str, entity_id: str, tenant_id: str):
        """Invalidate cache when data changes"""
        try:
            if data_type == 'user':
                await self.cache_manager.invalidate_user_cache(entity_id)
            elif data_type == 'tenant':
                await self.cache_manager.invalidate_tenant_cache(entity_id)
            elif data_type == 'dashboard':
                await self.cache_manager.cache.delete(f"dashboard:{tenant_id}:*")
            elif data_type == 'weather':
                await self.cache_manager.cache.delete(f"weather:*")
            elif data_type == 'market':
                await self.cache_manager.cache.delete(f"market:price:*")
            
            logger.info(f"Cache invalidated for {data_type}:{entity_id}")
            
        except Exception as e:
            logger.error(f"Cache invalidation error: {e}")
    
    async def invalidate_related_cache(self, primary_key: str, related_keys: List[str]):
        """Invalidate related cache entries"""
        try:
            for key in related_keys:
                await self.cache_manager.cache.delete(key)
            
            logger.info(f"Related cache invalidated for {primary_key}")
            
        except Exception as e:
            logger.error(f"Related cache invalidation error: {e}")

# Global cache instance
cache_manager = CacheManager()
cache_warmer = CacheWarmer(cache_manager)
cache_invalidator = CacheInvalidationService(cache_manager)
