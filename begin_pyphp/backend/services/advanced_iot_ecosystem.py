"""
FarmOS Advanced IoT Ecosystem Service
Advanced IoT ecosystem for comprehensive farm automation and monitoring
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from ..common.database import get_db
from ..common import models
import json

logger = logging.getLogger(__name__)

class AdvancedIoTService:
    """Advanced IoT ecosystem service for comprehensive farm automation"""
    
    def __init__(self):
        self.devices = {}
        self.sensors = {}
        self.actuators = {}
        self.data_streams = {}
        self.automation_rules = {}
        self.is_running = False
        
        # Initialize IoT ecosystem
        self._initialize_devices()
        self._initialize_sensors()
        self._initialize_actuators()
        self._initialize_automation_rules()
        
    def _initialize_devices(self):
        """Initialize IoT device configurations"""
        self.devices = {
            'weather_station': {
                'name': 'Weather Station',
                'type': 'environmental_monitoring',
                'location': 'field_1',
                'sensors': ['temperature', 'humidity', 'rainfall', 'wind_speed', 'solar_radiation'],
                'connectivity': 'lora_wan',
                'power_source': 'solar',
                'battery_level': 85,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'soil_sensors': {
                'name': 'Soil Sensor Network',
                'type': 'soil_monitoring',
                'location': 'field_1',
                'sensors': ['soil_moisture', 'soil_temperature', 'ph_level', 'nutrient_levels'],
                'connectivity': 'zigbee',
                'power_source': 'battery',
                'battery_level': 72,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'water_quality_monitor': {
                'name': 'Water Quality Monitor',
                'type': 'water_monitoring',
                'location': 'pond_1',
                'sensors': ['dissolved_oxygen', 'ph', 'turbidity', 'temperature', 'ammonia'],
                'connectivity': 'wifi',
                'power_source': 'mains',
                'battery_level': 100,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'livestock_trackers': {
                'name': 'Livestock GPS Trackers',
                'type': 'livestock_monitoring',
                'location': 'barn_1',
                'sensors': ['gps_location', 'activity_level', 'body_temperature'],
                'connectivity': 'nb_iot',
                'power_source': 'battery',
                'battery_level': 68,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'greenhouse_controller': {
                'name': 'Greenhouse Controller',
                'type': 'climate_control',
                'location': 'greenhouse_1',
                'sensors': ['temperature', 'humidity', 'co2_level', 'light_intensity'],
                'actuators': ['ventilation_fans', 'heating_system', 'co2_injection', 'led_lights'],
                'connectivity': 'ethernet',
                'power_source': 'mains',
                'battery_level': 100,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'irrigation_system': {
                'name': 'Smart Irrigation System',
                'type': 'irrigation_control',
                'location': 'field_1',
                'sensors': ['flow_rate', 'pressure', 'soil_moisture'],
                'actuators': ['valves', 'pumps', 'sprinklers'],
                'connectivity': 'lora_wan',
                'power_source': 'solar',
                'battery_level': 91,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'feed_monitor': {
                'name': 'Feed Consumption Monitor',
                'type': 'livestock_monitoring',
                'location': 'barn_1',
                'sensors': ['feed_weight', 'consumption_rate', 'feed_level'],
                'connectivity': 'wifi',
                'power_source': 'mains',
                'battery_level': 100,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            },
            'biogas_monitor': {
                'name': 'Biogas Plant Monitor',
                'type': 'energy_monitoring',
                'location': 'biogas_plant',
                'sensors': ['gas_production', 'methane_content', 'temperature', 'pressure'],
                'actuators': ['mixing_motors', 'gas_valves'],
                'connectivity': 'ethernet',
                'power_source': 'mains',
                'battery_level': 100,
                'last_seen': datetime.utcnow(),
                'status': 'active'
            }
        }
    
    def _initialize_sensors(self):
        """Initialize sensor configurations"""
        self.sensors = {
            'temperature': {
                'unit': 'celsius',
                'range': {'min': -40, 'max': 85},
                'accuracy': 0.1,
                'calibration_interval': 30,  # days
                'alert_thresholds': {
                    'low': 10,
                    'high': 35,
                    'critical_low': 5,
                    'critical_high': 40
                }
            },
            'humidity': {
                'unit': 'percent',
                'range': {'min': 0, 'max': 100},
                'accuracy': 1.0,
                'calibration_interval': 60,
                'alert_thresholds': {
                    'low': 30,
                    'high': 80,
                    'critical_low': 20,
                    'critical_high': 90
                }
            },
            'soil_moisture': {
                'unit': 'percent',
                'range': {'min': 0, 'max': 100},
                'accuracy': 2.0,
                'calibration_interval': 90,
                'alert_thresholds': {
                    'low': 20,
                    'high': 80,
                    'critical_low': 10,
                    'critical_high': 90
                }
            },
            'ph_level': {
                'unit': 'ph',
                'range': {'min': 0, 'max': 14},
                'accuracy': 0.01,
                'calibration_interval': 30,
                'alert_thresholds': {
                    'low': 6.0,
                    'high': 8.0,
                    'critical_low': 5.5,
                    'critical_high': 8.5
                }
            },
            'dissolved_oxygen': {
                'unit': 'mg_per_liter',
                'range': {'min': 0, 'max': 20},
                'accuracy': 0.1,
                'calibration_interval': 14,
                'alert_thresholds': {
                    'low': 5.0,
                    'high': 12.0,
                    'critical_low': 3.0,
                    'critical_high': 15.0
                }
            }
        }
    
    def _initialize_actuators(self):
        """Initialize actuator configurations"""
        self.actuators = {
            'irrigation_valve': {
                'type': 'binary_actuator',
                'states': ['open', 'closed'],
                'response_time': 5,  # seconds
                'power_consumption': 12,  # watts
                'operating_voltage': 24,
                'safety_interlocks': ['pressure_sensor', 'flow_sensor']
            },
            'ventilation_fan': {
                'type': 'variable_speed_actuator',
                'speed_range': {'min': 0, 'max': 100},
                'response_time': 3,
                'power_consumption': 150,
                'operating_voltage': 220,
                'safety_interlocks': ['temperature_sensor', 'humidity_sensor']
            },
            'led_lights': {
                'type': 'dimming_actuator',
                'brightness_range': {'min': 0, 'max': 100},
                'spectrum': ['full_spectrum', 'red', 'blue', 'white'],
                'response_time': 1,
                'power_consumption': 200,
                'operating_voltage': 24
            },
            'feed_dispenser': {
                'type': 'precision_actuator',
                'dispense_range': {'min': 10, 'max': 1000},  # grams
                'accuracy': 5,  # grams
                'response_time': 2,
                'power_consumption': 50,
                'operating_voltage': 12
            }
        }
    
    def _initialize_automation_rules(self):
        """Initialize automation rules"""
        self.automation_rules = {
            'irrigation_automation': {
                'name': 'Smart Irrigation',
                'description': 'Automated irrigation based on soil moisture and weather',
                'triggers': [
                    {'sensor': 'soil_moisture', 'condition': 'less_than', 'value': 30},
                    {'sensor': 'weather_forecast', 'condition': 'no_rain', 'days': 3}
                ],
                'actions': [
                    {'actuator': 'irrigation_valve', 'action': 'open', 'duration': 1800},
                    {'actuator': 'irrigation_pump', 'action': 'start'}
                ],
                'conditions': [
                    {'time': 'between', 'start': '06:00', 'end': '18:00'},
                    {'day': 'not_sunday'}
                ],
                'priority': 'high',
                'enabled': True
            },
            'greenhouse_climate': {
                'name': 'Greenhouse Climate Control',
                'description': 'Maintain optimal greenhouse conditions',
                'triggers': [
                    {'sensor': 'temperature', 'condition': 'greater_than', 'value': 28},
                    {'sensor': 'humidity', 'condition': 'greater_than', 'value': 75}
                ],
                'actions': [
                    {'actuator': 'ventilation_fans', 'action': 'set_speed', 'value': 80},
                    {'actuator': 'heating_system', 'action': 'off'}
                ],
                'conditions': [
                    {'time': 'always'}
                ],
                'priority': 'high',
                'enabled': True
            },
            'livestock_feeding': {
                'name': 'Automated Livestock Feeding',
                'description': 'Scheduled feeding based on consumption patterns',
                'triggers': [
                    {'time': 'schedule', 'times': ['06:00', '12:00', '18:00']},
                    {'sensor': 'feed_level', 'condition': 'less_than', 'value': 20}
                ],
                'actions': [
                    {'actuator': 'feed_dispenser', 'action': 'dispense', 'amount': 500}
                ],
                'conditions': [
                    {'day': 'everyday'}
                ],
                'priority': 'medium',
                'enabled': True
            },
            'water_quality_alerts': {
                'name': 'Water Quality Monitoring',
                'description': 'Alert on poor water quality conditions',
                'triggers': [
                    {'sensor': 'dissolved_oxygen', 'condition': 'less_than', 'value': 4},
                    {'sensor': 'ammonia', 'condition': 'greater_than', 'value': 0.5}
                ],
                'actions': [
                    {'notification': 'sms', 'message': 'Critical water quality issue detected'},
                    {'notification': 'email', 'message': 'Water quality parameters exceeded safe limits'},
                    {'actuator': 'aeration_system', 'action': 'increase_speed'}
                ],
                'conditions': [
                    {'time': 'always'}
                ],
                'priority': 'critical',
                'enabled': True
            }
        }
    
    async def start_iot_ecosystem(self):
        """Start IoT ecosystem"""
        try:
            if self.is_running:
                logger.warning("IoT ecosystem is already running")
                return
            
            self.is_running = True
            logger.info("Starting advanced IoT ecosystem")
            
            # Initialize device connections
            await self._initialize_device_connections()
            
            # Start data collection
            await self._start_data_collection()
            
            # Start automation engine
            await self._start_automation_engine()
            
            # Start monitoring
            await self._start_device_monitoring()
            
            return {
                "status": "success",
                "message": "Advanced IoT ecosystem started",
                "started_at": datetime.utcnow().isoformat(),
                "devices_connected": len(self.devices)
            }
        
        except Exception as e:
            logger.error(f"Error starting IoT ecosystem: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def stop_iot_ecosystem(self):
        """Stop IoT ecosystem"""
        try:
            self.is_running = False
            
            if self.data_collection_task:
                self.data_collection_task.cancel()
                self.data_collection_task = None
            
            if self.automation_task:
                self.automation_task.cancel()
                self.automation_task = None
            
            if self.monitoring_task:
                self.monitoring_task.cancel()
                self.monitoring_task = None
            
            logger.info("Advanced IoT ecosystem stopped")
            
            return {
                "status": "success",
                "message": "Advanced IoT ecosystem stopped",
                "stopped_at": datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error stopping IoT ecosystem: {e}")
            return {
                "status": "error",
                "message": str(e)
            }
    
    async def _initialize_device_connections(self):
        """Initialize device connections"""
        try:
            for device_id, device_config in self.devices.items():
                # Simulate device connection
                await asyncio.sleep(0.1)
                
                device_config['connected_at'] = datetime.utcnow()
                device_config['connection_status'] = 'connected'
                
                logger.info(f"Device {device_id} connected successfully")
        
        except Exception as e:
            logger.error(f"Error initializing device connections: {e}")
    
    async def _start_data_collection(self):
        """Start data collection from devices"""
        try:
            logger.info("Starting IoT data collection")
            
            self.data_collection_task = asyncio.create_task(self._data_collection_loop())
            
            logger.info("IoT data collection started")
        
        except Exception as e:
            logger.error(f"Error starting data collection: {e}")
    
    async def _data_collection_loop(self):
        """Main data collection loop"""
        while self.is_running:
            try:
                # Collect data from all devices
                await self._collect_sensor_data()
                
                # Process collected data
                await self._process_sensor_data()
                
                # Store data in database
                await self._store_sensor_data()
                
                # Wait for next collection (30 seconds)
                await asyncio.sleep(30)
                
        except Exception as e:
            logger.error(f"Error in data collection loop: {e}")
            await asyncio.sleep(30)
    
    async def _collect_sensor_data(self):
        """Collect sensor data from devices"""
        try:
            for device_id, device_config in self.devices.items():
                # Simulate sensor data collection
                sensor_data = {}
                
                for sensor_type in device_config['sensors']:
                    # Generate mock sensor data
                    if sensor_type == 'temperature':
                        sensor_data[sensor_type] = 22.5 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 10)
                    elif sensor_type == 'humidity':
                        sensor_data[sensor_type] = 65 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 5)
                    elif sensor_type == 'soil_moisture':
                        sensor_data[sensor_type] = 45 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 3)
                    elif sensor_type == 'ph_level':
                        sensor_data[sensor_type] = 6.8 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 20)
                    elif sensor_type == 'dissolved_oxygen':
                        sensor_data[sensor_type] = 7.2 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 10)
                    else:
                        sensor_data[sensor_type] = 50 + (hashlib.md5(f'{datetime.utcnow()}{sensor_type}'.encode()).hexdigest()[-1] / 2)
                
                # Update device data
                device_config['current_data'] = sensor_data
                device_config['last_seen'] = datetime.utcnow()
                
                # Store in data streams
                if device_id not in self.data_streams:
                    self.data_streams[device_id] = []
                
                self.data_streams[device_id].append({
                    'timestamp': datetime.utcnow(),
                    'data': sensor_data
                })
                
                # Keep only last 100 readings per device
                if len(self.data_streams[device_id]) > 100:
                    self.data_streams[device_id] = self.data_streams[device_id][-100:]
        
        except Exception as e:
            logger.error(f"Error collecting sensor data: {e}")
    
    async def _process_sensor_data(self):
        """Process collected sensor data"""
        try:
            for device_id, device_config in self.devices.items():
                if 'current_data' not in device_config:
                    continue
                
                sensor_data = device_config['current_data']
                
                # Check for alerts
                await self._check_sensor_alerts(device_id, sensor_data)
                
                # Update device status
                await self._update_device_status(device_id, sensor_data)
        
        except Exception as e:
            logger.error(f"Error processing sensor data: {e}")
    
    async def _check_sensor_alerts(self, device_id: str, sensor_data: Dict):
        """Check for sensor alerts"""
        try:
            for sensor_type, value in sensor_data.items():
                if sensor_type in self.sensors:
                    sensor_config = self.sensors[sensor_type]
                    thresholds = sensor_config['alert_thresholds']
                    
                    # Check critical thresholds
                    if value <= thresholds['critical_low'] or value >= thresholds['critical_high']:
                        await self._trigger_alert(device_id, sensor_type, value, 'critical')
                    elif value <= thresholds['low'] or value >= thresholds['high']:
                        await self._trigger_alert(device_id, sensor_type, value, 'warning')
        
        except Exception as e:
            logger.error(f"Error checking sensor alerts: {e}")
    
    async def _trigger_alert(self, device_id: str, sensor_type: str, value: float, severity: str):
        """Trigger sensor alert"""
        try:
            alert = {
                'device_id': device_id,
                'sensor_type': sensor_type,
                'value': value,
                'severity': severity,
                'timestamp': datetime.utcnow(),
                'message': f"{severity.capitalize()} alert: {sensor_type} value {value} at {device_id}"
            }
            
            logger.warning(alert['message'])
            
            # Store alert in database (mock)
            # In production, this would save to database and send notifications
        
        except Exception as e:
            logger.error(f"Error triggering alert: {e}")
    
    async def _update_device_status(self, device_id: str, sensor_data: Dict):
        """Update device status based on sensor data"""
        try:
            device_config = self.devices[device_id]
            
            # Update battery level (mock)
            if 'battery_level' in device_config:
                device_config['battery_level'] = max(0, device_config['battery_level'] - 0.1)
            
            # Check device health
            if device_config['battery_level'] < 20:
                device_config['status'] = 'low_battery'
            elif datetime.utcnow() - device_config['last_seen'] > timedelta(minutes=5):
                device_config['status'] = 'offline'
            else:
                device_config['status'] = 'active'
        
        except Exception as e:
            logger.error(f"Error updating device status: {e}")
    
    async def _store_sensor_data(self):
        """Store sensor data in database"""
        try:
            # Mock database storage
            # In production, this would save to database
            pass
        
        except Exception as e:
            logger.error(f"Error storing sensor data: {e}")
    
    async def _start_automation_engine(self):
        """Start automation engine"""
        try:
            logger.info("Starting IoT automation engine")
            
            self.automation_task = asyncio.create_task(self._automation_loop())
            
            logger.info("IoT automation engine started")
        
        except Exception as e:
            logger.error(f"Error starting automation engine: {e}")
    
    async def _automation_loop(self):
        """Main automation loop"""
        while self.is_running:
            try:
                # Evaluate automation rules
                await self._evaluate_automation_rules()
                
                # Execute automation actions
                await self._execute_automation_actions()
                
                # Wait for next evaluation (60 seconds)
                await asyncio.sleep(60)
                
        except Exception as e:
            logger.error(f"Error in automation loop: {e}")
            await asyncio.sleep(60)
    
    async def _evaluate_automation_rules(self):
        """Evaluate automation rules"""
        try:
            for rule_id, rule_config in self.automation_rules.items():
                if not rule_config.get('enabled', False):
                    continue
                
                # Check triggers
                triggers_met = await self._check_triggers(rule_config['triggers'])
                
                # Check conditions
                conditions_met = await self._check_conditions(rule_config.get('conditions', []))
                
                if triggers_met and conditions_met:
                    rule_config['active'] = True
                    rule_config['last_triggered'] = datetime.utcnow()
                    logger.info(f"Automation rule {rule_id} triggered")
        
        except Exception as e:
            logger.error(f"Error evaluating automation rules: {e}")
    
    async def _check_triggers(self, triggers: List[Dict]) -> bool:
        """Check if automation triggers are met"""
        try:
            for trigger in triggers:
                if trigger['sensor'] == 'time':
                    # Time-based trigger
                    current_time = datetime.utcnow().time()
                    if trigger['condition'] == 'schedule':
                        # Check if current time matches schedule
                        pass  # Simplified for mock
                elif trigger['sensor'] == 'weather_forecast':
                    # Weather forecast trigger
                    pass  # Simplified for mock
                else:
                    # Sensor-based trigger
                    sensor_value = await self._get_sensor_value(trigger['sensor'])
                    
                    if trigger['condition'] == 'less_than':
                        if sensor_value >= trigger['value']:
                            return False
                    elif trigger['condition'] == 'greater_than':
                        if sensor_value <= trigger['value']:
                            return False
            
            return True
        
        except Exception as e:
            logger.error(f"Error checking triggers: {e}")
            return False
    
    async def _check_conditions(self, conditions: List[Dict]) -> bool:
        """Check if automation conditions are met"""
        try:
            for condition in conditions:
                if condition['time'] == 'always':
                    continue
                elif condition['time'] == 'between':
                    # Check time range
                    current_time = datetime.utcnow().time()
                    start_time = datetime.strptime(condition['start'], '%H:%M').time()
                    end_time = datetime.strptime(condition['end'], '%H:%M').time()
                    
                    if start_time <= current_time <= end_time:
                        continue
                    else:
                        return False
                elif condition['day'] == 'not_sunday':
                    if datetime.utcnow().weekday() == 6:  # Sunday
                        return False
            
            return True
        
        except Exception as e:
            logger.error(f"Error checking conditions: {e}")
            return False
    
    async def _get_sensor_value(self, sensor_type: str) -> float:
        """Get current sensor value"""
        try:
            # Find device with this sensor
            for device_id, device_config in self.devices.items():
                if 'current_data' in device_config and sensor_type in device_config['current_data']:
                    return device_config['current_data'][sensor_type]
            
            return 0.0
        
        except Exception as e:
            logger.error(f"Error getting sensor value: {e}")
            return 0.0
    
    async def _execute_automation_actions(self):
        """Execute automation actions"""
        try:
            for rule_id, rule_config in self.automation_rules.items():
                if rule_config.get('active', False):
                    # Execute actions
                    for action in rule_config['actions']:
                        await self._execute_action(action)
                    
                    # Reset rule
                    rule_config['active'] = False
        
        except Exception as e:
            logger.error(f"Error executing automation actions: {e}")
    
    async def _execute_action(self, action: Dict):
        """Execute automation action"""
        try:
            if 'actuator' in action:
                # Control actuator
                await self._control_actuator(action['actuator'], action)
            elif 'notification' in action:
                # Send notification
                await self._send_notification(action)
        
        except Exception as e:
            logger.error(f"Error executing action: {e}")
    
    async def _control_actuator(self, actuator_type: str, action: Dict):
        """Control actuator"""
        try:
            # Simulate actuator control
            await asyncio.sleep(0.5)
            
            logger.info(f"Controlling {actuator_type}: {action}")
        
        except Exception as e:
            logger.error(f"Error controlling actuator: {e}")
    
    async def _send_notification(self, notification: Dict):
        """Send notification"""
        try:
            # Simulate notification sending
            await asyncio.sleep(0.2)
            
            logger.info(f"Sending {notification['notification']}: {notification['message']}")
        
        except Exception as e:
            logger.error(f"Error sending notification: {e}")
    
    async def _start_device_monitoring(self):
        """Start device monitoring"""
        try:
            logger.info("Starting device monitoring")
            
            self.monitoring_task = asyncio.create_task(self._device_monitoring_loop())
            
            logger.info("Device monitoring started")
        
        except Exception as e:
            logger.error(f"Error starting device monitoring: {e}")
    
    async def _device_monitoring_loop(self):
        """Main device monitoring loop"""
        while self.is_running:
            try:
                # Check device connectivity
                await self._check_device_connectivity()
                
                # Check device health
                await self._check_device_health()
                
                # Update device metrics
                await self._update_device_metrics()
                
                # Wait for next check (120 seconds)
                await asyncio.sleep(120)
                
        except Exception as e:
            logger.error(f"Error in device monitoring loop: {e}")
            await asyncio.sleep(120)
    
    async def _check_device_connectivity(self):
        """Check device connectivity"""
        try:
            for device_id, device_config in self.devices.items():
                # Simulate connectivity check
                await asyncio.sleep(0.1)
                
                time_since_last_seen = datetime.utcnow() - device_config['last_seen']
                
                if time_since_last_seen > timedelta(minutes=5):
                    device_config['status'] = 'offline'
                    logger.warning(f"Device {device_id} is offline")
                else:
                    device_config['status'] = 'active'
        
        except Exception as e:
            logger.error(f"Error checking device connectivity: {e}")
    
    async def _check_device_health(self):
        """Check device health"""
        try:
            for device_id, device_config in self.devices.items():
                # Check battery level
                if device_config['battery_level'] < 10:
                    device_config['status'] = 'critical_battery'
                    logger.critical(f"Device {device_id} has critical battery level")
                elif device_config['battery_level'] < 20:
                    device_config['status'] = 'low_battery'
                    logger.warning(f"Device {device_id} has low battery")
        
        except Exception as e:
            logger.error(f"Error checking device health: {e}")
    
    async def _update_device_metrics(self):
        """Update device metrics"""
        try:
            for device_id, device_config in self.devices.items():
                # Calculate uptime
                if 'connected_at' in device_config:
                    uptime = datetime.utcnow() - device_config['connected_at']
                    device_config['uptime_hours'] = uptime.total_seconds() / 3600
                
                # Calculate data points
                if device_id in self.data_streams:
                    device_config['total_data_points'] = len(self.data_streams[device_id])
        
        except Exception as e:
            logger.error(f"Error updating device metrics: {e}")
    
    def get_iot_status(self) -> Dict:
        """Get IoT ecosystem status"""
        try:
            device_status = {}
            for device_id, device_config in self.devices.items():
                device_status[device_id] = {
                    'name': device_config['name'],
                    'type': device_config['type'],
                    'location': device_config['location'],
                    'status': device_config['status'],
                    'battery_level': device_config.get('battery_level', 0),
                    'last_seen': device_config['last_seen'],
                    'sensors': device_config['sensors'],
                    'actuators': device_config.get('actuators', [])
                }
            
            return {
                'is_running': self.is_running,
                'total_devices': len(self.devices),
                'active_devices': len([d for d in self.devices.values() if d['status'] == 'active']),
                'offline_devices': len([d for d in self.devices.values() if d['status'] == 'offline']),
                'automation_rules': len(self.automation_rules),
                'active_rules': len([r for r in self.automation_rules.values() if r.get('enabled', False)]),
                'devices': device_status,
                'last_updated': datetime.utcnow().isoformat()
            }
        
        except Exception as e:
            logger.error(f"Error getting IoT status: {e}")
            return {
                'is_running': False,
                'total_devices': 0,
                'active_devices': 0,
                'offline_devices': 0,
                'automation_rules': 0,
                'active_rules': 0,
                'devices': {},
                'last_updated': datetime.utcnow().isoformat()
            }
    
    def get_sensor_data(self, device_id: str, limit: int = 50) -> List[Dict]:
        """Get sensor data for a device"""
        try:
            if device_id in self.data_streams:
                return self.data_streams[device_id][-limit:]
            return []
        
        except Exception as e:
            logger.error(f"Error getting sensor data: {e}")
            return []

# Global advanced IoT service instance
advanced_iot_service = AdvancedIoTService()
