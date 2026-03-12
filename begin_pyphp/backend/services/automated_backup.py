"""
FarmOS Automated Backup Service
Automated backup systems for data protection and disaster recovery
"""

import asyncio
import os
import shutil
import zipfile
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class AutomatedBackupService:
    """Automated backup service for data protection"""
    
    def __init__(self):
        self.backup_schedules = {}
        self.backup_storage = {}
        self.backup_jobs = {}
        self.is_running = False
        self.backup_retention_days = 30
        
        # Initialize backup configurations
        self._initialize_backup_schedules()
        self._initialize_backup_storage()
        
    def _initialize_backup_schedules(self):
        """Initialize default backup schedules"""
        self.backup_schedules = {
            'daily_database': {
                'name': 'Daily Database Backup',
                'type': 'database',
                'frequency': 'daily',
                'time': '02:00',  # 2 AM
                'retention_days': 7,
                'compression': True,
                'encryption': True
            },
            'weekly_full': {
                'name': 'Weekly Full Backup',
                'type': 'full',
                'frequency': 'weekly',
                'day': 'sunday',  # Sunday
                'time': '01:00',  # 1 AM
                'retention_days': 30,
                'compression': True,
                'encryption': True
            },
            'monthly_archive': {
                'name': 'Monthly Archive Backup',
                'type': 'archive',
                'frequency': 'monthly',
                'day': 1,  # 1st of month
                'time': '00:00',  # Midnight
                'retention_days': 365,
                'compression': True,
                'encryption': True
            },
            'incremental': {
                'name': 'Incremental Backup',
                'type': 'incremental',
                'frequency': 'hourly',
                'time': '*/15',  # Every 15 minutes
                'retention_days': 3,
                'compression': False,
                'encryption': True
            }
        }
    
    def _initialize_backup_storage(self):
        """Initialize backup storage configurations"""
        self.backup_storage = {
            'local': {
                'enabled': True,
                'directory': '/backups/farmos/',
                'max_size_gb': 100,
                'compression': True,
                'encryption': True
            },
            'cloud': {
                'enabled': False,  # Would be configured with cloud provider
                'provider': 'aws_s3',
                'bucket': 'farmos-backups',
                'region': 'us-east-1',
                'access_key': 'AWS_ACCESS_KEY',
                'secret_key': 'AWS_SECRET_KEY',
                'encryption': True
            },
            'offsite': {
                'enabled': False,
                'location': 'backup-server.farmos.local',
                'username': 'backup_user',
                'password': 'backup_password',
                'encryption': True
            }
        }
    
    async def start_backup_service(self):
        """Start the automated backup service"""
        try:
            if self.is_running:
                logger.warning("Backup service is already running")
                return
            
            self.is_running = True
            logger.info("Starting automated backup service")
            
            # Create backup directories if they don't exist
            await self._ensure_backup_directories()
            
            # Start backup scheduling loop
            self.backup_task = asyncio.create_task(self._backup_scheduling_loop())
            
            return {
                "status": "success",
                "message": "Backup service started",
                "started_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error starting backup service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_backup_service(self):
        """Stop the automated backup service"""
        try:
            self.is_running = False
            
            if self.backup_task:
                self.backup_task.cancel()
                self.backup_task = None
            
            logger.info("Backup service stopped")
            
            return {
                "status": "success",
                "message": "Backup service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error stopping backup service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _ensure_backup_directories(self):
        """Ensure backup directories exist"""
        try:
            directories = [
                self.backup_storage['local']['directory'],
                f"{self.backup_storage['local']['directory']}/database",
                f"{self.backup_storage['local']['directory']}/files",
                f"{self.backup_storage['local']['directory']}/logs",
                f"{self.backup_storage['local']['directory']}/temp"
            ]
            
            for directory in directories:
                os.makedirs(directory, exist_ok=True)
                logger.info(f"Backup directory ensured: {directory}")
        
        except Exception as e:
            logger.error(f"Error creating backup directories: {e}")
    
    async def _backup_scheduling_loop(self):
        """Main backup scheduling loop"""
        while self.is_running:
            try:
                current_time = datetime.utcnow()
                
                # Check each backup schedule
                for schedule_id, schedule in self.backup_schedules.items():
                    if self._should_run_backup(schedule, current_time):
                        await self._execute_backup(schedule_id, schedule)
                
                # Wait for next check (60 seconds)
                await asyncio.sleep(60)
                
        except Exception as e:
            logger.error(f"Error in backup scheduling loop: {e}")
            await asyncio.sleep(60)
    
    def _should_run_backup(self, schedule: Dict, current_time: datetime) -> bool:
        """Check if backup should run based on schedule"""
        try:
            # Check if backup already ran recently
            last_run = schedule.get('last_run')
            if last_run:
                time_since_last_run = (current_time - last_run).total_seconds()
                min_interval = 3600  # Minimum 1 hour between backups
                
                if time_since_last_run < min_interval:
                    return False
            
            # Check schedule frequency
            frequency = schedule.get('frequency', 'daily')
            
            if frequency == 'daily':
                # Check if current time matches scheduled time
                scheduled_time = schedule.get('time', '02:00')
                current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                return current_hour_minute == scheduled_time
            
            elif frequency == 'weekly':
                # Check if it's the right day and time
                scheduled_day = schedule.get('day', 'sunday').lower()
                scheduled_time = schedule.get('time', '01:00')
                
                if current_time.strftime('%A').lower() == scheduled_day:
                    current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                    return current_hour_minute == scheduled_time
            
            elif frequency == 'monthly':
                # Check if it's the right day and time
                scheduled_day = schedule.get('day', 1)
                scheduled_time = schedule.get('time', '00:00')
                
                if current_time.day == scheduled_day:
                    current_hour_minute = f"{current_time.hour:02d}:{current_time.minute:02d}"
                    return current_hour_minute == scheduled_time
            
            elif frequency == 'hourly':
                # Check if it's the right minute (every 15 minutes)
                return current_time.minute % 15 == 0
            
            return False
            
        except Exception as e:
            logger.error(f"Error checking backup schedule: {e}")
            return False
    
    async def _execute_backup(self, schedule_id: str, schedule: Dict):
        """Execute a backup job"""
        try:
            logger.info(f"Executing backup: {schedule_id}")
            
            # Create backup job record
            backup_job = {
                'id': f"backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
                'schedule_id': schedule_id,
                'schedule_name': schedule.get('name'),
                'type': schedule.get('type'),
                'started_at': datetime.utcnow(),
                'status': 'running'
            }
            
            self.backup_jobs[backup_job['id']] = backup_job
            
            # Execute backup based on type
            if schedule.get('type') == 'database':
                result = await self._backup_database(schedule)
            elif schedule.get('type') == 'full':
                result = await self._backup_full_system(schedule)
            elif schedule.get('type') == 'archive':
                result = await self._backup_archive(schedule)
            elif schedule.get('type') == 'incremental':
                result = await self._backup_incremental(schedule)
            else:
                result = {'success': False, 'error': f"Unknown backup type: {schedule.get('type')}"}
            
            # Update backup job
            backup_job.update({
                'completed_at': datetime.utcnow(),
                'status': 'completed' if result.get('success') else 'failed',
                'result': result
            })
            
            # Update schedule
            schedule['last_run'] = datetime.utcnow()
            
            # Log backup completion
            await self._log_backup_completion(backup_job)
            
            logger.info(f"Backup {schedule_id} completed: {result.get('success', False)}")
            
        except Exception as e:
            logger.error(f"Error executing backup {schedule_id}: {e}")
            
            # Update backup job with error
            if backup_job.get('id'):
                backup_job.update({
                    'completed_at': datetime.utcnow(),
                    'status': 'failed',
                    'result': {'success': False, 'error': str(e)}
                })
    
    async def _backup_database(self, schedule: Dict) -> Dict:
        """Backup database"""
        try:
            # Get database connection info
            from ..common.config import settings
            
            # Create database backup
            backup_file = f"{self.backup_storage['local']['directory']}/database/db_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.sql"
            
            # Use mysqldump for MySQL backup
            import subprocess
            
            command = [
                'mysqldump',
                f'--host={settings.DATABASE_HOST}',
                f'--user={settings.DATABASE_USER}',
                f'--password={settings.DATABASE_PASSWORD}',
                f'--databases={settings.DATABASE_NAME}',
                '--single-transaction',
                '--routines',
                '--triggers',
                f'--result-file={backup_file}'
            ]
            
            result = subprocess.run(command, capture_output=True, text=True)
            
            if result.returncode == 0:
                # Compress backup if enabled
                if schedule.get('compression', True):
                    compressed_file = await self._compress_backup(backup_file)
                    os.remove(backup_file)  # Remove uncompressed file
                    backup_file = compressed_file
                
                # Encrypt backup if enabled
                if schedule.get('encryption', True):
                    encrypted_file = await self._encrypt_backup(backup_file)
                    os.remove(backup_file)  # Remove unencrypted file
                    backup_file = encrypted_file
                
                return {
                    'success': True,
                    'backup_file': backup_file,
                    'size_mb': os.path.getsize(backup_file) / (1024 * 1024),
                    'compression': schedule.get('compression', True),
                    'encryption': schedule.get('encryption', True)
                }
            else:
                return {
                    'success': False,
                    'error': result.stderr,
                    'backup_file': backup_file
                }
        
        except Exception as e:
            logger.error(f"Error backing up database: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _backup_full_system(self, schedule: Dict) -> Dict:
        """Backup full system including files and database"""
        try:
            # Create full backup archive
            backup_dir = f"{self.backup_storage['local']['directory']}/temp/full_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
            os.makedirs(backup_dir, exist_ok=True)
            
            # Backup database
            db_result = await self._backup_database(schedule)
            
            # Backup important files
            files_to_backup = [
                '/farmos/config',
                '/farmos/uploads',
                '/farmos/logs',
                '/farmos/reports'
            ]
            
            file_backups = []
            for file_path in files_to_backup:
                if os.path.exists(file_path):
                    dest_path = f"{backup_dir}/files/{os.path.basename(file_path)}"
                    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
                    shutil.copytree(file_path, dest_path, ignore_errors=True)
                    file_backups.append(dest_path)
            
            # Create backup manifest
            manifest = {
                'backup_type': 'full',
                'created_at': datetime.utcnow().isoformat(),
                'database_backup': db_result,
                'file_backups': file_backups,
                'total_files': len(file_backups)
            }
            
            manifest_file = f"{backup_dir}/manifest.json"
            with open(manifest_file, 'w') as f:
                json.dump(manifest, f, indent=2)
            
            # Create compressed archive
            archive_file = f"{self.backup_storage['local']['directory']}/full_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.zip"
            
            with zipfile.ZipFile(archive_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for root, dirs, files in os.walk(backup_dir):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, backup_dir)
                        zipf.write(file_path, arcname)
            
            # Clean up temp directory
            shutil.rmtree(backup_dir)
            
            # Compress backup if enabled
            if schedule.get('compression', True):
                compressed_file = await self._compress_backup(archive_file)
                os.remove(archive_file)
                archive_file = compressed_file
            
            # Encrypt backup if enabled
            if schedule.get('encryption', True):
                encrypted_file = await self._encrypt_backup(archive_file)
                os.remove(archive_file)
                archive_file = encrypted_file
            
            return {
                'success': True,
                'backup_file': archive_file,
                'size_mb': os.path.getsize(archive_file) / (1024 * 1024),
                'database_backup': db_result,
                'file_backups': len(file_backups),
                'compression': schedule.get('compression', True),
                'encryption': schedule.get('encryption', True)
            }
        
        except Exception as e:
            logger.error(f"Error in full system backup: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _backup_archive(self, schedule: Dict) -> Dict:
        """Create archive backup"""
        try:
            # Create archive backup
            archive_dir = f"{self.backup_storage['local']['directory']}/temp/archive_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
            os.makedirs(archive_dir, exist_ok=True)
            
            # Copy old backups to archive
            source_dir = f"{self.backup_storage['local']['directory']}/database"
            if os.path.exists(source_dir):
                archive_files = [f for f in os.listdir(source_dir) if f.endswith('.sql') or f.endswith('.zip')]
                
                for file in archive_files[:10]:  # Archive last 10 files
                    shutil.copy2(os.path.join(source_dir, file), archive_dir)
            
            # Create archive manifest
            manifest = {
                'backup_type': 'archive',
                'created_at': datetime.utcnow().isoformat(),
                'archived_files': archive_files,
                'total_files': len(archive_files)
            }
            
            manifest_file = f"{archive_dir}/archive_manifest.json"
            with open(manifest_file, 'w') as f:
                json.dump(manifest, f, indent=2)
            
            # Create compressed archive
            archive_file = f"{self.backup_storage['local']['directory']}/archive_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.zip"
            
            with zipfile.ZipFile(archive_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for root, dirs, files in os.walk(archive_dir):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, archive_dir)
                        zipf.write(file_path, arcname)
            
            # Clean up temp directory
            shutil.rmtree(archive_dir)
            
            return {
                'success': True,
                'backup_file': archive_file,
                'size_mb': os.path.getsize(archive_file) / (1024 * 1024),
                'archived_files': len(archive_files),
                'compression': schedule.get('compression', True),
                'encryption': schedule.get('encryption', True)
            }
        
        except Exception as e:
            logger.error(f"Error in archive backup: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def _backup_incremental(self, schedule: Dict) -> Dict:
        """Create incremental backup"""
        try:
            # Get last full backup time
            last_full_backup = self._get_last_full_backup_time()
            
            # Create incremental backup
            backup_file = f"{self.backup_storage['local']['directory']}/incremental/inc_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.sql"
            
            # Use mysqldump with incremental options
            from ..common.config import settings
            
            command = [
                'mysqldump',
                f'--host={settings.DATABASE_HOST}',
                f'--user={settings.DATABASE_USER}',
                f'--password={settings.DATABASE_PASSWORD}',
                f'--databases={settings.DATABASE_NAME}',
                '--incremental',
                f'--flush-logs',
                f'--master-data=2',
                f'--result-file={backup_file}'
            ]
            
            result = subprocess.run(command, capture_output=True, text=True)
            
            if result.returncode == 0:
                return {
                    'success': True,
                    'backup_file': backup_file,
                    'size_mb': os.path.getsize(backup_file) / (1024 * 1024),
                    'type': 'incremental',
                    'last_full_backup': last_full_backup
                }
            else:
                return {
                    'success': False,
                    'error': result.stderr,
                    'backup_file': backup_file
                }
        
        except Exception as e:
            logger.error(f"Error in incremental backup: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _get_last_full_backup_time(self) -> Optional[datetime]:
        """Get the time of the last full backup"""
        try:
            backup_dir = f"{self.backup_storage['local']['directory']}/database"
            if not os.path.exists(backup_dir):
                return None
            
            # Find most recent full backup
            full_backups = [f for f in os.listdir(backup_dir) if f.startswith('full_backup_')]
            
            if not full_backups:
                return None
            
            latest_backup = max(full_backups)
            backup_path = os.path.join(backup_dir, latest_backup)
            
            # Extract timestamp from filename
            timestamp_str = latest_backup.replace('full_backup_', '').replace('.zip', '').replace('.sql', '')
            return datetime.strptime(timestamp_str, '%Y%m%d_%H%M%S')
        
        except Exception as e:
            logger.error(f"Error getting last full backup time: {e}")
            return None
    
    async def _compress_backup(self, file_path: str) -> str:
        """Compress backup file"""
        try:
            import gzip
            
            compressed_file = f"{file_path}.gz"
            
            with open(file_path, 'rb') as f_in:
                with gzip.open(compressed_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            return compressed_file
        
        except Exception as e:
            logger.error(f"Error compressing backup {file_path}: {e}")
            return file_path
    
    async def _encrypt_backup(self, file_path: str) -> str:
        """Encrypt backup file"""
        try:
            # Simple encryption using AES (in production, use proper encryption)
            from cryptography.fernet import Fernet
            
            # Generate or load encryption key
            key = Fernet.generate_key()
            
            # Encrypt file
            encrypted_file = f"{file_path}.enc"
            
            with open(file_path, 'rb') as f:
                data = f.read()
            
            fernet = Fernet(key)
            encrypted_data = fernet.encrypt(data)
            
            with open(encrypted_file, 'wb') as f:
                f.write(encrypted_data)
            
            # Store key securely (in production, this would be in a secure key store)
            key_file = f"{encrypted_file}.key"
            with open(key_file, 'wb') as f:
                f.write(key)
            
            return encrypted_file
        
        except Exception as e:
            logger.error(f"Error encrypting backup {file_path}: {e}")
            return file_path
    
    async def _log_backup_completion(self, backup_job: Dict):
        """Log backup completion to database"""
        try:
            # Create backup log entry
            log_entry = models.FinancialTransaction(
                tenant_id="default",
                type="backup",
                amount=0.0,
                category="system",
                description=f"Backup completed: {backup_job.get('schedule_name', 'Unknown')}",
                created_at=backup_job.get('completed_at', datetime.utcnow()),
                metadata={
                    "backup_id": backup_job.get('id'),
                    "schedule_id": backup_job.get('schedule_id'),
                    "backup_type": backup_job.get('type'),
                    "status": backup_job.get('status'),
                    "result": backup_job.get('result', {})
                }
            )
            
            db = next(get_db())
            db.add(log_entry)
            db.commit()
            
            logger.info(f"Backup completion logged: {backup_job.get('id')}")
        
        except Exception as e:
            logger.error(f"Error logging backup completion: {e}")
    
    def get_backup_status(self) -> Dict:
        """Get current backup service status"""
        return {
            "is_running": self.is_running,
            "backup_schedules": self.backup_schedules,
            "backup_storage": self.backup_storage,
            "active_jobs": len([job for job in self.backup_jobs.values() if job.get('status') == 'running']),
            "completed_jobs": len([job for job in self.backup_jobs.values() if job.get('status') == 'completed']),
            "last_update": datetime.utcnow().isoformat()
        }
    
    def get_backup_history(self, limit: int = 50) -> List[Dict]:
        """Get backup history"""
        try:
            # Get backup logs from database
            db = next(get_db())
            backup_logs = db.query(models.FinancialTransaction).filter(
                models.FinancialTransaction.type == 'backup'
            ).order_by(models.FinancialTransaction.created_at.desc()).limit(limit).all()
            
            history = []
            for log in backup_logs:
                history.append({
                    'id': log.id,
                    'backup_type': log.metadata.get('backup_type', 'unknown') if log.metadata else 'unknown',
                    'status': log.metadata.get('status', 'unknown') if log.metadata else 'unknown',
                    'created_at': log.created_at.isoformat() if log.created_at else None,
                    'description': log.description,
                    'result': log.metadata.get('result', {}) if log.metadata else {}
                })
            
            return history
        
        except Exception as e:
            logger.error(f"Error getting backup history: {e}")
            return []

# Global backup service instance
automated_backup_service = AutomatedBackupService()
