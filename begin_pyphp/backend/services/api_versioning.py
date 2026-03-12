"""
API Versioning - Phase 1 Feature
Advanced API versioning system for backward compatibility and evolution
Derived from Begin Reference System
"""

import logging
import asyncio
from typing import Dict, List, Optional, Any, Callable
from datetime import datetime, timedelta
from functools import wraps
from fastapi import FastAPI, Request, Response, HTTPException, Depends
from fastapi.routing import APIRoute
import inspect
import json

logger = logging.getLogger(__name__)

class APIVersionManager:
    """Advanced API versioning system"""
    
    def __init__(self):
        self.versions = {
            'v1': {
                'status': 'stable',
                'deprecated': False,
                'sunset_date': None,
                'supported_until': None,
                'features': ['basic_crud', 'authentication', 'reporting']
            },
            'v2': {
                'status': 'stable',
                'deprecated': False,
                'sunset_date': None,
                'supported_until': None,
                'features': ['advanced_analytics', 'real_time', 'ml_predictions']
            },
            'v3': {
                'status': 'beta',
                'deprecated': False,
                'sunset_date': None,
                'supported_until': None,
                'features': ['graphql', 'advanced_ml', 'blockchain']
            }
        }
        self.default_version = 'v2'
        self.version_headers = {
            'API-Version': 'Current API version',
            'Supported-Versions': 'List of supported versions',
            'Deprecated-Versions': 'List of deprecated versions',
            'Sunset-Date': 'Date when version will be sunset'
        }
    
    def get_version_info(self, version: str) -> Dict[str, Any]:
        """Get information about a specific version"""
        return self.versions.get(version, {})
    
    def is_version_supported(self, version: str) -> bool:
        """Check if a version is supported"""
        version_info = self.versions.get(version)
        if not version_info:
            return False
        
        if version_info['deprecated']:
            if version_info['sunset_date']:
                sunset_date = datetime.fromisoformat(version_info['sunset_date'])
                return datetime.utcnow() < sunset_date
            return False
        
        return True
    
    def get_latest_version(self) -> str:
        """Get the latest stable version"""
        stable_versions = [v for v, info in self.versions.items() 
                          if info['status'] == 'stable' and not info['deprecated']]
        
        if stable_versions:
            # Return the highest version number
            return max(stable_versions, key=lambda x: int(x[1:]))
        
        return self.default_version
    
    def get_supported_versions(self) -> List[str]:
        """Get list of all supported versions"""
        return [v for v in self.versions.keys() if self.is_version_supported(v)]
    
    def get_deprecated_versions(self) -> List[str]:
        """Get list of deprecated versions"""
        return [v for v, info in self.versions.items() if info['deprecated']]
    
    def deprecate_version(self, version: str, sunset_date: datetime, migration_guide: str = ""):
        """Deprecate a version with sunset date"""
        if version in self.versions:
            self.versions[version]['deprecated'] = True
            self.versions[version]['sunset_date'] = sunset_date.isoformat()
            self.versions[version]['migration_guide'] = migration_guide
            logger.info(f"Version {version} deprecated. Sunset date: {sunset_date}")
    
    def add_version(self, version: str, status: str = 'beta', features: List[str] = None):
        """Add a new API version"""
        self.versions[version] = {
            'status': status,
            'deprecated': False,
            'sunset_date': None,
            'supported_until': None,
            'features': features or []
        }
        logger.info(f"Added new API version: {version}")

class VersionedAPIRoute(APIRoute):
    """Custom API route that supports versioning"""
    
    def __init__(self, path: str, endpoint: Callable, version: str = None, 
                 deprecated_versions: List[str] = None, **kwargs):
        self.version = version
        self.deprecated_versions = deprecated_versions or []
        
        # Add version to path if specified
        if version:
            path = f"/{version}{path}"
        
        super().__init__(path, endpoint, **kwargs)
    
    def get_route_handler(self):
        original_route_handler = super().get_route_handler()
        
        async def custom_route_handler(request: Request) -> Response:
            # Extract version from request
            requested_version = self._extract_version(request)
            
            # Check if version is supported
            version_manager = APIVersionManager()
            if not version_manager.is_version_supported(requested_version):
                raise HTTPException(
                    status_code=400,
                    detail=f"API version {requested_version} is not supported"
                )
            
            # Add version headers
            response = await original_route_handler(request)
            self._add_version_headers(response, requested_version, version_manager)
            
            return response
        
        return custom_route_handler
    
    def _extract_version(self, request: Request) -> str:
        """Extract API version from request"""
        # Try to get version from URL path
        path_parts = request.url.path.strip('/').split('/')
        if len(path_parts) > 0 and path_parts[0].startswith('v'):
            return path_parts[0]
        
        # Try to get version from header
        version_header = request.headers.get('API-Version')
        if version_header:
            return version_header
        
        # Try to get version from query parameter
        version_query = request.query_params.get('version')
        if version_query:
            return version_query
        
        # Return default version
        return APIVersionManager().default_version
    
    def _add_version_headers(self, response: Response, version: str, version_manager: APIVersionManager):
        """Add version-related headers to response"""
        response.headers['API-Version'] = version
        response.headers['Supported-Versions'] = ', '.join(version_manager.get_supported_versions())
        response.headers['Deprecated-Versions'] = ', '.join(version_manager.get_deprecated_versions())
        
        version_info = version_manager.get_version_info(version)
        if version_info.get('sunset_date'):
            response.headers['Sunset-Date'] = version_info['sunset_date']

