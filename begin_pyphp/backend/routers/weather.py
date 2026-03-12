from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class WeatherLog(BaseModel):
    id: int
    temperature: float
    humidity: float
    precipitation: float
    wind_speed: float
    conditions: str
    timestamp: str

# Mock Data
weather_logs_db = [
    {"id": 1, "temperature": 22.5, "humidity": 55, "precipitation": 0, "wind_speed": 12, "conditions": "Sunny", "timestamp": "2023-10-27T08:00:00Z"},
    {"id": 2, "temperature": 24.0, "humidity": 50, "precipitation": 0, "wind_speed": 15, "conditions": "Partly Cloudy", "timestamp": "2023-10-27T12:00:00Z"},
]

@router.get("/logs")
async def get_all_logs():
    return weather_logs_db

@router.post("/logs")
async def create_log(log: WeatherLog):
    new_log = log.dict()
    new_log["id"] = len(weather_logs_db) + 1
    weather_logs_db.append(new_log)
    return new_log

@router.get("/current")
async def get_current_weather():
    # Simulate realistic weather based on month and random variance
    import random
    from datetime import datetime, timedelta
    
    now = datetime.utcnow()
    month = now.month
    hour = now.hour
    
    # Base temperature by season (assuming Southern Hemisphere / Zimbabwe context)
    # Summer: Oct-Mar (Hot/Wet), Winter: May-Aug (Cool/Dry)
    if 10 <= month or month <= 3:
        base_temp = 25.0
        rain_prob = 0.6
    else:
        base_temp = 15.0
        rain_prob = 0.1
        
    # Day/Night variance
    if 6 <= hour <= 18:
        temp = base_temp + random.uniform(0, 10)
        is_day = True
    else:
        temp = base_temp - random.uniform(0, 5)
        is_day = False
        
    # Simulate rain/conditions
    is_raining = random.random() < rain_prob
    
    if is_raining:
        conditions = "Rainy"
        humidity = random.uniform(70, 95)
    elif is_day:
        conditions = random.choice(["Sunny", "Partly Cloudy", "Cloudy"])
        humidity = random.uniform(40, 65)
    else:
        conditions = random.choice(["Clear", "Partly Cloudy", "Cloudy"])
        humidity = random.uniform(50, 75)
        
    return {
        "temperature": round(temp, 1),
        "humidity": int(humidity),
        "conditions": conditions,
        "wind_speed": round(random.uniform(0, 20), 1),
        "timestamp": now.isoformat()
    }
