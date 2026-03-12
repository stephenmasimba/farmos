"""
FarmOS Security Monitoring Service
Security monitoring and threat detection for the FarmOS system
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class SecurityMonitoringService:
    """Security monitoring service for threat detection and response"""
    
    def __init__(self):
        self.security_events = []
        self.threat_levels = {
            'low': {'priority': 'low', 'color': 'yellow', 'description': 'Minor security events'},
            'medium': {'priority': 'medium', 'color': 'orange', 'description': 'Moderate security threats'},
            'high': {'priority': 'high', 'color': 'red', 'description': 'Critical security threats'}
        }
        
        self.monitoring_active = False
        self.alert_thresholds = {
            'failed_login_attempts': 5,  # 5 failed logins in 15 minutes
            'suspicious_activities': 3,  # 3 suspicious activities in 1 hour
            'unauthorized_access': 2,  # 2 unauthorized access attempts in 1 hour
            'high_resource_usage': 10, 10+ requests in 1 minute
            'database_errors': 5, # 5 DB errors in 1 hour
            'api_errors': 10, # 10 API errors in 1 hour
        }
        
        self.blocked_ips = set()
        self.failed_attempts = {}
        self.security_score = 100  # Start at 100%
        
    async def start_monitoring(self):
        """Start security monitoring"""
        try:
            self.monitoring_active = True
            logger.info("Security monitoring started")
            
            # Start monitoring loop
            self.monitoring_task = asyncio.create_task(self._monitoring_loop())
            
            return {
                "status": "success",
                "message": "Security monitoring started",
                "started_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error starting security monitoring: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_monitoring(self):
        """Stop security monitoring"""
        try:
            self.monitoring_active = False
            
            if self.monitoring_task:
                self.monitoring_task.cancel()
                self.monitoring_task = None
            
            logger.info("Security monitoring stopped")
            
            return {
                "status": "success",
                "message": "Security monitoring stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping security monitoring: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _monitoring_loop(self):
        """Main security monitoring loop"""
        while self.monitoring_active:
            try:
                # Check for security events
                await self._check_security_events()
                
                # Check system health
                await self._check_system_health()
                
                # Wait for next check (30 seconds)
                await asyncio.sleep(30)
                
        except Exception as e:
            logger.error(f"Error in monitoring loop: {e}")
                await asyncio.sleep(30)
    
    async def _check_security_events(self):
        """Check for security events"""
        try:
            # Get recent security events
            end_time = datetime.utcnow() - timedelta(minutes=5)
            
            # Get recent security events
            db = next(get_db())
            recent_events = db.query(models.SecurityEvent).filter(
                models.SecurityEvent.timestamp >= end_time
            ).order_by(models.SecurityEvent.timestamp.desc()).limit(20).all()
            
            # Analyze events for threats
            for event in recent_events:
                threat_level = self._analyze_threat_level(event)
                
                # Log security event
                security_event = models.SecurityEvent(
                    tenant_id=event.tenant_id or "default",
                    event_type=event.type,
                    severity=threat_level['priority'],
                    description=event.description,
                    details=event.details,
                    source_ip=event.source_ip,
                    user_id=event.user_id,
                    created_at=event.timestamp,
                    resolved_at=event.resolved_at
                )
                )
                
                db.add(security_event)
                db.commit()
                
                # Check for specific threat patterns
                await self._check_threat_patterns(event)
                
                # Update security score
                self._update_security_score()
                
        except Exception as e:
            logger.error(f"Error checking security events: {e}")
    
    def _analyze_threat_level(self, event: models.SecurityEvent) -> Dict:
        """Analyze threat level of security event"""
        event_type = event.type.lower()
        
        if event_type in ['failed_login', 'unauthorized_access', 'suspicious_activity']:
            return self.threat_levels['high']
        elif event_type in ['sql_injection', 'brute_force', 'privilege_escalation']:
            return self.threat_levels['high']
        elif event_type in ['malware_detected', 'data_breach', 'system_compromise']:
            return self.threat_levels['high']
        elif event_type in ['invalid_input', 'configuration_error', 'resource_exhaustion']:
            return self.threat_levels['medium']
        elif event_type in ['policy_violation', 'access_denied']:
            return self.threat_levels['medium']
        elif event_type in ['performance_issue', 'capacity_warning']:
            return self.threat_levels['low']
        else:
            return self.threat_levels['low']
    
    def _check_system_health(self):
        """Check overall system health"""
        try:
            # Check database connectivity
            db = next(get_db())
            db.execute("SELECT 1").fetchone()
            
            # Check file system health
            disk_usage = self._check_disk_space()
            memory_usage = self._check_memory_usage()
            
            # Check API response times
            api_health = await self._check_api_health()
            
            # Calculate system health score
            health_score = (api_health['score'] + disk_usage['score'] + memory_usage['score']) / 3
            
            # Update security score
            self._update_security_score()
            
            return {
                'database_status': 'connected' if db else 'disconnected',
                'disk_usage': disk_usage,
                'memory_usage': memory_usage,
                'api_health': api_health,
                'overall_score': health_score
            }
        
        except Exception as e:
            logger.error(f"Error checking system health: {e}")
            return {
                'database_status': 'error',
                'disk_usage': {},
                'memory_usage': {},
                'api_health': {},
                'overall_score': 0
            }
    
    def _check_disk_space(self) -> Dict:
        """Check disk space availability"""
        try:
            import shutil
            
            total, used, free = shutil.disk_usage('.')
            
            usage_percentage = (used / total) * 100 if total > 0 else 0
            
            return {
                'total_gb': round(total / (1024**3), 2),  # Convert to GB
                'used_gb': round(used / (1024**3), 2),
                'free_gb': round(free / (1024**3), 2),
                'usage_percentage': usage_percentage,
                'status': 'critical' if usage_percentage > 90 else 'warning' if usage_percentage > 80 else 'good'
            }
            
        except Exception as e:
            logger.error(f"Error checking disk space: {e}")
            return {
                'total_gb': 0,
                'used_gb': 0,
                'free_gb': 0,
                'usage_percentage': 0,
                'status': 'error'
            }
    
    def _check_memory_usage(self) -> Dict:
        """Check memory usage"""
        try:
            import psutil
            memory = psutil.virtual_memory()
            
            total_memory = memory.total
            used_memory = memory.used
            usage_percentage = (used_memory / total_memory) * 100 if total_memory > 0 else 0)
            
            return {
                'total_memory_gb': round(total_memory / (1024**3), 2),  # Convert to GB
                'used_memory_gb': round(used_memory / (1024**3), 2),
                'free_memory_gb': round((total_memory - used_memory) / (1024**3), 2),
                'usage_percentage': usage_percentage,
                'status': 'critical' if usage_percentage > 90 else 'warning' if usage_percentage > 80 else 'good'
            }
            
        except Exception as e:
            logger.error(f"Error checking memory usage: {e}")
            return {
                'total_memory_gb': 0,
                'used_memory_gb': 0,
                'free_memory_gb': 0,
                'usage_percentage': 0,
                'status': 'error'
            }
    
    async def _check_api_health(self) -> Dict:
        """Check API health and response times"""
        try:
            # Test API endpoints
            health_checks = {
                'api_health': await self._check_endpoint_health('/api/health'),
                'dashboard_health': await self._check_endpoint_health('/api/dashboard/summary'),
                'livestock_health': await self._check_endpoint_health('/api/livestock/health/summary'),
                'inventory_health': await self._check_endpoint_health('/api/inventory/health')
            }
            
            # Calculate API health score
            api_health_scores = [
                health_checks['api_health'].get('score', 0),
                health_checks['dashboard_health'].get('score', 0),
                health_checks['livestock_health'].get('score', 0),
                health_checks['inventory_health'].get('score', 0)
            ]
            
            api_health_score = sum(api_health_scores) / len(api_health_scores)
            
            return {
                'api_health': api_health_score,
                'dashboard_health': health_checks['dashboard_health'],
                'livestock_health': health_checks['livestock_health'],
                'inventory_health': health_checks['inventory_health'],
                'average_response_time': api_health.get('avg_response_time', 0),
                'error_rate': api_health.get('error_rate', 0)
            }
            
        except Exception as e:
            logger.error(f"Error checking API health: {e}")
            return {
                'api_health': 0,
                'dashboard_health': 0,
                'livestock_health': 0,
                'inventory_health': 0,
                'average_response_time': 0,
                'error_rate': 0
            }
    
    async def _check_endpoint_health(self, endpoint: str) -> Dict:
        """Check health of a specific API endpoint"""
        try:
            import aiohttp
            
            start_time = datetime.utcnow()
            
            # Make request with timeout
            timeout = aiohttp.ClientTimeout(total=10)
            
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                        url=f"http://127.0.0.1:8000{endpoint}",
                        timeout=timeout
                    ) as response:
                        response_time = (datetime.utcnow() - start_time).total_seconds()
                        
                        if response.status == 200:
                            return {
                                'endpoint': endpoint,
                                'status': 'healthy',
                                'response_time': response_time,
                                'error_rate': 0
                            }
                        else:
                            return {
                                'endpoint': endpoint,
                                'status': 'unhealthy',
                                'response_time': 0,
                                'error_rate': 100,
                                'http_error': response.status
                            }
                    
            except Exception as e:
                return {
                    'endpoint': endpoint,
                    'status': 'error',
                    'response_time': 0,
                    'error_rate': 100,
                    'http_error': str(e)
                }
            
        except Exception as e:
            logger.error(f"Error checking endpoint {endpoint}: {e}")
            return {
                'endpoint': endpoint,
                'status': 'error',
                'response_time': 0,
                'error_rate': 100,
                'http_error': str(e)
            }
    
    def _update_security_score(self):
        """Update overall security score based on recent events"""
        try:
            # Get recent security events
            db = next(get_db())
            recent_events = db.query(models.SecurityEvent).filter(
                models.SecurityEvent.timestamp >= datetime.utcnow() - timedelta(hours=24)  # Last 24 hours
            ).all()
            
            if not recent_events:
                return
            
            # Calculate security score based on recent events
            threat_scores = [self._analyze_threat_level(event) for event in recent_events]
            
            # Calculate overall security score
            if threat_scores:
                high_threats = len([s for s in threat_scores if s['priority'] == 'high'])
                medium_threats = len([s for s in threat_scores if s['priority'] == 'medium'])
                low_threats = len([s for s in threat_scores if s['priority'] == 'low'])
                
                # Calculate score (100 - (high_threats * 3 + medium_threats * 2 + low_threats) / 6
                current_score = max(0, 100 - (high_threats * 3 + medium_threats * 2 + low_threats) / 6)
            else:
                current_score = 100
            
            self.security_score = current_score
            
            # Log security score
            logger.info(f"Security score updated: {self.security_score}%")
            
        except Exception as e:
            logger.error(f"Error updating security score: {e}")
    
    def get_security_summary(self, db: Session, tenant_id: str = "default") -> Dict:
        """Get security summary"""
        try:
            # Get recent security events
            end_time = datetime.utcnow() - timedelta(days=7)  # Last 7 days
            
            events = db.query(models.SecurityEvent).filter(
                models.SecurityEvent.timestamp >= end_time
            ).order_by(models.SecurityEvent.timestamp.desc()).all()
            
            # Analyze events by type
            event_types = {}
            for event in events:
                event_type = event.type
                if event_type not in event_types:
                    event_types[event_type] = []
                event_types[event_type] = len([e for e in events if e.type == event_type])
            
            # Calculate threat distribution
            threat_distribution = {
                'high': len([s for s in event_types if s.get('priority') == 'high']),
                'medium': len([s for s in event_types if s.get('priority') == 'medium']),
                'low': len([s for s in event_types if s.get('priority') == 'low']),
                'info': len([s for s in event_types if s.get('priority') == 'info'])
            }
            
            # Calculate security metrics
            total_events = len(events)
            resolved_events = len([e for e in events if e.status == 'resolved'])
            
            return {
                'total_events': total_events,
                'resolved_events': resolved_events,
                'unresolved_events': total_events - resolved_events,
                'resolution_rate': (resolved_events / total_events * 100) if total_events > 0 else 0,
                'threat_distribution': threat_distribution,
                'event_types': event_types,
                'recent_events': events[-10:],  # Last 10 events
                'last_update': events[-1].date.isoformat() if events else None
            }
            }
            
        except Exception as e:
            logger.error(f"Error getting security summary: {e}")
            return {
                'total_events': 0,
                'resolved_events': 0,
                'unresolved_events': 0,
                'threat_distribution': {},
                'event_types': {},
                'recent_events': [],
                'last_update': None
            }
    
    def get_blocked_ips(self, db: Session, tenant_id: str = "default") -> List[str]:
        """Get list of blocked IP addresses"""
        try:
            blocked_ips = db.query(models.BlockedIP).filter(
                models.BlockedIP.tenant_id == tenant_id,
                models.BlockedIP.blocked_until > datetime.utcnow()
            ).all()
            
            return [ip.ip for ip in blocked_ips]
            
        except Exception as e:
            logger.error(f"Error getting blocked IPs: {e}")
            return []
    
    def block_ip(self, ip_address: str, reason: str, db: Session, tenant_id: str = "default") -> Dict:
        """Block an IP address"""
        try:
            # Check if IP is already blocked
            existing_block = db.query(models.BlockedIP).filter(
                models.BlockedIP.ip == ip_address,
                models.BlockedIP.tenant_id == tenant_id
            ).first()
            
            if existing_block:
                return {
                    'success': False,
                    'message': f"IP {ip_address} is already blocked"
                }
            
            # Create new block entry
            new_block = models.BlockedIP(
                tenant_id=tenant_id,
                ip_address=ip_address,
                reason=reason,
                blocked_until=datetime.utcnow() + timedelta(days=30),  # Block for 30 days
                created_at=datetime.utcnow()
            )
            
            db.add(new_block)
            db.commit()
            
            logger.warning(f"IP {ip_address} blocked for: {reason}")
            
            return {
                'success': True,
                'message': f"IP {ip_address} blocked successfully",
                'blocked_until': new_block.blocked_until.isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error blocking IP {ip_address}: {e}")
            return {
                'success': False,
                'message': f"Error blocking IP {ip_address}: {e}"
            }
    
    def unblock_ip(self, ip_address: str, db: Session, tenant_id: str = "default") -> Dict:
        """Unblock an IP address"""
        try:
            # Find and remove block entry
            blocked_ip = db.query(models.BlockedIP).filter(
                models.BlockedIP.ip == ip_address,
                models.BlockedIP.tenant_id == tenant_id
            ).first()
            
            if not blocked_ip:
                return {
                    'success': False,
                    'message': f"IP {ip_address} not found"
                }
            
            # Remove block
            db.delete(blocked_ip)
            db.commit()
            
            logger.info(f"IP {ip_address} unblocked successfully")
            
            return {
                'success': True,
                'message': f"IP {ip_address} unblocked successfully"
            }
            
        except Exception as e:
            logger.error(f"Error unblocking IP {ip_address}: {e}")
            return {
                'success': False,
                'message': f"Error unblocking IP {ip_address}: {e}"
            }

# Global security monitoring instance
security_monitoring_service = SecurityMonitoringService()
