"""
Water Management Module - Phase 2 Feature
Handles pump automation, water usage tracking, and irrigation management
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

class WaterManagementService:
    """Water management service for pump automation and irrigation"""
    
    def __init__(self):
        self.water_systems = {}
        self.pump_controllers = {}
        self.irrigation_schedules = {}
        self.water_usage_data = {}
        self.is_running = False
        
        # Initialize water management modules
        self._initialize_water_systems()
        self._initialize_pump_controllers()
        self._initialize_irrigation_schedules()
        
    def _initialize_water_systems(self):
        """Initialize water system configurations"""
        self.water_systems = {
            'borehole_pumps': {
                'name': 'Borehole Water Pumps',
                'description': 'Main water extraction from boreholes',
                'pumps': [
                    {
                        'id': 'pump_001',
                        'name': 'Main Borehole Pump',
                        'capacity': '5000 L/hour',
                        'status': 'active',
                        'power_source': 'solar',
                        'flow_rate': 0,
                        'pressure': 0,
                        'runtime_today': 0
                    },
                    {
                        'id': 'pump_002', 
                        'name': 'Backup Borehole Pump',
                        'capacity': '3000 L/hour',
                        'status': 'standby',
                        'power_source': 'solar_battery',
                        'flow_rate': 0,
                        'pressure': 0,
                        'runtime_today': 0
                    }
                ],
                'total_capacity': '8000 L/hour',
                'auto_switch_enabled': True
            },
            'storage_tanks': {
                'name': 'Water Storage Tanks',
                'description': 'Water storage and distribution',
                'tanks': [
                    {
                        'id': 'tank_001',
                        'name': 'Main Storage Tank',
                        'capacity': 50000,
                        'current_level': 35000,
                        'level_percentage': 70,
                        'last_filled': datetime.utcnow() - timedelta(hours=6),
                        'temperature': 22.5
                    },
                    {
                        'id': 'tank_002',
                        'name': 'Backup Storage Tank', 
                        'capacity': 25000,
                        'current_level': 18000,
                        'level_percentage': 72,
                        'last_filled': datetime.utcnow() - timedelta(hours=12),
                        'temperature': 21.8
                    }
                ]
            },
            'irrigation_systems': {
                'name': 'Irrigation Distribution',
                'description': 'Crop irrigation and livestock water distribution',
                'zones': [
                    {
                        'id': 'zone_001',
                        'name': 'Crop Field Irrigation',
                        'type': 'drip_irrigation',
                        'area': '2.5 hectares',
                        'crop_type': 'vegetables',
                        'water_requirement': 1500,  # L/day
                        'last_irrigated': datetime.utcnow() - timedelta(hours=8),
                        'valve_status': 'closed',
                        'flow_rate': 0
                    },
                    {
                        'id': 'zone_002',
                        'name': 'Livestock Water Points',
                        'type': 'distribution_points',
                        'area': 'livestock housing',
                        'water_requirement': 2000,  # L/day
                        'last_filled': datetime.utcnow() - timedelta(hours=2),
                        'valve_status': 'open',
                        'flow_rate': 85
                    },
                    {
                        'id': 'zone_003',
                        'name': 'Aquaculture System',
                        'type': 'recirculating',
                        'area': 'fish ponds',
                        'water_requirement': 3000,  # L/day
                        'last_circulation': datetime.utcnow() - timedelta(minutes=30),
                        'pump_status': 'running',
                        'flow_rate': 125
                    }
                ]
            }
        }
    
    def _initialize_pump_controllers(self):
        """Initialize pump control systems"""
        self.pump_controllers = {
            'automation_rules': [
                {
                    'id': 'auto_001',
                    'name': 'Tank Level Auto-Fill',
                    'description': 'Automatically fill tanks when level drops below 30%',
                    'condition': 'tank_level < 30',
                    'action': 'start_pump',
                    'pump_id': 'pump_001',
                    'enabled': True,
                    'priority': 'high'
                },
                {
                    'id': 'auto_002',
                    'name': 'Peak Hour Optimization',
                    'description': 'Optimize pumping during solar peak hours',
                    'condition': 'solar_output > 80% AND tank_level < 60',
                    'action': 'start_pump',
                    'pump_id': 'pump_001',
                    'enabled': True,
                    'priority': 'medium'
                },
                {
                    'id': 'auto_003',
                    'name': 'Emergency Backup',
                    'description': 'Switch to backup pump if main fails',
                    'condition': 'pump_001_status = failed',
                    'action': 'switch_pump',
                    'pump_id': 'pump_002',
                    'enabled': True,
                    'priority': 'critical'
                }
            ],
            'safety_limits': {
                'max_runtime_hours': 8,  # Maximum continuous runtime
                'min_pressure': 1.5,  # Bar
                'max_pressure': 4.0,  # Bar
                'max_flow_rate': 5000,  # L/hour
                'auto_shutdown_enabled': True
            }
        }
    
    def _initialize_irrigation_schedules(self):
        """Initialize irrigation scheduling"""
        self.irrigation_schedules = {
            'crop_irrigation': [
                {
                    'id': 'schedule_001',
                    'zone_id': 'zone_001',
                    'name': 'Morning Vegetable Irrigation',
                    'time': '06:00',
                    'duration': 120,  # minutes
                    'frequency': 'daily',
                    'water_amount': 1500,
                    'enabled': True,
                    'weather_adjustment': True,
                    'soil_moisture_threshold': 30
                },
                {
                    'id': 'schedule_002',
                    'zone_id': 'zone_001', 
                    'name': 'Evening Vegetable Irrigation',
                    'time': '18:00',
                    'duration': 90,
                    'frequency': 'daily',
                    'water_amount': 1000,
                    'enabled': True,
                    'weather_adjustment': True,
                    'soil_moisture_threshold': 40
                }
            ],
            'livestock_water': [
                {
                    'id': 'schedule_003',
                    'zone_id': 'zone_002',
                    'name': 'Livestock Water Refresh',
                    'time': '04:00',
                    'duration': 60,
                    'frequency': 'twice_daily',
                    'water_amount': 2000,
                    'enabled': True,
                    'quality_check': True
                }
            ],
            'aquaculture_circulation': [
                {
                    'id': 'schedule_004',
                    'zone_id': 'zone_003',
                    'name': 'Fish Pond Circulation',
                    'time': 'continuous',
                    'duration': 1440,  # 24 hours
                    'frequency': 'continuous',
                    'water_amount': 3000,
                    'enabled': True,
                    'oxygen_monitoring': True
                }
            ]
        }
    
    async def start_water_management(self):
        """Start water management service"""
        try:
            if self.is_running:
                logger.warning("Water management service is already running")
                return
            
            self.is_running = True
            logger.info("Starting water management service")
            
            # Start pump monitoring
            await self._start_pump_monitoring()
            
            # Start irrigation scheduling
            await self._start_irrigation_scheduling()
            
            # Start water usage tracking
            await self._start_water_usage_tracking()
            
            return {
                "status": "success",
                "message": "Water management service started",
                "started_at": datetime.utcnow().isoformat(),
                "active_pumps": len([p for p in self.water_systems['borehole_pumps']['pumps'] if p['status'] == 'active']),
                "irrigation_zones": len(self.water_systems['irrigation_systems']['zones'])
            }
        
        except Exception as e:
            logger.error(f"Error starting water management service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _start_pump_monitoring(self):
        """Monitor pump performance and status"""
        while self.is_running:
            try:
                # Simulate pump monitoring
                for pump in self.water_systems['borehole_pumps']['pumps']:
                    if pump['status'] == 'active':
                        # Update pump metrics
                        pump['flow_rate'] = 85 + (hash(pump['id']) % 20)  # Simulated flow rate
                        pump['pressure'] = 2.5 + (hash(pump['id']) % 1.5)  # Simulated pressure
                        pump['runtime_today'] += 1  # Increment runtime
                        
                        # Check safety limits
                        await self._check_pump_safety(pump)
                
                await asyncio.sleep(60)  # Check every minute
                
            except Exception as e:
                logger.error(f"Error in pump monitoring: {e}")
                await asyncio.sleep(60)
    
    async def _check_pump_safety(self, pump: Dict):
        """Check pump safety parameters"""
        safety = self.pump_controllers['safety_limits']
        
        # Check runtime limits
        if pump['runtime_today'] > safety['max_runtime_hours'] * 60:
            logger.warning(f"Pump {pump['id']} exceeded maximum runtime")
            await self._emergency_stop_pump(pump['id'], 'Runtime limit exceeded')
        
        # Check pressure limits
        if pump['pressure'] < safety['min_pressure'] or pump['pressure'] > safety['max_pressure']:
            logger.warning(f"Pump {pump['id']} pressure out of range: {pump['pressure']} bar")
            await self._emergency_stop_pump(pump['id'], 'Pressure out of range')
        
        # Check flow rate limits
        if pump['flow_rate'] > safety['max_flow_rate']:
            logger.warning(f"Pump {pump['id']} flow rate too high: {pump['flow_rate']} L/h")
            await self._emergency_stop_pump(pump['id'], 'Flow rate exceeded')
    
    async def _emergency_stop_pump(self, pump_id: str, reason: str):
        """Emergency stop pump"""
        for pump in self.water_systems['borehole_pumps']['pumps']:
            if pump['id'] == pump_id:
                pump['status'] = 'emergency_stopped'
                pump['flow_rate'] = 0
                pump['pressure'] = 0
                logger.error(f"Emergency stop pump {pump_id}: {reason}")
                
                # Trigger backup pump if available
                if reason != 'Runtime limit exceeded':
                    await self._activate_backup_pump(pump_id)
                break
    
    async def _activate_backup_pump(self, failed_pump_id: str):
        """Activate backup pump"""
        backup_rules = [rule for rule in self.pump_controllers['automation_rules'] 
                      if rule['id'] == 'auto_003' and rule['enabled']]
        
        if backup_rules:
            backup_pump_id = backup_rules[0]['pump_id']
            for pump in self.water_systems['borehole_pumps']['pumps']:
                if pump['id'] == backup_pump_id and pump['status'] == 'standby':
                    pump['status'] = 'active'
                    logger.info(f"Activated backup pump {backup_pump_id}")
                    break
    
    async def _start_irrigation_scheduling(self):
        """Manage irrigation schedules"""
        while self.is_running:
            try:
                current_time = datetime.utcnow().time()
                
                # Check all schedules
                for schedule_type, schedules in self.irrigation_schedules.items():
                    for schedule in schedules:
                        if schedule['enabled']:
                            await self._check_and_execute_schedule(schedule, current_time)
                
                await asyncio.sleep(300)  # Check every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in irrigation scheduling: {e}")
                await asyncio.sleep(300)
    
    async def _check_and_execute_schedule(self, schedule: Dict, current_time):
        """Check and execute irrigation schedule"""
        schedule_time = datetime.strptime(schedule['time'], '%H:%M').time()
        
        # Check if it's time to run
        if (current_time.hour == schedule_time.hour and 
            current_time.minute >= schedule_time.minute and
            current_time.minute < schedule_time.minute + 5):
            
            logger.info(f"Executing irrigation schedule: {schedule['name']}")
            await self._execute_irrigation(schedule)
    
    async def _execute_irrigation(self, schedule: Dict):
        """Execute irrigation for a zone"""
        zone_id = schedule['zone_id']
        
        # Find the zone
        for zone in self.water_systems['irrigation_systems']['zones']:
            if zone['id'] == zone_id:
                # Simulate irrigation
                zone['valve_status'] = 'open'
                zone['flow_rate'] = schedule['water_amount'] / (schedule['duration'] / 60)  # L/min
                
                # Log irrigation event
                logger.info(f"Irrigation started for {zone['name']}: {schedule['water_amount']}L over {schedule['duration']}min")
                
                # Schedule valve closure after duration
                asyncio.create_task(self._close_irrigation_valve(zone_id, schedule['duration']))
                break
    
    async def _close_irrigation_valve(self, zone_id: str, delay_minutes: int):
        """Close irrigation valve after specified duration"""
        await asyncio.sleep(delay_minutes * 60)
        
        for zone in self.water_systems['irrigation_systems']['zones']:
            if zone['id'] == zone_id:
                zone['valve_status'] = 'closed'
                zone['flow_rate'] = 0
                zone['last_irrigated'] = datetime.utcnow()
                logger.info(f"Irrigation completed for {zone['name']}")
                break
    
    async def _start_water_usage_tracking(self):
        """Track water usage and generate reports"""
        while self.is_running:
            try:
                # Calculate daily water usage
                daily_usage = await self._calculate_daily_usage()
                
                # Update water usage data
                today = datetime.utcnow().date()
                self.water_usage_data[str(today)] = {
                    'total_usage': daily_usage,
                    'pump_runtime': sum(p['runtime_today'] for p in self.water_systems['borehole_pumps']['pumps']),
                    'irrigation_usage': daily_usage * 0.6,  # 60% for irrigation
                    'livestock_usage': daily_usage * 0.25,  # 25% for livestock
                    'aquaculture_usage': daily_usage * 0.15,  # 15% for aquaculture
                    'efficiency_score': await self._calculate_water_efficiency(),
                    'timestamp': datetime.utcnow()
                }
                
                await asyncio.sleep(3600)  # Update every hour
                
            except Exception as e:
                logger.error(f"Error in water usage tracking: {e}")
                await asyncio.sleep(3600)
    
    async def _calculate_daily_usage(self) -> float:
        """Calculate total daily water usage"""
        total_usage = 0
        
        # Sum pump usage
        for pump in self.water_systems['borehole_pumps']['pumps']:
            if pump['status'] == 'active':
                total_usage += pump['flow_rate']  # L/hour
        
        # Add irrigation usage
        for zone in self.water_systems['irrigation_systems']['zones']:
            if zone['valve_status'] == 'open':
                total_usage += zone['flow_rate']  # L/min
        
        return total_usage
    
    async def _calculate_water_efficiency(self) -> float:
        """Calculate water efficiency score"""
        # Simulate efficiency calculation based on various factors
        base_efficiency = 85.0
        
        # Adjust for tank levels (optimal range 60-80%)
        tank_levels = [tank['level_percentage'] for tank in self.water_systems['storage_tanks']['tanks']]
        avg_tank_level = sum(tank_levels) / len(tank_levels)
        
        if 60 <= avg_tank_level <= 80:
            efficiency_bonus = 5.0
        else:
            efficiency_bonus = -2.0
        
        # Adjust for pump performance
        active_pumps = len([p for p in self.water_systems['borehole_pumps']['pumps'] if p['status'] == 'active'])
        if active_pumps == 1:
            efficiency_bonus += 3.0  # Optimal single pump operation
        elif active_pumps > 1:
            efficiency_bonus -= 2.0  # Multiple pumps less efficient
        
        return min(100.0, base_efficiency + efficiency_bonus)
    
    async def get_water_status(self) -> Dict:
        """Get current water system status"""
        try:
            return {
                'pumps': self.water_systems['borehole_pumps'],
                'storage_tanks': self.water_systems['storage_tanks'],
                'irrigation_zones': self.water_systems['irrigation_systems'],
                'automation_rules': self.pump_controllers['automation_rules'],
                'daily_usage': self.water_usage_data.get(str(datetime.utcnow().date()), {}),
                'efficiency_score': await self._calculate_water_efficiency(),
                'system_status': 'operational' if self.is_running else 'stopped',
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting water status: {e}")
            return {
                'error': str(e),
                'system_status': 'error'
            }
    
    async def control_pump(self, pump_id: str, action: str, parameters: Dict = None) -> Dict:
        """Control pump operations"""
        try:
            for pump in self.water_systems['borehole_pumps']['pumps']:
                if pump['id'] == pump_id:
                    if action == 'start':
                        pump['status'] = 'active'
                        pump['flow_rate'] = parameters.get('flow_rate', 100) if parameters else 100
                        logger.info(f"Started pump {pump_id}")
                    
                    elif action == 'stop':
                        pump['status'] = 'standby'
                        pump['flow_rate'] = 0
                        pump['pressure'] = 0
                        logger.info(f"Stopped pump {pump_id}")
                    
                    elif action == 'set_flow_rate':
                        if parameters and 'flow_rate' in parameters:
                            pump['flow_rate'] = parameters['flow_rate']
                            logger.info(f"Set pump {pump_id} flow rate to {parameters['flow_rate']} L/h")
                    
                    return {
                        'success': True,
                        'pump_id': pump_id,
                        'action': action,
                        'pump_status': pump['status']
                    }
            
            return {
                'success': False,
                'error': f'Pump {pump_id} not found'
            }
        
        except Exception as e:
            logger.error(f"Error controlling pump {pump_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def set_irrigation_schedule(self, schedule_data: Dict) -> Dict:
        """Set or update irrigation schedule"""
        try:
            schedule_id = schedule_data.get('id', f"schedule_{datetime.utcnow().timestamp()}")
            
            # Update existing schedule or create new one
            for schedule_type, schedules in self.irrigation_schedules.items():
                for i, schedule in enumerate(schedules):
                    if schedule['id'] == schedule_id:
                        schedules[i] = {**schedule, **schedule_data}
                        logger.info(f"Updated irrigation schedule {schedule_id}")
                        return {
                            'success': True,
                            'schedule_id': schedule_id,
                            'action': 'updated'
                        }
            
            # Create new schedule
            new_schedule = {
                'id': schedule_id,
                'zone_id': schedule_data['zone_id'],
                'name': schedule_data['name'],
                'time': schedule_data['time'],
                'duration': schedule_data['duration'],
                'frequency': schedule_data['frequency'],
                'water_amount': schedule_data['water_amount'],
                'enabled': schedule_data.get('enabled', True),
                'weather_adjustment': schedule_data.get('weather_adjustment', False),
                'created_at': datetime.utcnow().isoformat()
            }
            
            # Add to appropriate schedule type
            if 'crop' in schedule_data.get('zone_id', '').lower():
                self.irrigation_schedules['crop_irrigation'].append(new_schedule)
            elif 'livestock' in schedule_data.get('zone_id', '').lower():
                self.irrigation_schedules['livestock_water'].append(new_schedule)
            else:
                self.irrigation_schedules['aquaculture_circulation'].append(new_schedule)
            
            logger.info(f"Created new irrigation schedule {schedule_id}")
            return {
                'success': True,
                'schedule_id': schedule_id,
                'action': 'created'
            }
        
        except Exception as e:
            logger.error(f"Error setting irrigation schedule: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def get_water_reports(self, period: str = 'daily') -> Dict:
        """Generate water management reports"""
        try:
            # Generate mock report data
            reports = {
                'daily': {
                    'period': 'Last 24 hours',
                    'total_usage': 12500,  # Liters
                    'pump_runtime': 8.5,  # Hours
                    'efficiency_score': 87.5,
                    'cost_estimate': 2.50,  # USD (solar energy cost)
                    'irrigation_usage': 7500,
                    'livestock_usage': 3125,
                    'aquaculture_usage': 1875,
                    'breakdown': {
                        'borehole_pumping': 65,
                        'storage_losses': 5,
                        'distribution_efficiency': 30
                    }
                },
                'weekly': {
                    'period': 'Last 7 days',
                    'total_usage': 87500,
                    'pump_runtime': 59.5,
                    'efficiency_score': 85.2,
                    'cost_estimate': 17.50,
                    'trend': '+5.2%',
                    'peak_usage_day': 'Wednesday',
                    'lowest_usage_day': 'Sunday'
                },
                'monthly': {
                    'period': 'Last 30 days',
                    'total_usage': 375000,
                    'pump_runtime': 255,
                    'efficiency_score': 83.8,
                    'cost_estimate': 75.00,
                    'trend': '+12.5%',
                    'comparison_to_target': '+8.3%',
                    'recommendations': [
                        'Optimize irrigation timing during solar peak hours',
                        'Consider tank level adjustments for better efficiency',
                        'Schedule pump maintenance for optimal performance'
                    ]
                }
            }
            
            return {
                'success': True,
                'report': reports.get(period, reports['daily']),
                'generated_at': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error generating water reports: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def stop_water_management(self):
        """Stop water management service"""
        try:
            self.is_running = False
            
            # Stop all pumps
            for pump in self.water_systems['borehole_pumps']['pumps']:
                if pump['status'] == 'active':
                    pump['status'] = 'standby'
                    pump['flow_rate'] = 0
                    pump['pressure'] = 0
            
            # Close all irrigation valves
            for zone in self.water_systems['irrigation_systems']['zones']:
                zone['valve_status'] = 'closed'
                zone['flow_rate'] = 0
            
            logger.info("Water management service stopped")
            
            return {
                "status": "success",
                "message": "Water management service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping water management service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }

# Global water management service instance
water_management_service = WaterManagementService()
