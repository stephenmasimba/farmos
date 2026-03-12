"""
Enhanced Weather Integration - Phase 2 Feature
OpenWeatherMap API integration with smart irrigation and climate prediction
Derived from Begin Reference System
"""

import logging
import asyncio
import aiohttp
import json
from typing import Dict, List, Optional, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from datetime import datetime, timedelta
from decimal import Decimal
import numpy as np

logger = logging.getLogger(__name__)

from ..common import models

class EnhancedWeatherService:
    """Advanced weather service with OpenWeatherMap integration and smart irrigation"""
    
    def __init__(self, db: Session, api_key: str = None):
        self.db = db
        self.api_key = api_key or "your_openweathermap_api_key"
        self.base_url = "https://api.openweathermap.org/data/2.5"
        self.onecall_url = "https://api.openweathermap.org/data/3.0"
        self.geocoding_url = "https://api.openweathermap.org/geo/1.0"
        
        # Weather thresholds for farming decisions
        self.thresholds = {
            'frost_warning': 2.0,  # Celsius
            'heat_stress': 35.0,    # Celsius
            'rain_threshold': 5.0,  # mm/day
            'wind_danger': 50.0,    # km/h
            'humidity_optimal_min': 40,  # %
            'humidity_optimal_max': 70,  # %
            'soil_moisture_min': 30,     # %
            'soil_moisture_max': 80      # %
        }

    async def get_current_weather(self, location: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Get current weather data for location"""
        try:
            # Get coordinates for location
            coords = await self._get_coordinates(location)
            if not coords:
                return {"error": "Location not found"}
            
            # Fetch current weather
            weather_url = f"{self.base_url}/weather"
            params = {
                "lat": coords['lat'],
                "lon": coords['lon'],
                "appid": self.api_key,
                "units": "metric"
            }
            
            async with aiohttp.ClientSession() as session:
                async with session.get(weather_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        # Process and save weather data
                        weather_data = await self._process_current_weather(data, location, tenant_id)
                        
                        # Generate farming recommendations
                        recommendations = await self._generate_weather_recommendations(weather_data, tenant_id)
                        
                        return {
                            "success": True,
                            "location": location,
                            "current_weather": weather_data,
                            "recommendations": recommendations,
                            "timestamp": datetime.utcnow().isoformat()
                        }
                    else:
                        return {"error": f"Weather API error: {response.status}"}
                        
        except Exception as e:
            logger.error(f"Error getting current weather: {e}")
            return {"error": "Weather data retrieval failed"}

    async def get_weather_forecast(self, location: str, days: int = 7, 
                                 tenant_id: str = "default") -> Dict[str, Any]:
        """Get weather forecast for specified days"""
        try:
            # Get coordinates for location
            coords = await self._get_coordinates(location)
            if not coords:
                return {"error": "Location not found"}
            
            # Fetch forecast data
            forecast_url = f"{self.base_url}/forecast"
            params = {
                "lat": coords['lat'],
                "lon": coords['lon'],
                "appid": self.api_key,
                "units": "metric",
                "cnt": days * 8  # 8 forecasts per day (3-hour intervals)
            }
            
            async with aiohttp.ClientSession() as session:
                async with session.get(forecast_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        # Process forecast data
                        forecast_data = await self._process_forecast_data(data, location, tenant_id)
                        
                        # Generate agricultural insights
                        insights = await self._generate_agricultural_insights(forecast_data, tenant_id)
                        
                        return {
                            "success": True,
                            "location": location,
                            "forecast_days": days,
                            "forecast_data": forecast_data,
                            "agricultural_insights": insights,
                            "timestamp": datetime.utcnow().isoformat()
                        }
                    else:
                        return {"error": f"Weather forecast error: {response.status}"}
                        
        except Exception as e:
            logger.error(f"Error getting weather forecast: {e}")
            return {"error": "Weather forecast retrieval failed"}

    async def get_historical_weather(self, location: str, start_date: str, 
                                   end_date: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Get historical weather data"""
        try:
            # Check database first
            start_dt = datetime.strptime(start_date, '%Y-%m-%d')
            end_dt = datetime.strptime(end_date, '%Y-%m-%d')
            
            weather_records = self.db.query(models.WeatherData).filter(
                and_(
                    models.WeatherData.location == location,
                    models.WeatherData.date >= start_dt.date(),
                    models.WeatherData.date <= end_dt.date(),
                    models.WeatherData.tenant_id == tenant_id
                )
            ).order_by(models.WeatherData.date).all()
            
            if weather_records:
                historical_data = [
                    {
                        "date": record.date.strftime('%Y-%m-%d'),
                        "temperature": record.temperature,
                        "humidity": record.humidity,
                        "rainfall": record.rainfall,
                        "wind_speed": record.wind_speed,
                        "pressure": record.pressure
                    }
                    for record in weather_records
                ]
                
                return {
                    "success": True,
                    "location": location,
                    "period": {"start": start_date, "end": end_date},
                    "historical_data": historical_data,
                    "data_source": "database"
                }
            
            # If not in database, would need to call historical weather API
            return {"error": "Historical data not available for this period"}
            
        except Exception as e:
            logger.error(f"Error getting historical weather: {e}")
            return {"error": "Historical weather retrieval failed"}

    async def calculate_smart_irrigation(self, field_id: int, tenant_id: str = "default") -> Dict[str, Any]:
        """Calculate smart irrigation recommendations based on weather and soil data"""
        try:
            # Get field information
            field = self.db.query(models.Field).filter(
                and_(
                    models.Field.id == field_id,
                    models.Field.tenant_id == tenant_id
                )
            ).first()
            
            if not field:
                return {"error": "Field not found"}
            
            # Get current weather for field location
            weather_result = await self.get_current_weather(field.location, tenant_id)
            if not weather_result.get("success"):
                return {"error": "Unable to get weather data"}
            
            # Get soil moisture data
            soil_data = await self._get_soil_moisture_data(field_id, tenant_id)
            
            # Get crop information
            crop_info = await self._get_active_crop_info(field_id, tenant_id)
            
            # Calculate irrigation needs
            irrigation_recommendation = await self._calculate_irrigation_needs(
                weather_result["current_weather"], soil_data, crop_info, field
            )
            
            # Generate irrigation schedule
            irrigation_schedule = await self._generate_irrigation_schedule(
                field, irrigation_recommendation, tenant_id
            )
            
            return {
                "success": True,
                "field_id": field_id,
                "field_name": field.name,
                "location": field.location,
                "current_weather": weather_result["current_weather"],
                "soil_data": soil_data,
                "crop_info": crop_info,
                "irrigation_recommendation": irrigation_recommendation,
                "irrigation_schedule": irrigation_schedule,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error calculating smart irrigation: {e}")
            return {"error": "Smart irrigation calculation failed"}

    async def get_weather_alerts(self, location: str, tenant_id: str = "default") -> Dict[str, Any]:
        """Get weather alerts and warnings for farming"""
        try:
            # Get current weather and forecast
            current_weather = await self.get_current_weather(location, tenant_id)
            forecast = await self.get_weather_forecast(location, 3, tenant_id)
            
            alerts = []
            
            if current_weather.get("success"):
                alerts.extend(await self._check_current_weather_alerts(
                    current_weather["current_weather"]
                ))
            
            if forecast.get("success"):
                alerts.extend(await self._check_forecast_alerts(
                    forecast["forecast_data"]
                ))
            
            # Categorize alerts by severity
            alert_categories = {
                "critical": [a for a in alerts if a["severity"] == "critical"],
                "warning": [a for a in alerts if a["severity"] == "warning"],
                "info": [a for a in alerts if a["severity"] == "info"]
            }
            
            return {
                "success": True,
                "location": location,
                "total_alerts": len(alerts),
                "alerts": alerts,
                "alert_categories": alert_categories,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting weather alerts: {e}")
            return {"error": "Weather alerts retrieval failed"}

    async def get_climate_prediction(self, location: str, months: int = 3, 
                                   tenant_id: str = "default") -> Dict[str, Any]:
        """Get long-term climate predictions and trends"""
        try:
            # Get historical data for trend analysis
            end_date = datetime.utcnow().strftime('%Y-%m-%d')
            start_date = (datetime.utcnow() - timedelta(days=365)).strftime('%Y-%m-%d')
            
            historical_result = await self.get_historical_weather(location, start_date, end_date, tenant_id)
            
            if not historical_result.get("success"):
                return {"error": "Insufficient historical data for prediction"}
            
            # Analyze trends
            trends = await self._analyze_climate_trends(historical_result["historical_data"])
            
            # Generate predictions
            predictions = await self._generate_climate_predictions(trends, months)
            
            # Agricultural impact assessment
            impact_assessment = await self._assess_agricultural_impact(predictions, tenant_id)
            
            return {
                "success": True,
                "location": location,
                "prediction_period_months": months,
                "historical_trends": trends,
                "climate_predictions": predictions,
                "agricultural_impact": impact_assessment,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting climate prediction: {e}")
            return {"error": "Climate prediction failed"}

    # Helper methods
    async def _get_coordinates(self, location: str) -> Optional[Dict[str, float]]:
        """Get coordinates for location using geocoding API"""
        try:
            geocoding_url = f"{self.geocoding_url}/direct"
            params = {
                "q": location,
                "limit": 1,
                "appid": self.api_key
            }
            
            async with aiohttp.ClientSession() as session:
                async with session.get(geocoding_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        if data:
                            return {
                                "lat": data[0]["lat"],
                                "lon": data[0]["lon"]
                            }
            return None
            
        except Exception as e:
            logger.error(f"Error getting coordinates: {e}")
            return None

    async def _process_current_weather(self, data: Dict, location: str, tenant_id: str) -> Dict[str, Any]:
        """Process current weather data"""
        try:
            weather_data = {
                "location": location,
                "temperature": data["main"]["temp"],
                "feels_like": data["main"]["feels_like"],
                "humidity": data["main"]["humidity"],
                "pressure": data["main"]["pressure"],
                "wind_speed": data["wind"]["speed"],
                "wind_direction": data["wind"].get("deg", 0),
                "visibility": data.get("visibility", 0) / 1000,  # Convert to km
                "cloud_cover": data["clouds"]["all"],
                "weather_condition": data["weather"][0]["main"],
                "weather_description": data["weather"][0]["description"],
                "sunrise": datetime.fromtimestamp(data["sys"]["sunrise"]).strftime('%H:%M'),
                "sunset": datetime.fromtimestamp(data["sys"]["sunset"]).strftime('%H:%M'),
                "data_time": datetime.fromtimestamp(data["dt"]).isoformat()
            }
            
            # Save to database
            weather_record = models.WeatherData(
                location=location,
                date=datetime.utcnow().date(),
                temperature=weather_data["temperature"],
                humidity=weather_data["humidity"],
                pressure=weather_data["pressure"],
                wind_speed=weather_data["wind_speed"],
                rainfall=data.get("rain", {}).get("1h", 0),  # Rain in last hour
                weather_condition=weather_data["weather_condition"],
                data_json=json.dumps(weather_data),
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(weather_record)
            self.db.commit()
            
            return weather_data
            
        except Exception as e:
            logger.error(f"Error processing current weather: {e}")
            return {}

    async def _process_forecast_data(self, data: Dict, location: str, tenant_id: str) -> Dict[str, Any]:
        """Process forecast weather data"""
        try:
            forecasts = []
            
            for item in data["list"]:
                forecast = {
                    "datetime": datetime.fromtimestamp(item["dt"]).isoformat(),
                    "temperature": item["main"]["temp"],
                    "feels_like": item["main"]["feels_like"],
                    "humidity": item["main"]["humidity"],
                    "pressure": item["main"]["pressure"],
                    "wind_speed": item["wind"]["speed"],
                    "wind_direction": item["wind"].get("deg", 0),
                    "cloud_cover": item["clouds"]["all"],
                    "weather_condition": item["weather"][0]["main"],
                    "weather_description": item["weather"][0]["description"],
                    "rain_probability": item.get("pop", 0) * 100,  # Convert to percentage
                    "rainfall": item.get("rain", {}).get("3h", 0)
                }
                forecasts.append(forecast)
            
            # Group by day
            daily_forecasts = {}
            for forecast in forecasts:
                date = forecast["datetime"][:10]
                if date not in daily_forecasts:
                    daily_forecasts[date] = []
                daily_forecasts[date].append(forecast)
            
            # Calculate daily summaries
            daily_summaries = {}
            for date, day_forecasts in daily_forecasts.items():
                temps = [f["temperature"] for f in day_forecasts]
                humidities = [f["humidity"] for f in day_forecasts]
                rainfalls = [f["rainfall"] for f in day_forecasts]
                
                daily_summaries[date] = {
                    "date": date,
                    "temp_min": min(temps),
                    "temp_max": max(temps),
                    "temp_avg": sum(temps) / len(temps),
                    "humidity_avg": sum(humidities) / len(humidities),
                    "total_rainfall": sum(rainfalls),
                    "rain_probability": max(f["rain_probability"] for f in day_forecasts),
                    "conditions": [f["weather_condition"] for f in day_forecasts],
                    "hourly_forecasts": day_forecasts
                }
            
            return {
                "location": location,
                "daily_forecasts": daily_summaries,
                "hourly_forecasts": forecasts
            }
            
        except Exception as e:
            logger.error(f"Error processing forecast data: {e}")
            return {}

    async def _generate_weather_recommendations(self, weather_data: Dict, tenant_id: str) -> List[Dict]:
        """Generate farming recommendations based on weather"""
        try:
            recommendations = []
            
            temp = weather_data.get("temperature", 0)
            humidity = weather_data.get("humidity", 0)
            wind_speed = weather_data.get("wind_speed", 0)
            condition = weather_data.get("weather_condition", "")
            
            # Temperature-based recommendations
            if temp < self.thresholds["frost_warning"]:
                recommendations.append({
                    "type": "frost_protection",
                    "priority": "high",
                    "message": f"Frost warning! Temperature is {temp}°C. Protect sensitive crops.",
                    "actions": ["Cover sensitive plants", "Use frost blankets", "Delay planting"]
                })
            elif temp > self.thresholds["heat_stress"]:
                recommendations.append({
                    "type": "heat_stress",
                    "priority": "high",
                    "message": f"Heat stress warning! Temperature is {temp}°C. Increase irrigation.",
                    "actions": ["Increase irrigation frequency", "Provide shade if possible", "Monitor for heat stress"]
                })
            
            # Humidity-based recommendations
            if humidity < self.thresholds["humidity_optimal_min"]:
                recommendations.append({
                    "type": "low_humidity",
                    "priority": "medium",
                    "message": f"Low humidity ({humidity}%). Consider misting for sensitive crops.",
                    "actions": ["Increase irrigation", "Use mulch to retain moisture", "Monitor plant stress"]
                })
            elif humidity > self.thresholds["humidity_optimal_max"]:
                recommendations.append({
                    "type": "high_humidity",
                    "priority": "medium",
                    "message": f"High humidity ({humidity}%). Watch for fungal diseases.",
                    "actions": ["Improve air circulation", "Monitor for disease", "Consider fungicide application"]
                })
            
            # Wind-based recommendations
            if wind_speed > self.thresholds["wind_danger"]:
                recommendations.append({
                    "type": "high_wind",
                    "priority": "high",
                    "message": f"High winds ({wind_speed} km/h). Secure equipment and protect crops.",
                    "actions": ["Secure loose items", "Delay pesticide application", "Check greenhouse structures"]
                })
            
            # Condition-based recommendations
            if condition == "Rain":
                recommendations.append({
                    "type": "rain",
                    "priority": "low",
                    "message": "Rain detected. Adjust outdoor activities accordingly.",
                    "actions": ["Delay pesticide application", "Check drainage", "Monitor soil moisture"]
                })
            elif condition == "Clear":
                recommendations.append({
                    "type": "clear_weather",
                    "priority": "low",
                    "message": "Clear weather. Good for field operations.",
                    "actions": ["Schedule field work", "Monitor irrigation needs", "Check pest activity"]
                })
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Error generating weather recommendations: {e}")
            return []

    async def _get_soil_moisture_data(self, field_id: int, tenant_id: str) -> Dict[str, Any]:
        """Get soil moisture data for field"""
        try:
            # Get latest soil sensor data
            sensor_data = self.db.query(models.SoilSensorData).filter(
                and_(
                    models.SoilSensorData.field_id == field_id,
                    models.SoilSensorData.tenant_id == tenant_id
                )
            ).order_by(models.SoilSensorData.timestamp.desc()).first()
            
            if sensor_data:
                return {
                    "soil_moisture": sensor_data.moisture_level,
                    "soil_temperature": sensor_data.soil_temperature,
                    "soil_ph": sensor_data.ph_level,
                    "timestamp": sensor_data.timestamp.isoformat()
                }
            
            # Return default values if no sensor data
            return {
                "soil_moisture": 50,  # Default 50%
                "soil_temperature": 20,  # Default 20°C
                "soil_ph": 6.5,  # Default pH
                "timestamp": None
            }
            
        except Exception as e:
            logger.error(f"Error getting soil moisture data: {e}")
            return {"soil_moisture": 50, "soil_temperature": 20, "soil_ph": 6.5}

    async def _get_active_crop_info(self, field_id: int, tenant_id: str) -> Dict[str, Any]:
        """Get active crop information for field"""
        try:
            crop_cycle = self.db.query(models.CropCycle).filter(
                and_(
                    models.CropCycle.field_id == field_id,
                    models.CropCycle.status == 'growing',
                    models.CropCycle.tenant_id == tenant_id
                )
            ).first()
            
            if crop_cycle:
                return {
                    "crop_type": crop_cycle.crop_type,
                    "crop_name": crop_cycle.crop_name,
                    "growth_stage": crop_cycle.growth_stage,
                    "planting_date": crop_cycle.planting_date.strftime('%Y-%m-%d'),
                    "water_requirements": await self._get_crop_water_requirements(crop_cycle.crop_type)
                }
            
            return {"crop_type": None, "crop_name": None, "growth_stage": None}
            
        except Exception as e:
            logger.error(f"Error getting crop info: {e}")
            return {}

    async def _get_crop_water_requirements(self, crop_type: str) -> Dict[str, Any]:
        """Get water requirements for crop type"""
        requirements = {
            "maize": {"daily_mm": 5, "optimal_moisture": 60, "critical_moisture": 30},
            "wheat": {"daily_mm": 4, "optimal_moisture": 55, "critical_moisture": 25},
            "soybean": {"daily_mm": 4.5, "optimal_moisture": 65, "critical_moisture": 35},
            "tomato": {"daily_mm": 6, "optimal_moisture": 70, "critical_moisture": 40},
            "potato": {"daily_mm": 5.5, "optimal_moisture": 75, "critical_moisture": 45}
        }
        
        return requirements.get(crop_type.lower(), {
            "daily_mm": 5, "optimal_moisture": 60, "critical_moisture": 30
        })

    async def _calculate_irrigation_needs(self, weather_data: Dict, soil_data: Dict, 
                                       crop_info: Dict, field: models.Field) -> Dict[str, Any]:
        """Calculate irrigation requirements"""
        try:
            current_moisture = soil_data.get("soil_moisture", 50)
            
            if crop_info.get("crop_type"):
                crop_requirements = crop_info.get("water_requirements", {})
                optimal_moisture = crop_requirements.get("optimal_moisture", 60)
                critical_moisture = crop_requirements.get("critical_moisture", 30)
                daily_water_need = crop_requirements.get("daily_mm", 5)
            else:
                optimal_moisture = 60
                critical_moisture = 30
                daily_water_need = 5
            
            # Calculate moisture deficit
            moisture_deficit = optimal_moisture - current_moisture
            
            # Factor in weather
            temp = weather_data.get("temperature", 20)
            humidity = weather_data.get("humidity", 50)
            wind_speed = weather_data.get("wind_speed", 0)
            
            # Adjust water need based on weather
            weather_factor = 1.0
            if temp > 30:
                weather_factor += 0.2  # Increase water need in heat
            if humidity < 40:
                weather_factor += 0.1  # Increase water need in low humidity
            if wind_speed > 15:
                weather_factor += 0.1  # Increase water need in wind
            
            adjusted_water_need = daily_water_need * weather_factor
            
            # Calculate irrigation amount
            if current_moisture < critical_moisture:
                irrigation_needed = True
                irrigation_amount = moisture_deficit * field.area_hectares * 10  # Convert to liters
                urgency = "critical"
            elif current_moisture < optimal_moisture:
                irrigation_needed = True
                irrigation_amount = moisture_deficit * field.area_hectares * 8
                urgency = "medium"
            else:
                irrigation_needed = False
                irrigation_amount = 0
                urgency = "low"
            
            return {
                "irrigation_needed": irrigation_needed,
                "irrigation_amount_liters": irrigation_amount,
                "irrigation_amount_mm": moisture_deficit,
                "current_moisture": current_moisture,
                "optimal_moisture": optimal_moisture,
                "urgency": urgency,
                "weather_factor": weather_factor,
                "recommendations": await self._generate_irrigation_recommendations(
                    irrigation_needed, urgency, current_moisture, optimal_moisture
                )
            }
            
        except Exception as e:
            logger.error(f"Error calculating irrigation needs: {e}")
            return {"irrigation_needed": False, "irrigation_amount_liters": 0}

    async def _generate_irrigation_recommendations(self, irrigation_needed: bool, urgency: str,
                                                current_moisture: float, optimal_moisture: float) -> List[str]:
        """Generate irrigation recommendations"""
        recommendations = []
        
        if irrigation_needed:
            if urgency == "critical":
                recommendations.append("Immediate irrigation required - soil moisture critically low")
                recommendations.append("Consider drip irrigation for water efficiency")
            elif urgency == "medium":
                recommendations.append("Schedule irrigation within 24 hours")
                recommendations.append("Monitor soil moisture levels closely")
            else:
                recommendations.append("Light irrigation recommended")
                recommendations.append("Can wait 2-3 days if rain forecasted")
        else:
            recommendations.append("No irrigation needed at this time")
            recommendations.append("Continue monitoring soil moisture")
        
        return recommendations

    async def _generate_irrigation_schedule(self, field: models.Field, 
                                           irrigation_recommendation: Dict, tenant_id: str) -> Dict[str, Any]:
        """Generate irrigation schedule"""
        try:
            if not irrigation_recommendation.get("irrigation_needed"):
                return {"schedule_needed": False}
            
            # Calculate irrigation duration based on flow rate
            flow_rate = 1000  # L/hour (default)
            irrigation_amount = irrigation_recommendation.get("irrigation_amount_liters", 0)
            duration_hours = irrigation_amount / flow_rate if flow_rate > 0 else 0
            
            # Schedule based on urgency
            urgency = irrigation_recommendation.get("urgency", "low")
            if urgency == "critical":
                start_time = datetime.utcnow() + timedelta(hours=1)
            elif urgency == "medium":
                start_time = datetime.utcnow() + timedelta(hours=6)
            else:
                start_time = datetime.utcnow() + timedelta(hours=12)
            
            # Create irrigation schedule record
            schedule = models.IrrigationSchedule(
                field_id=field.id,
                scheduled_start=start_time,
                estimated_duration_hours=duration_hours,
                irrigation_amount_liters=irrigation_amount,
                irrigation_type="drip",  # Default to drip irrigation
                status="scheduled",
                priority=urgency,
                tenant_id=tenant_id,
                created_at=datetime.utcnow()
            )
            
            self.db.add(schedule)
            self.db.commit()
            
            return {
                "schedule_needed": True,
                "schedule_id": schedule.id,
                "start_time": start_time.strftime('%Y-%m-%d %H:%M'),
                "duration_hours": duration_hours,
                "irrigation_amount_liters": irrigation_amount,
                "priority": urgency
            }
            
        except Exception as e:
            logger.error(f"Error generating irrigation schedule: {e}")
            return {"schedule_needed": False, "error": "Schedule generation failed"}

    async def _check_current_weather_alerts(self, weather_data: Dict) -> List[Dict]:
        """Check for current weather alerts"""
        alerts = []
        
        temp = weather_data.get("temperature", 0)
        humidity = weather_data.get("humidity", 0)
        wind_speed = weather_data.get("wind_speed", 0)
        condition = weather_data.get("weather_condition", "")
        
        # Temperature alerts
        if temp < self.thresholds["frost_warning"]:
            alerts.append({
                "type": "frost_warning",
                "severity": "critical",
                "message": f"Frost warning: {temp}°C",
                "recommendation": "Protect sensitive crops immediately"
            })
        
        if temp > self.thresholds["heat_stress"]:
            alerts.append({
                "type": "heat_stress",
                "severity": "warning",
                "message": f"Heat stress: {temp}°C",
                "recommendation": "Increase irrigation and provide shade"
            })
        
        # Wind alerts
        if wind_speed > self.thresholds["wind_danger"]:
            alerts.append({
                "type": "high_wind",
                "severity": "warning",
                "message": f"High winds: {wind_speed} km/h",
                "recommendation": "Secure equipment and delay spraying"
            })
        
        return alerts

    async def _check_forecast_alerts(self, forecast_data: Dict) -> List[Dict]:
        """Check for forecast weather alerts"""
        alerts = []
        
        for date, daily_data in forecast_data.get("daily_forecasts", {}).items():
            temp_min = daily_data.get("temp_min", 0)
            temp_max = daily_data.get("temp_max", 0)
            rain_probability = daily_data.get("rain_probability", 0)
            total_rainfall = daily_data.get("total_rainfall", 0)
            
            # Frost forecast
            if temp_min < self.thresholds["frost_warning"]:
                alerts.append({
                    "type": "frost_forecast",
                    "severity": "critical",
                    "date": date,
                    "message": f"Frost forecast: {temp_min}°C",
                    "recommendation": "Prepare frost protection for {date}"
                })
            
            # Heavy rain forecast
            if total_rainfall > self.thresholds["rain_threshold"]:
                alerts.append({
                    "type": "heavy_rain",
                    "severity": "warning",
                    "date": date,
                    "message": f"Heavy rain forecast: {total_rainfall}mm",
                    "recommendation": "Check drainage and delay field work on {date}"
                })
        
        return alerts

    async def _analyze_climate_trends(self, historical_data: List[Dict]) -> Dict[str, Any]:
        """Analyze climate trends from historical data"""
        try:
            if len(historical_data) < 30:
                return {"error": "Insufficient data for trend analysis"}
            
            # Extract temperature data
            temperatures = [d["temperature"] for d in historical_data if d.get("temperature")]
            rainfall = [d["rainfall"] for d in historical_data if d.get("rainfall")]
            
            # Calculate trends
            temp_trend = np.polyfit(range(len(temperatures)), temperatures, 1)[0]
            rain_trend = np.polyfit(range(len(rainfall)), rainfall, 1)[0]
            
            # Calculate averages
            avg_temp = np.mean(temperatures)
            avg_rainfall = np.mean(rainfall)
            
            return {
                "temperature_trend": "warming" if temp_trend > 0 else "cooling",
                "temperature_change_rate": temp_trend,
                "average_temperature": avg_temp,
                "rainfall_trend": "increasing" if rain_trend > 0 else "decreasing",
                "rainfall_change_rate": rain_trend,
                "average_rainfall": avg_rainfall,
                "data_points": len(historical_data)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing climate trends: {e}")
            return {}

    async def _generate_climate_predictions(self, trends: Dict, months: int) -> Dict[str, Any]:
        """Generate climate predictions based on trends"""
        try:
            predictions = []
            
            for month in range(1, months + 1):
                future_date = datetime.utcnow() + timedelta(days=30 * month)
                
                # Simple linear prediction based on trends
                temp_change = trends.get("temperature_change_rate", 0) * month
                rain_change = trends.get("rainfall_change_rate", 0) * month
                
                prediction = {
                    "month": future_date.strftime("%Y-%m"),
                    "predicted_temperature": trends.get("average_temperature", 20) + temp_change,
                    "predicted_rainfall": trends.get("average_rainfall", 50) + rain_change,
                    "confidence": max(50, 95 - (month * 5))  # Decreasing confidence over time
                }
                predictions.append(prediction)
            
            return {
                "predictions": predictions,
                "prediction_method": "linear_trend",
                "confidence_level": "medium"
            }
            
        except Exception as e:
            logger.error(f"Error generating climate predictions: {e}")
            return {}

    async def _assess_agricultural_impact(self, predictions: List[Dict], tenant_id: str) -> Dict[str, Any]:
        """Assess agricultural impact of climate predictions"""
        try:
            impacts = []
            
            for prediction in predictions:
                month = prediction["month"]
                temp = prediction["predicted_temperature"]
                rain = prediction["predicted_rainfall"]
                
                month_impacts = []
                
                # Temperature impacts
                if temp > 35:
                    month_impacts.append("High heat stress risk for crops")
                elif temp < 10:
                    month_impacts.append("Low temperature may slow growth")
                
                # Rainfall impacts
                if rain < 30:
                    month_impacts.append("Drought conditions expected")
                elif rain > 100:
                    month_impacts.append("Risk of waterlogging and disease")
                
                # Recommendations
                recommendations = []
                if temp > 35:
                    recommendations.append("Plan heat stress mitigation")
                if rain < 30:
                    recommendations.append("Prepare irrigation systems")
                if rain > 100:
                    recommendations.append("Ensure proper drainage")
                
                impacts.append({
                    "month": month,
                    "predicted_conditions": f"Temp: {temp:.1f}°C, Rain: {rain:.1f}mm",
                    "impacts": month_impacts,
                    "recommendations": recommendations,
                    "confidence": prediction["confidence"]
                })
            
            return {
                "monthly_impacts": impacts,
                "overall_assessment": "Climate change impacts require adaptive farming strategies",
                "key_recommendations": [
                    "Implement water conservation measures",
                    "Develop heat stress management plans",
                    "Consider drought-resistant crop varieties"
                ]
            }
            
        except Exception as e:
            logger.error(f"Error assessing agricultural impact: {e}")
            return {}

    async def _generate_agricultural_insights(self, forecast_data: Dict, tenant_id: str) -> List[Dict]:
        """Generate agricultural insights from forecast data"""
        try:
            insights = []
            
            daily_forecasts = forecast_data.get("daily_forecasts", {})
            
            # Analyze patterns
            consecutive_dry_days = 0
            consecutive_wet_days = 0
            high_temp_days = 0
            
            for date, daily_data in daily_forecasts.items():
                temp_max = daily_data.get("temp_max", 0)
                total_rainfall = daily_data.get("total_rainfall", 0)
                
                if total_rainfall < 1:
                    consecutive_dry_days += 1
                    consecutive_wet_days = 0
                elif total_rainfall > 5:
                    consecutive_wet_days += 1
                    consecutive_dry_days = 0
                else:
                    consecutive_dry_days = 0
                    consecutive_wet_days = 0
                
                if temp_max > 30:
                    high_temp_days += 1
            
            # Generate insights
            if consecutive_dry_days >= 3:
                insights.append({
                    "type": "dry_period",
                    "message": f"{consecutive_dry_days} consecutive dry days expected",
                    "recommendation": "Plan supplemental irrigation"
                })
            
            if consecutive_wet_days >= 3:
                insights.append({
                    "type": "wet_period",
                    "message": f"{consecutive_wet_days} consecutive wet days expected",
                    "recommendation": "Monitor for fungal diseases"
                })
            
            if high_temp_days >= 2:
                insights.append({
                    "type": "heat_period",
                    "message": f"{high_temp_days} days with high temperatures expected",
                    "recommendation": "Implement heat stress management"
                })
            
            return insights
            
        except Exception as e:
            logger.error(f"Error generating agricultural insights: {e}")
            return []
