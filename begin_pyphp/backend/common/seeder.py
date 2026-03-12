# from passlib.context import CryptContext
import bcrypt

from .database import SessionLocal
from . import models

# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    # return pwd_context.hash(password)
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def seed_all():
    db = SessionLocal()
    try:
        # --- Users Seeding (SQL) ---
        if db.query(models.User).count() == 0:
            print("Seeding Users to SQL Database...")
            users_data = [
                {"name": "Admin User", "email": "admin@example.com", "role": "admin", "status": "active", "password": "password123"},
                {"name": "Farm Manager", "email": "manager@example.com", "role": "manager", "status": "active", "password": "password123"},
                {"name": "Field Worker", "email": "worker@example.com", "role": "worker", "status": "active", "password": "password123"},
            ]
            for u in users_data:
                db_user = models.User(
                    name=u["name"],
                    email=u["email"],
                    role=u["role"],
                    status=u["status"],
                    hashed_password=get_password_hash(u["password"])
                )
                db.add(db_user)
            db.commit()

        # --- Livestock Seeding (SQL) ---
        if db.query(models.LivestockBatch).count() == 0:
            print("Seeding Livestock to SQL Database...")
            batches = [
                {"type": "Cattle", "count": 45, "quantity": 45, "status": "healthy", "breed": "Mashona", "location": "North Paddock", "name": "Batch 001", "start_date": "2023-01-01"},
                {"type": "Goats", "count": 30, "quantity": 30, "status": "healthy", "breed": "Matabele", "location": "East Pen", "name": "Batch 002", "start_date": "2023-02-15"},
                {"type": "Chickens", "count": 500, "quantity": 500, "status": "healthy", "breed": "Broilers", "location": "Coop 1", "name": "Batch 003", "start_date": "2023-03-10"},
                {"type": "Cattle", "count": 5, "quantity": 5, "status": "sick", "breed": "Brahman", "location": "Quarantine Area", "name": "Batch 004", "start_date": "2023-04-05"},
            ]
            for b in batches:
                db_batch = models.LivestockBatch(**b)
                db.add(db_batch)
            db.commit()
            
            # Seed events for the first batch
            first_batch = db.query(models.LivestockBatch).first()
            if first_batch:
                events = [
                    {"batch_id": first_batch.id, "type": "Vaccination", "date": "2023-10-01", "details": "Anthrax booster", "performed_by": "Dr. Vet", "cost": 150.0},
                    {"batch_id": first_batch.id, "type": "Feeding", "date": "2023-10-15", "details": "Supplement", "performed_by": "Worker", "cost": 50.0},
                ]
                for e in events:
                    db.add(models.LivestockEvent(**e))
                db.commit()

        # --- Inventory Seeding (SQL) ---
        if db.query(models.InventoryItem).count() == 0:
            print("Seeding Inventory to SQL Database...")
            items = [
                {"name": "Maize Seed (SC727)", "category": "Seeds", "quantity": 250.0, "unit": "kg", "location": "Shed A"},
                {"name": "Compound D Fertilizer", "category": "Fertilizer", "quantity": 1000.0, "unit": "kg", "location": "Shed B"},
                {"name": "Diesel", "category": "Fuel", "quantity": 500.0, "unit": "liters", "location": "Fuel Tank"},
                {"name": "Cattle Dip", "category": "Chemicals", "quantity": 20.0, "unit": "liters", "location": "Chemical Store"},
            ]
            for i in items:
                db.add(models.InventoryItem(**i))
            db.commit()

        # --- Fields Seeding (SQL) ---
        if db.query(models.Field).count() == 0:
            print("Seeding Fields to SQL Database...")
            fields = [
                {"name": "Home Field", "area": 5.0, "unit": "hectares", "crop": "Maize", "status": "planted"},
                {"name": "River Plot", "area": 2.5, "unit": "hectares", "crop": "Vegetables", "status": "active"},
                {"name": "Grazing Land", "area": 50.0, "unit": "hectares", "crop": "Pasture", "status": "active"},
            ]
            for f in fields:
                db.add(models.Field(**f))
            db.commit()

        # --- Tasks Seeding (SQL) ---
        if db.query(models.Task).count() == 0:
            print("Seeding Tasks to SQL Database...")
            tasks = [
                {"title": "Scout Home Field", "description": "Check for armyworm", "assigned_to": "Field Worker", "status": "pending", "priority": "high", "due_date": "2023-11-01"},
                {"title": "Buy Diesel", "description": "Refill main tank", "assigned_to": "Farm Manager", "status": "in_progress", "priority": "medium", "due_date": "2023-10-30"},
                {"title": "Vaccinate Goats", "description": "Routine checkup", "assigned_to": "Vet", "status": "completed", "priority": "high", "due_date": "2023-10-20"},
            ]
            for t in tasks:
                db.add(models.Task(**t))
            db.commit()

        # --- Financial Seeding (SQL) ---
        if db.query(models.FinancialTransaction).count() == 0:
            print("Seeding Financials to SQL Database...")
            transactions = [
                {"type": "income", "category": "Sales", "amount": 5000.00, "description": "Sold 5 steers", "date": "2023-09-15"},
                {"type": "expense", "category": "Inputs", "amount": 1200.00, "description": "Purchased Fertilizer", "date": "2023-09-20"},
                {"type": "expense", "category": "Labor", "amount": 800.00, "description": "Casual labor wages", "date": "2023-09-30"},
            ]
            for t in transactions:
                db.add(models.FinancialTransaction(**t))
            db.commit()

        # --- Equipment Seeding (SQL) ---
        if db.query(models.Equipment).count() == 0:
            print("Seeding Equipment to SQL Database...")
            equipment = [
                {"name": "Irrigation Pump Main", "location": "Dam 1", "status": "healthy", "vibration_baseline": 4.2, "temperature_baseline": 45.0, "current_draw_baseline": 15.0},
                {"name": "Cold Storage Compressor", "location": "Warehouse B", "status": "healthy", "vibration_baseline": 2.5, "temperature_baseline": 35.0, "current_draw_baseline": 32.0},
                {"name": "Milling Unit 3", "location": "Processing Plant", "status": "healthy", "vibration_baseline": 5.0, "temperature_baseline": 60.0, "current_draw_baseline": 25.0},
            ]
            for e in equipment:
                db.add(models.Equipment(**e))
            db.commit()

        # --- Compost Seeding (SQL) ---
        if db.query(models.CompostPile).count() == 0:
            print("Seeding Compost to SQL Database...")
            piles = [
                {"name": "Primary Aerobic Pile", "type": "Hot Compost", "status": "OPTIMAL", "temperature_c": 58.5, "moisture_pct": 55.0, "ph": 6.8, "days_active": 12},
                {"name": "Manure Curing Pile", "type": "Cold Compost", "status": "SLOW", "temperature_c": 32.0, "moisture_pct": 40.0, "ph": 7.2, "days_active": 45},
            ]
            for p in piles:
                db.add(models.CompostPile(**p))
            db.commit()

        # --- Feed Ingredient Seeding (SQL) ---
        if db.query(models.FeedIngredient).count() == 0:
            print("Seeding Feed Ingredients to SQL Database...")
            ingredients = [
                {"name": "Maize Meal", "protein_content": 9.0, "quantity_kg": 1000.0, "cost_per_kg": 0.45},
                {"name": "Soya Bean Meal", "protein_content": 44.0, "quantity_kg": 500.0, "cost_per_kg": 0.85},
                {"name": "Fish Meal", "protein_content": 60.0, "quantity_kg": 100.0, "cost_per_kg": 1.50},
                {"name": "Wheat Bran", "protein_content": 14.0, "quantity_kg": 300.0, "cost_per_kg": 0.35},
                {"name": "Sunflower Cake", "protein_content": 28.0, "quantity_kg": 200.0, "cost_per_kg": 0.55},
            ]
            for ing in ingredients:
                db.add(models.FeedIngredient(**ing))
            db.commit()

        # --- Energy Load Seeding (SQL) ---
        if db.query(models.EnergyLoad).count() == 0:
            print("Seeding Energy Loads to SQL Database...")
            loads = [
                {"name": "Cold Storage A", "location": "Main Barn", "load_type": "cooling", "power_watts": 450.0, "is_essential": True, "status": "on", "priority": 10},
                {"name": "Incubator #1", "location": "Hatchery", "load_type": "heating", "power_watts": 200.0, "is_essential": True, "status": "on", "priority": 10},
                {"name": "Irrigation Pump 1", "location": "North Field", "load_type": "pump", "power_watts": 1200.0, "is_essential": False, "status": "off", "priority": 5},
                {"name": "Workshop Lighting", "location": "Workshop", "load_type": "lighting", "power_watts": 150.0, "is_essential": False, "status": "on", "priority": 3},
            ]
            for l in loads:
                db.add(models.EnergyLoad(**l))
            db.commit()

        # --- Irrigation Seeding (SQL) ---
        if db.query(models.IrrigationZone).count() == 0:
            print("Seeding Irrigation Zones to SQL Database...")
            # Get a field ID
            field = db.query(models.Field).first()
            field_id = field.id if field else 1
            
            zones = [
                {"name": "North Orchard", "field_id": field_id, "moisture_threshold": 40.0, "current_moisture": 72.0, "status": "WET"},
                {"name": "Vegetable Patch 2", "field_id": field_id, "moisture_threshold": 35.0, "current_moisture": 38.0, "status": "OPTIMAL"},
                {"name": "Main Pasture", "field_id": field_id, "moisture_threshold": 30.0, "current_moisture": 22.0, "status": "DRY"},
            ]
            for z in zones:
                db_zone = models.IrrigationZone(**z)
                db.add(db_zone)
            db.commit()

            # Seed some events
            z1 = db.query(models.IrrigationZone).filter(models.IrrigationZone.name == "North Orchard").first()
            if z1:
                from datetime import datetime, timedelta
                events = [
                    {"zone_id": z1.id, "scheduled_time": datetime.utcnow() + timedelta(hours=2), "duration_minutes": 45, "status": "AUTO_SKIPPED", "reason": "Rain Forecast"},
                    {"zone_id": z1.id, "scheduled_time": datetime.utcnow() - timedelta(hours=3), "duration_minutes": 60, "status": "COMPLETED"},
                ]
                for ev in events:
                    db.add(models.IrrigationEvent(**ev))
                db.commit()

        # --- Biogas Seeding (SQL) ---
        if db.query(models.BiogasSystem).count() == 0:
            print("Seeding Biogas Systems to SQL Database...")
            systems = [
                {"name": "Main Digester Alpha", "total_capacity_m3": 500.0, "current_pressure_bar": 0.85, "max_safe_pressure": 1.2, "min_safe_pressure": 0.2, "production_rate_m3h": 12.5, "consumption_rate_m3h": 10.2, "status": "normal"},
            ]
            for s in systems:
                db_system = models.BiogasSystem(**s)
                db.add(db_system)
            db.commit()
            
            # Seed zones for the system
            sys = db.query(models.BiogasSystem).first()
            if sys:
                zones = [
                    {"system_id": sys.id, "name": "Primary Digester Tank", "zone_type": "digester", "current_pressure": 0.85, "flow_rate": 5.2, "valve_status": "open", "leak_sensor_status": "normal", "pressure_drop_rate": 0.01},
                    {"system_id": sys.id, "name": "Gas Storage Tank A", "zone_type": "storage", "current_pressure": 0.82, "flow_rate": 0.0, "valve_status": "open", "leak_sensor_status": "normal", "pressure_drop_rate": 0.005},
                    {"system_id": sys.id, "name": "Main Distribution Line", "zone_type": "pipeline", "current_pressure": 0.78, "flow_rate": 4.8, "valve_status": "open", "leak_sensor_status": "warning", "pressure_drop_rate": 0.06},
                ]
                for z in zones:
                    db.add(models.BiogasZone(**z))
                db.commit()

        # --- Energy Log Seeding (SQL) ---
        if db.query(models.EnergyLog).count() == 0:
            print("Seeding Energy Logs to SQL Database...")
            from datetime import datetime, timedelta
            for i in range(24):
                log = {
                    "timestamp": datetime.utcnow() - timedelta(hours=i),
                    "battery_voltage": 50.0 + (i % 5),
                    "battery_percentage": 70 + (i % 20),
                    "consumption_watts": 1200 + (i * 10),
                    "solar_generation_watts": 1500 if 6 < (datetime.utcnow() - timedelta(hours=i)).hour < 18 else 0,
                    "grid_status": "disconnected" if i % 12 == 0 else "connected"
                }
                db.add(models.EnergyLog(**log))
            db.commit()
            
        print("Sample data seeded successfully.")

    except Exception as e:
        print(f"Error seeding database: {e}")
    finally:
        db.close()
