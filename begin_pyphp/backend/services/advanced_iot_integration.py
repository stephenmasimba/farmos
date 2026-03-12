"""
Advanced IoT Integration - Phase 2 Feature
MQTT broker implementation with real-time sensor data processing and edge computing
Derived from Begin Reference System
"""

import logging
import asyncio
import json
import paho.mqtt.client as mqtt
from typing import Dict, List, Optional, Any, Callable
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
from decimal import Decimal
import numpy as np
from collections import defaultdict, deque
import threading
import queue

logger = logging.getLogger(__name__)

from ..common import models

class AdvancedIoTService:
    """Advanced IoT service with MQTT broker and real-time processing"""
    
    def __init__(self, db: Session, broker_host: str = "localhost", broker_port: int = 1883):
        self.db = db
        self.broker_host = broker_host
        self.broker_port = broker_port
        self.mqtt_client = None
        self.connected = False
        
        # Device management
        self.devices = {}
        self.device_configs = {}
        
        # Real-time data processing
        self.sensor_data_queue = queue.Queue()
        self.alert_queue = queue.Queue()
        self.processing_threads = []
        
        # Edge computing
        self.edge_processors = {}
        self.local_cache = defaultdict(lambda: deque(maxlen=100))
        
        # MQTT topics
        self.topics = {
            "sensors": "farmos/sensors/+/data",
            "alerts": "farmos/alerts/+/+",
            "commands": "farmos/commands/+/+",
            "status": "farmos/status/+/+",
            "control": "farmos/control/+/+"
        }

    async def start_mqtt_broker(self) -> Dict[str, Any]:
        """Start MQTT broker and connect clients"""
        try:
            # Initialize MQTT client
            self.mqtt_client = mqtt.Client()
            
            # Set callbacks
            self.mqtt_client.on_connect = self._on_connect
            self.mqtt_client.on_message = self._on_message
            self.mqtt_client.on_disconnect = self._on_disconnect
            self.mqtt_client.on_publish = self._on_publish
            
            # Connect to broker
            self.mqtt_client.connect(self.broker_host, self.broker_port, 60)
            self.mqtt_client.loop_start()
            
            # Start processing threads
            await self._start_processing_threads()
            
            # Initialize edge processors
            await self._initialize_edge_processors()
            
            return {
                "success": True,
                "broker_host": self.broker_host,
                "broker_port": self.broker_port,
                "status": "connected",
                "message": "MQTT broker started successfully"
            }
            
        except Exception as e:
            logger.error(f"Error starting MQTT broker: {e}")
            return {"error": "MQTT broker startup failed"}

    async def register_device(self, device_data: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Register new IoT device"""
        try:
            # Create device record
            device = models.IoTDevice(
                device_id=device_data['device_id'],
                device_name=device_data['device_name'],
                device_type=device_data['device_type'],
                location=device_data.get('location'),
                manufacturer=device_data.get('manufacturer'),
                model=device_data.get('model'),
                firmware_version=device_data.get('firmware_version'),
                configuration_json=json.dumps(device_data.get('configuration', {})),
                status='active',
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(device)
            self.db.commit()
            
            # Store in memory for quick access
            self.devices[device.device_id] = device
            self.device_configs[device.device_id] = device_data.get('configuration', {})
            
            # Subscribe to device topics
            await self._subscribe_to_device_topics(device.device_id)
            
            # Send initial configuration
            await self._send_device_configuration(device.device_id)
            
            return {
                "success": True,
                "device_id": device.device_id,
                "device_name": device.device_name,
                "status": "registered",
                "message": "Device registered successfully"
            }
            
        except Exception as e:
            logger.error(f"Error registering device: {e}")
            self.db.rollback()
            return {"error": "Device registration failed"}

    async def process_sensor_data(self, device_id: str, sensor_data: Dict[str, Any], 
                                tenant_id: str = "default") -> Dict[str, Any]:
        """Process real-time sensor data"""
        try:
            # Validate device
            if device_id not in self.devices:
                return {"error": "Device not registered"}
            
            device = self.devices[device_id]
            
            # Process data through edge computing
            processed_data = await self._edge_process_sensor_data(device_id, sensor_data)
            
            # Store raw sensor data
            sensor_record = models.SensorData(
                device_id=device_id,
                sensor_type=sensor_data.get('sensor_type'),
                value=sensor_data.get('value'),
                unit=sensor_data.get('unit'),
                quality_score=processed_data.get('quality_score', 1.0),
                processed_data_json=json.dumps(processed_data),
                timestamp=datetime.fromisoformat(sensor_data.get('timestamp', datetime.utcnow().isoformat())),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(sensor_record)
            
            # Update device status
            await self._update_device_status(device_id, processed_data)
            
            # Check for alerts
            alerts = await self._check_sensor_alerts(device_id, processed_data, tenant_id)
            
            # Cache recent data for real-time access
            self.local_cache[f"{device_id}_recent"].append({
                "timestamp": datetime.utcnow().isoformat(),
                "data": processed_data
            })
            
            self.db.commit()
            
            return {
                "success": True,
                "device_id": device_id,
                "processed_data": processed_data,
                "alerts": alerts,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error processing sensor data: {e}")
            self.db.rollback()
            return {"error": "Sensor data processing failed"}

    async def send_device_command(self, device_id: str, command: str, 
                                 parameters: Dict[str, Any], tenant_id: str = "default") -> Dict[str, Any]:
        """Send command to IoT device"""
        try:
            # Validate device
            if device_id not in self.devices:
                return {"error": "Device not registered"}
            
            # Create command record
            command_record = models.DeviceCommand(
                device_id=device_id,
                command=command,
                parameters_json=json.dumps(parameters),
                status='sent',
                sent_at=datetime.utcnow(),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(command_record)
            self.db.commit()
            
            # Send via MQTT
            topic = f"farmos/commands/{device_id}/{command}"
            payload = {
                "command_id": command_record.id,
                "command": command,
                "parameters": parameters,
                "timestamp": datetime.utcnow().isoformat()
            }
            
            result = self.mqtt_client.publish(topic, json.dumps(payload))
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                return {
                    "success": True,
                    "command_id": command_record.id,
                    "device_id": device_id,
                    "command": command,
                    "status": "sent",
                    "message": "Command sent successfully"
                }
            else:
                command_record.status = 'failed'
                self.db.commit()
                return {"error": "Failed to send command"}
            
        except Exception as e:
            logger.error(f"Error sending device command: {e}")
            return {"error": "Command sending failed"}

    async def get_device_status(self, device_id: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Get real-time device status"""
        try:
            if device_id not in self.devices:
                return {"error": "Device not registered"}
            
            device = self.devices[device_id]
            
            # Get recent sensor data
            recent_data = list(self.local_cache.get(f"{device_id}_recent", []))
            
            # Get device health metrics
            health_metrics = await self._calculate_device_health(device_id)
            
            # Get active alerts
            active_alerts = self.db.query(models.IoTAlert).filter(
                and_(
                    models.IoTAlert.device_id == device_id,
                    models.IoTAlert.status == 'active',
                    models.IoTAlert.tenant_id == tenant_id
                )
            ).order_by(models.IoTAlert.created_at.desc()).limit(10).all()
            
            return {
                "success": True,
                "device_id": device_id,
                "device_name": device.device_name,
                "device_type": device.device_type,
                "status": device.status,
                "last_seen": device.last_seen.isoformat() if device.last_seen else None,
                "health_metrics": health_metrics,
                "recent_data": recent_data[-10:],  # Last 10 readings
                "active_alerts": [
                    {
                        "id": alert.id,
                        "alert_type": alert.alert_type,
                        "message": alert.message,
                        "severity": alert.severity,
                        "created_at": alert.created_at.isoformat()
                    }
                    for alert in active_alerts
                ]
            }
            
        except Exception as e:
            logger.error(f"Error getting device status: {e}")
            return {"error": "Device status retrieval failed"}

    async def get_iot_analytics(self, start_date: str, end_date: str, 
                              tenant_id: str = "default") -> Dict[str, Any]:
        """Get IoT analytics and insights"""
        try:
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            # Get sensor data statistics
            sensor_stats = await self._get_sensor_statistics(start_dt, end_dt, tenant_id)
            
            # Get device performance metrics
            device_performance = await self._get_device_performance(start_dt, end_dt, tenant_id)
            
            # Get alert analytics
            alert_analytics = await self._get_alert_analytics(start_dt, end_dt, tenant_id)
            
            # Get data quality metrics
            data_quality = await self._get_data_quality_metrics(start_dt, end_dt, tenant_id)
            
            return {
                "period": {"start": start_date, "end": end_date},
                "sensor_statistics": sensor_stats,
                "device_performance": device_performance,
                "alert_analytics": alert_analytics,
                "data_quality": data_quality
            }
            
        except Exception as e:
            logger.error(f"Error getting IoT analytics: {e}")
            return {"error": "IoT analytics retrieval failed"}

    # MQTT Callbacks
    def _on_connect(self, client, userdata, flags, rc):
        """MQTT connection callback"""
        if rc == 0:
            self.connected = True
            logger.info("Connected to MQTT broker")
            
            # Subscribe to topics
            for topic in self.topics.values():
                client.subscribe(topic)
                logger.info(f"Subscribed to topic: {topic}")
        else:
            logger.error(f"Failed to connect to MQTT broker: {rc}")

    def _on_message(self, client, userdata, msg):
        """MQTT message callback"""
        try:
            topic = msg.topic
            payload = json.loads(msg.payload.decode())
            
            # Route message based on topic
            if "sensors" in topic and "data" in topic:
                self.sensor_data_queue.put((topic, payload))
            elif "alerts" in topic:
                self.alert_queue.put((topic, payload))
            elif "status" in topic:
                asyncio.create_task(self._handle_status_update(topic, payload))
            
        except Exception as e:
            logger.error(f"Error processing MQTT message: {e}")

    def _on_disconnect(self, client, userdata, rc):
        """MQTT disconnection callback"""
        self.connected = False
        logger.warning(f"Disconnected from MQTT broker: {rc}")

    def _on_publish(self, client, userdata, mid):
        """MQTT publish callback"""
        logger.debug(f"Message published: {mid}")

    # Processing Methods
    async def _start_processing_threads(self):
        """Start background processing threads"""
        try:
            # Sensor data processing thread
            sensor_thread = threading.Thread(
                target=self._process_sensor_queue,
                daemon=True
            )
            sensor_thread.start()
            self.processing_threads.append(sensor_thread)
            
            # Alert processing thread
            alert_thread = threading.Thread(
                target=self._process_alert_queue,
                daemon=True
            )
            alert_thread.start()
            self.processing_threads.append(alert_thread)
            
            logger.info("Processing threads started")
            
        except Exception as e:
            logger.error(f"Error starting processing threads: {e}")

    def _process_sensor_queue(self):
        """Process sensor data from queue"""
        while True:
            try:
                if not self.sensor_data_queue.empty():
                    topic, payload = self.sensor_data_queue.get()
                    asyncio.run(self._handle_sensor_data(topic, payload))
                else:
                    threading.Event().wait(0.1)  # Small delay
            except Exception as e:
                logger.error(f"Error processing sensor queue: {e}")

    def _process_alert_queue(self):
        """Process alerts from queue"""
        while True:
            try:
                if not self.alert_queue.empty():
                    topic, payload = self.alert_queue.get()
                    asyncio.run(self._handle_device_alert(topic, payload))
                else:
                    threading.Event().wait(0.1)  # Small delay
            except Exception as e:
                logger.error(f"Error processing alert queue: {e}")

    async def _handle_sensor_data(self, topic: str, payload: Dict):
        """Handle incoming sensor data"""
        try:
            device_id = payload.get('device_id')
            if device_id and device_id in self.devices:
                await self.process_sensor_data(device_id, payload)
        except Exception as e:
            logger.error(f"Error handling sensor data: {e}")

    async def _handle_device_alert(self, topic: str, payload: Dict):
        """Handle device alert"""
        try:
            device_id = payload.get('device_id')
            if device_id:
                # Store alert
                alert = models.IoTAlert(
                    device_id=device_id,
                    alert_type=payload.get('alert_type'),
                    message=payload.get('message'),
                    severity=payload.get('severity', 'medium'),
                    alert_data_json=json.dumps(payload),
                    status='active',
                    tenant_id=payload.get('tenant_id', 'default'),
                    created_at=datetime.utcnow()
                )
                
                self.db.add(alert)
                self.db.commit()
                
                # Send notification
                await self._send_alert_notification(alert)
                
        except Exception as e:
            logger.error(f"Error handling device alert: {e}")

    async def _handle_status_update(self, topic: str, payload: Dict):
        """Handle device status update"""
        try:
            device_id = payload.get('device_id')
            if device_id and device_id in self.devices:
                device = self.devices[device_id]
                device.status = payload.get('status', 'unknown')
                device.last_seen = datetime.utcnow()
                device.battery_level = payload.get('battery_level')
                device.signal_strength = payload.get('signal_strength')
                
                self.db.commit()
                
        except Exception as e:
            logger.error(f"Error handling status update: {e}")

    # Edge Computing Methods
    async def _initialize_edge_processors(self):
        """Initialize edge computing processors"""
        try:
            # Temperature anomaly detection
            self.edge_processors['temperature_anomaly'] = self._temperature_anomaly_processor
            
            # Vibration analysis
            self.edge_processors['vibration_analysis'] = self._vibration_analysis_processor
            
            # Data quality assessment
            self.edge_processors['data_quality'] = self._data_quality_processor
            
            # Predictive maintenance
            self.edge_processors['predictive_maintenance'] = self._predictive_maintenance_processor
            
            logger.info("Edge processors initialized")
            
        except Exception as e:
            logger.error(f"Error initializing edge processors: {e}")

    async def _edge_process_sensor_data(self, device_id: str, sensor_data: Dict) -> Dict:
        """Process sensor data through edge computing"""
        try:
            processed_data = sensor_data.copy()
            
            # Apply relevant processors
            sensor_type = sensor_data.get('sensor_type')
            
            if sensor_type == 'temperature':
                processed_data.update(await self.edge_processors['temperature_anomaly'](sensor_data))
            elif sensor_type == 'vibration':
                processed_data.update(await self.edge_processors['vibration_analysis'](sensor_data))
            
            # Apply data quality processor to all data
            quality_result = await self.edge_processors['data_quality'](sensor_data)
            processed_data['quality_score'] = quality_result['quality_score']
            processed_data['quality_flags'] = quality_result['flags']
            
            # Apply predictive maintenance processor
            maintenance_result = await self.edge_processors['predictive_maintenance'](device_id, sensor_data)
            processed_data['maintenance_prediction'] = maintenance_result
            
            return processed_data
            
        except Exception as e:
            logger.error(f"Error in edge processing: {e}")
            return sensor_data

    async def _temperature_anomaly_processor(self, sensor_data: Dict) -> Dict:
        """Temperature anomaly detection processor"""
        try:
            value = sensor_data.get('value', 0)
            device_id = sensor_data.get('device_id')
            
            # Get recent temperature data
            recent_data = list(self.local_cache.get(f"{device_id}_recent", []))
            
            if len(recent_data) >= 10:
                recent_temps = [d['data'].get('value', 0) for d in recent_data[-10:]]
                mean_temp = np.mean(recent_temps)
                std_temp = np.std(recent_temps)
                
                # Z-score anomaly detection
                z_score = abs(value - mean_temp) / std_temp if std_temp > 0 else 0
                
                return {
                    'anomaly_detected': z_score > 2.5,
                    'anomaly_score': z_score,
                    'temperature_trend': 'increasing' if value > mean_temp else 'decreasing',
                    'deviation_from_mean': value - mean_temp
                }
            
            return {
                'anomaly_detected': False,
                'anomaly_score': 0,
                'temperature_trend': 'stable',
                'deviation_from_mean': 0
            }
            
        except Exception as e:
            logger.error(f"Error in temperature anomaly processor: {e}")
            return {}

    async def _vibration_analysis_processor(self, sensor_data: Dict) -> Dict:
        """Vibration analysis processor"""
        try:
            value = sensor_data.get('value', 0)
            
            # Vibration severity levels
            if value < 0.1:
                severity = 'normal'
                risk_score = 0
            elif value < 0.3:
                severity = 'minor'
                risk_score = 25
            elif value < 0.5:
                severity = 'moderate'
                risk_score = 50
            elif value < 1.0:
                severity = 'severe'
                risk_score = 75
            else:
                severity = 'critical'
                risk_score = 100
            
            return {
                'vibration_severity': severity,
                'risk_score': risk_score,
                'maintenance_required': risk_score > 50,
                'estimated_remaining_hours': max(0, 100 - risk_score) * 10
            }
            
        except Exception as e:
            logger.error(f"Error in vibration analysis processor: {e}")
            return {}

    async def _data_quality_processor(self, sensor_data: Dict) -> Dict:
        """Data quality assessment processor"""
        try:
            value = sensor_data.get('value')
            flags = []
            quality_score = 1.0
            
            # Check for null/invalid values
            if value is None:
                flags.append('null_value')
                quality_score -= 0.5
            
            # Check for out-of-range values
            sensor_type = sensor_data.get('sensor_type')
            if sensor_type == 'temperature' and (value < -50 or value > 100):
                flags.append('out_of_range')
                quality_score -= 0.3
            elif sensor_type == 'humidity' and (value < 0 or value > 100):
                flags.append('out_of_range')
                quality_score -= 0.3
            
            # Check timestamp freshness
            timestamp = sensor_data.get('timestamp')
            if timestamp:
                try:
                    data_time = datetime.fromisoformat(timestamp)
                    age_minutes = (datetime.utcnow() - data_time).total_seconds() / 60
                    
                    if age_minutes > 60:
                        flags.append('stale_data')
                        quality_score -= 0.2
                except:
                    flags.append('invalid_timestamp')
                    quality_score -= 0.2
            
            return {
                'quality_score': max(0, quality_score),
                'flags': flags,
                'data_freshness_minutes': age_minutes if 'age_minutes' in locals() else 0
            }
            
        except Exception as e:
            logger.error(f"Error in data quality processor: {e}")
            return {'quality_score': 0, 'flags': ['processing_error']}

    async def _predictive_maintenance_processor(self, device_id: str, sensor_data: Dict) -> Dict:
        """Predictive maintenance processor"""
        try:
            # Get device maintenance history
            maintenance_history = self.db.query(models.DeviceMaintenance).filter(
                models.DeviceMaintenance.device_id == device_id
            ).order_by(models.DeviceMaintenance.maintenance_date.desc()).limit(5).all()
            
            # Simple rule-based prediction
            sensor_type = sensor_data.get('sensor_type')
            value = sensor_data.get('value', 0)
            
            maintenance_needed = False
            urgency = 'low'
            estimated_days = 30
            
            if sensor_type == 'vibration' and value > 0.5:
                maintenance_needed = True
                urgency = 'high' if value > 1.0 else 'medium'
                estimated_days = max(1, int((1.0 - value) * 30))
            elif sensor_type == 'temperature' and value > 80:
                maintenance_needed = True
                urgency = 'medium'
                estimated_days = 7
            
            return {
                'maintenance_needed': maintenance_needed,
                'urgency': urgency,
                'estimated_days_until_maintenance': estimated_days,
                'confidence': 0.7  # Simple confidence score
            }
            
        except Exception as e:
            logger.error(f"Error in predictive maintenance processor: {e}")
            return {}

    # Helper Methods
    async def _subscribe_to_device_topics(self, device_id: str):
        """Subscribe to device-specific topics"""
        try:
            topics = [
                f"farmos/sensors/{device_id}/data",
                f"farmos/status/{device_id}/+",
                f"farmos/alerts/{device_id}/+"
            ]
            
            for topic in topics:
                self.mqtt_client.subscribe(topic)
                logger.info(f"Subscribed to device topic: {topic}")
                
        except Exception as e:
            logger.error(f"Error subscribing to device topics: {e}")

    async def _send_device_configuration(self, device_id: str):
        """Send configuration to device"""
        try:
            config = self.device_configs.get(device_id, {})
            topic = f"farmos/config/{device_id}"
            
            payload = {
                "device_id": device_id,
                "configuration": config,
                "timestamp": datetime.utcnow().isoformat()
            }
            
            self.mqtt_client.publish(topic, json.dumps(payload))
            
        except Exception as e:
            logger.error(f"Error sending device configuration: {e}")

    async def _update_device_status(self, device_id: str, processed_data: Dict):
        """Update device status based on processed data"""
        try:
            if device_id in self.devices:
                device = self.devices[device_id]
                device.last_seen = datetime.utcnow()
                
                # Update battery level if available
                if 'battery_level' in processed_data:
                    device.battery_level = processed_data['battery_level']
                
                # Update status based on data quality
                quality_score = processed_data.get('quality_score', 1.0)
                if quality_score < 0.5:
                    device.status = 'warning'
                elif quality_score < 0.2:
                    device.status = 'error'
                else:
                    device.status = 'active'
                
                self.db.commit()
                
        except Exception as e:
            logger.error(f"Error updating device status: {e}")

    async def _check_sensor_alerts(self, device_id: str, processed_data: Dict, tenant_id: str) -> List[Dict]:
        """Check for sensor alerts"""
        try:
            alerts = []
            
            # Check for anomalies
            if processed_data.get('anomaly_detected'):
                alerts.append({
                    "type": "anomaly",
                    "message": f"Anomaly detected in sensor data",
                    "severity": "warning"
                })
            
            # Check maintenance predictions
            maintenance_pred = processed_data.get('maintenance_prediction', {})
            if maintenance_pred.get('maintenance_needed'):
                alerts.append({
                    "type": "maintenance",
                    "message": f"Maintenance required (urgency: {maintenance_pred.get('urgency')})",
                    "severity": maintenance_pred.get('urgency', 'low')
                })
            
            # Check data quality
            quality_score = processed_data.get('quality_score', 1.0)
            if quality_score < 0.3:
                alerts.append({
                    "type": "data_quality",
                    "message": f"Poor data quality detected (score: {quality_score:.2f})",
                    "severity": "warning"
                })
            
            # Store alerts in database
            for alert in alerts:
                alert_record = models.IoTAlert(
                    device_id=device_id,
                    alert_type=alert["type"],
                    message=alert["message"],
                    severity=alert["severity"],
                    alert_data_json=json.dumps(processed_data),
                    status='active',
                    tenant_id=tenant_id,
                    created_at=datetime.utcnow()
                )
                self.db.add(alert_record)
            
            return alerts
            
        except Exception as e:
            logger.error(f"Error checking sensor alerts: {e}")
            return []

    async def _calculate_device_health(self, device_id: str) -> Dict[str, Any]:
        """Calculate device health metrics"""
        try:
            device = self.devices[device_id]
            
            # Get recent data quality scores
            recent_data = list(self.local_cache.get(f"{device_id}_recent", []))
            
            if recent_data:
                quality_scores = [d['data'].get('quality_score', 1.0) for d in recent_data[-20:]]
                avg_quality = np.mean(quality_scores)
            else:
                avg_quality = 0.5
            
            # Calculate uptime (simplified)
            uptime_percentage = 95.0  # Default
            
            # Calculate battery health
            battery_health = (device.battery_level / 100 * 100) if device.battery_level else 100
            
            # Overall health score
            overall_health = (avg_quality * 0.4 + uptime_percentage * 0.3 + battery_health * 0.3)
            
            return {
                "overall_health": overall_health,
                "data_quality": avg_quality * 100,
                "uptime_percentage": uptime_percentage,
                "battery_health": battery_health,
                "health_status": "excellent" if overall_health > 90 else "good" if overall_health > 70 else "fair" if overall_health > 50 else "poor"
            }
            
        except Exception as e:
            logger.error(f"Error calculating device health: {e}")
            return {"overall_health": 0}

    async def _send_alert_notification(self, alert: models.IoTAlert):
        """Send alert notification"""
        try:
            # This would integrate with notification system
            logger.info(f"Alert notification sent: {alert.message}")
        except Exception as e:
            logger.error(f"Error sending alert notification: {e}")

    async def _get_sensor_statistics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get sensor data statistics"""
        try:
            sensor_data = self.db.query(models.SensorData).filter(
                and_(
                    models.SensorData.timestamp >= start_dt,
                    models.SensorData.timestamp <= end_dt,
                    models.SensorData.tenant_id == tenant_id
                )
            ).all()
            
            if not sensor_data:
                return {"total_readings": 0}
            
            # Group by sensor type
            sensor_types = defaultdict(list)
            for data in sensor_data:
                sensor_types[data.sensor_type].append(data.value)
            
            statistics = {}
            for sensor_type, values in sensor_types.items():
                statistics[sensor_type] = {
                    "count": len(values),
                    "min": min(values),
                    "max": max(values),
                    "avg": sum(values) / len(values),
                    "std": np.std(values)
                }
            
            return {
                "total_readings": len(sensor_data),
                "sensor_types": statistics,
                "data_points_per_hour": len(sensor_data) / ((end_dt - start_dt).total_seconds() / 3600)
            }
            
        except Exception as e:
            logger.error(f"Error getting sensor statistics: {e}")
            return {}

    async def _get_device_performance(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get device performance metrics"""
        try:
            devices = self.db.query(models.IoTDevice).filter(
                models.IoTDevice.tenant_id == tenant_id
            ).all()
            
            performance = {}
            for device in devices:
                # Get device uptime (simplified)
                uptime = 95.0  # Default
                
                # Get data quality
                device_data = self.db.query(models.SensorData).filter(
                    and_(
                        models.SensorData.device_id == device.device_id,
                        models.SensorData.timestamp >= start_dt,
                        models.SensorData.timestamp <= end_dt
                    )
                ).all()
                
                if device_data:
                    quality_scores = [d.quality_score for d in device_data]
                    avg_quality = sum(quality_scores) / len(quality_scores)
                else:
                    avg_quality = 0
                
                performance[device.device_id] = {
                    "device_name": device.device_name,
                    "device_type": device.device_type,
                    "uptime_percentage": uptime,
                    "data_quality": avg_quality * 100,
                    "total_readings": len(device_data),
                    "status": device.status
                }
            
            return performance
            
        except Exception as e:
            logger.error(f"Error getting device performance: {e}")
            return {}

    async def _get_alert_analytics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get alert analytics"""
        try:
            alerts = self.db.query(models.IoTAlert).filter(
                and_(
                    models.IoTAlert.created_at >= start_dt,
                    models.IoTAlert.created_at <= end_dt,
                    models.IoTAlert.tenant_id == tenant_id
                )
            ).all()
            
            if not alerts:
                return {"total_alerts": 0}
            
            # Group by severity
            severity_counts = defaultdict(int)
            type_counts = defaultdict(int)
            
            for alert in alerts:
                severity_counts[alert.severity] += 1
                type_counts[alert.alert_type] += 1
            
            return {
                "total_alerts": len(alerts),
                "severity_breakdown": dict(severity_counts),
                "type_breakdown": dict(type_counts),
                "alerts_per_day": len(alerts) / ((end_dt - start_dt).days or 1)
            }
            
        except Exception as e:
            logger.error(f"Error getting alert analytics: {e}")
            return {}

    async def _get_data_quality_metrics(self, start_dt: datetime, end_dt: datetime, tenant_id: str) -> Dict:
        """Get data quality metrics"""
        try:
            sensor_data = self.db.query(models.SensorData).filter(
                and_(
                    models.SensorData.timestamp >= start_dt,
                    models.SensorData.timestamp <= end_dt,
                    models.SensorData.tenant_id == tenant_id
                )
            ).all()
            
            if not sensor_data:
                return {"average_quality": 0}
            
            quality_scores = [d.quality_score for d in sensor_data]
            
            return {
                "average_quality": sum(quality_scores) / len(quality_scores),
                "quality_distribution": {
                    "excellent": len([q for q in quality_scores if q > 0.9]),
                    "good": len([q for q in quality_scores if 0.7 < q <= 0.9]),
                    "fair": len([q for q in quality_scores if 0.5 < q <= 0.7]),
                    "poor": len([q for q in quality_scores if q <= 0.5])
                },
                "total_data_points": len(sensor_data)
            }
            
        except Exception as e:
            logger.error(f"Error getting data quality metrics: {e}")
            return {}
