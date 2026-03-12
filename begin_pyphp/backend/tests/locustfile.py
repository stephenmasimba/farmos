from locust import HttpUser, task, between
import sys
import os
import time
import jwt

# Add parent directory to path to import backend modules
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

# Manual JWT generation to avoid importing backend if dependencies are complex
# Or we can try to import. Let's try manual first to be safe and standalone.
JWT_SECRET = "change_me"
JWT_ALG = "HS256"

def create_token():
    payload = {
        "sub": "testuser",
        "role": "admin",
        "tenant_id": "1",
        "exp": int(time.time()) + 3600
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALG)

class FarmOSUser(HttpUser):
    wait_time = between(1, 2)
    
    # Common headers simulating an authenticated user
    def on_start(self):
        token = create_token()
        self.client.headers.update({
            "X-API-Key": "local-dev-key",
            "X-Tenant-ID": "1",
            "Authorization": f"Bearer {token}"
        })

    @task(3)
    def view_inventory(self):
        self.client.get("/api/inventory/items")

    @task(1)
    def create_contract(self):
        self.client.post("/api/contracts/contracts", json={
            "grower_name": "Locust User",
            "crop": "Stress Test Crop",
            "acreage": 5.0,
            "agreed_price_per_kg": 2.5,
            "start_date": "2023-01-01",
            "end_date": "2023-12-31",
            "status": "Draft"
        })

    @task(2)
    def check_compliance(self):
        self.client.get("/api/compliance/requirements")
