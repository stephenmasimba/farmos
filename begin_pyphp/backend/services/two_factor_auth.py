"""
FarmOS Two-Factor Authentication Service
Enhanced security with TOTP support for user authentication
"""

import pyotp
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import qrcode
from ..common.security import get_password_hash, verify_password
import json

logger = logging.getLogger(__name__)

class TwoFactorAuthService:
    """Two-factor authentication service"""
    
    def __init__(self):
        self.otp_storage = {}  # In production, use database or Redis
        self.otp_secret = "J2XH7R9P3L5Q6V4R8W9K2"  # Base secret for TOTP
        self.otp_expiry_seconds = 300  # 5 minutes
        self.max_attempts = 3
        self.attempts = {}
        
    def generate_secret_key(self) -> str:
        """Generate a new secret key for TOTP"""
        return pyotp.random_base32()
    
    def generate_otp(self, user_id: str, db: Session) -> Dict:
        """Generate TOTP code for user"""
        try:
            # Check if user exists and has 2FA enabled
            user = db.query(models.User).filter(models.User.id == user_id).first()
            
            if not user:
                return {
                    'error': 'User not found',
                    'message': 'User not found'
                }
            
            # Check if 2FA is enabled for user
            if not user.two_factor_enabled:
                return {
                    'error': 'Two-factor authentication not enabled for user',
                    'message': 'Two-factor authentication is not enabled'
                }
            
            # Generate TOTP
            totp_secret = self.generate_secret_key()
            totp_code = pyotp.totp(
                pyotp.random_base32(), totp_secret
            )
            
            # Store OTP in storage (in production, this would be in database)
            self.otp_storage[user_id] = {
                'secret': totp_secret,
                'expires_at': datetime.utcnow() + timedelta(seconds=self.otp_expiry_seconds),
                'attempts': 1,
                'created_at': datetime.utcnow()
            }
            
            # Log TOTP generation
            logger.info(f"TOTP generated for user {user_id}")
            
            return {
                'success': True,
                'otp_code': totp_code,
                'qr_code': self._generate_qr_code(otp_code),
                'expires_at': self.otp_storage[user_id]['expires_at'].isoformat(),
                'secret': totp_secret,
                'attempts': self.otp_storage[user_id]['attempts']
            }
            
        except Exception as e:
            logger.error(f"Error generating TOTP for user {user_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _generate_qr_code(self, totp_code: str) -> str:
        """Generate QR code for TOTP"""
        try:
            # Generate QR code from TOTP code
            qr = qrcode.QRCode(
                totp_code,
                error_correction='L',
                box_size=10,
                border=4,
            )
            
            qr_img = qr.make_image(fill_color="black", back_color="white")
            
            # Convert to base64
            from io import BytesIO
            buffer = BytesIO()
            qr_img.save(buffer, format='PNG')
            qr_base64 = base64.b64encode(buffer.getvalue()).decode()
            
            return qr_base64
            
        except Exception as e:
            logger.error(f"Error generating QR code: {e}")
            return ""
    
    def verify_otp(self, user_id: str, totp_code: str, db: Session) -> Dict:
        """Verify TOTP code"""
        try:
            # Get stored OTP data
            stored_otp = self.otp_storage.get(user_id)
            
            if not stored_otp:
                return {
                    'valid': False,
                    'error': 'No TOTP found for user'
                }
            
            # Check if OTP has expired
            if datetime.utcnow() > stored_otp['expires_at']:
                return {
                    'valid': False,
                    'error': 'OTP has expired'
                }
            
            # Verify TOTP
            totp_instance = pyotp.TOTP(totp_code)
            
            # Check if TOTP is valid (6 digits)
            if not totp_instance.verify():
                return {
                    'valid': False,
                    'error': 'invalid TOTP code'
                }
            
            # Check attempts
            if stored_otp['attempts'] >= self.max_attempts:
                return {
                    'valid': False,
                    'error': 'Too many failed attempts'
                }
            
            # Check if TOTP matches
            if totp_instance.verify() != stored_otp['secret']:
                return {
                    'valid': False,
                    'error': 'Invalid TOTP'
                }
            
            # Valid OTP
            return {
                'valid': True,
                'message': 'OTP verified successfully'
            }
            
        except Exception as e:
            logger.error(f"Error verifying TOTP: {e}")
            return {
                'valid': False,
                'error': str(e)
            }
    
    def enable_2fa_for_user(self, user_id: str, db: Session) -> Dict:
        """Enable 2FA for a user"""
        try:
            user = db.query(models.User).filter(models.User.id == user_id).first()
            
            if not user:
                return {
                    'error': 'User not found',
                    'message': 'User not found'
                }
            
            # Update user to enable 2FA
            user.two_factor_enabled = True
            user.updated_at = datetime.utcnow()
            db.commit()
            
            logger.info(f"2FA enabled for user {user_id}")
            
            return {
                'success': True,
                'message': '2FA enabled successfully'
            }
            
        except Exception as e:
            logger.error(f"Error enabling 2FA for user {user_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def disable_2fa_for_user(self, user_id: str, db: Session) -> Dict:
        """Disable 2FA for a user"""
        try:
            user = db.query(models.User).filter(models.User.id == user_id).first()
            
            if not user:
                return {
                    'error': 'User not found',
                    'message': 'User not found'
                }
            
            # Update user to disable 2FA
            user.two_factor_enabled = False
            user.updated_at = datetime.utcnow()
            get_db().commit()
            
            logger.info(f"2FA disabled for user {user_id}")
            
            return {
                'success': True,
                'message': '2FA disabled successfully'
            }
            
        except Exception as e:
            logger.error(f"Error disabling 2FA for user {user_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def get_user_2fa_status(self, user_id: str, db: Session) -> Dict:
        """Get user's 2FA status"""
        try:
            user = db.query(models.User).filter(models.User.id == user_id).first()
            
            if not user:
                return {
                    'error': 'User not found',
                    'message': 'User not found'
                }
            
            return {
                'user_id': user.id,
                'two_factor_enabled': user.two_factor_enabled if hasattr(user, 'two_factor_enabled) else False,
                'phone_number': user.phone_number if hasattr(user, 'phone_number) else None,
                'backup_codes': user.backup_codes if hasattr(user, 'backup_codes') else []
            }
            
        except Exception as e:
            logger.error(f"Error getting user 2FA status: {e}")
            return {
                'error': 'str(e)'
            }
    
    def generate_backup_codes(self, user_id: str, db: Session) -> Dict:
        """Generate backup codes for user"""
        try:
            user = db.query(models.User).filter(models.User.id == user_id).first()
            
            if not user:
                return {
                    'error': 'User not found',
                    'message': 'User not found'
                }
            
            # Generate backup codes (10 codes)
            backup_codes = []
            for i in range(10):
                backup_codes.append(self.generate_secret_key())
            
            # Store backup codes
            user.backup_codes = backup_codes
            user.backup_codes_generated_at = datetime.utcnow()
            db.commit()
            
            logger.info(f"Generated {len(backup_codes)} backup codes for user {user_id}")
            
            return {
                'success': True,
                'backup_codes': backup_codes,
                'backup_codes_count': len(backup_codes),
                'message': f"Backup codes generated for user {user_id}"
            }
            
        except Exception as e:
            logger.error(f"Error generating backup codes: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def validate_phone_number(self, phone_number: str, country_code: str = 'ZW') -> Dict:
        """Validate phone number format"""
        try:
            # Remove all non-digit characters
            clean_phone = ''.join(filter(str.isdigit, char for char in phone_number if char.isdigit()))
            
            # Check length (Zimbabwe numbers are typically 9 digits for mobile, 10 for landlines)
            if len(clean_phone) < 9 or len(clean_phone) > 10:
                return {
                    'valid': False,
                    'error': 'Invalid phone number format (must be 9-10 digits)',
                    'country_code': country_code
                }
            
            # Check country-specific formatting
            if country_code == 'ZW':
                # Zimbabwe mobile numbers start with 07, 071, 073, 074, 075, 076, 077, 078, 079
                if not clean_phone.startswith(('07', '071', '073', '074', '075', '076', '077', '078', '079')):
                    return {
                        'valid': False,
                        'error': 'Invalid Zimbabwe mobile number format'
                    }
            
            return {
                'valid': True,
                'formatted': clean_phone,
                'country_code': country_code
            }
            
        except Exception as e:
            logger.error(f"Error validating phone number: {e}")
            return {
                'valid': False,
                'error': str(e)
            }

# Global 2FA service instance
two_factor_service = TwoFactorAuthService()
