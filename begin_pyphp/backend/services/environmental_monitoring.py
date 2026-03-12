"""
Environmental Sensors Module - Phase 2 Feature
Handles temperature, humidity, pH, ammonia, and other environmental monitoring
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from ..common.database import get_db
from ..common import models
import json
import random
import math

logger = logging.getLogger(__name__)

class EnvironmentalMonitoringService:
    """Environmental monitoring service for farm conditions"""
    
    def __init__(self):
        self.sensor_networks = {}
        self.sensor_data = {}
        self.alert_thresholds = {}
        self.automation_rules = {}
        self.is_running = False
        
        # Initialize sensor networks
        self._initialize_temperature_sensors()
        self._initialize_humidity_sensors()
        self._initialize_ph_sensors()
        self._initialize_ammonia_sensors()
        self._initialize_air_quality_sensors()
        self._initialize_soil_sensors()
        self._initialize_alert_thresholds()
        self._initialize_automation_rules()
        
    def _initialize_temperature_sensors(self):
        """Initialize temperature monitoring sensors"""
        self.sensor_networks['temperature'] = {
            'name': 'Temperature Monitoring Network',
            'description': 'Temperature sensors across all farm areas',
            'sensors': [
                {
                    'id': 'temp_001',
                    'name': 'Poultry House 1 - Ambient',
                    'location': 'poultry_house_1',
                    'type': 'ambient_temperature',
                    'range': '-10 to 50°C',
                    'accuracy': '±0.5°C',
                    'current_reading': 28.5,
                    'optimal_range': {'min': 20, 'max': 30},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=30),
                    'battery_level': 85
                },
                {
                    'id': 'temp_002',
                    'name': 'Poultry House 1 - Core',
                    'location': 'poultry_house_1',
                    'type': 'core_temperature',
                    'range': '-10 to 50°C',
                    'accuracy': '±0.3°C',
                    'current_reading': 29.2,
                    'optimal_range': {'min': 21, 'max': 29},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=30),
                    'battery_level': 92
                },
                {
                    'id': 'temp_003',
                    'name': 'Piggery - Ambient',
                    'location': 'piggery',
                    'type': 'ambient_temperature',
                    'range': '-10 to 50°C',
                    'accuracy': '±0.5°C',
                    'current_reading': 26.8,
                    'optimal_range': {'min': 18, 'max': 28},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=45),
                    'battery_level': 78
                },
                {
                    'id': 'temp_004',
                    'name': 'Aquaculture Pond 1',
                    'location': 'aquaculture_pond_1',
                    'type': 'water_temperature',
                    'range': '0 to 40°C',
                    'accuracy': '±0.2°C',
                    'current_reading': 26.5,
                    'optimal_range': {'min': 24, 'max': 30},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=15),
                    'battery_level': 88
                },
                {
                    'id': 'temp_005',
                    'name': 'Greenhouse - Ambient',
                    'location': 'greenhouse',
                    'type': 'ambient_temperature',
                    'range': '-10 to 50°C',
                    'accuracy': '±0.5°C',
                    'current_reading': 31.2,
                    'optimal_range': {'min': 22, 'max': 32},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=20),
                    'battery_level': 95
                }
            ]
        }
    
    def _initialize_humidity_sensors(self):
        """Initialize humidity monitoring sensors"""
        self.sensor_networks['humidity'] = {
            'name': 'Humidity Monitoring Network',
            'description': 'Relative humidity sensors for environmental control',
            'sensors': [
                {
                    'id': 'humid_001',
                    'name': 'Poultry House 1',
                    'location': 'poultry_house_1',
                    'type': 'relative_humidity',
                    'range': '0 to 100% RH',
                    'accuracy': '±3% RH',
                    'current_reading': 65.5,
                    'optimal_range': {'min': 50, 'max': 70},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=30),
                    'battery_level': 82
                },
                {
                    'id': 'humid_002',
                    'name': 'Piggery',
                    'location': 'piggery',
                    'type': 'relative_humidity',
                    'range': '0 to 100% RH',
                    'accuracy': '±3% RH',
                    'current_reading': 72.3,
                    'optimal_range': {'min': 60, 'max': 80},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=45),
                    'battery_level': 75
                },
                {
                    'id': 'humid_003',
                    'name': 'Greenhouse',
                    'location': 'greenhouse',
                    'type': 'relative_humidity',
                    'range': '0 to 100% RH',
                    'accuracy': '±3% RH',
                    'current_reading': 78.5,
                    'optimal_range': {'min': 65, 'max': 85},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=20),
                    'battery_level': 90
                }
            ]
        }
    
    def _initialize_ph_sensors(self):
        """Initialize pH monitoring sensors"""
        self.sensor_networks['ph'] = {
            'name': 'pH Monitoring Network',
            'description': 'pH sensors for water and soil monitoring',
            'sensors': [
                {
                    'id': 'ph_001',
                    'name': 'Aquaculture Pond 1',
                    'location': 'aquaculture_pond_1',
                    'type': 'water_ph',
                    'range': '0 to 14 pH',
                    'accuracy': '±0.1 pH',
                    'current_reading': 7.2,
                    'optimal_range': {'min': 6.5, 'max': 8.5},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=7),
                    'battery_level': 88
                },
                {
                    'id': 'ph_002',
                    'name': 'Aquaculture Pond 2',
                    'location': 'aquaculture_pond_2',
                    'type': 'water_ph',
                    'range': '0 to 14 pH',
                    'accuracy': '±0.1 pH',
                    'current_reading': 7.5,
                    'optimal_range': {'min': 6.5, 'max': 8.5},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=7),
                    'battery_level': 92
                },
                {
                    'id': 'ph_003',
                    'name': 'Greenhouse Soil 1',
                    'location': 'greenhouse_soil_1',
                    'type': 'soil_ph',
                    'range': '0 to 14 pH',
                    'accuracy': '±0.2 pH',
                    'current_reading': 6.8,
                    'optimal_range': {'min': 6.0, 'max': 7.5},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=30),
                    'battery_level': 80
                }
            ]
        }
    
    def _initialize_ammonia_sensors(self):
        """Initialize ammonia monitoring sensors"""
        self.sensor_networks['ammonia'] = {
            'name': 'Ammonia Monitoring Network',
            'description': 'Ammonia gas sensors for livestock housing',
            'sensors': [
                {
                    'id': 'nh3_001',
                    'name': 'Poultry House 1',
                    'location': 'poultry_house_1',
                    'type': 'air_ammonia',
                    'range': '0 to 100 ppm',
                    'accuracy': '±2 ppm',
                    'current_reading': 15.5,
                    'optimal_range': {'min': 0, 'max': 25},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=15),
                    'battery_level': 85
                },
                {
                    'id': 'nh3_002',
                    'name': 'Poultry House 2',
                    'location': 'poultry_house_2',
                    'type': 'air_ammonia',
                    'range': '0 to 100 ppm',
                    'accuracy': '±2 ppm',
                    'current_reading': 18.2,
                    'optimal_range': {'min': 0, 'max': 25},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=15),
                    'battery_level': 78
                },
                {
                    'id': 'nh3_003',
                    'name': 'Piggery',
                    'location': 'piggery',
                    'type': 'air_ammonia',
                    'range': '0 to 100 ppm',
                    'accuracy': '±2 ppm',
                    'current_reading': 22.8,
                    'optimal_range': {'min': 0, 'max': 30},
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=20),
                    'battery_level': 82
                }
            ]
        }
    
    def _initialize_air_quality_sensors(self):
        """Initialize air quality monitoring sensors"""
        self.sensor_networks['air_quality'] = {
            'name': 'Air Quality Monitoring Network',
            'description': 'Multi-parameter air quality sensors',
            'sensors': [
                {
                    'id': 'aq_001',
                    'name': 'Poultry House 1',
                    'location': 'poultry_house_1',
                    'type': 'multi_parameter',
                    'parameters': {
                        'co2': {'current': 850, 'optimal_min': 400, 'optimal_max': 1000, 'unit': 'ppm'},
                        'o2': {'current': 20.5, 'optimal_min': 19.5, 'optimal_max': 21.5, 'unit': '%'},
                        'h2s': {'current': 2.5, 'optimal_min': 0, 'optimal_max': 10, 'unit': 'ppm'},
                        'dust_pm25': {'current': 35, 'optimal_min': 0, 'optimal_max': 50, 'unit': 'μg/m³'}
                    },
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=30),
                    'battery_level': 88
                }
            ]
        }
    
    def _initialize_soil_sensors(self):
        """Initialize soil monitoring sensors"""
        self.sensor_networks['soil'] = {
            'name': 'Soil Monitoring Network',
            'description': 'Soil moisture and nutrient sensors',
            'sensors': [
                {
                    'id': 'soil_001',
                    'name': 'Field 1 - Zone A',
                    'location': 'field_1_zone_a',
                    'type': 'multi_parameter',
                    'depth': '15cm',
                    'parameters': {
                        'moisture': {'current': 65, 'optimal_min': 60, 'optimal_max': 80, 'unit': '%'},
                        'temperature': {'current': 24.5, 'optimal_min': 20, 'optimal_max': 30, 'unit': '°C'},
                        'conductivity': {'current': 1.2, 'optimal_min': 0.8, 'optimal_max': 2.0, 'unit': 'dS/m'},
                        'nitrogen': {'current': 45, 'optimal_min': 30, 'optimal_max': 60, 'unit': 'mg/kg'}
                    },
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=60),
                    'battery_level': 75
                },
                {
                    'id': 'soil_002',
                    'name': 'Field 1 - Zone B',
                    'location': 'field_1_zone_b',
                    'type': 'multi_parameter',
                    'depth': '15cm',
                    'parameters': {
                        'moisture': {'current': 58, 'optimal_min': 60, 'optimal_max': 80, 'unit': '%'},
                        'temperature': {'current': 25.2, 'optimal_min': 20, 'optimal_max': 30, 'unit': '°C'},
                        'conductivity': {'current': 1.5, 'optimal_min': 0.8, 'optimal_max': 2.0, 'unit': 'dS/m'},
                        'nitrogen': {'current': 38, 'optimal_min': 30, 'optimal_max': 60, 'unit': 'mg/kg'}
                    },
                    'status': 'active',
                    'last_calibration': datetime.utcnow() - timedelta(days=60),
                    'battery_level': 80
                }
            ]
        }
    
    def _initialize_alert_thresholds(self):
        """Initialize alert thresholds for all sensor types"""
        self.alert_thresholds = {
            'temperature': {
                'critical_high': 35,
                'warning_high': 32,
                'warning_low': 18,
                'critical_low': 15,
                'rate_of_change_threshold': 2.0  # °C per hour
            },
            'humidity': {
                'critical_high': 85,
                'warning_high': 80,
                'warning_low': 40,
                'critical_low': 30
            },
            'ph': {
                'critical_high': 9.0,
                'warning_high': 8.5,
                'warning_low': 6.0,
                'critical_low': 5.5
            },
            'ammonia': {
                'critical_high': 40,
                'warning_high': 30,
                'warning_low': 0,
                'critical_low': 0
            },
            'air_quality': {
                'co2': {'critical_high': 1500, 'warning_high': 1200},
                'o2': {'critical_low': 18.0, 'warning_low': 19.0},
                'h2s': {'critical_high': 20, 'warning_high': 15},
                'dust_pm25': {'critical_high': 100, 'warning_high': 75}
            },
            'soil': {
                'moisture': {'critical_low': 30, 'warning_low': 50},
                'conductivity': {'critical_high': 3.0, 'warning_high': 2.5}
            }
        }
    
    def _initialize_automation_rules(self):
        """Initialize automation rules based on sensor readings"""
        self.automation_rules = {
            'ventilation_control': [
                {
                    'id': 'vent_001',
                    'name': 'Temperature-Based Ventilation',
                    'trigger_sensor': 'temp_001',
                    'condition': 'temperature > 30',
                    'action': 'increase_ventilation',
                    'actuator': 'vent_fan_001',
                    'enabled': True,
                    'priority': 'high'
                },
                {
                    'id': 'vent_002',
                    'name': 'Ammonia-Based Ventilation',
                    'trigger_sensor': 'nh3_001',
                    'condition': 'ammonia > 25',
                    'action': 'increase_ventilation',
                    'actuator': 'vent_fan_001',
                    'enabled': True,
                    'priority': 'critical'
                }
            ],
            'heating_control': [
                {
                    'id': 'heat_001',
                    'name': 'Low Temperature Heating',
                    'trigger_sensor': 'temp_001',
                    'condition': 'temperature < 20',
                    'action': 'activate_heating',
                    'actuator': 'heater_001',
                    'enabled': True,
                    'priority': 'high'
                }
            ],
            'irrigation_control': [
                {
                    'id': 'irrig_001',
                    'name': 'Soil Moisture Irrigation',
                    'trigger_sensor': 'soil_001',
                    'condition': 'moisture < 60',
                    'action': 'start_irrigation',
                    'actuator': 'irrig_valve_001',
                    'enabled': True,
                    'priority': 'medium'
                }
            ],
            'water_quality_control': [
                {
                    'id': 'water_001',
                    'name': 'pH Correction System',
                    'trigger_sensor': 'ph_001',
                    'condition': 'ph < 6.5 OR ph > 8.5',
                    'action': 'adjust_ph',
                    'actuator': 'ph_doser_001',
                    'enabled': True,
                    'priority': 'high'
                }
            ]
        }
    
    async def start_environmental_monitoring(self):
        """Start environmental monitoring service"""
        try:
            if self.is_running:
                logger.warning("Environmental monitoring service is already running")
                return
            
            self.is_running = True
            logger.info("Starting environmental monitoring service")
            
            # Start sensor data collection
            await self._start_sensor_data_collection()
            
            # Start alert monitoring
            await self._start_alert_monitoring()
            
            # Start automation execution
            await self._start_automation_execution()
            
            return {
                "status": "success",
                "message": "Environmental monitoring service started",
                "started_at": datetime.utcnow().isoformat(),
                "active_sensors": self._count_active_sensors(),
                "sensor_types": list(self.sensor_networks.keys())
            }
        
        except Exception as e:
            logger.error(f"Error starting environmental monitoring service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    def _count_active_sensors(self) -> int:
        """Count total active sensors"""
        total = 0
        for network in self.sensor_networks.values():
            if 'sensors' in network:
                total += len([s for s in network['sensors'] if s['status'] == 'active'])
        return total
    
    async def _start_sensor_data_collection(self):
        """Collect data from all sensors"""
        while self.is_running:
            try:
                timestamp = datetime.utcnow()
                
                # Simulate sensor data updates
                for network_type, network in self.sensor_networks.items():
                    if 'sensors' in network:
                        for sensor in network['sensors']:
                            if sensor['status'] == 'active':
                                await self._update_sensor_reading(sensor, network_type, timestamp)
                
                await asyncio.sleep(60)  # Update every minute
                
            except Exception as e:
                logger.error(f"Error in sensor data collection: {e}")
                await asyncio.sleep(60)
    
    async def _update_sensor_reading(self, sensor: Dict, network_type: str, timestamp: datetime):
        """Update individual sensor reading with realistic simulation"""
        # Generate realistic sensor variations
        base_variation = random.uniform(-0.5, 0.5)
        time_factor = math.sin(timestamp.hour * math.pi / 12)  # Daily variation
        
        if network_type == 'temperature':
            optimal = sensor['optimal_range']
            target = (optimal['min'] + optimal['max']) / 2
            sensor['current_reading'] = target + base_variation + time_factor * 2
            
        elif network_type == 'humidity':
            optimal = sensor['optimal_range']
            target = (optimal['min'] + optimal['max']) / 2
            sensor['current_reading'] = target + base_variation * 5 + time_factor * 3
            sensor['current_reading'] = max(0, min(100, sensor['current_reading']))
            
        elif network_type == 'ph':
            optimal = sensor['optimal_range']
            target = (optimal['min'] + optimal['max']) / 2
            sensor['current_reading'] = target + base_variation * 0.2
            
        elif network_type == 'ammonia':
            # Ammonia tends to increase over time without ventilation
            current = sensor['current_reading']
            sensor['current_reading'] = max(0, current + random.uniform(0, 0.5))
            
        elif network_type == 'air_quality':
            for param, data in sensor['parameters'].items():
                if param == 'co2':
                    data['current'] = 850 + base_variation * 50 + time_factor * 100
                elif param == 'o2':
                    data['current'] = 20.5 + base_variation * 0.2
                elif param == 'h2s':
                    data['current'] = max(0, 2.5 + base_variation * 0.5)
                elif param == 'dust_pm25':
                    data['current'] = max(0, 35 + base_variation * 10)
                    
        elif network_type == 'soil':
            for param, data in sensor['parameters'].items():
                if param == 'moisture':
                    data['current'] = 65 + base_variation * 5 - time_factor * 2
                    data['current'] = max(0, min(100, data['current']))
                elif param == 'temperature':
                    data['current'] = 25 + base_variation + time_factor
                elif param == 'conductivity':
                    data['current'] = 1.2 + base_variation * 0.2
                elif param == 'nitrogen':
                    data['current'] = max(0, 45 + base_variation * 5)
        
        # Update sensor metadata
        sensor['last_reading'] = timestamp
        
        # Store in sensor data history
        sensor_id = sensor['id']
        if sensor_id not in self.sensor_data:
            self.sensor_data[sensor_id] = []
        
        self.sensor_data[sensor_id].append({
            'timestamp': timestamp,
            'value': sensor['current_reading'],
            'sensor_type': network_type
        })
        
        # Keep only last 24 hours of data
        cutoff_time = timestamp - timedelta(hours=24)
        self.sensor_data[sensor_id] = [
            reading for reading in self.sensor_data[sensor_id]
            if reading['timestamp'] > cutoff_time
        ]
    
    async def _start_alert_monitoring(self):
        """Monitor sensor readings for alert conditions"""
        while self.is_running:
            try:
                alerts = []
                
                # Check all sensors for alert conditions
                for network_type, network in self.sensor_networks.items():
                    if 'sensors' in network and network_type in self.alert_thresholds:
                        for sensor in network['sensors']:
                            if sensor['status'] == 'active':
                                sensor_alerts = await self._check_sensor_alerts(sensor, network_type)
                                alerts.extend(sensor_alerts)
                
                # Send alerts if any
                if alerts:
                    await self._send_alerts(alerts)
                
                await asyncio.sleep(300)  # Check every 5 minutes
                
            except Exception as e:
                logger.error(f"Error in alert monitoring: {e}")
                await asyncio.sleep(300)
    
    async def _check_sensor_alerts(self, sensor: Dict, network_type: str) -> List[Dict]:
        """Check if sensor reading triggers any alerts"""
        alerts = []
        thresholds = self.alert_thresholds.get(network_type, {})
        
        if network_type in ['temperature', 'humidity', 'ph', 'ammonia']:
            reading = sensor['current_reading']
            optimal = sensor['optimal_range']
            
            # Check high thresholds
            if 'critical_high' in thresholds and reading > thresholds['critical_high']:
                alerts.append({
                    'sensor_id': sensor['id'],
                    'sensor_name': sensor['name'],
                    'type': 'critical_high',
                    'value': reading,
                    'threshold': thresholds['critical_high'],
                    'message': f"Critical high {network_type}: {reading}",
                    'timestamp': datetime.utcnow()
                })
            elif 'warning_high' in thresholds and reading > thresholds['warning_high']:
                alerts.append({
                    'sensor_id': sensor['id'],
                    'sensor_name': sensor['name'],
                    'type': 'warning_high',
                    'value': reading,
                    'threshold': thresholds['warning_high'],
                    'message': f"Warning high {network_type}: {reading}",
                    'timestamp': datetime.utcnow()
                })
            
            # Check low thresholds
            if 'critical_low' in thresholds and reading < thresholds['critical_low']:
                alerts.append({
                    'sensor_id': sensor['id'],
                    'sensor_name': sensor['name'],
                    'type': 'critical_low',
                    'value': reading,
                    'threshold': thresholds['critical_low'],
                    'message': f"Critical low {network_type}: {reading}",
                    'timestamp': datetime.utcnow()
                })
            elif 'warning_low' in thresholds and reading < thresholds['warning_low']:
                alerts.append({
                    'sensor_id': sensor['id'],
                    'sensor_name': sensor['name'],
                    'type': 'warning_low',
                    'value': reading,
                    'threshold': thresholds['warning_low'],
                    'message': f"Warning low {network_type}: {reading}",
                    'timestamp': datetime.utcnow()
                })
        
        elif network_type == 'air_quality' and 'parameters' in sensor:
            for param, data in sensor['parameters'].items():
                if param in thresholds['air_quality']:
                    value = data['current']
                    param_thresholds = thresholds['air_quality'][param]
                    
                    if 'critical_high' in param_thresholds and value > param_thresholds['critical_high']:
                        alerts.append({
                            'sensor_id': sensor['id'],
                            'sensor_name': sensor['name'],
                            'parameter': param,
                            'type': 'critical_high',
                            'value': value,
                            'threshold': param_thresholds['critical_high'],
                            'message': f"Critical high {param}: {value}",
                            'timestamp': datetime.utcnow()
                        })
        
        return alerts
    
    async def _send_alerts(self, alerts: List[Dict]):
        """Send alerts to notification system"""
        for alert in alerts:
            logger.warning(f"Environmental alert: {alert['message']}")
            # Here you would integrate with the notification service
            # For now, just log the alerts
    
    async def _start_automation_execution(self):
        """Execute automation rules based on sensor readings"""
        while self.is_running:
            try:
                for rule_category, rules in self.automation_rules.items():
                    for rule in rules:
                        if rule['enabled']:
                            await self._evaluate_and_execute_rule(rule)
                
                await asyncio.sleep(60)  # Check every minute
                
            except Exception as e:
                logger.error(f"Error in automation execution: {e}")
                await asyncio.sleep(60)
    
    async def _evaluate_and_execute_rule(self, rule: Dict):
        """Evaluate and execute automation rule"""
        try:
            # Find trigger sensor
            trigger_sensor_id = rule['trigger_sensor']
            trigger_sensor = None
            trigger_network_type = None
            
            for network_type, network in self.sensor_networks.items():
                if 'sensors' in network:
                    for sensor in network['sensors']:
                        if sensor['id'] == trigger_sensor_id:
                            trigger_sensor = sensor
                            trigger_network_type = network_type
                            break
                if trigger_sensor:
                    break
            
            if not trigger_sensor:
                return
            
            # Evaluate condition
            condition = rule['condition']
            reading = trigger_sensor['current_reading']
            
            condition_met = False
            
            if 'temperature >' in condition:
                threshold = float(condition.split('>')[-1].strip())
                condition_met = reading > threshold
            elif 'temperature <' in condition:
                threshold = float(condition.split('<')[-1].strip())
                condition_met = reading < threshold
            elif 'ammonia >' in condition:
                threshold = float(condition.split('>')[-1].strip())
                condition_met = reading > threshold
            elif 'moisture <' in condition:
                # For soil sensors
                if 'parameters' in trigger_sensor and 'moisture' in trigger_sensor['parameters']:
                    threshold = float(condition.split('<')[-1].strip())
                    condition_met = trigger_sensor['parameters']['moisture']['current'] < threshold
            elif 'ph <' in condition or 'ph >' in condition:
                threshold = float(condition.split('>')[-1].strip() if '>' in condition else condition.split('<')[-1].strip())
                condition_met = reading > threshold if '>' in condition else reading < threshold
            
            # Execute action if condition is met
            if condition_met:
                await self._execute_automation_action(rule)
                logger.info(f"Automation rule triggered: {rule['name']}")
        
        except Exception as e:
            logger.error(f"Error evaluating automation rule {rule['id']}: {e}")
    
    async def _execute_automation_action(self, rule: Dict):
        """Execute automation action"""
        action = rule['action']
        actuator = rule['actuator']
        
        # Simulate actuator control
        if action == 'increase_ventilation':
            logger.info(f"Increasing ventilation via {actuator}")
        elif action == 'activate_heating':
            logger.info(f"Activating heating via {actuator}")
        elif action == 'start_irrigation':
            logger.info(f"Starting irrigation via {actuator}")
        elif action == 'adjust_ph':
            logger.info(f"Adjusting pH via {actuator}")
        
        # Here you would integrate with actual actuator control systems
    
    async def get_environmental_status(self) -> Dict:
        """Get current environmental monitoring status"""
        try:
            return {
                'sensor_networks': self.sensor_networks,
                'alert_thresholds': self.alert_thresholds,
                'automation_rules': self.automation_rules,
                'active_alerts': await self._get_current_alerts(),
                'system_status': 'operational' if self.is_running else 'stopped',
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting environmental status: {e}")
            return {
                'error': str(e),
                'system_status': 'error'
            }
    
    async def _get_current_alerts(self) -> List[Dict]:
        """Get current active alerts"""
        alerts = []
        
        for network_type, network in self.sensor_networks.items():
            if 'sensors' in network and network_type in self.alert_thresholds:
                for sensor in network['sensors']:
                    if sensor['status'] == 'active':
                        sensor_alerts = await self._check_sensor_alerts(sensor, network_type)
                        alerts.extend(sensor_alerts)
        
        return alerts
    
    async def get_sensor_history(self, sensor_id: str, hours: int = 24) -> Dict:
        """Get historical data for a specific sensor"""
        try:
            if sensor_id not in self.sensor_data:
                return {
                    'success': False,
                    'error': f'Sensor {sensor_id} not found'
                }
            
            # Filter data by time range
            cutoff_time = datetime.utcnow() - timedelta(hours=hours)
            history = [
                reading for reading in self.sensor_data[sensor_id]
                if reading['timestamp'] > cutoff_time
            ]
            
            return {
                'success': True,
                'sensor_id': sensor_id,
                'period_hours': hours,
                'data_points': len(history),
                'history': history,
                'latest_reading': history[-1] if history else None,
                'statistics': self._calculate_sensor_statistics(history)
            }
        
        except Exception as e:
            logger.error(f"Error getting sensor history: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _calculate_sensor_statistics(self, history: List[Dict]) -> Dict:
        """Calculate statistics for sensor history"""
        if not history:
            return {}
        
        values = [reading['value'] for reading in history]
        
        return {
            'min': min(values),
            'max': max(values),
            'average': sum(values) / len(values),
            'median': sorted(values)[len(values) // 2],
            'std_dev': (sum((x - sum(values) / len(values)) ** 2 for x in values) / len(values)) ** 0.5
        }
    
    async def get_environmental_reports(self, period: str = 'daily') -> Dict:
        """Generate environmental monitoring reports"""
        try:
            # Generate mock report data
            reports = {
                'daily': {
                    'period': 'Last 24 hours',
                    'total_readings': 1440,  # 1 reading per minute
                    'alerts_triggered': 8,
                    'critical_alerts': 2,
                    'automation_executions': 15,
                    'sensor_uptime': 99.2,
                    'battery_status': {
                        'good': 12,
                        'warning': 3,
                        'critical': 0
                    },
                    'environmental_summary': {
                        'avg_temperature': 26.8,
                        'avg_humidity': 68.5,
                        'avg_ph': 7.3,
                        'max_ammonia': 28.5
                    }
                },
                'weekly': {
                    'period': 'Last 7 days',
                    'total_readings': 10080,
                    'alerts_triggered': 56,
                    'critical_alerts': 14,
                    'automation_executions': 105,
                    'sensor_uptime': 98.8,
                    'trend': 'stable',
                    'recommendations': [
                        'Calibrate ammonia sensors in poultry house 2',
                        'Check battery levels in soil sensors',
                        'Review ventilation automation rules'
                    ]
                },
                'monthly': {
                    'period': 'Last 30 days',
                    'total_readings': 43200,
                    'alerts_triggered': 240,
                    'critical_alerts': 45,
                    'automation_executions': 450,
                    'sensor_uptime': 98.5,
                    'trend': 'improving',
                    'comparison_to_target': '+2.3%',
                    'maintenance_due': 5,
                    'recommendations': [
                        'Schedule preventive maintenance for temperature sensors',
                        'Upgrade ammonia monitoring in piggery',
                        'Consider additional soil moisture sensors'
                    ]
                }
            }
            
            return {
                'success': True,
                'report': reports.get(period, reports['daily']),
                'generated_at': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error generating environmental reports: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def stop_environmental_monitoring(self):
        """Stop environmental monitoring service"""
        try:
            self.is_running = False
            
            logger.info("Environmental monitoring service stopped")
            
            return {
                "status": "success",
                "message": "Environmental monitoring service stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping environmental monitoring service: {e}")
            return {
                "status": "error",
                "message": str(e)
            }

# Global environmental monitoring service instance
environmental_monitoring_service = EnvironmentalMonitoringService()