class APIVersionMiddleware:
    """Middleware for API versioning"""
    
    def __init__(self, version_manager: APIVersionManager):
        self.version_manager = version_manager
    
    async def __call__(self, request: Request, call_next):
        """Middleware implementation"""
        try:
            # Extract version from request
            requested_version = self._extract_version(request)
            
            # Validate version
            if not self.version_manager.is_version_supported(requested_version):
                raise HTTPException(
                    status_code=400,
                    detail={
                        "error": "Unsupported API version",
                        "requested_version": requested_version,
                        "supported_versions": self.version_manager.get_supported_versions(),
                        "default_version": self.version_manager.default_version
                    },
                    headers={
                        "Supported-Versions": ', '.join(self.version_manager.get_supported_versions()),
                        "Default-Version": self.version_manager.default_version
                    }
                )
            
            # Process request
            response = await call_next(request)
            
            # Add version headers
            self._add_version_headers(response, requested_version)
            
            return response
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"API versioning middleware error: {e}")
            return await call_next(request)
    
    def _extract_version(self, request: Request) -> str:
        """Extract API version from request"""
        # Try URL path
        path_parts = request.url.path.strip('/').split('/')
        if len(path_parts) > 0 and path_parts[0].startswith('v'):
            return path_parts[0]
        
        # Try header
        version_header = request.headers.get('API-Version')
        if version_header:
            return version_header
        
        # Try query parameter
        version_query = request.query_params.get('version')
        if version_query:
            return version_query
        
        # Return default
        return self.version_manager.default_version
    
    def _add_version_headers(self, response: Response, version: str):
        """Add version headers to response"""
        response.headers['API-Version'] = version
        response.headers['Supported-Versions'] = ', '.join(self.version_manager.get_supported_versions())
        response.headers['Deprecated-Versions'] = ', '.join(self.version_manager.get_deprecated_versions())
        response.headers['Default-Version'] = self.version_manager.default_version

def version(version: str, deprecated_versions: List[str] = None):
    """Decorator to add version information to endpoints"""
    def decorator(func):
        # Store version information in function
        func._api_version = version
        func._deprecated_versions = deprecated_versions or []
        
        @wraps(func)
        async def wrapper(*args, **kwargs):
            return await func(*args, **kwargs)
        
        return wrapper
    return decorator

