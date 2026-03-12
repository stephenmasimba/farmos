
def test_get_inventory_items(client):
    response = client.get(
        "/api/inventory/items",
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["name"] == "Test Item"

def test_create_inventory_item(client):
    response = client.post(
        "/api/inventory/items",
        json={
            "name": "New Item",
            "category": "Seeds",
            "quantity": 50,
            "unit": "packs",
            "location": "Warehouse"
        },
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "New Item"
    assert data["qr_code"] is not None

def test_scan_qr_code(client):
    # First get the item to find its QR
    response = client.get(
        "/api/inventory/items",
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    item = response.json()[0]
    qr_code = item["qr_code"]
    
    # Now scan it
    scan_response = client.get(
        f"/api/inventory/items/scan/{qr_code}",
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert scan_response.status_code == 200
    assert scan_response.json()["id"] == item["id"]

def test_scan_invalid_qr(client):
    response = client.get(
        "/api/inventory/items/scan/INVALID-QR",
        headers={"X-API-Key": "test", "X-Tenant-ID": "1", "Authorization": "Bearer test"}
    )
    assert response.status_code == 404
