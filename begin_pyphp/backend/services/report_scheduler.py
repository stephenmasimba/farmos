"""
FarmOS Automated Reports Scheduling Service
Automated report generation and scheduling system
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class ReportScheduler:
    """Automated reports scheduling service"""
    
    def __init__(self):
        self.scheduled_reports = {}
        self.report_templates = {}
        self.delivery_methods = {}
        self.is_running = False
        self.scheduler_task = None
        
        # Initialize default report templates
        self._initialize_report_templates()
        self._initialize_delivery_methods()
    
    def _initialize_report_templates(self):
        """Initialize default report templates"""
        self.report_templates = {
            'daily_financial': {
                'name': 'Daily Financial Report',
                'description': 'Daily summary of income, expenses, and profit',
                'schedule': '0 6 * *',  # Daily at 6 AM
                'recipients': ['manager@farmos.local'],
                'template': 'daily_financial',
                'format': 'pdf'
            },
            'weekly_production': {
                'name': 'Weekly Production Report',
                'description': 'Weekly livestock and crop production summary',
                'schedule': '0 8 * *',  # Weekly on Monday at 8 AM
                'recipients': ['manager@farmos.local', 'supervisor@farmos.local'],
                'template': 'weekly_production',
                'format': 'pdf'
            },
            'monthly_inventory': {
                'name': 'Monthly Inventory Report',
                'description': 'Monthly inventory levels and stock movements',
                'schedule': '0 5 1 * *',  # Monthly on 1st at 5 AM
                'recipients': ['manager@farmos.local', 'inventory@farmos.local'],
                'template': 'monthly_inventory',
                'format': 'excel'
            },
            'monthly_performance': {
                'name': 'Monthly Performance Report',
                'description': 'Comprehensive monthly performance metrics',
                'schedule': '0 5 1 * *',  # Monthly on 1st at 5 AM
                'recipients': ['manager@farmos.local', 'owner@farmos.local'],
                'template': 'monthly_performance',
                'format': 'pdf'
            },
            'health_safety': {
                'name': 'Health & Safety Report',
                'description': 'Weekly health and safety compliance report',
                'schedule': '0 9 * *',  # Weekly on Monday at 9 AM
                'recipients': ['manager@farmos.local', 'safety_officer@farmos.local'],
                'template': 'health_safety',
                'format': 'pdf'
            },
            'regulatory_compliance': {
                'name': 'Regulatory Compliance Report',
                'description': 'Monthly regulatory compliance status',
                'schedule': '0 1 1 * *', # Monthly on 1st at 9 AM
                'recipients': ['manager@farmos.local', 'compliance@farmos.local'],
                'template': 'regulatory_compliance',
                'format': 'pdf'
            }
        }
    
    def _initialize_delivery_methods(self):
        """Initialize report delivery methods"""
        self.delivery_methods = {
            'email': {
                'enabled': True,
                'smtp_server': 'smtp.farmos.local',
                'smtp_port': 587,
                'smtp_username': 'reports@farmos.local',
                'smtp_password': 'password123',
                'from_email': 'noreply@farmos.local'
            },
            'webhook': {
                'enabled': True,
                'endpoints': [
                    'https://farmos.local/api/reports/webhook',
                    'https://external-system.com/api/reports'
                ]
            },
            'file_system': {
                'enabled': True,
                'directory': '/reports/generated/',
                'retention_days': 90
            },
            'api_download': {
                'enabled': True,
                'base_url': 'https://farmos.local/api/reports/download'
            }
        }
    
    async def start_scheduler(self):
        """Start the report scheduler"""
        try:
            if self.is_running:
                logger.warning("Report scheduler is already running")
                return
            
            self.is_running = True
            logger.info("Starting automated report scheduler")
            
            # Start the scheduling loop
            self.scheduler_task = asyncio.create_task(self._scheduling_loop())
            
            return {
                "status": "success",
                "message": "Report scheduler started",
                "started_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error starting report scheduler: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_scheduler(self):
        """Stop the report scheduler"""
        try:
            self.is_running = False
            
            if self.scheduler_task:
                self.scheduler_task.cancel()
                self.scheduler_task = None
            
            logger.info("Report scheduler stopped")
            
            return {
                "status": "success",
                "message": "Report scheduler stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error stopping report scheduler: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _scheduling_loop(self):
        """Main scheduling loop"""
        while self.is_running:
            try:
                # Check for scheduled reports
                current_time = datetime.utcnow()
                
                for report_id, report_config in self.scheduled_reports.items():
                    if self._should_generate_report(report_config, current_time):
                        await self._generate_and_deliver_report(report_id, report_config)
                
                # Wait for next check (60 seconds)
                await asyncio.sleep(60)
                
            except Exception as e:
                logger.error(f"Error in scheduling loop: {e}")
                await asyncio.sleep(60)
    
    def _should_generate_report(self, report_config: Dict, current_time: datetime) -> bool:
        """Check if report should be generated"""
        try:
            last_generated = report_config.get('last_generated')
            
            if not last_generated:
                return True
            
            # Calculate next scheduled time
            schedule = report_config.get('schedule', '0 6 * *')  # Default daily at 6 AM
            
            # Parse schedule (cron-like format)
            if '*' in schedule:
                parts = schedule.split('*')
                time_parts = parts[0].strip().split()
                hour, minute = map(int, time_parts[1].strip().split(':'))
            else:
                # Simple daily format
                hour, minute = 6, 0  # Default 6:00 AM
            
            next_run = current_time.replace(hour=hour, minute=minute, second=0, microsecond=0)
            
            # If next run has passed and report hasn't been generated today
            if current_time >= next_run and current_time.date() != last_generated.date():
                return True
            
            return False
            
        except Exception as e:
            logger.error(f"Error checking report schedule: {e}")
            return False
    
    async def _generate_and_deliver_report(self, report_id: str, report_config: Dict):
        """Generate and deliver a report"""
        try:
            logger.info(f"Generating report: {report_id}")
            
            # Generate report data
            report_data = await self._generate_report_data(report_config)
            
            # Generate report file
            report_file = await self._generate_report_file(report_id, report_data, report_config)
            
            # Deliver report
            delivery_results = await self._deliver_report(report_id, report_file, report_config)
            
            # Update last generated time
            report_config['last_generated'] = datetime.utcnow()
            
            # Log report generation
            await self._log_report_generation(report_id, report_data, delivery_results)
            
            logger.info(f"Report {report_id} generated and delivered successfully")
            
        except Exception as e:
            logger.error(f"Error generating report {report_id}: {e}")
            await self._log_report_generation(report_id, {}, {}, {'error': str(e)})
    
    async def _generate_report_data(self, report_config: Dict) -> Dict:
        """Generate report data based on template"""
        try:
            template_name = report_config.get('template')
            
            if template_name == 'daily_financial':
                return await self._generate_daily_financial_data()
            elif template_name == 'weekly_production':
                return await self._generate_weekly_production_data()
            elif template_name == 'monthly_inventory':
                return await self._generate_monthly_inventory_data()
            elif template_name == 'monthly_performance':
                return await self._generate_monthly_performance_data()
            elif template_name == 'health_safety':
                return await self._generate_health_safety_data()
            elif template_name == 'regulatory_compliance':
                return await self._generate_regulatory_compliance_data()
            else:
                return {'error': f'Unknown template: {template_name}'}
        
        except Exception as e:
            logger.error(f"Error generating report data: {e}")
            return {'error': str(e)}
    
    async def _generate_report_file(self, report_id: str, report_data: Dict, report_config: Dict) -> str:
        """Generate report file based on data and format"""
        try:
            template_name = report_config.get('template')
            format_type = report_config.get('format', 'pdf')
            
            # Generate file content based on template
            if format_type == 'pdf':
                file_content = await self._generate_pdf_report(report_id, report_data)
                file_extension = '.pdf'
            elif format_type == 'excel':
                file_content = await self._generate_excel_report(report_id, report_data)
                file_extension = '.xlsx'
            else:
                file_content = await self._generate_text_report(report_id, report_data)
                file_extension = '.txt'
            
            # Save file
            timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
            filename = f"{report_id}_{timestamp}{file_extension}"
            
            file_path = f"{self.delivery_methods['file_system']['directory']}{filename}"
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(file_content)
            
            logger.info(f"Report file generated: {file_path}")
            return file_path
            
        except Exception as e:
            logger.error(f"Error generating report file: {e}")
            raise
    
    async def _generate_pdf_report(self, report_id: str, report_data: Dict) -> str:
        """Generate PDF report content"""
        # This would use a PDF library like ReportLab
        # For now, return a simple HTML-based PDF structure
        html_content = f"""
        <html>
        <head>
            <title>{report_data.get('title', 'Report')}</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background-color: #f0f0f0; color: white; padding: 20px; text-align: center; }}
                .content {{ padding: 20px; }}
                .section {{ margin-bottom: 20px; }}
                .metric {{ margin-bottom: 10px; }}
                .value {{ font-size: 24px; font-weight: bold; color: #2c3e50; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>{report_data.get('title', 'Report')}</h1>
                <p>Generated on {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}</p>
            </div>
            <div class="content">
                {self._format_report_content(report_data)}
            </div>
        </body>
        </html>
        """
        
        return html_content
    
    async def _generate_excel_report(self, report_id: str, report_data: Dict) -> str:
        """Generate Excel report content"""
        # This would use a library like openpyxl
        # For now, return CSV format
        return self._generate_text_report(report_id, report_data)
    
    async def _generate_text_report(self, report_id: str, report_data: Dict) -> str:
        """Generate text report content"""
        content = f"""
        {report_data.get('title', 'Report')}
        Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}
        
        {'=' * 50}
        {self._format_report_content(report_data)}
        {'=' * 50}
        """
        
        return content
    
    def _format_report_content(self, report_data: Dict) -> str:
        """Format report data for display"""
        content = []
        
        for section, data in report_data.get('sections', {}).items():
            content.append(f"\n=== {section.upper()} ===\n")
            
            if isinstance(data, dict):
                for key, value in data.items():
                    content.append(f"{key}: {value}")
            elif isinstance(data, list):
                for item in data:
                    content.append(f"- {item}")
            else:
                content.append(str(data))
        
        return '\n'.join(content)
    
    async def _deliver_report(self, report_id: str, report_file_path: str, report_config: Dict) -> Dict:
        """Deliver report through configured methods"""
        results = {
            'email': {'success': False, 'message': ''},
            'webhook': {'success': False, 'message': ''},
            'file_system': {'success': True, 'file_path': file_file_path},
            'api_download': {'success': False, 'message': ''}
        }
        
        # Email delivery
        if self.delivery_methods['email']['enabled']:
            try:
                await self._deliver_via_email(report_id, report_file_path, report_config)
                results['email'] = {'success': True, 'message': 'Email sent successfully'}
            except Exception as e:
                results['email'] = {'success': False, 'message': f"Email failed: {str(e)}"}
        
        # Webhook delivery
        if self.delivery_methods['webhook']['enabled']:
            try:
                await self._deliver_via_webhook(report_id, report_file_path, report_config)
                results['webhook'] = {'success': True, 'message': 'Webhook sent successfully'}
            except Exception as e:
                results['webhook'] = {'success': False, 'message': f"Webhook failed: {str(e)}"}
        
        # API download
        if self.delivery_methods['api_download']['enabled']:
            try:
                await self._deliver_via_api(report_id, report_file_path, report_config)
                results['api_download'] = {'success': True, 'message': 'Download link available'}
            except Exception as e:
                results['api_download'] = {'success': False, 'message': f"API delivery failed: {str(e)}"}
        
        return results
    
    async def _deliver_via_email(self, report_id: str, file_path: str, report_config: Dict):
        """Deliver report via email"""
        try:
            import aiosmtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart
            from email.mime.base import MIMEBase64
            
            # Create email message
            msg = MIMEMultipart()
            msg['From'] = self.delivery_methods['email']['from_email']
            msg['To'] = ', '.join(report_config.get('recipients', []))
            msg['Subject'] = f"{report_config.get('name', 'Report')} - {datetime.utcnow().strftime('%Y-%m-%d')}"
            
            # Attach file
            with open(file_path, 'rb') as f:
                part = MIMEBase64('application/octet-stream')
                part.set_payload(f.read())
                part.add_header('Content-Disposition', f'attachment; filename="{os.path.basename(file_path)}"')
                msg.attach(part)
            
            # Add body
            body = MIMEText(f"""
                Dear User,
                
                Please find attached the {report_config.get('name', 'Report')} generated on {datetime.utcnow().strftime('%Y-%m-%d')}.
                
                Report Summary:
                {self._format_report_content(await self._generate_report_data(report_config))}
                
                The report file is saved at: {file_path}
                
                Best regards,
                FarmOS Team
            """)
            
            msg.attach(body)
            
            # Send email
            import smtplib
            server = smtplib.SMTP(
                host=self.delivery_methods['email']['smtp_server'],
                port=self.delivery_methods['email']['smtp_port'],
                username=self.delivery_methods['email']['smtp_username'],
                password=self.delivery_methods['email']['smtp_password']
            )
            
            server.send_message(msg)
            server.quit()
            
            logger.info(f"Email sent for report {report_id}")
            
        except Exception as e:
            logger.error(f"Error sending email: {e}")
            raise
    
    async def _deliver_via_webhook(self, report_id: str, file_path: str, report_config: Dict):
        """Deliver report via webhook"""
        try:
            import aiohttp
            
            # Prepare webhook payload
            payload = {
                'report_id': report_id,
                'report_name': report_config.get('name'),
                'generated_at': datetime.utcnow().isoformat(),
                'file_path': file_path,
                'file_size': os.path.getsize(file_path),
                'download_url': f"{self.delivery_methods['api_download']['base_url']}/download/{report_id}",
                'metadata': report_config.get('metadata', {})
            }
            
            # Send to all webhook endpoints
            for endpoint in self.delivery_methods['webhook']['endpoints']:
                try:
                    async with aiohttp.ClientSession() as session:
                        async with session.post(
                            endpoint,
                            json=payload,
                            timeout=aiohttp.ClientTimeout(total=30)
                        ) as response:
                            if response.status == 200:
                                logger.info(f"Webhook sent to {endpoint}: {report_id}")
                            else:
                                logger.warning(f"Webhook failed for {endpoint}: {response.status}")
                except Exception as e:
                    logger.error(f"Webhook error for {endpoint}: {e}")
            
        except Exception as e:
            logger.error(f"Error in webhook delivery: {e}")
    
    async def _deliver_via_api(self, report_id: str, file_path: str, report_config: Dict):
        """Make report available for API download"""
        # This would generate a secure download link
        # For now, just log the availability
        logger.info(f"Report {report_id} available for API download: {file_path}")
    
    async def _log_report_generation(self, report_id: str, report_data: Dict, delivery_results: Dict):
        """Log report generation in database"""
        try:
            # Create report log entry
            log_entry = models.FinancialTransaction(
                tenant_id="default",
                type="report_generation",
                amount=0.0,
                category="system",
                description=f"Automated report generated: {report_id}",
                created_at=datetime.utcnow()
            )
            
            db = next(get_db())
            db.add(log_entry)
            db.commit()
            
            logger.info(f"Report generation logged: {report_id}")
            
        except Exception as e:
            logger.error(f"Error logging report generation: {e}")
    
    async def _generate_daily_financial_data(self) -> Dict:
        """Generate daily financial report data"""
        try:
            # Get financial data for the last day
            # This would query the database
            # For now, return mock data
            
            return {
                'title': 'Daily Financial Report',
                'sections': {
                    'summary': {
                        'date': datetime.utcnow().strftime('%Y-%m-%d'),
                        'total_income': 2500.00,
                        'total_expenses': 1800.00,
                        'net_profit': 700.00,
                        'transaction_count': 15
                    },
                    'income_breakdown': {
                        'sales': 2000.00,
                        'services': 500.00
                    },
                    'expense_breakdown': {
                        'feed': 800.00,
                        'labor': 600.00,
                        'equipment': 200.00,
                        'other': 200.00
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error generating daily financial data: {e}")
            return {'error': str(e)}
    
    async def _generate_weekly_production_data(self) -> Dict:
        """Generate weekly production report data"""
        try:
            return {
                'title': 'Weekly Production Report',
                'sections': {
                    'livestock_summary': {
                        'total_batches': 8,
                        'total_animals': 1250,
                        'health_status': 'Good',
                        'average_growth_rate': 0.032
                    },
                    'production_metrics': {
                        'eggs_collected': 2500,
                        'weight_gain': 450kg,
                        'feed_efficiency': 2.2
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error generating weekly production data: {e}")
            return {'error': str(e)}
    
    async def _generate_monthly_inventory_data(self) -> Dict:
        """Generate monthly inventory report data"""
        try:
            return {
                'title': 'Monthly Inventory Report',
                'sections': {
                    'inventory_levels': {
                        'total_items': 150,
                        'low_stock_items': 12,
                        'out_of_stock_items': 3,
                        'total_value': 50000.00
                    },
                    'stock_movements': {
                        'items_in': 25,
                        'items_out': 18,
                        'adjustments': 5
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error generating monthly inventory data: {e}")
            return {'error': str(e)}
    
    async def _generate_monthly_performance_data(self) -> Dict:
        """Generate monthly performance report data"""
        try:
            return {
                'title': 'Monthly Performance Report',
                'sections': {
                    'overall_metrics': {
                        'efficiency_score': 0.82,
                        'profit_margin': 0.18,
                        'cost_per_unit': 0.82,
                        'revenue_per_animal': 120.00
                    },
                    'livestock_performance': {
                        'mortality_rate': 0.015,
                        'growth_rate': 0.034,
                        'feed_conversion': 2.8
                    },
                    'operational_metrics': {
                        'task_completion_rate': 0.85,
                        'equipment_uptime': 0.95,
                        'facility_utilization': 0.78
                    }
                }
            }
            }
            
        except Exception as e:
            logger.error(f"Error generating monthly performance data: {e}")
            return {'error': str(e)}
    
    async def _generate_health_safety_data(self) -> Dict:
        """Generate health and safety report data"""
        try:
            return {
                'title': 'Health & Safety Report',
                'sections': {
                    'health_incidents': {
                        'total_incidents': 2,
                        'resolved_incidents': 2,
                        'open_incidents': 0
                    },
                    'safety_metrics': {
                        'days_without_incident': 45,
                        'safety_score': 0.92,
                        'training_hours_completed': 8
                    },
                    'compliance_status': 'compliant'
                }
            }
            }
            
        except Exception as e:
            logger.error(f"Error generating health safety data: {e}")
            return {'error': str(e)}
    
    async def _generate_regulatory_compliance_data(self) -> Dict:
        """Generate regulatory compliance report data"""
        try:
            return {
                'title': 'Regulatory Compliance Report',
                'sections': {
                    'compliance_areas': {
                        'food_safety': 'compliant',
                        'animal_welfare': 'compliant',
                        'environmental': 'compliant',
                        'record_keeping': 'compliant'
                    },
                    'certifications': {
                        'valid_certificates': 12,
                        'expired_certificates': 1,
                        'pending_audits': 2
                    },
                    'inspections_passed': 5,
                    'violations': 0
                }
            }
            }
            
        except Exception as e:
            logger.error(f"Error generating regulatory compliance data: {e}")
            return {'error': str(e)}

# Global report scheduler instance
report_scheduler = ReportScheduler()
