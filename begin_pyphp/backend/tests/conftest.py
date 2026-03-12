import pytest
import sys
import os

# Ensure test-friendly DB (SQLite) before importing app
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

# Add the parent directory to sys.path to resolve backend modules
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from backend.app import app, api_key_dependency, tenant_dependency
from backend.common.dependencies import get_current_user
from backend.common.database import Base, get_db
from backend.common import models
from backend.routers import contracts, inventory, financial

# Mock Authentication & Dependencies
async def override_get_current_user():
    return {
        "id": 1,
        "username": "testuser",
        "role": "admin",
        "tenant_id": 1
    }

async def override_api_key_dependency():
    return True

async def override_tenant_dependency():
    return "1"

app.dependency_overrides[get_current_user] = override_get_current_user
app.dependency_overrides[api_key_dependency] = override_api_key_dependency
app.dependency_overrides[tenant_dependency] = override_tenant_dependency

# Test database setup (SQLite)
test_engine = create_engine(os.environ["DATABASE_URL"])
TestSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)
Base.metadata.create_all(bind=test_engine)

def get_test_db():
    db = TestSessionLocal()
    try:
        yield db
    finally:
        db.close()

# Override application DB dependency with test DB
app.dependency_overrides[get_db] = get_test_db

@pytest.fixture(scope="module")
def client():
    # Setup: Ensure overrides are present
    app.dependency_overrides[get_current_user] = override_get_current_user
    app.dependency_overrides[api_key_dependency] = override_api_key_dependency
    app.dependency_overrides[tenant_dependency] = override_tenant_dependency
    app.dependency_overrides[get_db] = get_test_db
    
    with TestClient(app) as c:
        yield c
    
    # Teardown
    app.dependency_overrides = {}

@pytest.fixture(autouse=True)
def reset_db():
    # Reset test database tables to ensure isolation
    db = TestSessionLocal()
    try:
        db.query(models.FinancialTransaction).delete()
        db.query(models.InventoryTransaction).delete()
        db.query(models.InventoryItem).delete()
        db.query(models.Contract).delete()
        db.commit()
        # Seed initial inventory item
        seed_item = models.InventoryItem(
            name="Test Item",
            category="Test",
            quantity=100,
            unit="kg",
            location="Test Loc",
            qr_code="INV-000001"
        )
        db.add(seed_item)
        db.commit()
    finally:
        db.close()
