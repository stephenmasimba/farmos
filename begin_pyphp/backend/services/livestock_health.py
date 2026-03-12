"""
FarmOS Livestock Health Monitoring Service
Automated health alerts and monitoring for livestock
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
from ..services.websocket_service import websocket_service

logger = logging.getLogger(__name__)

class LivestockHealthMonitor:
    """Health monitoring service for livestock"""
    
    def __init__(self):
        self.health_thresholds = {
            'temperature': {
                'poultry': {'min': 18.0, 'max': 24.0, 'optimal': 21.0},
                'pig': {'min': 15.0, 'max': 25.0, 'optimal': 20.0},
                'cattle': {'min': 10.0, 'max': 30.0, 'optimal': 20.0}
            },
            'humidity': {
                'poultry': {'min': 30.0, 'max': 70.0, 'optimal': 50.0},
                'pig': {'min': 40.0, 'max': 80.0, 'optimal': 60.0},
                'cattle': {'min': 30.0, 'max': 80.0, 'optimal': 55.0}
            },
            'weight': {
                'poultry': {'daily_gain_min': 0.025, 'daily_gain_optimal': 0.035},  # kg per day
                'pig': {'daily_gain_min': 0.5, 'daily_gain_optimal': 0.8},        # kg per day
                'cattle': {'daily_gain_min': 0.8, 'daily_gain_optimal': 1.2}       # kg per day
            },
            'mortality': {
                'poultry': {'max_daily_rate': 0.02},  # 2% per day
                'pig': {'max_daily_rate': 0.01},      # 1% per day
                'cattle': {'max_daily_rate': 0.005}    # 0.5% per day
            }
        }
        
        self.alert_cooldown = {}
        self.monitoring_active = False
    
    async def start_monitoring(self):
        """Start health monitoring service"""
        self.monitoring_active = True
        logger.info("Livestock health monitoring started")
        
        # Start monitoring loop
        asyncio.create_task(self._monitoring_loop())
    
    async def stop_monitoring(self):
        """Stop health monitoring service"""
        self.monitoring_active = False
        logger.info("Livestock health monitoring stopped")
    
    async def _monitoring_loop(self):
        """Main monitoring loop"""
        while self.monitoring_active:
            try:
                # Get database session
                db = next(get_db())
                
                # Check all active livestock batches
                active_batches = db.query(models.LivestockBatch).filter(
                    models.LivestockBatch.status == 'active'
                ).all()
                
                for batch in active_batches:
                    await self._check_batch_health(db, batch)
                
                db.close()
                
                # Wait before next check (5 minutes)
                await asyncio.sleep(300)
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                await asyncio.sleep(60)  # Wait 1 minute on error
    
    async def _check_batch_health(self, db: Session, batch: models.LivestockBatch):
        """Check health of individual livestock batch"""
        try:
            batch_id = batch.id
            livestock_type = batch.type.lower()
            
            # Get recent health events
            recent_events = db.query(models.LivestockEvent).filter(
                models.LivestockEvent.batch_id == batch_id,
                models.LivestockEvent.date >= datetime.utcnow() - timedelta(hours=24)
            ).all()
            
            # Analyze health data
            health_analysis = await self._analyze_health_data(db, batch, recent_events)
            
            # Check for health alerts
            alerts = await self._check_health_alerts(batch_id, livestock_type, health_analysis)
            
            # Send alerts via WebSocket
            for alert in alerts:
                await self._send_health_alert(batch.tenant_id, alert)
            
        except Exception as e:
            logger.error(f"Error checking batch {batch.id} health: {e}")
    
    async def _analyze_health_data(self, db: Session, batch: models.LivestockBatch, events: List[models.LivestockEvent]) -> Dict:
        """Analyze health data from recent events"""
        analysis = {
            'temperature_status': 'normal',
            'weight_gain_status': 'normal',
            'mortality_status': 'normal',
            'overall_health': 'good',
            'recommendations': []
        }
        
        if not events:
            return analysis
        
        # Extract health metrics from events
        temperature_readings = []
        weight_measurements = []
        mortality_events = []
        
        for event in events:
            if event.type == 'health_check':
                if 'temperature' in event.details:
                    temperature_readings.append(float(event.details['temperature']))
                if 'weight' in event.details:
                    weight_measurements.append(float(event.details['weight']))
            elif event.type == 'mortality':
                mortality_events.append(event)
        
        # Analyze temperature
        if temperature_readings:
            avg_temp = sum(temperature_readings) / len(temperature_readings)
            thresholds = self.health_thresholds['temperature'].get(batch.type.lower(), {})
            
            if avg_temp < thresholds['min'] or avg_temp > thresholds['max']:
                analysis['temperature_status'] = 'critical'
                analysis['recommendations'].append(
                    f"Temperature out of range: {avg_temp}°C (optimal: {thresholds['optimal']}°C)"
                )
            elif abs(avg_temp - thresholds['optimal']) > 2:
                analysis['temperature_status'] = 'warning'
                analysis['recommendations'].append(
                    f"Temperature suboptimal: {avg_temp}°C"
                )
        
        # Analyze weight gain
        if len(weight_measurements) > 1:
            # Calculate daily weight gain
            weight_gain = weight_measurements[-1] - weight_measurements[0]
            days_between = len(weight_measurements)  # Assuming daily measurements
            daily_gain = weight_gain / days_between if days_between > 0 else 0
            
            thresholds = self.health_thresholds['weight'].get(batch.type.lower(), {})
            
            if daily_gain < thresholds['daily_gain_min']:
                analysis['weight_gain_status'] = 'critical'
                analysis['recommendations'].append(
                    f"Low weight gain: {daily_gain:.3f}kg/day (optimal: {thresholds['daily_gain_optimal']}kg/day)"
                )
            elif daily_gain < thresholds['daily_gain_optimal'] * 0.8:
                analysis['weight_gain_status'] = 'warning'
                analysis['recommendations'].append(
                    f"Suboptimal weight gain: {daily_gain:.3f}kg/day"
                )
        
        # Analyze mortality
        if mortality_events:
            recent_mortality = len(mortality_events)
            total_quantity = batch.quantity or 0
            
            if total_quantity > 0:
                mortality_rate = recent_mortality / total_quantity
                thresholds = self.health_thresholds['mortality'].get(batch.type.lower(), {})
                
                if mortality_rate > thresholds['max_daily_rate']:
                    analysis['mortality_status'] = 'critical'
                    analysis['recommendations'].append(
                        f"High mortality rate: {mortality_rate:.2%} (max: {thresholds['max_daily_rate']:.2%})"
                    )
                elif mortality_rate > thresholds['max_daily_rate'] * 0.5:
                    analysis['mortality_status'] = 'warning'
                    analysis['recommendations'].append(
                        f"Elevated mortality rate: {mortality_rate:.2%}"
                    )
        
        # Determine overall health
        critical_count = sum([
            1 for status in [analysis['temperature_status'], analysis['weight_gain_status'], analysis['mortality_status']]
            if status == 'critical'
        ])
        
        warning_count = sum([
            1 for status in [analysis['temperature_status'], analysis['weight_gain_status'], analysis['mortality_status']]
            if status == 'warning'
        ])
        
        if critical_count > 0:
            analysis['overall_health'] = 'critical'
        elif critical_count == 0 and warning_count > 1:
            analysis['overall_health'] = 'warning'
        elif critical_count == 0 and warning_count == 1:
            analysis['overall_health'] = 'fair'
        else:
            analysis['overall_health'] = 'good'
        
        return analysis
    
    async def _check_health_alerts(self, batch_id: int, livestock_type: str, health_analysis: Dict) -> List[Dict]:
        """Check for health alerts based on analysis"""
        alerts = []
        current_time = datetime.utcnow()
        
        # Check cooldown period
        cooldown_key = f"health_alert_{batch_id}"
        if cooldown_key in self.alert_cooldown:
            last_alert_time = self.alert_cooldown[cooldown_key]
            if (current_time - last_alert_time).seconds < 1800:  # 30 minutes cooldown
                return alerts
        
        # Generate alerts based on health analysis
        if health_analysis['overall_health'] == 'critical':
            alerts.append({
                'type': 'health_critical',
                'batch_id': batch_id,
                'livestock_type': livestock_type,
                'message': f"Critical health issues detected in {livestock_type}",
                'recommendations': health_analysis['recommendations'],
                'priority': 'high',
                'timestamp': current_time.isoformat(),
                'requires_immediate_action': True
            })
        
        elif health_analysis['overall_health'] == 'warning':
            alerts.append({
                'type': 'health_warning',
                'batch_id': batch_id,
                'livestock_type': livestock_type,
                'message': f"Health warnings for {livestock_type}",
                'recommendations': health_analysis['recommendations'],
                'priority': 'medium',
                'timestamp': current_time.isoformat(),
                'requires_immediate_action': False
            })
        
        # Set cooldown
        if alerts:
            self.alert_cooldown[cooldown_key] = current_time
        
        return alerts
    
    async def _send_health_alert(self, tenant_id: str, alert: Dict):
        """Send health alert via WebSocket"""
        try:
            await websocket_service.send_notification(tenant_id, {
                'title': 'Livestock Health Alert',
                'message': alert['message'],
                'type': 'health_alert',
                'priority': alert['priority'],
                'data': alert,
                'actions': [
                    {
                        'label': 'View Batch Details',
                        'url': f'/livestock?batch_id={alert["batch_id"]}'
                    },
                    {
                        'label': 'Health Check',
                        'url': f'/livestock?batch_id={alert["batch_id"]}&action=health_check'
                    }
                ]
            })
            
            logger.info(f"Health alert sent for tenant {tenant_id}: {alert['type']}")
            
        except Exception as e:
            logger.error(f"Error sending health alert: {e}")
    
    async def get_health_summary(self, db: Session, tenant_id: str) -> Dict:
        """Get overall health summary for dashboard"""
        try:
            # Get all active batches for tenant
            active_batches = db.query(models.LivestockBatch).filter(
                models.LivestockBatch.tenant_id == tenant_id,
                models.LivestockBatch.status == 'active'
            ).all()
            
            health_summary = {
                'total_batches': len(active_batches),
                'healthy_batches': 0,
                'warning_batches': 0,
                'critical_batches': 0,
                'total_animals': sum(batch.quantity or 0 for batch in active_batches),
                'health_issues': []
            }
            
            # Analyze each batch
            for batch in active_batches:
                # Get recent events for this batch
                recent_events = db.query(models.LivestockEvent).filter(
                    models.LivestockEvent.batch_id == batch.id,
                    models.LivestockEvent.date >= datetime.utcnow() - timedelta(hours=24)
                ).all()
                
                health_analysis = await self._analyze_health_data(db, batch, recent_events)
                
                # Update counters
                if health_analysis['overall_health'] == 'good':
                    health_summary['healthy_batches'] += 1
                elif health_analysis['overall_health'] == 'warning':
                    health_summary['warning_batches'] += 1
                elif health_analysis['overall_health'] == 'critical':
                    health_summary['critical_batches'] += 1
                
                # Add health issues
                if health_analysis['recommendations']:
                    health_summary['health_issues'].extend(health_analysis['recommendations'])
            
            # Calculate health score
            if health_summary['total_batches'] > 0:
                health_score = (
                    (health_summary['healthy_batches'] * 100) +
                    (health_summary['warning_batches'] * 50) +
                    (health_summary['critical_batches'] * 0)
                ) / health_summary['total_batches']
            else:
                health_score = 100
            
            health_summary['health_score'] = round(health_score, 1)
            health_summary['last_check'] = datetime.utcnow().isoformat()
            
            return health_summary
            
        except Exception as e:
            logger.error(f"Error getting health summary: {e}")
            return {
                'total_batches': 0,
                'healthy_batches': 0,
                'warning_batches': 0,
                'critical_batches': 0,
                'total_animals': 0,
                'health_score': 0,
                'health_issues': [],
                'last_check': datetime.utcnow().isoformat()
            }

# Global health monitor instance
livestock_health_monitor = LivestockHealthMonitor()
