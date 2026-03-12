"""
Enhanced Auto-scaling - Phase 4 Feature
Advanced auto-scaling with cloud integration, predictive scaling, and resource optimization
Derived from Begin Reference System
"""

import logging
import asyncio
import json
import numpy as np
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, timedelta
from collections import defaultdict, deque
import statistics
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)

class ScalingDirection(Enum):
    SCALE_OUT = "scale_out"
    SCALE_IN = "scale_in"
    SCALE_UP = "scale_up"
    SCALE_DOWN = "scale_down"

class ScalingPolicy(Enum):
    MANUAL = "manual"
    SCHEDULED = "scheduled"
    REACTIVE = "reactive"
    PREDICTIVE = "predictive"

@dataclass
class ScalingMetric:
    name: str
    current_value: float
    threshold_min: float
    threshold_max: float
    unit: str
    timestamp: datetime

@dataclass
class ScalingRule:
    rule_id: str
    metric_name: str
    condition: str  # gt, lt, eq
    threshold: float
    duration: int  # seconds
    scaling_action: ScalingDirection
    adjustment: int  # number of instances

class CloudProvider:
    """Abstract cloud provider interface"""
    
    async def scale_instances(self, service_name: str, direction: ScalingDirection, 
                            count: int) -> Dict[str, Any]:
        """Scale instances up or down"""
        raise NotImplementedError
    
    async def get_instance_metrics(self, service_name: str) -> List[ScalingMetric]:
        """Get metrics for instances"""
        raise NotImplementedError
    
    async def get_current_capacity(self, service_name: str) -> Dict[str, Any]:
        """Get current capacity information"""
        raise NotImplementedError

class AWSProvider(CloudProvider):
    """AWS cloud provider implementation"""
    
    def __init__(self, access_key: str, secret_key: str, region: str):
        self.access_key = access_key
        self.secret_key = secret_key
        self.region = region
        self.ec2_client = None  # Would initialize boto3 client
        self.cloudwatch_client = None  # Would initialize CloudWatch client
    
    async def scale_instances(self, service_name: str, direction: ScalingDirection, 
                            count: int) -> Dict[str, Any]:
        """Scale AWS instances"""
        try:
            # This would use boto3 to scale EC2 instances or ECS services
            # For now, return mock response
            
            if direction == ScalingDirection.SCALE_OUT:
                action = "scale_out"
                new_instances = count
            elif direction == ScalingDirection.SCALE_IN:
                action = "scale_in"
                new_instances = -count
            else:
                return {"error": "Unsupported scaling direction"}
            
            return {
                "success": True,
                "provider": "aws",
                "service_name": service_name,
                "action": action,
                "instance_count": abs(new_instances),
                "scaling_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error scaling AWS instances: {e}")
            return {"error": "AWS scaling failed"}
    
    async def get_instance_metrics(self, service_name: str) -> List[ScalingMetric]:
        """Get AWS CloudWatch metrics"""
        try:
            # This would use CloudWatch to get actual metrics
            # For now, return mock data
            
            metrics = [
                ScalingMetric(
                    name="cpu_utilization",
                    current_value=65.5,
                    threshold_min=20.0,
                    threshold_max=80.0,
                    unit="percent",
                    timestamp=datetime.utcnow()
                ),
                ScalingMetric(
                    name="memory_utilization",
                    current_value=45.2,
                    threshold_min=30.0,
                    threshold_max=85.0,
                    unit="percent",
                    timestamp=datetime.utcnow()
                ),
                ScalingMetric(
                    name="request_count",
                    current_value=1250,
                    threshold_min=100,
                    threshold_max=5000,
                    unit="count",
                    timestamp=datetime.utcnow()
                )
            ]
            
            return metrics
            
        except Exception as e:
            logger.error(f"Error getting AWS metrics: {e}")
            return []
    
    async def get_current_capacity(self, service_name: str) -> Dict[str, Any]:
        """Get current AWS capacity"""
        try:
            return {
                "current_instances": 3,
                "desired_instances": 3,
                "min_instances": 1,
                "max_instances": 10,
                "instance_type": "t3.medium",
                "auto_scaling_group": f"{service_name}-asg"
            }
        except Exception as e:
            logger.error(f"Error getting AWS capacity: {e}")
            return {}

