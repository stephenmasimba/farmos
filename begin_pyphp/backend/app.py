import os
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, Depends, Header, HTTPException, status, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .common.security import verify_api_key, get_tenant_context
from .common.dependencies import get_current_user as auth_dependency, get_tenant_id as tenant_dependency
from .routers import (
    auth, dashboard, livestock, inventory, fields, tasks, financial, 
    iot, weather, reports, notifications, breeding, equipment, labor,
    users, tenants, system, analytics, payments, marketplace, blockchain,
    feed, waste, hr, contracts, suppliers, compliance, sync,
    biogas, sales_crm, production_management, energy_management, waste_circularity,
    financial_analytics, predictive_maintenance, feed_formulation, weather_irrigation,
    veterinary, qr_inventory, camera
)
from .common.database import engine, Base
from .common import models
from .common.seeder import seed_all
import importlib
import_router = importlib.import_module("backend.routers.import")
_ensure_models = models

# Create database tables
try:
    print(f"Creating tables. Registered tables: {list(Base.metadata.tables.keys())}")
    Base.metadata.create_all(bind=engine)
except Exception as e:

    print(f"Warning: Database tables might already exist or error during creation: {e}")

app = FastAPI(
    title="Begin Masimba FarmOS API (Python)",
    version="1.0.0",
    description="Python backend mirroring the original API structure",
    docs_url="/docs",
    redoc_url="/redoc"
)

@app.on_event("startup")
async def startup_event():
    seed_all()

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # In production, log the error and hide details
    environment = os.getenv("NODE_ENV", "development")
    error_detail = str(exc) if environment == "development" else "Internal Server Error"
    return JSONResponse(
        status_code=500,
        content={"message": "Internal Server Error", "detail": error_detail},
    )

origins = [os.getenv("CORS_ORIGIN", "http://localhost")]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["Content-Type", "Authorization", "x-api-key", "X-Tenant-ID"],
)


async def api_key_dependency(x_api_key: Optional[str] = Header(None)):
    if not verify_api_key(x_api_key):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid API key")

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    environment: str
    uptime: float

start_time = datetime.utcnow()

@app.get("/health", response_model=HealthResponse)
async def health():
    environment = os.getenv("NODE_ENV", "development")
    return HealthResponse(
        status="OK",
        timestamp=datetime.utcnow().isoformat(),
        environment=environment,
        uptime=(datetime.utcnow() - start_time).total_seconds()
    )

@app.get("/api/version")
async def version():
    return {
        "version": "1.0.0",
        "api": "Begin Masimba FarmOS API (Python)",
        "environment": os.getenv("NODE_ENV", "development"),
    }

# Public routes (only API Key required for some, or completely public)
app.include_router(
    auth.router,
    prefix="/api/auth",
    tags=["Authentication"],
    dependencies=[Depends(api_key_dependency), Depends(tenant_dependency)]
)

# Protected routes (require Auth Token)
protected_deps = [Depends(api_key_dependency), Depends(tenant_dependency), Depends(auth_dependency)]

