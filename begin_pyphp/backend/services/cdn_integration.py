"""
FarmOS CDN Integration Service
Content Delivery Network integration for static assets and API acceleration
"""

import asyncio
import aiohttp
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from ..common.database import get_db
from ..common import models
import json
import os
import hashlib

logger = logging.getLogger(__name__)

class CDNIntegrationService:
    """CDN integration service for content delivery acceleration"""
    
    def __init__(self):
        self.cdn_providers = {}
        self.cdn_config = {}
        self.cache_config = {}
        self.is_running = False
        self.cache_stats = {}
        
        # Initialize CDN providers
        self._initialize_cdn_providers()
        self._initialize_cache_config()
        
    def _initialize_cdn_providers(self):
        """Initialize CDN provider configurations"""
        self.cdn_providers = {
            'cloudflare': {
                'name': 'Cloudflare CDN',
                'enabled': True,
                'api_endpoint': 'https://api.cloudflare.com/client/v4',
                'zone_id': 'farmos-zone',
                'api_token': 'CLOUDFLARE_API_TOKEN',
                'features': [
                    'static_asset_caching',
                    'api_acceleration',
                    'image_optimization',
                    'security_protection',
                    'ddos_protection'
                ],
                'cache_settings': {
                    'browser_cache_ttl': 3153600,  # 1 year
                    'edge_cache_ttl': 86400,    # 1 day
                    's3_cache_ttl': 2592000,  # 30 days
                    'development_mode': False
                }
            },
                'purge_rules': [
                    '/api/*',
                    '/admin/*',
                    '/reports/*'
                ]
            },
            'aws_cloudfront': {
                'name': 'AWS CloudFront CDN',
                'enabled': False,
                'distribution_id': 'E1234567890',
                's3_bucket': 'farmos-cdn-assets',
                'origin': 'https://farmos.local',
                'features': [
                    'static_asset_caching',
                    'api_acceleration',
                    'image_optimization',
                    'geo_distribution'
                ],
                'cache_settings': {
                    'default_ttl': 86400,
                    'max_ttl': 31536000,  # 1 year
                    'compress': True,
                    'gzip': True
                }
            },
            'fastly': {
                'name': 'Fastly CDN',
                'enabled': False,
                'service_id': 'farmos-cdn',
                'api_key': 'FASTLY_API_KEY',
                'features': [
                    'static_asset_caching',
                    'image_optimization',
                    'web_acceleration',
                    'instant_purge'
                ],
                'cache_settings': {
                    'default_ttl': 2592000,  # 30 days
                    'stale_while_revalidate': 3600,
                    'compress': True,
                    'gzip': True
                }
            },
            'azure_cdn': {
                'name': 'Azure CDN',
                'enabled': False,
                'profile_name': 'farmos-cdn-profile',
                'endpoint': 'farmos-cdn.azureedge.net',
                'resource_group': 'farmos-assets',
                'features': [
                    'static_asset_caching',
                    'image_optimization',
                    'dynamic_acceleration'
                ],
                'cache_settings': {
                    'default_ttl': 86400,
                    'compress': True,
                    'query_string_caching': True
                }
            }
        }
    
    def _initialize_cache_config(self):
        """Initialize cache configuration"""
        self.cache_config = {
            'local_cache': {
                'enabled': True,
                'directory': '/var/cache/farmos/',
                'max_size_gb': 10,
                'cache_levels': [
                    {'name': 'static', 'ttl': 3600, 'max_size_mb': 100},
                    {'name': 'api', 'ttl': 300, 'max_size_mb': 50},
                    {'name': 'images', 'ttl': 7200, 'max_size_mb': 500}
                ],
                'compression': {
                    'enabled': True,
                    'level': 6
                },
                'invalidation': {
                    'patterns': ['/api/*', '/admin/*'],
                    'method': ['POST', 'PUT', 'DELETE', 'PATCH']
                }
            },
            'redis_cache': {
                'enabled': False,
                'host': 'localhost',
                'port': 6379,
                'db': 0,
                'key_prefix': 'farmos:',
                'ttl': 3600
            },
            'browser_cache': {
                'enabled': True,
                'max_age': 86400,
                'etag_support': True,
                'last_modified_support': True
            }
        }
    
    async def start_cdn_service(self):
        """Start CDN integration service"""
        try:
            if self.is_running:
                logger.warning("CDN service is already running")
                return
            
            self.is_running = True
            logger.info("Starting CDN integration service")
            
            # Start CDN monitoring loop
            self.cdn_task = asyncio.create_task(self._cdn_monitoring_loop())
            
            return {
                "status": "success",
                "message": "CDN integration service started",
                "started_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error starting CDN service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_cdn_service(self):
        """Stop CDN integration service"""
        try:
            self.is_running = False
            
            if self.cdn_task:
                self.cdn_task.cancel()
                self.cdn_task = None
            
            logger.info("CDN integration service stopped")
            
            return {
                "status": "success",
                "message": "CDN integration service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping CDN service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _cdn_monitoring_loop(self):
        """Main CDN monitoring loop"""
        while self.is_running:
            try:
                # Monitor CDN performance
                await self._monitor_cdn_performance()
                
                # Check cache invalidation needs
                await self._check_cache_invalidation()
                
                # Update cache statistics
                await self._update_cache_stats()
                
                # Wait for next check (60 seconds)
                await asyncio.sleep(60)
                
        except Exception as e:
            logger.error(f"Error in CDN monitoring loop: {e}")
            await asyncio.sleep(60)
    
    async def _monitor_cdn_performance(self):
        """Monitor CDN performance metrics"""
        try:
            # Get performance metrics from active CDN provider
            active_provider = self._get_active_cdn_provider()
            
            if active_provider and self.cdn_providers[active_provider]['enabled']:
                metrics = await self._get_cdn_metrics(active_provider)
                
                # Update cache stats
                self.cache_stats[active_provider] = metrics
                
                # Check for performance issues
                if metrics.get('error_rate', 0) > 5:
                    await self._handle_performance_issue(active_provider, 'high_error_rate')
                elif metrics.get('avg_response_time', 0) > 3.0:
                    await self._handle_performance_issue(active_provider, 'high_response_time')
                elif metrics.get('cache_hit_rate', 0) < 80:
                    await self._handle_performance_issue(active_provider, 'low_cache_hit_rate')
            
            logger.info(f"CDN performance monitored for {active_provider}")
        
        except Exception as e:
            logger.error(f"Error monitoring CDN performance: {e}")
    
    async def _get_active_cdn_provider(self) -> Optional[str]:
        """Get the active CDN provider"""
        try:
            for provider, config in self.cdn_providers.items():
                if config.get('enabled', False):
                    continue
                
                # Check if provider is responding
                if await self._test_cdn_connectivity(provider):
                    return provider
            
            return None
        
        except Exception as e:
            logger.error(f"Error getting active CDN provider: {e}")
            return None
    
    async def _test_cdn_connectivity(self, provider: str) -> bool:
        """Test CDN provider connectivity"""
        try:
            config = self.cdn_providers[provider]
            
            if provider == 'cloudflare':
                return await self._test_cloudflare_connectivity(config)
            elif provider == 'aws_cloudfront':
                return await self._test_aws_cloudfront_connectivity(config)
            elif provider == 'fastly':
                return await self._test_fastly_connectivity(config)
            elif provider == 'azure_cdn':
                return await self._test_azure_cdn_connectivity(config)
            
            return False
        
        except Exception as e:
            logger.error(f"Error testing CDN connectivity for {provider}: {e}")
            return False
    
    async def _test_cloudflare_connectivity(self, config: Dict) -> bool:
        """Test Cloudflare CDN connectivity"""
        try:
            headers = {
                'Authorization': f"Bearer {config.get('api_token')}",
                'Content-Type': 'application/json'
            }
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=10)) as session:
                async with session.get(
                    url=f"{config['api_endpoint']}/zones/{config['zone_id']}/dns_records",
                    headers=headers
                ) as response:
                    return response.status == 200
        
        except Exception as e:
            logger.error(f"Error testing Cloudflare connectivity: {e}")
            return False
    
    async def _test_aws_cloudfront_connectivity(self, config: Dict) -> bool:
        """Test AWS CloudFront connectivity"""
        try:
            # Test CloudFront distribution
            test_url = f"https://{config['distribution_id']}.cloudfront.net/test-file.txt"
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=10)) as session:
                async with session.head(test_url) as response:
                    return response.status == 200
        
        except Exception as e:
            logger.error(f"Error testing AWS CloudFront connectivity: {e}")
            return False
    
    async def _test_fastly_connectivity(self, config: Dict) -> bool:
        """Test Fastly CDN connectivity"""
        try:
            headers = {
                'Fastly-Key': config.get('api_key'),
                'Content-Type': 'application/json'
            }
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=10)) as session:
                async with session.get(
                    url=f"https://api.fastly.com/v1/purge/{config['service_id']}/url",
                    headers=headers
                ) as response:
                    return response.status == 200
        
        except Exception as e:
            logger.error(f"Error testing Fastly connectivity: {e}")
            return False
    
    async def _test_azure_cdn_connectivity(self, config: Dict) -> bool:
        """Test Azure CDN connectivity"""
        try:
            # Test Azure CDN endpoint
            test_url = f"https://{config['endpoint']}/ping"
            
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=10)) as session:
                async with session.get(test_url) as response:
                    return response.status == 200
        
        except Exception as e:
            logger.error(f"Error testing Azure CDN connectivity: {e}")
            return False
    
    async def _get_cdn_metrics(self, provider: str) -> Dict:
        """Get performance metrics from CDN provider"""
        try:
            if provider == 'cloudflare':
                return await self._get_cloudflare_metrics()
            elif provider == 'aws_cloudfront':
                return await self._get_aws_cloudfront_metrics()
            elif provider == 'fastly':
                return await self._get_fastly_metrics()
            elif provider == 'azure_cdn':
                return await self._get_azure_cdn_metrics()
            
            return {}
        
        except Exception as e:
            logger.error(f"Error getting CDN metrics for {provider}: {e}")
            return {}
    
    async def _get_cloudflare_metrics(self) -> Dict:
        """Get Cloudflare CDN metrics"""
        try:
            config = self.cdn_providers['cloudflare']
            
            # Mock Cloudflare metrics (would use actual API)
            return {
                'provider': 'cloudflare',
                'requests_total': 15000,
                'requests_cached': 12000,
                'cache_hit_rate': 80.0,
                'bandwidth_saved_gb': 45.2,
                'avg_response_time': 0.8,
                'error_rate': 1.2,
                'threats_blocked': 25,
                'unique_visitors': 850
                'timestamp': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting Cloudflare metrics: {e}")
            return {}
    
    async def _get_aws_cloudfront_metrics(self) -> Dict:
        """Get AWS CloudFront metrics"""
        try:
            config = self.cdn_providers['aws_cloudfront']
            
            # Mock CloudFront metrics (would use AWS CloudWatch)
            return {
                'provider': 'aws_cloudfront',
                'requests_total': 12000,
                'requests_served_from_cache': 9600,
                'cache_hit_rate': 80.0,
                'bandwidth_saved_gb': 38.5,
                'avg_response_time': 1.2,
                'error_rate': 2.1,
                'timestamp': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting AWS CloudFront metrics: {e}")
            return {}
    
    async def _get_fastly_metrics(self) -> Dict:
        """Get Fastly CDN metrics"""
        try:
            config = self.cdn_providers['fastly']
            
            # Mock Fastly metrics (would use actual API)
            return {
                'provider': 'fastly',
                'requests_total': 10000,
                'requests_cached': 8500,
                'cache_hit_rate': 85.0,
                'bandwidth_saved_gb': 32.1,
                'avg_response_time': 0.6,
                'error_rate': 0.8,
                'timestamp': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting Fastly metrics: {e}")
            return {}
    
    async def _get_azure_cdn_metrics(self) -> Dict:
        """Get Azure CDN metrics"""
        try:
            config = self.cdn_providers['azure_cdn']
            
            # Mock Azure CDN metrics (would use Azure Monitor)
            return {
                'provider': 'azure_cdn',
                'requests_total': 8000,
                'requests_served_from_cache': 6400,
                'cache_hit_rate': 80.0,
                'bandwidth_saved_gb': 28.7,
                'avg_response_time': 1.1,
                'error_rate': 1.5,
                'timestamp': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting Azure CDN metrics: {e}")
            return {}
    
    async def _handle_performance_issue(self, provider: str, issue_type: str):
        """Handle CDN performance issues"""
        try:
            action = {
                'type': 'performance_issue',
                'provider': provider,
                'issue_type': issue_type,
                'timestamp': datetime.utcnow(),
                'action_taken': f"Automatic mitigation for {issue_type}"
            }
            
            self.cache_stats[provider]['issues'].append(action)
            
            # In production, this would trigger automatic mitigation
            logger.warning(f"Performance issue detected for {provider}: {issue_type}")
            
            # Switch to backup provider if available
            if provider != 'cloudflare':
                await self._switch_to_backup_provider()
        
        except Exception as e:
            logger.error(f"Error handling performance issue for {provider}: {e}")
    
    async def _switch_to_backup_provider(self):
        """Switch to backup CDN provider"""
        try:
            # Find available backup provider
            backup_provider = None
            for provider, config in self.cdn_providers.items():
                if config.get('enabled', False):
                    backup_provider = provider
                    break
            
            if backup_provider:
                logger.info(f"Switching to backup CDN provider: {backup_provider}")
                # In production, this would update DNS and configuration
                self._set_active_cdn_provider(backup_provider)
        
        except Exception as e:
            logger.error(f"Error switching to backup provider: {e}")
    
    def _set_active_cdn_provider(self, provider: str):
        """Set the active CDN provider"""
        try:
            # Update active provider
            for p in self.cdn_providers:
                self.cdn_providers[p]['active'] = (p == provider)
            
            logger.info(f"Active CDN provider set to: {provider}")
        
        except Exception as e:
            logger.error(f"Error setting active CDN provider: {e}")
    
    async def _check_cache_invalidation(self):
        """Check for cache invalidation needs"""
        try:
            # Check for recent content changes
            recent_changes = await self._get_recent_content_changes()
            
            if recent_changes:
                await self._invalidate_cdn_cache(recent_changes)
        
        except Exception as e:
            logger.error(f"Error checking cache invalidation: {e}")
    
    async def _get_recent_content_changes(self) -> List[Dict]:
        """Get recent content changes"""
        try:
            # Mock content changes (would check database or file system)
            return [
                {
                    'type': 'file_update',
                    'path': '/uploads/images/new_image.jpg',
                    'timestamp': datetime.utcnow().isoformat()
                },
                {
                    'type': 'content_update',
                    'path': '/api/endpoint',
                    'timestamp': datetime.utcnow().isoformat()
                }
            ]
        
        except Exception as e:
            logger.error(f"Error getting recent content changes: {e}")
            return []
    
    async def _invalidate_cdn_cache(self, changes: List[Dict]):
        """Invalidate CDN cache for specific content"""
        try:
            active_provider = self._get_active_cdn_provider()
            
            if active_provider == 'cloudflare':
                await self._invalidate_cloudflare_cache(changes)
            elif active_provider == 'fastly':
                await self._invalidate_fastly_cache(changes)
            elif active_provider == 'aws_cloudfront':
                await self._invalidate_aws_cloudfront_cache(changes)
            elif active_provider == 'azure_cdn':
                await self._invalidate_azure_cdn_cache(changes)
        
        except Exception as e:
            logger.error(f"Error invalidating CDN cache: {e}")
    
    async def _invalidate_cloudflare_cache(self, changes: List[Dict]):
        """Invalidate Cloudflare cache"""
        try:
            config = self.cdn_providers['cloudflare']
            
            for change in changes:
                try:
                    # Purge specific URL
                    url = f"{config['api_endpoint']}/zones/{config['zone_id']}/purge"
                    headers = {
                        'Authorization': f"Bearer {config['api_token']}",
                        'Content-Type': 'application/json'
                    }
                    
                    purge_data = {
                        'files': [change.get('path', '')],
                        'tags': ['farmos-cache-invalidation']
                    }
                    
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=30)) as session:
                        async with session.post(url, json=purge_data, headers=headers) as response:
                            if response.status == 200:
                                logger.info(f"Cloudflare cache purged for: {change.get('path', '')}")
                            else:
                                logger.error(f"Failed to purge Cloudflare cache: {response.status}")
                
                except Exception as e:
                    logger.error(f"Error purging Cloudflare cache: {e}")
        
        except Exception as e:
            logger.error(f"Error in Cloudflare cache invalidation: {e}")
    
    async def _invalidate_fastly_cache(self, changes: List[Dict]):
        """Invalidate Fastly cache"""
        try:
            config = self.cdn_providers['fastly']
            
            for change in changes:
                try:
                    # Purge by URL
                    url = f"https://api.fastly.com/v1/purge/{config['service_id']}/url"
                    headers = {
                        'Fastly-Key': config.get('api_key'),
                        'Content-Type': 'application/json'
                    }
                    
                    purge_data = {
                        'url': change.get('path', ''),
                        'surrogate_keys': ['farmos-cache-invalidation']
                    }
                    
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=30)) as session:
                        async with session.post(url, json=purge_data, headers=headers) as response:
                            if response.status == 200:
                                logger.info(f"Fastly cache purged for: {change.get('path', '')}")
                            else:
                                logger.error(f"Failed to purge Fastly cache: {response.status}")
                
                except Exception as e:
                    logger.error(f"Error in Fastly cache invalidation: {e}")
        
        except Exception as e:
            logger.error(f"Error in Fastly cache invalidation: {e}")
    
    async def _invalidate_aws_cloudfront_cache(self, changes: List[Dict]):
        """Invalidate AWS CloudFront cache"""
        try:
            config = self.cdn_providers['aws_cloudfront']
            
            for change in changes:
                try:
                    # Create invalidation
                    invalidation = {
                        'DistributionId': config['distribution_id'],
                        'InvalidationBatch': {
                            'Paths': {
                                'Quantity': 1,
                                'Items': [{'Path': change.get('path', '')}]
                            }
                        },
                        'CallerReference': f"farmos-invalidation-{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
                    }
                    
                    # Create invalidation file and upload to S3
                    invalidation_file = f"/tmp/cloudfront_invalidation_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
                    
                    with open(invalidation_file, 'w') as f:
                        json.dump(invalidation, f, indent=2)
                    
                    # Upload to S3 (in production, this would use boto3)
                    logger.info(f"AWS CloudFront invalidation created for: {change.get('path', '')}")
                
                except Exception as e:
                    logger.error(f"Error in AWS CloudFront invalidation: {e}")
        
        except Exception as e:
            logger.error(f"Error in AWS CloudFront cache invalidation: {e}")
    
    async def _invalidate_azure_cdn_cache(self, changes: List[Dict]):
        """Invalidate Azure CDN cache"""
        try:
            config = self.cdn_providers['azure_cdn']
            
            for change in changes:
                try:
                    # Purge by URL path
                    url = f"https://{config['endpoint']}/purge"
                    headers = {
                        'Content-Type': 'application/json'
                    }
                    
                    purge_data = {
                        'contentPaths': [change.get('path', '')]
                    'purge_type': 'wildcard'
                    }
                    
                    async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=30)) as session:
                        async with session.post(url, json=purge_data, headers=headers) as response:
                            if response.status == 200:
                                logger.info(f"Azure CDN cache purged for: {change.get('path', '')}")
                            else:
                                logger.error(f"Failed to purge Azure CDN cache: {response.status}")
                
                except Exception as e:
                    logger.error(f"Error in Azure CDN cache invalidation: {e}")
        
        except Exception as e:
            logger.error(f"Error in Azure CDN cache invalidation: {e}")
    
    async def _update_cache_stats(self):
        """Update cache statistics"""
        try:
            # Update cache hit rates and performance metrics
            for provider, stats in self.cache_stats.items():
                if stats:
                    # Calculate cache efficiency
                    if 'requests_total' in stats and 'requests_cached' in stats:
                        hit_rate = (stats['requests_cached'] / stats['requests_total']) * 100
                        stats['cache_efficiency'] = hit_rate
                    
                    # Log performance
                    if 'avg_response_time' in stats:
                        if stats['avg_response_time'] > 2.0:
                            stats['performance_status'] = 'poor'
                        elif stats['avg_response_time'] > 1.0:
                            stats['performance_status'] = 'fair'
                        else:
                            stats['performance_status'] = 'good'
            
                    logger.info(f"Cache stats updated for {provider}: Hit Rate: {stats.get('cache_hit_rate', 0):.1f}%, Performance: {stats.get('performance_status', 'unknown')}")
        
        except Exception as e:
            logger.error(f"Error updating cache stats: {e}")
    
    def get_cdn_status(self) -> Dict:
        """Get current CDN status"""
        try:
            active_provider = self._get_active_cdn_provider()
            
            return {
                'is_running': self.is_running,
                'active_provider': active_provider,
                'cache_stats': self.cache_stats,
                'cdn_providers': self.cdn_providers,
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting CDN status: {e}")
            return {
                'is_running': False,
                'active_provider': None,
                'cache_stats': {},
                'cdn_providers': self.cdn_providers,
                'last_updated': datetime.utcnow().isoformat()
            }
    
    def get_cache_recommendations(self) -> List[str]:
        """Get cache optimization recommendations"""
        try:
            recommendations = []
            
            # Check cache hit rates
            for provider, stats in self.cache_stats.items():
                if stats.get('cache_hit_rate', 0) < 80:
                    recommendations.append(f"Improve {provider} cache hit rate (current: {stats.get('cache_hit_rate', 0):.1f}%)")
                elif stats.get('cache_hit_rate', 0) < 90:
                    recommendations.append(f"Optimize {provider} cache configuration")
            
            # Check response times
            for provider, stats in self.cache_stats.items():
                if stats.get('avg_response_time', 0) > 2.0:
                    recommendations.append(f"Optimize {provider} performance settings")
                elif stats.get('avg_response_time', 0) > 1.5:
                    recommendations.append(f"Consider edge optimization for {provider}")
            
            # Check error rates
            for provider, stats in self.cache_stats.items():
                if stats.get('error_rate', 0) > 3.0:
                    recommendations.append(f"Investigate {provider} error sources")
            
            return recommendations
        
        except Exception as e:
            logger.error(f"Error getting cache recommendations: {e}")
            return ["Error generating recommendations"]

# Global CDN integration service instance
cdn_integration_service = CDNIntegrationService()
