from datetime import date

def test_create_contract(client):
    response = client.post(
        "/api/contracts/contracts",
        json={
            "grower_name": "Test Grower",
            "crop": "Test Crop",
            "acreage": 10.5,
            "agreed_price_per_kg": 5.0,
            "start_date": str(date.today()),
            "end_date": str(date.today()),
            "status": "Active"
        },
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["grower_name"] == "Test Grower"
    assert "id" in data

def test_get_contracts(client):
    # Create one first
    client.post(
        "/api/contracts/contracts",
        json={
            "grower_name": "Grower 2",
            "crop": "Wheat",
            "acreage": 20,
            "agreed_price_per_kg": 4.5,
            "start_date": "2024-01-01",
            "end_date": "2024-06-01",
            "status": "Active"
        },
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    
    response = client.get(
        "/api/contracts/contracts",
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1