app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"], dependencies=protected_deps)
app.include_router(livestock.router, prefix="/api/livestock", tags=["Livestock"], dependencies=protected_deps)
app.include_router(inventory.router, prefix="/api/inventory", tags=["Inventory"], dependencies=protected_deps)
app.include_router(fields.router, prefix="/api/fields", tags=["Fields"], dependencies=protected_deps)
app.include_router(tasks.router, prefix="/api/tasks", tags=["Tasks"], dependencies=protected_deps)
app.include_router(financial.router, prefix="/api/financial", tags=["Financial"], dependencies=protected_deps)
app.include_router(iot.router, prefix="/api/iot", tags=["IoT"], dependencies=protected_deps)
app.include_router(weather.router, prefix="/api/weather", tags=["Weather"], dependencies=protected_deps)
app.include_router(reports.router, prefix="/api/reports", tags=["Reports"], dependencies=protected_deps)
app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"], dependencies=protected_deps)
app.include_router(breeding.router, prefix="/api/breeding", tags=["Breeding"], dependencies=protected_deps)
app.include_router(equipment.router, prefix="/api/equipment", tags=["Equipment"], dependencies=protected_deps)
app.include_router(labor.router, prefix="/api/labor", tags=["Labor"], dependencies=protected_deps)
app.include_router(users.router, prefix="/api/users", tags=["Users"], dependencies=protected_deps)
app.include_router(tenants.router, prefix="/api/tenants", tags=["Tenants"], dependencies=protected_deps)
app.include_router(system.router, prefix="/api/system", tags=["System"], dependencies=protected_deps)
app.include_router(analytics.router, prefix="/api/analytics", tags=["Analytics"], dependencies=protected_deps)
app.include_router(payments.router, prefix="/api/payments", tags=["Payments"], dependencies=protected_deps)
app.include_router(
    marketplace.router,
    prefix="/api/marketplace",
    tags=["Marketplace"],
    dependencies=protected_deps
)
app.include_router(
    blockchain.router,
    prefix="/api/blockchain",
    tags=["Blockchain"],
    dependencies=protected_deps
)
app.include_router(
    import_router.router,
    prefix="/api/import",
    tags=["Import"],
    dependencies=protected_deps
)
app.include_router(
    feed.router,
    prefix="/api/feed",
    tags=["Feed"],
    dependencies=protected_deps
)
app.include_router(
    waste.router,
    prefix="/api/waste",
    tags=["Waste"],
    dependencies=protected_deps
)
app.include_router(
    suppliers.router,
    prefix="/api/suppliers",
    tags=["Suppliers"],
    dependencies=protected_deps
)
app.include_router(
    compliance.router,
    prefix="/api/compliance",
    tags=["Compliance"],
    dependencies=protected_deps
)
app.include_router(
    sync.router,
    prefix="/api/sync",
    tags=["Sync"],
    dependencies=protected_deps
)
app.include_router(
    hr.router,
    prefix="/api/hr",
    tags=["HR"],
    dependencies=protected_deps
)
app.include_router(
    contracts.router,
    prefix="/api/contracts",
    tags=["Contracts"],
    dependencies=protected_deps
)
app.include_router(
    biogas.router,
    prefix="/api/biogas",
    tags=["Biogas"],
    dependencies=protected_deps
)
app.include_router(
    sales_crm.router,
    prefix="/api/sales-crm",
    tags=["Sales CRM"],
    dependencies=protected_deps
)
app.include_router(
    production_management.router,
    prefix="/api/production-management",
    tags=["Production Management"],
    dependencies=protected_deps
)
app.include_router(
    energy_management.router,
    prefix="/api/energy",
    tags=["Energy Management"],
    dependencies=protected_deps
)
app.include_router(
    waste_circularity.router,
    prefix="/api/circularity",
    tags=["Waste & Circularity"],
    dependencies=protected_deps
)
app.include_router(
    financial_analytics.router,
    prefix="/api/financial-analytics",
    tags=["Financial Analytics"],
    dependencies=protected_deps
)
app.include_router(
    predictive_maintenance.router,
    prefix="/api/predictive-maintenance",
    tags=["Predictive Maintenance"],
    dependencies=protected_deps
)
app.include_router(
    feed_formulation.router,
    prefix="/api/feed-formulation",
    tags=["Feed Formulation"],
    dependencies=protected_deps
)
app.include_router(
    weather_irrigation.router,
    prefix="/api/weather-irrigation",
    tags=["Weather Irrigation"],
    dependencies=protected_deps
)
app.include_router(
    veterinary.router,
    prefix="/api/veterinary",
    tags=["Veterinary Management"],
    dependencies=protected_deps
)
app.include_router(
    qr_inventory.router,
    prefix="/api/qr",
    tags=["QR Inventory"],
    dependencies=protected_deps
)
app.include_router(
    camera.router,
    prefix="/api/camera",
    tags=["Camera"],
    dependencies=protected_deps
)
app.include_router(
    # advanced_analytics.router,
    # prefix="/api/analytics/advanced",
    # tags=["Advanced Analytics"],
    # dependencies=protected_deps
)
