"""
Test specific livestock batch insertion with user's data
"""

import requests
import json

# Base URL
BASE_URL = "http://127.0.0.1:8000"

def test_specific_livestock_batch():
    """Test the specific livestock batch data provided by user"""
    print("🐄 Testing Specific Livestock Batch Insertion...")
    print("=" * 50)
    
    # User's exact data
    data = {
        "batch_code": "Broiler 001",
        "animal_type": "Poultry",
        "breed": "White Chicken",
        "quantity": 1000,
        "birth_date": "2026-02-03",  # Note: 02/03/2026 format
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
            
            # Verify it was saved
            print("\n🔍 Verifying data was saved...")
            verify_response = requests.get(f"{BASE_URL}/api/livestock/batches")
            if verify_response.status_code == 200:
                batches = verify_response.json().get('data', [])
                print(f"Found {len(batches)} batches in database")
                
                # Look for our batch
                found = False
                for batch in batches:
                    if batch.get('batch_code') == "Broiler 001":
                        found = True
                        print("✅ Found our batch in database:")
                        print(f"  Batch Code: {batch.get('batch_code')}")
                        print(f"  Type: {batch.get('type')}")
                        print(f"  Name: {batch.get('name')}")
                        print(f"  Quantity: {batch.get('quantity')}")
                        break
                
                if not found:
                    print("❌ Batch not found in database")
            else:
                print(f"❌ Failed to verify: {verify_response.status_code}")
                
        else:
            print("❌ FAILED: Insertion failed")
            print(f"Error: {response.json()}")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

def test_alternative_date_format():
    """Test with alternative date format"""
    print("\n🔄 Testing with alternative date format...")
    
    data = {
        "batch_code": "Broiler 002",
        "animal_type": "Poultry", 
        "breed": "White Chicken",
        "quantity": 1000,
        "entry_date": "2026-02-03",  # Use entry_date instead of birth_date
        "health_status": "HEALTHY",
        "location": "Main Farm",
        "notes": "Test with entry_date field"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/livestock/add", json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ SUCCESS with entry_date!")
        else:
            print("❌ FAILED with entry_date")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

def main():
    """Run the specific test"""
    print("🧪 Testing User's Specific Livestock Batch")
    print("=" * 60)
    
    # Test server health first
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"✅ Server Health: {response.json()}")
    except:
        print("❌ Server not running!")
        return
    
    # Test user's specific data
    test_specific_livestock_batch()
    
    # Test alternative date format
    test_alternative_date_format()

if __name__ == "__main__":
    main()
