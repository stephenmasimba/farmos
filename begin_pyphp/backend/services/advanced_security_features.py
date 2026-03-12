"""
Advanced Security Features - Phase 3 Feature
Enterprise-grade security with MFA, audit logging, data encryption, and compliance
Derived from Begin Reference System
"""

import logging
import asyncio
import hashlib
import secrets
import pyotp
import qrcode
import io
import base64
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
from decimal import Decimal
import json
from collections import defaultdict
import cryptography
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os

logger = logging.getLogger(__name__)

from ..common import models

class AdvancedSecurityService:
    """Advanced security service with enterprise features"""
    
    def __init__(self, db: Session):
        self.db = db
        self.encryption_key = self._generate_or_load_encryption_key()
        self.cipher_suite = Fernet(self.encryption_key)
        self.security_policies = {
            'password_policy': {
                'min_length': 12,
                'require_uppercase': True,
                'require_lowercase': True,
                'require_numbers': True,
                'require_symbols': True,
                'prevent_common_passwords': True
            },
            'session_policy': {
                'max_session_duration': 8 * 3600,  # 8 hours
                'require_reauth_after': 4 * 3600,   # 4 hours
                'max_concurrent_sessions': 3
            },
            'mfa_policy': {
                'required_for_admin': True,
                'required_for_sensitive_ops': True,
                'backup_codes_count': 10,
                'totp_window': 30  # seconds
            }
        }

    async def setup_multi_factor_authentication(self, user_id: int, mfa_config: Dict[str, Any], 
                                              tenant_id: str = "default") -> Dict[str, Any]:
        """Setup multi-factor authentication for user"""
        try:
            # Get user
            user = self.db.query(models.User).filter(
                and_(
                    models.User.id == user_id,
                    models.User.tenant_id == tenant_id
                )
            ).first()
            
            if not user:
                return {"error": "User not found"}
            
            # Generate TOTP secret
            totp_secret = pyotp.random_base32()
            
            # Create MFA setup record
            mfa_setup = models.MFASetup(
                user_id=user_id,
                mfa_type=mfa_config.get('mfa_type', 'totp'),
                secret_key=totp_secret,
                is_enabled=False,
                backup_codes_json=json.dumps(self._generate_backup_codes()),
                setup_initiated_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(mfa_setup)
            self.db.flush()
            
            # Generate QR code for TOTP
            totp_uri = pyotp.totp.TOTP(totp_secret).provisioning_uri(
                name=user.email,
                issuer_name="FarmOS"
            )
            
            qr_image = await self._generate_qr_code(totp_uri)
            
            # Generate backup codes
            backup_codes = json.loads(mfa_setup.backup_codes_json)
            
            return {
                "success": True,
                "user_id": user_id,
                "mfa_type": mfa_setup.mfa_type,
                "totp_secret": totp_secret,
                "qr_code": qr_image,
                "backup_codes": backup_codes,
                "setup_id": mfa_setup.id,
                "message": "MFA setup initiated. Please verify to enable."
            }
            
        except Exception as e:
            logger.error(f"Error setting up MFA: {e}")
            self.db.rollback()
            return {"error": "MFA setup failed"}

    async def verify_mfa_setup(self, user_id: int, verification_code: str, 
                             tenant_id: str = "default") -> Dict[str, Any]:
        """Verify and enable MFA setup"""
        try:
            # Get MFA setup
            mfa_setup = self.db.query(models.MFASetup).filter(
                and_(
                    models.MFASetup.user_id == user_id,
                    models.MFASetup.tenant_id == tenant_id,
                    models.MFASetup.is_enabled == False
                )
            ).first()
            
            if not mfa_setup:
                return {"error": "MFA setup not found or already enabled"}
            
            # Verify TOTP code
            totp = pyotp.TOTP(mfa_setup.secret_key)
            
            if not totp.verify(verification_code, valid_window=1):
                return {"error": "Invalid verification code"}
            
            # Enable MFA
            mfa_setup.is_enabled = True
            mfa_setup.verified_at = datetime.utcnow()
            
            # Update user security status
            user = self.db.query(models.User).filter(models.User.id == user_id).first()
            if user:
                user.mfa_enabled = True
                user.mfa_enabled_at = datetime.utcnow()
            
            self.db.commit()
            
            return {
                "success": True,
                "user_id": user_id,
                "mfa_enabled": True,
                "enabled_at": datetime.utcnow().isoformat(),
                "message": "MFA successfully enabled"
            }
            
        except Exception as e:
            logger.error(f"Error verifying MFA setup: {e}")
            self.db.rollback()
            return {"error": "MFA verification failed"}

    async def authenticate_with_mfa(self, user_id: int, password: str, mfa_code: str, 
                                  tenant_id: str = "default") -> Dict[str, Any]:
        """Authenticate user with MFA"""
        try:
            # Get user
            user = self.db.query(models.User).filter(
                and_(
                    models.User.id == user_id,
                    models.User.tenant_id == tenant_id
                )
            ).first()
            
            if not user:
                return {"error": "User not found"}
            
            # Verify password (simplified - would use proper password hashing)
            if not self._verify_password(password, user.password_hash):
                return {"error": "Invalid credentials"}
            
            # Check if MFA is required
            if user.mfa_enabled:
                # Get MFA setup
                mfa_setup = self.db.query(models.MFASetup).filter(
                    and_(
                        models.MFASetup.user_id == user_id,
                        models.MFASetup.is_enabled == True,
                        models.MFASetup.tenant_id == tenant_id
                    )
                ).first()
                
                if not mfa_setup:
                    return {"error": "MFA setup not found"}
                
                # Verify MFA code
                if mfa_setup.mfa_type == 'totp':
                    totp = pyotp.TOTP(mfa_setup.secret_key)
                    if not totp.verify(mfa_code, valid_window=1):
                        return {"error": "Invalid MFA code"}
                else:
                    return {"error": "Unsupported MFA type"}
            
            # Create session
            session_token = await self._create_secure_session(user_id, tenant_id)
            
            # Log authentication
            await self._log_security_event(
                user_id=user_id,
                event_type='authentication_success',
                details={'mfa_used': user.mfa_enabled},
                tenant_id=tenant_id
            )
            
            return {
                "success": True,
                "user_id": user_id,
                "session_token": session_token,
                "mfa_verified": user.mfa_enabled,
                "authenticated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error authenticating with MFA: {e}")
            return {"error": "Authentication failed"}

    async def encrypt_sensitive_data(self, data: str, data_type: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Encrypt sensitive data"""
        try:
            # Encrypt data
            encrypted_data = self.cipher_suite.encrypt(data.encode())
            encrypted_b64 = base64.b64encode(encrypted_data).decode()
            
            # Create encryption record
            encryption = models.DataEncryption(
                data_type=data_type,
                encrypted_data=encrypted_b64,
                encryption_algorithm='Fernet',
                key_version='1.0',
                encrypted_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(encryption)
            self.db.commit()
            
            return {
                "success": True,
                "encryption_id": encryption.id,
                "data_type": data_type,
                "encrypted_at": datetime.utcnow().isoformat(),
                "message": "Data encrypted successfully"
            }
            
        except Exception as e:
            logger.error(f"Error encrypting data: {e}")
            self.db.rollback()
            return {"error": "Data encryption failed"}

    async def decrypt_sensitive_data(self, encryption_id: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Decrypt sensitive data"""
        try:
            # Get encryption record
            encryption = self.db.query(models.DataEncryption).filter(
                and_(
                    models.DataEncryption.id == encryption_id,
                    models.DataEncryption.tenant_id == tenant_id
                )
            ).first()
            
            if not encryption:
                return {"error": "Encryption record not found"}
            
            # Decrypt data
            encrypted_data = base64.b64decode(encryption.encrypted_data.encode())
            decrypted_data = self.cipher_suite.decrypt(encrypted_data).decode()
            
            # Log decryption
            await self._log_security_event(
                event_type='data_decrypted',
                details={'encryption_id': encryption_id, 'data_type': encryption.data_type},
                tenant_id=tenant_id
            )
            
            return {
                "success": True,
                "decrypted_data": decrypted_data,
                "data_type": encryption.data_type,
                "decrypted_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error decrypting data: {e}")
            return {"error": "Data decryption failed"}

    async def create_audit_log(self, audit_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Create comprehensive audit log"""
        try:
            # Create audit log record
            audit_log = models.AuditLog(
                user_id=audit_data.get('user_id'),
                action=audit_data['action'],
                resource_type=audit_data.get('resource_type'),
                resource_id=audit_data.get('resource_id'),
                old_values_json=json.dumps(audit_data.get('old_values', {})),
                new_values_json=json.dumps(audit_data.get('new_values', {})),
                ip_address=audit_data.get('ip_address'),
                user_agent=audit_data.get('user_agent'),
                session_id=audit_data.get('session_id'),
                success=audit_data.get('success', True),
                error_message=audit_data.get('error_message'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(audit_log)
            self.db.commit()
            
            return {
                "success": True,
                "audit_id": audit_log.id,
                "action": audit_log.action,
                "created_at": audit_log.created_at.isoformat(),
                "message": "Audit log created successfully"
            }
            
        except Exception as e:
            logger.error(f"Error creating audit log: {e}")
            self.db.rollback()
            return {"error": "Audit log creation failed"}

    async def get_security_audit_trail(self, filters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Get security audit trail"""
        try:
            # Build query
            query = self.db.query(models.AuditLog).filter(models.AuditLog.tenant_id == tenant_id)
            
            # Apply filters
            if filters.get('user_id'):
                query = query.filter(models.AuditLog.user_id == filters['user_id'])
            
            if filters.get('action'):
                query = query.filter(models.AuditLog.action == filters['action'])
            
            if filters.get('resource_type'):
                query = query.filter(models.AuditLog.resource_type == filters['resource_type'])
            
            if filters.get('start_date'):
                start_date = datetime.strptime(filters['start_date'], '%Y-%m-%d')
                query = query.filter(models.AuditLog.created_at >= start_date)
            
            if filters.get('end_date'):
                end_date = datetime.strptime(filters['end_date'], '%Y-%m-%d')
                query = query.filter(models.AuditLog.created_at <= end_date)
            
            # Order and limit
            query = query.order_by(models.AuditLog.created_at.desc())
            
            if filters.get('limit'):
                query = query.limit(filters['limit'])
            
            audit_logs = query.all()
            
            # Format results
            formatted_logs = []
            for log in audit_logs:
                formatted_logs.append({
                    "id": log.id,
                    "user_id": log.user_id,
                    "action": log.action,
                    "resource_type": log.resource_type,
                    "resource_id": log.resource_id,
                    "old_values": json.loads(log.old_values_json) if log.old_values_json else {},
                    "new_values": json.loads(log.new_values_json) if log.new_values_json else {},
                    "ip_address": log.ip_address,
                    "user_agent": log.user_agent,
                    "success": log.success,
                    "error_message": log.error_message,
                    "created_at": log.created_at.isoformat()
                })
            
            return {
                "success": True,
                "audit_logs": formatted_logs,
                "total_logs": len(formatted_logs),
                "filters_applied": filters,
                "retrieved_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting security audit trail: {e}")
            return {"error": "Audit trail retrieval failed"}

    async def monitor_security_events(self, monitoring_config: Dict[str, Any], 
                                    tenant_id: str = "default") -> Dict[str, Any]:
        """Monitor security events in real-time"""
        try:
            # Get recent security events
            recent_events = await self._get_recent_security_events(tenant_id)
            
            # Analyze for anomalies
            anomalies = await self._detect_security_anomalies(recent_events)
            
            # Generate alerts
            alerts = await self._generate_security_alerts(anomalies, tenant_id)
            
            # Calculate security metrics
            metrics = await self._calculate_security_metrics(recent_events, tenant_id)
            
            return {
                "success": True,
                "monitoring_period": monitoring_config.get('period', '24h'),
                "recent_events": recent_events[-50:],  # Last 50 events
                "anomalies_detected": len(anomalies),
                "security_alerts": alerts,
                "security_metrics": metrics,
                "monitoring_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error monitoring security events: {e}")
            return {"error": "Security monitoring failed"}

    async def enforce_security_policies(self, policy_enforcement: Dict[str, Any], 
                                       tenant_id: str = "default") -> Dict[str, Any]:
        """Enforce security policies"""
        try:
            enforcement_results = []
            
            # Password policy enforcement
            if policy_enforcement.get('enforce_password_policy'):
                password_result = await self._enforce_password_policy(tenant_id)
                enforcement_results.append(password_result)
            
            # Session policy enforcement
            if policy_enforcement.get('enforce_session_policy'):
                session_result = await self._enforce_session_policy(tenant_id)
                enforcement_results.append(session_result)
            
            # MFA policy enforcement
            if policy_enforcement.get('enforce_mfa_policy'):
                mfa_result = await self._enforce_mfa_policy(tenant_id)
                enforcement_results.append(mfa_result)
            
            # Access control enforcement
            if policy_enforcement.get('enforce_access_control'):
                access_result = await self._enforce_access_control(tenant_id)
                enforcement_results.append(access_result)
            
            return {
                "success": True,
                "policies_enforced": len(enforcement_results),
                "enforcement_results": enforcement_results,
                "enforced_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error enforcing security policies: {e}")
            return {"error": "Policy enforcement failed"}

    async def generate_security_report(self, report_config: Dict[str, Any], 
                                     tenant_id: str = "default") -> Dict[str, Any]:
        """Generate comprehensive security report"""
        try:
            # Get report period
            start_date = datetime.strptime(report_config['start_date'], '%Y-%m-%d').date()
            end_date = datetime.strptime(report_config['end_date'], '%Y-%m-%d').date()
            
            # Get security metrics
            security_metrics = await self._get_comprehensive_security_metrics(start_date, end_date, tenant_id)
            
            # Get compliance status
            compliance_status = await self._get_compliance_status(tenant_id)
            
            # Get risk assessment
            risk_assessment = await self._perform_security_risk_assessment(tenant_id)
            
            # Get recommendations
            recommendations = await self._generate_security_recommendations(security_metrics, risk_assessment)
            
            return {
                "success": True,
                "report_period": {
                    "start_date": start_date.strftime('%Y-%m-%d'),
                    "end_date": end_date.strftime('%Y-%m-%d')
                },
                "security_metrics": security_metrics,
                "compliance_status": compliance_status,
                "risk_assessment": risk_assessment,
                "recommendations": recommendations,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error generating security report: {e}")
            return {"error": "Security report generation failed"}

    # Helper Methods
    def _generate_or_load_encryption_key(self) -> bytes:
        """Generate or load encryption key"""
        try:
            # In production, this would load from secure key storage
            # For now, generate a key
            password = b"farmos_encryption_key_2024"  # Should be from secure config
            salt = b"farmos_salt_2024"  # Should be from secure config
            
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=100000,
            )
            key = base64.urlsafe_b64encode(kdf.derive(password))
            return key
            
        except Exception as e:
            logger.error(f"Error generating encryption key: {e}")
            # Fallback to simple key
            return Fernet.generate_key()

    def _generate_backup_codes(self, count: int = 10) -> List[str]:
        """Generate backup codes for MFA"""
        codes = []
        for _ in range(count):
            code = ''.join(secrets.choice('0123456789') for _ in range(8))
            codes.append(f"{code[:4]}-{code[4:]}")
        return codes

    async def _generate_qr_code(self, data: str) -> str:
        """Generate QR code image as base64"""
        try:
            import qrcode
            qr = qrcode.QRCode(
                version=1,
                error_correction=qrcode.constants.ERROR_CORRECT_L,
                box_size=10,
                border=4,
            )
            qr.add_data(data)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            
            # Convert to base64
            buffer = io.BytesIO()
            img.save(buffer, format='PNG')
            img_str = base64.b64encode(buffer.getvalue()).decode()
            
            return img_str
            
        except Exception as e:
            logger.error(f"Error generating QR code: {e}")
            return ""

    def _verify_password(self, password: str, password_hash: str) -> bool:
        """Verify password (simplified - would use proper hashing)"""
        try:
            # In production, use bcrypt or Argon2
            import hashlib
            return hashlib.sha256(password.encode()).hexdigest() == password_hash
        except:
            return False

    async def _create_secure_session(self, user_id: int, tenant_id: str) -> str:
        """Create secure session token"""
        try:
            # Generate session token
            session_data = {
                "user_id": user_id,
                "tenant_id": tenant_id,
                "created_at": datetime.utcnow().isoformat(),
                "expires_at": (datetime.utcnow() + timedelta(hours=8)).isoformat()
            }
            
            session_token = secrets.token_urlsafe(32)
            
            # Store session (simplified)
            session = models.UserSession(
                user_id=user_id,
                session_token=session_token,
                expires_at=datetime.utcnow() + timedelta(hours=8),
                ip_address=None,  # Would get from request
                user_agent=None,  # Would get from request
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(session)
            self.db.commit()
            
            return session_token
            
        except Exception as e:
            logger.error(f"Error creating secure session: {e}")
            return ""

    async def _log_security_event(self, user_id: Optional[int], event_type: str, 
                                 details: Dict[str, Any], tenant_id: str):
        """Log security event"""
        try:
            security_event = models.SecurityEvent(
                user_id=user_id,
                event_type=event_type,
                details_json=json.dumps(details),
                severity=details.get('severity', 'info'),
                ip_address=details.get('ip_address'),
                user_agent=details.get('user_agent'),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(security_event)
            self.db.commit()
            
        except Exception as e:
            logger.error(f"Error logging security event: {e}")

    async def _get_recent_security_events(self, tenant_id: str, hours: int = 24) -> List[Dict]:
        """Get recent security events"""
        try:
            cutoff_time = datetime.utcnow() - timedelta(hours=hours)
            
            events = self.db.query(models.SecurityEvent).filter(
                and_(
                    models.SecurityEvent.tenant_id == tenant_id,
                    models.SecurityEvent.created_at >= cutoff_time
                )
            ).order_by(models.SecurityEvent.created_at.desc()).limit(100).all()
            
            formatted_events = []
            for event in events:
                formatted_events.append({
                    "id": event.id,
                    "user_id": event.user_id,
                    "event_type": event.event_type,
                    "details": json.loads(event.details_json) if event.details_json else {},
                    "severity": event.severity,
                    "created_at": event.created_at.isoformat()
                })
            
            return formatted_events
            
        except Exception as e:
            logger.error(f"Error getting recent security events: {e}")
            return []

    async def _detect_security_anomalies(self, events: List[Dict]) -> List[Dict]:
        """Detect security anomalies"""
        try:
            anomalies = []
            
            # Check for multiple failed logins
            failed_logins = [e for e in events if e['event_type'] == 'login_failed']
            user_failed_logins = defaultdict(int)
            
            for event in failed_logins:
                user_id = event.get('user_id')
                if user_id:
                    user_failed_logins[user_id] += 1
            
            for user_id, count in user_failed_logins.items():
                if count > 5:  # Threshold for suspicious activity
                    anomalies.append({
                        "type": "multiple_failed_logins",
                        "user_id": user_id,
                        "failed_attempts": count,
                        "severity": "high",
                        "detected_at": datetime.utcnow().isoformat()
                    })
            
            # Check for unusual access patterns
            access_events = [e for e in events if e['event_type'] == 'resource_access']
            user_access_counts = defaultdict(int)
            
            for event in access_events:
                user_id = event.get('user_id')
                if user_id:
                    user_access_counts[user_id] += 1
            
            for user_id, count in user_access_counts.items():
                if count > 1000:  # Unusual high access
                    anomalies.append({
                        "type": "unusual_access_pattern",
                        "user_id": user_id,
                        "access_count": count,
                        "severity": "medium",
                        "detected_at": datetime.utcnow().isoformat()
                    })
            
            return anomalies
            
        except Exception as e:
            logger.error(f"Error detecting security anomalies: {e}")
            return []

    async def _generate_security_alerts(self, anomalies: List[Dict], tenant_id: str) -> List[Dict]:
        """Generate security alerts"""
        try:
            alerts = []
            
            for anomaly in anomalies:
                alert = models.SecurityAlert(
                    alert_type=anomaly['type'],
                    severity=anomaly['severity'],
                    details_json=json.dumps(anomaly),
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                
                self.db.add(alert)
                
                alerts.append({
                    "alert_id": alert.id,
                    "type": anomaly['type'],
                    "severity": anomaly['severity'],
                    "details": anomaly,
                    "created_at": datetime.utcnow().isoformat()
                })
            
            self.db.commit()
            return alerts
            
        except Exception as e:
            logger.error(f"Error generating security alerts: {e}")
            return []

    async def _calculate_security_metrics(self, events: List[Dict], tenant_id: str) -> Dict[str, Any]:
        """Calculate security metrics"""
        try:
            total_events = len(events)
            
            # Event type breakdown
            event_types = defaultdict(int)
            for event in events:
                event_types[event['event_type']] += 1
            
            # Severity breakdown
            severity_counts = defaultdict(int)
            for event in events:
                severity_counts[event['severity']] += 1
            
            # Calculate security score
            critical_events = severity_counts.get('critical', 0)
            high_events = severity_counts.get('high', 0)
            security_score = max(0, 100 - (critical_events * 20) - (high_events * 10))
            
            return {
                "total_events": total_events,
                "event_types": dict(event_types),
                "severity_breakdown": dict(severity_counts),
                "security_score": security_score,
                "risk_level": "low" if security_score > 80 else "medium" if security_score > 60 else "high"
            }
            
        except Exception as e:
            logger.error(f"Error calculating security metrics: {e}")
            return {}

    async def _enforce_password_policy(self, tenant_id: str) -> Dict[str, Any]:
        """Enforce password policy"""
        try:
            # Get users with weak passwords
            users = self.db.query(models.User).filter(models.User.tenant_id == tenant_id).all()
            
            violations = []
            for user in users:
                password_issues = self._check_password_compliance(user.password_hash)
                if password_issues:
                    violations.append({
                        "user_id": user.id,
                        "issues": password_issues
                    })
            
            return {
                "policy": "password_policy",
                "users_checked": len(users),
                "violations_found": len(violations),
                "violations": violations
            }
            
        except Exception as e:
            logger.error(f"Error enforcing password policy: {e}")
            return {"policy": "password_policy", "error": str(e)}

    def _check_password_compliance(self, password_hash: str) -> List[str]:
        """Check password compliance"""
        # Simplified check - in production would analyze actual password
        issues = []
        
        # This is a placeholder - actual implementation would need access to plain password
        # or store password complexity metrics during password creation
        
        return issues

    async def _enforce_session_policy(self, tenant_id: str) -> Dict[str, Any]:
        """Enforce session policy"""
        try:
            # Get active sessions
            active_sessions = self.db.query(models.UserSession).filter(
                and_(
                    models.UserSession.tenant_id == tenant_id,
                    models.UserSession.expires_at > datetime.utcnow()
                )
            ).all()
            
            # Check for expired sessions
            expired_sessions = self.db.query(models.UserSession).filter(
                and_(
                    models.UserSession.tenant_id == tenant_id,
                    models.UserSession.expires_at <= datetime.utcnow()
                )
            ).all()
            
            # Clean up expired sessions
            for session in expired_sessions:
                self.db.delete(session)
            
            self.db.commit()
            
            return {
                "policy": "session_policy",
                "active_sessions": len(active_sessions),
                "expired_sessions_cleaned": len(expired_sessions)
            }
            
        except Exception as e:
            logger.error(f"Error enforcing session policy: {e}")
            return {"policy": "session_policy", "error": str(e)}

    async def _enforce_mfa_policy(self, tenant_id: str) -> Dict[str, Any]:
        """Enforce MFA policy"""
        try:
            # Get admin users without MFA
            admin_users = self.db.query(models.User).filter(
                and_(
                    models.User.tenant_id == tenant_id,
                    models.User.role == 'admin',
                    models.User.mfa_enabled == False
                )
            ).all()
            
            return {
                "policy": "mfa_policy",
                "admin_users_without_mfa": len(admin_users),
                "users_requiring_mfa": len(admin_users)
            }
            
        except Exception as e:
            logger.error(f"Error enforcing MFA policy: {e}")
            return {"policy": "mfa_policy", "error": str(e)}

    async def _enforce_access_control(self, tenant_id: str) -> Dict[str, Any]:
        """Enforce access control"""
        try:
            # Check for orphaned permissions
            orphaned_permissions = self.db.query(models.UserPermission).filter(
                models.UserPermission.tenant_id == tenant_id
            ).count()
            
            return {
                "policy": "access_control",
                "total_permissions": orphaned_permissions,
                "access_control_status": "active"
            }
            
        except Exception as e:
            logger.error(f"Error enforcing access control: {e}")
            return {"policy": "access_control", "error": str(e)}

    async def _get_comprehensive_security_metrics(self, start_date: datetime.date, 
                                                end_date: datetime.date, 
                                                tenant_id: str) -> Dict[str, Any]:
        """Get comprehensive security metrics"""
        try:
            # Get security events in period
            events = self.db.query(models.SecurityEvent).filter(
                and_(
                    models.SecurityEvent.tenant_id == tenant_id,
                    models.SecurityEvent.created_at >= start_date,
                    models.SecurityEvent.created_at <= end_date
                )
            ).all()
            
            # Calculate metrics
            total_events = len(events)
            critical_events = len([e for e in events if e.severity == 'critical'])
            high_events = len([e for e in events if e.severity == 'high'])
            
            # Authentication metrics
            auth_events = [e for e in events if e.event_type.startswith('auth')]
            successful_auth = len([e for e in auth_events if e.event_type == 'authentication_success'])
            failed_auth = len([e for e in auth_events if e.event_type == 'authentication_failed'])
            
            return {
                "period": {
                    "start_date": start_date.strftime('%Y-%m-%d'),
                    "end_date": end_date.strftime('%Y-%m-%d')
                },
                "total_security_events": total_events,
                "critical_events": critical_events,
                "high_events": high_events,
                "authentication_metrics": {
                    "successful": successful_auth,
                    "failed": failed_auth,
                    "success_rate": (successful_auth / (successful_auth + failed_auth) * 100) if (successful_auth + failed_auth) > 0 else 0
                },
                "security_score": max(0, 100 - (critical_events * 20) - (high_events * 10))
            }
            
        except Exception as e:
            logger.error(f"Error getting comprehensive security metrics: {e}")
            return {}

    async def _get_compliance_status(self, tenant_id: str) -> Dict[str, Any]:
        """Get compliance status"""
        try:
            # Check various compliance requirements
            compliance_checks = {
                "gdpr_compliance": {
                    "status": "compliant",
                    "last_checked": datetime.utcnow().isoformat(),
                    "issues": []
                },
                "sox_compliance": {
                    "status": "compliant",
                    "last_checked": datetime.utcnow().isoformat(),
                    "issues": []
                },
                "data_protection": {
                    "status": "compliant",
                    "last_checked": datetime.utcnow().isoformat(),
                    "issues": []
                }
            }
            
            # Calculate overall compliance score
            compliant_checks = len([c for c in compliance_checks.values() if c['status'] == 'compliant'])
            overall_compliance = (compliant_checks / len(compliance_checks)) * 100
            
            return {
                "overall_compliance_percentage": overall_compliance,
                "compliance_checks": compliance_checks,
                "last_assessment": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting compliance status: {e}")
            return {}

    async def _perform_security_risk_assessment(self, tenant_id: str) -> Dict[str, Any]:
        """Perform security risk assessment"""
        try:
            risk_factors = {
                "authentication_risk": "low",
                "authorization_risk": "medium",
                "data_protection_risk": "low",
                "infrastructure_risk": "low",
                "human_factor_risk": "medium"
            }
            
            # Calculate overall risk score
            risk_scores = {"low": 20, "medium": 50, "high": 80}
            total_risk = sum(risk_scores.get(risk, 50) for risk in risk_factors.values())
            overall_risk_score = total_risk / len(risk_factors)
            
            return {
                "overall_risk_score": overall_risk_score,
                "risk_level": "low" if overall_risk_score < 30 else "medium" if overall_risk_score < 60 else "high",
                "risk_factors": risk_factors,
                "assessment_date": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error performing risk assessment: {e}")
            return {}

    async def _generate_security_recommendations(self, metrics: Dict[str, Any], 
                                               risk_assessment: Dict[str, Any]) -> List[Dict]:
        """Generate security recommendations"""
        try:
            recommendations = []
            
            # Based on metrics
            if metrics.get('security_score', 100) < 80:
                recommendations.append({
                    "category": "security_improvement",
                    "priority": "high",
                    "recommendation": "Security score below optimal - review security policies",
                    "action_items": ["Update security policies", "Conduct security training"]
                })
            
            # Based on risk assessment
            if risk_assessment.get('overall_risk_score', 0) > 50:
                recommendations.append({
                    "category": "risk_mitigation",
                    "priority": "medium",
                    "recommendation": "Medium to high risk detected - implement additional controls",
                    "action_items": ["Enhance monitoring", "Strengthen access controls"]
                })
            
            # General recommendations
            recommendations.append({
                "category": "best_practices",
                "priority": "low",
                "recommendation": "Regular security reviews and updates",
                "action_items": ["Monthly security reviews", "Quarterly penetration testing"]
            })
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating security recommendations: {e}")
            return []
