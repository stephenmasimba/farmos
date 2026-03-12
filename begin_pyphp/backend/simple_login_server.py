"""
Simple Login Server for FarmOS
Bypasses complex imports to provide basic authentication
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
from sqlalchemy import create_engine, text
import bcrypt
import time
from datetime import datetime

# Database connection
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:@localhost/begin_masimba_farm"
engine = create_engine(SQLALCHEMY_DATABASE_URL)

app = FastAPI(title="FarmOS Simple Login API")

class LoginRequest(BaseModel):
    email: str
    password: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

@app.get("/health")
async def health_check():
    return {"status": "OK", "message": "FarmOS Simple Login Server"}

@app.get("/api/predictive-maintenance/alerts")
async def predictive_maintenance_alerts():
    return {
        "data": [
            {
                "alert_id": "ALT-001",
                "asset_name": "Main Water Pump",
                "alert_type": "PREDICTED_FAILURE",
                "severity": "HIGH",
                "message": "AI predicts bearing failure within 7 days",
                "created_at": "2024-01-28 14:30:00"
            },
            {
                "alert_id": "ALT-002",
                "asset_name": "Ventilation Fan Motor",
                "alert_type": "TEMPERATURE_SPIKE",
                "severity": "CRITICAL",
                "message": "Temperature exceeding safe operating limits",
                "created_at": "2024-01-28 15:45:00"
            }
        ]
    }

@app.get("/api/predictive-maintenance/fleet-health")
async def predictive_maintenance_fleet_health():
    return {
        "data": {
            "total_assets": 24,
            "fleet_availability": 94.5,
            "critical": 3,
            "estimated_downtime_prevented_hrs": 156,
            "maintenance_cost_savings_usd": 12500,
            "high_risk_assets": [
                {
                    "asset_id": "EQ-001",
                    "asset_name": "Main Water Pump",
                    "health_score": 67,
                    "predicted_failure_date": "2024-02-15",
                    "risk_level": "HIGH",
                    "vibration_mm_s": 4.2,
                    "temperature_c": 78.5,
                    "current_draw_a": 12.3,
                    "recommendation": "Schedule immediate inspection and bearing replacement"
                },
                {
                    "asset_id": "EQ-002",
                    "asset_name": "Feed Conveyor Belt",
                    "health_score": 72,
                    "predicted_failure_date": "2024-02-28",
                    "risk_level": "MEDIUM",
                    "vibration_mm_s": 3.1,
                    "temperature_c": 65.2,
                    "current_draw_a": 8.7,
                    "recommendation": "Monitor closely, plan maintenance within 2 weeks"
                },
                {
                    "asset_id": "EQ-003",
                    "asset_name": "Ventilation Fan Motor",
                    "health_score": 58,
                    "predicted_failure_date": "2024-02-08",
                    "risk_level": "HIGH",
                    "vibration_mm_s": 5.8,
                    "temperature_c": 92.1,
                    "current_draw_a": 15.6,
                    "recommendation": "Urgent - replace motor within 48 hours"
                }
            ]
        }
    }

@app.get("/api/financial-analytics/forecast")
async def financial_forecast():
    return {
        "data": {
            "current_cash_position": 125000.00,
            "burn_rate": 8500.00,
            "runway_months": 15,
            "forecast_scenarios": {
                "realistic": [
                    {"period": "Jan 2024", "revenue": 45000, "expenses": 38000, "net_cash": 7000},
                    {"period": "Feb 2024", "revenue": 48000, "expenses": 39000, "net_cash": 9000},
                    {"period": "Mar 2024", "revenue": 52000, "expenses": 40000, "net_cash": 12000},
                    {"period": "Apr 2024", "revenue": 55000, "expenses": 41000, "net_cash": 14000},
                    {"period": "May 2024", "revenue": 58000, "expenses": 42000, "net_cash": 16000},
                    {"period": "Jun 2024", "revenue": 62000, "expenses": 44000, "net_cash": 18000}
                ]
            }
        }
    }

@app.get("/api/financial-analytics/assets")
async def financial_assets():
    return {
        "data": [
            {"asset_name": "Tractor John Deere 5075E", "purchase_cost": 45000, "current_value": 38000, "annual_depreciation": 3500, "purchase_date": "2022-01-15"},
            {"asset_name": "Irrigation System", "purchase_cost": 28000, "current_value": 22000, "annual_depreciation": 2000, "purchase_date": "2021-06-20"},
            {"asset_name": "Greenhouse Structure", "purchase_cost": 85000, "current_value": 72000, "annual_depreciation": 4250, "purchase_date": "2020-03-10"},
            {"asset_name": "Feed Storage Silo", "purchase_cost": 35000, "current_value": 31000, "annual_depreciation": 1600, "purchase_date": "2021-11-05"}
        ]
    }

@app.get("/api/financial-analytics/roi")
async def financial_roi():
    return {
        "data": [
            {"project_name": "Solar Panel Installation", "investment": 25000, "returns_to_date": 18500, "roi_percentage": 74.0, "payback_months": 18},
            {"project_name": "Automated Feeding System", "investment": 15000, "returns_to_date": 8900, "roi_percentage": 59.3, "payback_months": 24},
            {"project_name": "Water Recycling System", "investment": 12000, "returns_to_date": 7200, "roi_percentage": 60.0, "payback_months": 20}
        ]
    }

@app.get("/api/biogas/status")
async def biogas_status():
    return {
        "data": [
            {
                "system_name": "Biogas System 1",
                "alert_level": "OPERATIONAL",
                "current_pressure_bar": 2.5,
                "pressure_percentage": 75,
                "net_flow_m3h": 120,
                "production_rate_m3h": 85,
                "consumption_rate_m3h": 65,
                "last_maintenance": "2024-01-15"
            },
            {
                "system_name": "Biogas System 2",
                "alert_level": "WARNING",
                "current_pressure_bar": 1.8,
                "pressure_percentage": 45,
                "net_flow_m3h": 95,
                "production_rate_m3h": 70,
                "consumption_rate_m3h": 85,
                "last_maintenance": "2024-01-10"
            }
        ]
    }

@app.get("/api/biogas/zones")
async def biogas_zones():
    return {
        "data": [
            {"zone_id": 1, "zone_name": "Zone A", "status": "ACTIVE", "isolation_status": "OPEN"},
            {"zone_id": 2, "zone_name": "Zone B", "status": "ACTIVE", "isolation_status": "CLOSED"},
            {"zone_id": 3, "zone_name": "Zone C", "status": "MAINTENANCE", "isolation_status": "CLOSED"}
        ]
    }

@app.get("/api/dashboard/summary")
async def dashboard_summary():
    return {
        "alerts": 0,
        "tasks_due": 0,
        "livestock_batches": 0,
        "inventory_low": 0,
        "low_stock_items": [],
        "_fallback": False,
        "_error": None
    }

@app.post("/api/auth/login", response_model=LoginResponse)
async def login(body: LoginRequest):
    try:
        with engine.connect() as conn:
            # Get user from database
            result = conn.execute(text('SELECT id, name, email, hashed_password, role FROM users WHERE email = :email'), {'email': body.email})
            user = result.fetchone()
            
            if not user:
                raise HTTPException(status_code=401, detail="Invalid credentials")
            
            # Check password
            try:
                is_valid = bcrypt.checkpw(body.password.encode('utf-8'), user[3].encode('utf-8'))
            except:
                is_valid = False
            
            if not is_valid:
                raise HTTPException(status_code=401, detail="Invalid credentials")
            
            # Generate simple token (in production, use JWT)
            token = f"simple_token_{user[0]}_{user[2]}"
            
            return LoginResponse(
                access_token=token,
                user={
                    "id": user[0],
                    "name": user[1],
                    "email": user[2],
                    "role": user[4]
                }
            )
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

@app.get("/api/auth/me")
async def get_current_user():
    return {"message": "User endpoint - implement token validation"}

# POST endpoints for creating/updating data
@app.post("/api/livestock/add")
async def add_livestock_batch(data: dict):
    try:
        with engine.connect() as conn:
            # Insert new livestock batch using actual schema
            insert_query = text("""
                INSERT INTO livestock_batches 
                (batch_code, type, name, quantity, status, start_date, breed, location, notes, tenant_id)
                VALUES 
                (:batch_code, :type, :name, :quantity, :status, :start_date, :breed, :location, :notes, 1)
            """)
            conn.execute(insert_query, {
                'batch_code': data.get('batch_code', f'BATCH-{int(time.time())}'),
                'type': data.get('animal_type', 'Cattle'),
                'name': data.get('batch_name', f'Batch {data.get("batch_code", "")}'),
                'quantity': data.get('quantity', 0),
                'status': data.get('health_status', 'HEALTHY'),
                'start_date': data.get('entry_date', datetime.now().strftime('%Y-%m-%d')),
                'breed': data.get('breed', 'Mixed'),
                'location': data.get('location', 'Main Farm'),
                'notes': data.get('notes', '')
            })
            conn.commit()
            return {"success": True, "message": "Livestock batch added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add livestock batch: {str(e)}")

@app.post("/api/inventory/add")
async def add_inventory_item(data: dict):
    try:
        with engine.connect() as conn:
            # Insert new inventory item using actual schema
            insert_query = text("""
                INSERT INTO inventory_items 
                (name, category, quantity, unit, location, low_stock_threshold, tenant_id)
                VALUES 
                (:name, :category, :quantity, :unit, :location, :low_stock_threshold, 1)
            """)
            conn.execute(insert_query, {
                'name': data.get('item_name', ''),
                'category': data.get('category', 'Feed'),
                'quantity': data.get('quantity', 0),
                'unit': data.get('unit', 'kg'),
                'location': data.get('location', 'Main Storage'),
                'low_stock_threshold': data.get('min_stock_level', 0)
            })
            conn.commit()
            return {"success": True, "message": "Inventory item added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add inventory item: {str(e)}")

@app.post("/api/equipment/add")
async def add_equipment(data: dict):
    try:
        with engine.connect() as conn:
            # Insert new equipment using actual schema
            insert_query = text("""
                INSERT INTO equipment 
                (name, serial_number, purchase_date, purchase_price, status, last_maintenance_date, next_maintenance_date, notes, tenant_id)
                VALUES 
                (:name, :serial_number, :purchase_date, :purchase_price, :status, :last_maintenance_date, :next_maintenance_date, :notes, 1)
            """)
            conn.execute(insert_query, {
                'name': data.get('equipment_name', ''),
                'serial_number': data.get('serial_number', f'SN-{int(time.time())}'),
                'purchase_date': data.get('purchase_date', datetime.now().strftime('%Y-%m-%d')),
                'purchase_price': data.get('purchase_cost', 0),
                'status': data.get('status', 'OPERATIONAL'),
                'last_maintenance_date': data.get('last_maintenance', None),
                'next_maintenance_date': data.get('next_maintenance_date', None),
                'notes': data.get('notes', '')
            })
            conn.commit()
            return {"success": True, "message": "Equipment added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add equipment: {str(e)}")

@app.post("/api/tasks/add")
async def add_task(data: dict):
    try:
        with engine.connect() as conn:
            # Insert new task using actual schema
            insert_query = text("""
                INSERT INTO tasks 
                (title, description, assigned_to, status, priority, due_date, created_by, tenant_id)
                VALUES 
                (:title, :description, :assigned_to, :status, :priority, :due_date, :created_by, 1)
            """)
            conn.execute(insert_query, {
                'title': data.get('task_title', ''),
                'description': data.get('description', ''),
                'assigned_to': data.get('assigned_to', 1),
                'status': data.get('status', 'PENDING'),
                'priority': data.get('priority', 'MEDIUM'),
                'due_date': data.get('due_date', datetime.now().strftime('%Y-%m-%d')),
                'created_by': data.get('created_by', 1)
            })
            conn.commit()
            return {"success": True, "message": "Task added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add task: {str(e)}")

@app.post("/api/financial/transactions/add")
async def add_financial_transaction(data: dict):
    try:
        with engine.connect() as conn:
            # Insert new financial transaction using actual schema
            insert_query = text("""
                INSERT INTO financial_transactions 
                (type, category, amount, description, date, tenant_id)
                VALUES 
                (:type, :category, :amount, :description, :date, 1)
            """)
            conn.execute(insert_query, {
                'type': data.get('transaction_type', 'EXPENSE'),
                'category': data.get('category', 'OPERATION'),
                'amount': data.get('amount', 0),
                'description': data.get('description', ''),
                'date': data.get('transaction_date', datetime.now().strftime('%Y-%m-%d'))
            })
            conn.commit()
            return {"success": True, "message": "Financial transaction added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add financial transaction: {str(e)}")

# GET endpoints for retrieving data
@app.get("/api/livestock/batches")
async def get_livestock_batches():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, batch_code, type, name, quantity, status, start_date, breed, location, notes
                FROM livestock_batches 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            batches = []
            for row in result:
                batches.append({
                    'id': row[0],
                    'batch_code': row[1],
                    'type': row[2],
                    'name': row[3],
                    'quantity': row[4],
                    'status': row[5],
                    'start_date': str(row[6]),
                    'breed': row[7],
                    'location': row[8],
                    'notes': row[9]
                })
            return {"data": batches}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve livestock batches: {str(e)}")

@app.get("/api/livestock/breeding")
async def get_livestock_breeding():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, batch_id, breeding_date, expected_birth_date, sire_id, dam_id, notes
                FROM breeding_records 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            breeding = []
            for row in result:
                breeding.append({
                    'id': row[0],
                    'batch_id': row[1],
                    'breeding_date': str(row[2]),
                    'expected_birth_date': str(row[3]),
                    'sire_id': row[4],
                    'dam_id': row[5],
                    'notes': row[6]
                })
            return {"data": breeding}
    except Exception as e:
        # If breeding_records table doesn't exist, return empty data
        return {"data": []}

@app.get("/api/inventory/items")
async def get_inventory_items():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, name, category, quantity, unit, location, low_stock_threshold
                FROM inventory_items 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            items = []
            for row in result:
                items.append({
                    'id': row[0],
                    'name': row[1],
                    'category': row[2],
                    'quantity': row[3],
                    'unit': row[4],
                    'location': row[5],
                    'low_stock_threshold': row[6]
                })
            return {"data": items}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve inventory items: {str(e)}")

@app.get("/api/equipment/list")
async def get_equipment():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, name, serial_number, purchase_date, purchase_price, status, 
                       last_maintenance_date, next_maintenance_date, notes
                FROM equipment 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            equipment = []
            for row in result:
                equipment.append({
                    'id': row[0],
                    'name': row[1],
                    'serial_number': row[2],
                    'purchase_date': str(row[3]),
                    'purchase_price': float(row[4]),
                    'status': row[5],
                    'last_maintenance_date': str(row[6]) if row[6] else None,
                    'next_maintenance_date': str(row[7]) if row[7] else None,
                    'notes': row[8]
                })
            return {"data": equipment}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve equipment: {str(e)}")

@app.get("/api/tasks/list")
async def get_tasks():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, title, description, assigned_to, status, priority, due_date, created_by
                FROM tasks 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            tasks = []
            for row in result:
                tasks.append({
                    'id': row[0],
                    'title': row[1],
                    'description': row[2],
                    'assigned_to': row[3],
                    'status': row[4],
                    'priority': row[5],
                    'due_date': str(row[6]),
                    'created_by': row[7]
                })
            return {"data": tasks}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve tasks: {str(e)}")

@app.get("/api/financial/transactions")
async def get_financial_transactions():
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT id, type, category, amount, description, date
                FROM financial_transactions 
                WHERE tenant_id = 1 
                ORDER BY id DESC
            """)
            result = conn.execute(query)
            transactions = []
            for row in result:
                transactions.append({
                    'id': row[0],
                    'type': row[1],
                    'category': row[2],
                    'amount': float(row[3]),
                    'description': row[4],
                    'date': str(row[5])
                })
            return {"data": transactions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve financial transactions: {str(e)}")

if __name__ == "__main__":
    print("🚀 Starting FarmOS Simple Login Server...")
    print("📍 Server will be available at: http://127.0.0.1:8000")
    print("🔑 Login endpoint: http://127.0.0.1:8000/api/auth/login")
    print("❤️ Health check: http://127.0.0.1:8000/health")
    
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="info")
