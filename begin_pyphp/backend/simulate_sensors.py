import requests
import time
import random
import datetime

# Configuration
API_URL = "http://localhost:8000/api/iot/ingest"
API_KEY = "local-dev-key"  # Matches default in security.py
DEVICES = [
    {"id": "dev_001", "type": "environment"},
    {"id": "dev_002", "type": "soil"}
]

def generate_readings(device_type):
    if device_type == "environment":
        return {
            "temperature": round(random.uniform(20.0, 35.0), 1),
            "humidity": round(random.uniform(40.0, 80.0), 1)
        }
    elif device_type == "soil":
        return {
            "soil_moisture": round(random.uniform(10.0, 40.0), 1),
            "ph": round(random.uniform(5.5, 7.5), 1)
        }
    return {}

def main():
    print(f"Starting sensor simulation to {API_URL}...")
    print("Press Ctrl+C to stop.")
    
    while True:
        for device in DEVICES:
            payload = {
                "device_id": device["id"],
                "timestamp": datetime.datetime.utcnow().isoformat(),
                "readings": generate_readings(device["type"])
            }
            
            headers = {
                "X-API-Key": API_KEY,
                "Content-Type": "application/json"
            }
            
            try:
                response = requests.post(API_URL, json=payload, headers=headers, timeout=5)
                if response.status_code == 201:
                    print(f"[{datetime.datetime.now().strftime('%H:%M:%S')}] Sent data for {device['id']}: {payload['readings']}")
                else:
                    print(f"[{datetime.datetime.now().strftime('%H:%M:%S')}] Error {response.status_code}: {response.text}")
            except Exception as e:
                print(f"[{datetime.datetime.now().strftime('%H:%M:%S')}] Connection Error: {e}")
        
        time.sleep(5)  # Send every 5 seconds

if __name__ == "__main__":
    main()
