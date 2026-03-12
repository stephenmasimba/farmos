import time
import random
import requests
import logging
import threading
from datetime import datetime

# Configuration
API_BASE_URL = "http://localhost:8000/api/iot"
TENANT_ID = "1"  # Default tenant
HEADERS = {
    "X-Tenant-ID": TENANT_ID,
    "Content-Type": "application/json"
}

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - [%(threadName)s] - %(message)s'
)
logger = logging.getLogger(__name__)

class SensorSimulator:
    def __init__(self, name, device_type, location, sensors, interval=5):
        self.name = name
        self.device_type = device_type
        self.location = location
        self.sensors = sensors  # List of sensor configs: {"type": "temp", "unit": "C", "min": 20, "max": 30}
        self.interval = interval
        self.device_id = None
        self.running = False

    def register_device(self):
        """Ensure device exists in backend and get its ID"""
        try:
            # First try to find existing device (This part depends on if we have a search/get endpoint by name, 
            # but for now we'll just try to create and if it exists, the backend might handle it or we assume 
            # we need to implement a lookup. 
            # Actually, the create endpoint might duplicate if we don't check. 
            # Let's fetch all devices first.)
            
            response = requests.get(f"{API_BASE_URL}/devices", headers=HEADERS)
            if response.status_code == 200:
                devices = response.json()
                for d in devices:
                    if d['name'] == self.name:
                        self.device_id = d['id']
                        logger.info(f"Found existing device '{self.name}' with ID {self.device_id}")
                        return

            # If not found, create it
            payload = {
                "name": self.name,
                "type": self.device_type,
                "location": self.location,
                "status": "online",
                "last_seen": datetime.utcnow().isoformat()
            }
            response = requests.post(f"{API_BASE_URL}/devices", json=payload, headers=HEADERS)
            if response.status_code in [200, 201]:
                data = response.json()
                # Handle case where API returns the object directly or wrapped
                self.device_id = data.get('id')
                logger.info(f"Registered new device '{self.name}' with ID {self.device_id}")
            else:
                logger.error(f"Failed to register device '{self.name}': {response.text}")

        except Exception as e:
            logger.error(f"Connection error registering '{self.name}': {e}")

    def generate_value(self, sensor_config):
        """Generate a random value based on config with some walk/noise"""
        # Basic random implementation for now
        base = random.uniform(sensor_config['min'], sensor_config['max'])
        return round(base, 2)

    def run(self):
        if not self.device_id:
            self.register_device()
            if not self.device_id:
                logger.error(f"Skipping simulation for '{self.name}' due to registration failure.")
                return

        self.running = True
        logger.info(f"Starting simulation for '{self.name}'...")
        
        while self.running:
            try:
                for sensor in self.sensors:
                    value = self.generate_value(sensor)
                    payload = {
                        "device_id": self.device_id,
                        "sensor_type": sensor['type'],
                        "value": value,
                        "unit": sensor['unit']
                    }
                    
                    # Send data
                    resp = requests.post(f"{API_BASE_URL}/ingest", json=payload, headers=HEADERS)
                    if resp.status_code != 200:
                        logger.warning(f"Failed to ingest {sensor['type']} for '{self.name}': {resp.status_code}")
                    
                time.sleep(self.interval)
                
            except Exception as e:
                logger.error(f"Error in simulation loop for '{self.name}': {e}")
                time.sleep(self.interval)

def start_simulations():
    simulators = [
        SensorSimulator(
            name="Field A Soil Sensor",
            device_type="sensor",
            location="Field A - North",
            sensors=[
                {"type": "moisture", "unit": "%", "min": 30, "max": 45},
                {"type": "temperature", "unit": "C", "min": 18, "max": 25}
            ],
            interval=10
        ),
        SensorSimulator(
            name="Main Weather Station",
            device_type="sensor",
            location="Farm HQ Roof",
            sensors=[
                {"type": "temperature", "unit": "C", "min": 15, "max": 32},
                {"type": "humidity", "unit": "%", "min": 40, "max": 80},
                {"type": "wind_speed", "unit": "km/h", "min": 0, "max": 15},
                {"type": "solar_radiation", "unit": "W/m2", "min": 0, "max": 800}
            ],
            interval=15
        ),
        SensorSimulator(
            name="Fish Pond Monitor",
            device_type="sensor",
            location="Pond 1",
            sensors=[
                {"type": "ph", "unit": "pH", "min": 6.5, "max": 7.5},
                {"type": "dissolved_oxygen", "unit": "mg/L", "min": 5, "max": 8},
                {"type": "water_temp", "unit": "C", "min": 20, "max": 24},
                {"type": "turbidity", "unit": "NTU", "min": 5, "max": 20}
            ],
            interval=12
        ),
        SensorSimulator(
            name="Biogas Digester Monitor",
            device_type="sensor",
            location="Digester 1",
            sensors=[
                {"type": "pressure", "unit": "bar", "min": 0.8, "max": 1.2},
                {"type": "methane", "unit": "%", "min": 55, "max": 65},
                {"type": "internal_temp", "unit": "C", "min": 35, "max": 40}
            ],
            interval=8
        )
    ]

    threads = []
    for sim in simulators:
        t = threading.Thread(target=sim.run, name=sim.name)
        t.daemon = True
        t.start()
        threads.append(t)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Stopping simulations...")

if __name__ == "__main__":
    print("Starting IoT Sensor Simulations...")
    print(f"Targeting Backend: {API_BASE_URL}")
    print("Press Ctrl+C to stop.")
    start_simulations()
