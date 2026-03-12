"""
Test new livestock batch insertion and retrieval
"""

import requests
import json

# Base URL
BASE_URL = "http://127.0.0.1:8000"

def test_new_livestock_batch():
    """Test with a new unique batch code"""
    print("🐄 Testing New Livestock Batch Insertion...")
    print("=" * 50)
    
    # New unique data
    import time
    timestamp = int(time.time())
    data = {
        "batch_code": f"Broiler-{timestamp}",
        "animal_type": "Poultry",
        "breed": "White Chicken",
        "quantity": 1000,
        "entry_date": "2026-02-03",
        "health_status": "HEALTHY",
        "location": "Main Farm",
        "notes": "New broiler batch for testing"
    }
    
    print("Data to insert:")
    for key, value in data.items():
        print(f"  {key}: {value}")
    
    print("\nTesting insertion...")
    
    try:
        response = requests.post(f"{BASE_URL}/api/livestock/add", json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Livestock batch added successfully!")
            
            # Now test retrieval
            print("\n🔍 Testing data retrieval...")
            verify_response = requests.get(f"{BASE_URL}/api/livestock/batches")
            if verify_response.status_code == 200:
                batches = verify_response.json().get('data', [])
                print(f"Found {len(batches)} batches in database")
                
                # Look for our batch
                found = False
                for batch in batches:
                    if batch.get('batch_code') == data['batch_code']:
                        found = True
                        print("✅ Found our new batch in database:")
                        print(f"  Batch Code: {batch.get('batch_code')}")
                        print(f"  Type: {batch.get('type')}")
                        print(f"  Name: {batch.get('name')}")
                        print(f"  Quantity: {batch.get('quantity')}")
                        print(f"  Status: {batch.get('status')}")
                        print(f"  Start Date: {batch.get('start_date')}")
                        print(f"  Breed: {batch.get('breed')}")
                        print(f"  Location: {batch.get('location')}")
                        break
                
                if not found:
                    print("❌ New batch not found in database")
                    print("Available batches:")
                    for i, batch in enumerate(batches[:3]):  # Show first 3
                        print(f"  {i+1}. {batch.get('batch_code')} - {batch.get('type')} - Qty: {batch.get('quantity')}")
            else:
                print(f"❌ Failed to retrieve: {verify_response.status_code}")
                print(f"Error: {verify_response.json()}")
                
        else:
            print("❌ FAILED: Insertion failed")
            print(f"Error: {response.json()}")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

def test_all_retrieval_endpoints():
    """Test all retrieval endpoints"""
    print("\n🔄 Testing All Retrieval Endpoints...")
    print("=" * 50)
    
    endpoints = [
        ("/api/livestock/batches", "Livestock Batches"),
        ("/api/inventory/items", "Inventory Items"),
        ("/api/equipment/list", "Equipment"),
        ("/api/tasks/list", "Tasks"),
        ("/api/financial/transactions", "Financial Transactions")
    ]
    
    for endpoint, name in endpoints:
        try:
            response = requests.get(f"{BASE_URL}{endpoint}")
            if response.status_code == 200:
                data = response.json().get('data', [])
                print(f"✅ {name}: {len(data)} items")
            else:
                print(f"❌ {name}: Failed ({response.status_code})")
        except Exception as e:
            print(f"❌ {name}: Error - {e}")

def main():
    """Run the complete test"""
    print("🧪 Complete Livestock Batch Test")
    print("=" * 60)
    
    # Test server health first
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ Server Health: {response.json()}")
    except:
        print("❌ Server not running!")
        return
    
    # Test new batch insertion and retrieval
    test_new_livestock_batch()
    
    # Test all retrieval endpoints
    test_all_retrieval_endpoints()

if __name__ == "__main__":
    main()