class APICompatibilityService:
    """Service for managing API compatibility and migrations"""
    
    def __init__(self):
        self.migration_guides = {
            'v1_to_v2': {
                'description': 'Upgrade from v1 to v2 API',
                'breaking_changes': [
                    'Endpoint paths changed from /api/ to /v2/api/',
                    'Response format updated to include metadata',
                    'Authentication header format changed'
                ],
                'migration_steps': [
                    'Update endpoint URLs to include version prefix',
                    'Update response parsing to handle new metadata format',
                    'Update authentication header format'
                ]
            },
            'v2_to_v3': {
                'description': 'Upgrade from v2 to v3 API',
                'breaking_changes': [
                    'GraphQL endpoints added, REST endpoints modified',
                    'Request/response format changes',
                    'New required fields in some endpoints'
                ],
                'migration_steps': [
                    'Consider migrating to GraphQL endpoints',
                    'Update request/response handling',
                    'Add new required fields to requests'
                ]
            }
        }
    
    def get_migration_guide(self, from_version: str, to_version: str) -> Dict[str, Any]:
        """Get migration guide between versions"""
        key = f"{from_version}_to_{to_version}"
        return self.migration_guides.get(key, {})
    
    def check_compatibility(self, client_version: str, server_version: str) -> Dict[str, Any]:
        """Check compatibility between client and server versions"""
        compatibility_matrix = {
            ('v1', 'v1'): {'compatible': True, 'level': 'full'},
            ('v1', 'v2'): {'compatible': True, 'level': 'partial', 'warnings': ['Some features deprecated']},
            ('v1', 'v3'): {'compatible': False, 'reason': 'v1 clients not supported in v3'},
            ('v2', 'v2'): {'compatible': True, 'level': 'full'},
            ('v2', 'v3'): {'compatible': True, 'level': 'partial', 'warnings': ['GraphQL recommended']},
            ('v3', 'v3'): {'compatible': True, 'level': 'full'}
        }
        
        return compatibility_matrix.get((client_version, server_version), {
            'compatible': False,
            'reason': 'Unknown version combination'
        })
    
    def suggest_version(self, client_capabilities: List[str]) -> str:
        """Suggest best API version based on client capabilities"""
        version_manager = APIVersionManager()
        
        # Check if client needs v3 features
        v3_features = {'graphql', 'advanced_ml', 'blockchain'}
        if any(cap in v3_features for cap in client_capabilities):
            return 'v3'
        
        # Check if client needs v2 features
        v2_features = {'advanced_analytics', 'real_time', 'ml_predictions'}
        if any(cap in v2_features for cap in client_capabilities):
            return 'v2'
        
        # Default to v1
        return 'v1'

class APIVersionAnalytics:
    """Analytics for API version usage"""
    
    def __init__(self):
        self.usage_stats = {
            'v1': {'requests': 0, 'clients': set(), 'last_used': None},
            'v2': {'requests': 0, 'clients': set(), 'last_used': None},
            'v3': {'requests': 0, 'clients': set(), 'last_used': None}
        }
    
    async def log_request(self, version: str, client_id: str, endpoint: str):
        """Log API request for analytics"""
        if version in self.usage_stats:
            self.usage_stats[version]['requests'] += 1
            self.usage_stats[version]['clients'].add(client_id)
            self.usage_stats[version]['last_used'] = datetime.utcnow()
        
        logger.info(f"API request: {version} - {client_id} - {endpoint}")
    
    def get_usage_stats(self) -> Dict[str, Any]:
        """Get usage statistics"""
        stats = {}
        total_requests = sum(data['requests'] for data in self.usage_stats.values())
        
        for version, data in self.usage_stats.items():
            stats[version] = {
                'requests': data['requests'],
                'clients': len(data['clients']),
                'last_used': data['last_used'].isoformat() if data['last_used'] else None,
                'percentage': (data['requests'] / total_requests * 100) if total_requests > 0 else 0
            }
        
        return stats
    
    def get_migration_recommendations(self) -> List[str]:
        """Get recommendations for version migrations"""
        recommendations = []
        
        # Check for deprecated versions with active usage
        version_manager = APIVersionManager()
        for version, data in self.usage_stats.items():
            if version_manager.versions[version]['deprecated'] and data['requests'] > 0:
                recommendations.append(
                    f"Version {version} is deprecated but has {data['requests']} recent requests. "
                    f"Consider migrating clients to newer version."
                )
        
        return recommendations

# Global instances
version_manager = APIVersionManager()
version_middleware = APIVersionMiddleware(version_manager)
compatibility_service = APICompatibilityService()
version_analytics = APIVersionAnalytics()

# Example usage decorators and functions
@version('v2')
async def get_crops_v2():
    """Example v2 endpoint"""
    return {"message": "Crops from v2 API"}

@version('v3', deprecated_versions=['v1'])
async def get_crops_v3():
    """Example v3 endpoint"""
    return {"message": "Crops from v3 API with GraphQL support"}

# Version compatibility checker
async def check_client_compatibility(client_version: str, client_capabilities: List[str]) -> Dict[str, Any]:
    """Check if client is compatible with current API"""
    server_version = version_manager.get_latest_version()
    compatibility = compatibility_service.check_compatibility(client_version, server_version)
    suggested_version = compatibility_service.suggest_version(client_capabilities)
    
    return {
        'client_version': client_version,
        'server_version': server_version,
        'compatible': compatibility['compatible'],
        'compatibility_level': compatibility.get('level'),
        'warnings': compatibility.get('warnings', []),
        'suggested_version': suggested_version,
        'migration_guide': compatibility_service.get_migration_guide(client_version, suggested_version)
    }
