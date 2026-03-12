import requests
import os

BASE_URL = "http://127.0.0.1:8000"
API_KEY = os.getenv("API_KEY", "local-dev-key")
TENANT_ID = os.getenv("TEST_TENANT", "default")

def make_headers(token: str | None = None):
    headers = {
        "x-api-key": API_KEY,
        "X-Tenant-ID": TENANT_ID,
        "Content-Type": "application/json",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

def login() -> str | None:
    try:
        r = requests.post(
            f"{BASE_URL}/api/auth/login",
            json={"email": "admin@example.com", "password": "password123"},
            headers=make_headers(),
            timeout=10,
        )
        if r.status_code == 200:
            return r.json()["access_token"]
        print(f"Login failed: {r.status_code} {r.text}")
        return None
    except Exception as e:
        print(f"Login error: {e}")
        return None

def test_livestock_insert(token: str):
    print("🐄 Testing Livestock INSERT...")
    data = {
        "name": "TEST-BATCH-001",
        "type": "Cattle",
        "count": 25,
        "quantity": 25,
        "status": "active",
        "start_date": "2026-02-13",
        "notes": "Test batch for validation"
    }
    r = requests.post(f"{BASE_URL}/api/livestock/", json=data, headers=make_headers(token), timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
    return r.status_code in (200, 201)

def test_inventory_insert(token: str):
    print("\n📦 Testing Inventory INSERT...")
    data = {
        "name": "Test Animal Feed",
        "category": "Feed",
        "quantity": 1000,
        "unit": "kg",
        "location": "Main Storage",
        "low_stock_threshold": 200
    }
    r = requests.post(f"{BASE_URL}/api/inventory/items", json=data, headers=make_headers(token), timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
    return r.status_code in (200, 201)

def test_equipment_insert(token: str):
    print("\n🔧 Testing Equipment INSERT...")
    data = {
        "name": "Test Tractor",
        "location": "Main Farm",
        "status": "healthy"
    }
    r = requests.post(f"{BASE_URL}/api/equipment/", json=data, headers=make_headers(token), timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
    return r.status_code in (200, 201)

def test_task_insert(token: str):
    print("\n📋 Testing Task INSERT...")
    data = {
        "title": "Test Farm Maintenance",
        "description": "Test task for equipment maintenance",
        "priority": "high",
        "status": "pending",
        "assigned_to": "Admin User",
        "due_date": "2026-02-20"
    }
    r = requests.post(f"{BASE_URL}/api/tasks/", json=data, headers=make_headers(token), timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
    return r.status_code in (200, 201)

def test_financial_insert(token: str):
    print("\n💰 Testing Financial INSERT...")
    data = {
        "type": "expense",
        "amount": 1500.00,
        "description": "Test equipment maintenance cost",
        "category": "maintenance",
        "date": "2026-02-13"
    }
    r = requests.post(f"{BASE_URL}/api/financial/transactions", json=data, headers=make_headers(token), timeout=10)
    print(f"Status: {r.status_code}")
    print(f"Response: {r.text}")
    return r.status_code in (200, 201)

def main():
    print("🧪 Testing FarmOS INSERT Operations")
    print("=" * 50)
    try:
        h = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"✅ Server Health: {h.json()}")
    except Exception:
        print("❌ Server not running!")
        return
    token = login()
    if not token:
        print("❌ Could not obtain token; aborting tests")
        return
    tests = [
        test_livestock_insert,
        test_inventory_insert,
        test_equipment_insert,
        test_task_insert,
        test_financial_insert
    ]
    results = []
    for test in tests:
        results.append(test(token))
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    for i, result in enumerate(results):
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   Test {i+1}: {status}")
    passed = sum(1 for r in results if r)
    total = len(results)
    print(f"\n🎯 Overall: {passed}/{total} tests passed")
    if passed == total:
        print("🎉 All INSERT operations working!")
    else:
        print("⚠️  Some INSERT operations failed")

if __name__ == "__main__":
    main()