class AzureProvider(CloudProvider):
    """Azure cloud provider implementation"""
    
    def __init__(self, subscription_id: str, client_id: str, client_secret: str, tenant_id: str):
        self.subscription_id = subscription_id
        self.client_id = client_id
        self.client_secret = client_secret
        self.tenant_id = tenant_id
        self.compute_client = None  # Would initialize Azure SDK client
        self.monitor_client = None  # Would initialize Monitor client
    
    async def scale_instances(self, service_name: str, direction: ScalingDirection, 
                            count: int) -> Dict[str, Any]:
        """Scale Azure instances"""
        try:
            # This would use Azure SDK to scale VM scale sets
            return {
                "success": True,
                "provider": "azure",
                "service_name": service_name,
                "action": direction.value,
                "instance_count": count,
                "scaling_timestamp": datetime.utcnow().isoformat()
            }
        except Exception as e:
            logger.error(f"Error scaling Azure instances: {e}")
            return {"error": "Azure scaling failed"}
    
    async def get_instance_metrics(self, service_name: str) -> List[ScalingMetric]:
        """Get Azure Monitor metrics"""
        try:
            # Mock Azure metrics
            return [
                ScalingMetric(
                    name="cpu_percentage",
                    current_value=58.3,
                    threshold_min=20.0,
                    threshold_max=80.0,
                    unit="percent",
                    timestamp=datetime.utcnow()
                )
            ]
        except Exception as e:
            logger.error(f"Error getting Azure metrics: {e}")
            return []
    
    async def get_current_capacity(self, service_name: str) -> Dict[str, Any]:
        """Get current Azure capacity"""
        try:
            return {
                "current_instances": 2,
                "desired_instances": 2,
                "min_instances": 1,
                "max_instances": 8,
                "vm_size": "Standard_D2s_v3",
                "scale_set": f"{service_name}-vmss"
            }
        except Exception as e:
            logger.error(f"Error getting Azure capacity: {e}")
            return {}

class PredictiveScalingEngine:
    """Predictive scaling using machine learning"""
    
    def __init__(self):
        self.historical_data = defaultdict(lambda: deque(maxlen=1000))
        self.models = {}
        self.prediction_window = 3600  # 1 hour prediction window
    
    async def train_model(self, service_name: str, metrics_history: List[Dict]):
        """Train predictive model for service"""
        try:
            # Extract features and targets
            features = []
            targets = []
            
            for data_point in metrics_history:
                feature_vector = [
                    data_point.get('cpu_utilization', 0),
                    data_point.get('memory_utilization', 0),
                    data_point.get('request_count', 0),
                    data_point.get('response_time', 0),
                    self._extract_time_features(data_point.get('timestamp'))
                ]
                
                features.append(feature_vector)
                targets.append(data_point.get('optimal_instances', 1))
            
            # Simple linear regression (in production, use proper ML library)
            if len(features) > 10:
                X = np.array(features)
                y = np.array(targets)
                
                # Train simple model
                coefficients = np.linalg.lstsq(X, y, rcond=None)[0]
                
                self.models[service_name] = {
                    'coefficients': coefficients.tolist(),
                    'trained_at': datetime.utcnow(),
                    'training_samples': len(features)
                }
                
                return {
                    "success": True,
                    "service_name": service_name,
                    "model_type": "linear_regression",
                    "training_samples": len(features),
                    "trained_at": datetime.utcnow().isoformat()
                }
            
            return {"error": "Insufficient training data"}
            
        except Exception as e:
            logger.error(f"Error training predictive model: {e}")
            return {"error": "Model training failed"}
    
    async def predict_scaling_needs(self, service_name: str, current_metrics: List[ScalingMetric]) -> Dict[str, Any]:
        """Predict future scaling needs"""
        try:
            if service_name not in self.models:
                return {"error": "No trained model for service"}
            
            model = self.models[service_name]
            coefficients = np.array(model['coefficients'])
            
            # Prepare current metrics as features
            features = [
                self._get_metric_value(current_metrics, 'cpu_utilization'),
                self._get_metric_value(current_metrics, 'memory_utilization'),
                self._get_metric_value(current_metrics, 'request_count'),
                self._get_metric_value(current_metrics, 'response_time', 0),
                *self._extract_time_features(datetime.utcnow())
            ]
            
            # Make prediction
            predicted_instances = np.dot(features, coefficients)
            predicted_instances = max(1, int(predicted_instances))
            
            # Calculate confidence
            confidence = self._calculate_prediction_confidence(service_name, features)
            
            return {
                "success": True,
                "service_name": service_name,
                "predicted_instances": predicted_instances,
                "confidence": confidence,
                "prediction_window": self.prediction_window,
                "prediction_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error predicting scaling needs: {e}")
            return {"error": "Prediction failed"}
    
    def _get_metric_value(self, metrics: List[ScalingMetric], metric_name: str, default: float = 0) -> float:
        """Get metric value by name"""
        for metric in metrics:
            if metric.name == metric_name:
                return metric.current_value
        return default
    
    def _extract_time_features(self, timestamp: datetime) -> List[float]:
        """Extract time-based features"""
        return [
            timestamp.hour / 24.0,  # Hour of day
            timestamp.weekday() / 7.0,  # Day of week
            (timestamp.day - 1) / 30.0  # Day of month
        ]
    
    def _calculate_prediction_confidence(self, service_name: str, features: List[float]) -> float:
        """Calculate prediction confidence"""
        # Simple confidence calculation based on training data recency
        model = self.models.get(service_name, {})
        trained_at = model.get('trained_at')
        
        if trained_at:
            hours_old = (datetime.utcnow() - trained_at).total_seconds() / 3600
            confidence = max(0.5, 1.0 - (hours_old / 168))  # Decay over 1 week
        else:
            confidence = 0.5
        
        return confidence

class EnhancedAutoScalingService:
    """Enhanced auto-scaling service with predictive capabilities"""
    
    def __init__(self):
        self.providers: Dict[str, CloudProvider] = {}
        self.scaling_policies: Dict[str, Dict] = {}
        self.scaling_rules: Dict[str, List[ScalingRule]] = {}
        self.predictive_engine = PredictiveScalingEngine()
        self.scaling_history: List[Dict] = []
        self.metrics_buffer = defaultdict(lambda: deque(maxlen=100))
        
    async def register_cloud_provider(self, provider_name: str, provider_config: Dict[str, Any]) -> Dict[str, Any]:
        """Register cloud provider"""
        try:
            provider_type = provider_config.get('type').lower()
            
            if provider_type == 'aws':
                provider = AWSProvider(
                    provider_config['access_key'],
                    provider_config['secret_key'],
                    provider_config['region']
                )
            elif provider_type == 'azure':
                provider = AzureProvider(
                    provider_config['subscription_id'],
                    provider_config['client_id'],
                    provider_config['client_secret'],
                    provider_config['tenant_id']
                )
            else:
                return {"error": f"Unsupported provider type: {provider_type}"}
            
            self.providers[provider_name] = provider
            
            return {
                "success": True,
                "provider_name": provider_name,
                "provider_type": provider_type,
                "registered_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error registering cloud provider: {e}")
            return {"error": "Provider registration failed"}
    
    async def configure_auto_scaling(self, service_name: str, scaling_config: Dict[str, Any]) -> Dict[str, Any]:
        """Configure auto-scaling for service"""
        try:
            # Validate configuration
            required_fields = ['provider', 'min_instances', 'max_instances', 'policy']
            for field in required_fields:
                if field not in scaling_config:
                    return {"error": f"Missing required field: {field}"}
            
            # Store scaling policy
            self.scaling_policies[service_name] = {
                **scaling_config,
                "configured_at": datetime.utcnow().isoformat(),
                "status": "active"
            }
            
            # Configure scaling rules
            rules = scaling_config.get('rules', [])
            scaling_rules = []
            
            for rule_config in rules:
                rule = ScalingRule(
                    rule_id=rule_config['rule_id'],
                    metric_name=rule_config['metric_name'],
                    condition=rule_config['condition'],
                    threshold=rule_config['threshold'],
                    duration=rule_config.get('duration', 300),
                    scaling_action=ScalingDirection(rule_config['scaling_action']),
                    adjustment=rule_config['adjustment']
                )
                scaling_rules.append(rule)
            
            self.scaling_rules[service_name] = scaling_rules
            
            # Train predictive model if data available
            if scaling_config.get('policy') == ScalingPolicy.PREDICTIVE.value:
                historical_data = scaling_config.get('historical_data', [])
                if historical_data:
                    await self.predictive_engine.train_model(service_name, historical_data)
            
            return {
                "success": True,
                "service_name": service_name,
                "policy": scaling_config['policy'],
                "rules_count": len(scaling_rules),
                "configured_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error configuring auto-scaling: {e}")
            return {"error": "Auto-scaling configuration failed"}
    
    async def execute_scaling_decision(self, service_name: str, decision: Dict[str, Any]) -> Dict[str, Any]:
        """Execute scaling decision"""
        try:
            policy = self.scaling_policies.get(service_name)
            if not policy:
                return {"error": "No scaling policy configured for service"}
            
            provider_name = policy['provider']
            provider = self.providers.get(provider_name)
            if not provider:
                return {"error": f"Provider {provider_name} not found"}
            
            # Validate scaling decision
            direction = ScalingDirection(decision['direction'])
            adjustment = decision['adjustment']
            
            # Check scaling limits
            current_capacity = await provider.get_current_capacity(service_name)
            current_instances = current_capacity.get('current_instances', 0)
            
            new_instance_count = current_instances
            
            if direction in [ScalingDirection.SCALE_OUT, ScalingDirection.SCALE_UP]:
                new_instance_count = min(
                    current_instances + adjustment,
                    policy['max_instances']
                )
            elif direction in [ScalingDirection.SCALE_IN, ScalingDirection.SCALE_DOWN]:
                new_instance_count = max(
                    current_instances - adjustment,
                    policy['min_instances']
                )
            
            if new_instance_count == current_instances:
                return {"error": "No scaling needed (at limits)"}
            
            # Execute scaling
            scaling_result = await provider.scale_instances(
                service_name, direction, abs(new_instance_count - current_instances)
            )
            
            if scaling_result.get('success'):
                # Record scaling event
                scaling_event = {
                    "service_name": service_name,
                    "direction": direction.value,
                    "previous_instances": current_instances,
                    "new_instances": new_instance_count,
                    "adjustment": adjustment,
                    "provider": provider_name,
                    "reason": decision.get('reason', 'auto_scaling'),
                    "timestamp": datetime.utcnow().isoformat()
                }
                
                self.scaling_history.append(scaling_event)
                
                return {
                    "success": True,
                    "scaling_event": scaling_event,
                    "provider_result": scaling_result
                }
            else:
                return scaling_result
            
        except Exception as e:
            logger.error(f"Error executing scaling decision: {e}")
            return {"error": "Scaling execution failed"}
    
    async def monitor_and_scale(self, service_name: str) -> Dict[str, Any]:
        """Monitor metrics and trigger scaling if needed"""
        try:
            policy = self.scaling_policies.get(service_name)
            if not policy:
                return {"error": "No scaling policy configured"}
            
            provider_name = policy['provider']
            provider = self.providers.get(provider_name)
            if not provider:
                return {"error": "Provider not found"}
            
            # Get current metrics
            metrics = await provider.get_instance_metrics(service_name)
            
            # Store metrics in buffer
            for metric in metrics:
                self.metrics_buffer[f"{service_name}_{metric.name}"].append({
                    "value": metric.current_value,
                    "timestamp": metric.timestamp
                })
            
            # Check scaling rules
            scaling_decisions = await self._evaluate_scaling_rules(service_name, metrics)
            
            # Execute scaling decisions
            results = []
            for decision in scaling_decisions:
                result = await self.execute_scaling_decision(service_name, decision)
                results.append(result)
            
            # Predictive scaling if enabled
            predictive_result = None
            if policy.get('policy') == ScalingPolicy.PREDICTIVE.value:
                predictive_result = await self._predictive_scaling_check(service_name, metrics)
            
            return {
                "success": True,
                "service_name": service_name,
                "current_metrics": [m.__dict__ for m in metrics],
                "scaling_decisions": scaling_decisions,
                "scaling_results": results,
                "predictive_result": predictive_result,
                "monitoring_timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error monitoring and scaling: {e}")
            return {"error": "Monitoring and scaling failed"}
    
    async def _evaluate_scaling_rules(self, service_name: str, metrics: List[ScalingMetric]) -> List[Dict]:
        """Evaluate scaling rules against current metrics"""
        try:
            decisions = []
            rules = self.scaling_rules.get(service_name, [])
            
            for rule in rules:
                # Find matching metric
                metric = next((m for m in metrics if m.name == rule.metric_name), None)
                if not metric:
                    continue
                
                # Check condition
                condition_met = self._check_condition(metric.current_value, rule.condition, rule.threshold)
                
                if condition_met:
                    # Check duration requirement
                    if await self._check_duration_requirement(service_name, rule.metric_name, rule.duration):
                        decision = {
                            "direction": rule.scaling_action.value,
                            "adjustment": rule.adjustment,
                            "reason": f"Rule {rule.rule_id} triggered: {rule.metric_name} {rule.condition} {rule.threshold}",
                            "triggering_metric": rule.metric_name,
                            "current_value": metric.current_value
                        }
                        decisions.append(decision)
            
            return decisions
            
        except Exception as e:
            logger.error(f"Error evaluating scaling rules: {e}")
            return []
    
    def _check_condition(self, value: float, condition: str, threshold: float) -> bool:
        """Check if condition is met"""
        if condition == 'gt':
            return value > threshold
        elif condition == 'lt':
            return value < threshold
        elif condition == 'eq':
            return abs(value - threshold) < 0.01
        elif condition == 'gte':
            return value >= threshold
        elif condition == 'lte':
            return value <= threshold
        else:
            return False
    
    async def _check_duration_requirement(self, service_name: str, metric_name: str, duration: int) -> bool:
        """Check if condition has been met for required duration"""
        try:
            buffer_key = f"{service_name}_{metric_name}"
            metric_buffer = self.metrics_buffer[buffer_key]
            
            if len(metric_buffer) < duration:
                return False
            
            # Check if condition has been met for duration
            cutoff_time = datetime.utcnow() - timedelta(seconds=duration)
            recent_values = [
                entry['value'] for entry in metric_buffer
                if entry['timestamp'] >= cutoff_time
            ]
            
            return len(recent_values) >= duration
            
        except Exception as e:
            logger.error(f"Error checking duration requirement: {e}")
            return False
    
    async def _predictive_scaling_check(self, service_name: str, metrics: List[ScalingMetric]) -> Dict[str, Any]:
        """Perform predictive scaling check"""
        try:
            prediction = await self.predictive_engine.predict_scaling_needs(service_name, metrics)
            
            if prediction.get('success'):
                # Get current capacity
                policy = self.scaling_policies.get(service_name)
                provider = self.providers.get(policy['provider'])
                current_capacity = await provider.get_current_capacity(service_name)
                
                current_instances = current_capacity.get('current_instances', 0)
                predicted_instances = prediction['predicted_instances']
                
                # Determine if scaling is needed
                if predicted_instances > current_instances:
                    scaling_decision = {
                        "direction": ScalingDirection.SCALE_OUT.value,
                        "adjustment": predicted_instances - current_instances,
                        "reason": f"Predictive scaling: predicted need for {predicted_instances} instances",
                        "confidence": prediction['confidence']
                    }
                    
                    result = await self.execute_scaling_decision(service_name, scaling_decision)
                    
                    return {
                        "prediction": prediction,
                        "scaling_decision": scaling_decision,
                        "scaling_result": result
                    }
            
            return {"prediction": prediction}
            
        except Exception as e:
            logger.error(f"Error in predictive scaling check: {e}")
            return {"error": "Predictive scaling check failed"}
    
    async def get_scaling_analytics(self, service_name: Optional[str] = None, 
                                 start_date: Optional[str] = None, end_date: Optional[str] = None) -> Dict[str, Any]:
        """Get scaling analytics"""
        try:
            # Filter scaling history
            filtered_history = self.scaling_history
            
            if service_name:
                filtered_history = [h for h in filtered_history if h['service_name'] == service_name]
            
            if start_date:
                start_dt = datetime.strptime(start_date, '%Y-%m-%d')
                filtered_history = [h for h in filtered_history if datetime.fromisoformat(h['timestamp']) >= start_dt]
            
            if end_date:
                end_dt = datetime.strptime(end_date, '%Y-%m-%d')
                filtered_history = [h for h in filtered_history if datetime.fromisoformat(h['timestamp']) <= end_dt]
            
            # Calculate analytics
            analytics = {
                "total_scaling_events": len(filtered_history),
                "scale_out_events": len([h for h in filtered_history if h['direction'] == 'scale_out']),
                "scale_in_events": len([h for h in filtered_history if h['direction'] == 'scale_in']),
                "services": list(set(h['service_name'] for h in filtered_history)),
                "scaling_frequency": self._calculate_scaling_frequency(filtered_history),
                "average_adjustment": self._calculate_average_adjustment(filtered_history),
                "scaling_by_reason": self._group_by_reason(filtered_history)
            }
            
            return {
                "success": True,
                "analytics": analytics,
                "period": {
                    "start_date": start_date,
                    "end_date": end_date,
                    "service_filter": service_name
                }
            }
            
        except Exception as e:
            logger.error(f"Error getting scaling analytics: {e}")
            return {"error": "Analytics retrieval failed"}
    
    def _calculate_scaling_frequency(self, history: List[Dict]) -> float:
        """Calculate scaling frequency per day"""
        if not history:
            return 0
        
        # Get date range
        timestamps = [datetime.fromisoformat(h['timestamp']) for h in history]
        date_range = (max(timestamps) - min(timestamps)).days or 1
        
        return len(history) / date_range
    
    def _calculate_average_adjustment(self, history: List[Dict]) -> float:
        """Calculate average instance adjustment"""
        if not history:
            return 0
        
        adjustments = [h['adjustment'] for h in history]
        return sum(adjustments) / len(adjustments)
    
    def _group_by_reason(self, history: List[Dict]) -> Dict[str, int]:
        """Group scaling events by reason"""
        reasons = defaultdict(int)
        for event in history:
            reasons[event['reason']] += 1
        return dict(reasons)

# Global auto-scaling service instance
auto_scaling_service = EnhancedAutoScalingService()
