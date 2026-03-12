from sqlalchemy import Column, Integer, String, Boolean, Float, ForeignKey, DateTime, Text, CheckConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100), index=True)
    email = Column(String(100), unique=True, index=True)
    role = Column(String(20))
    status = Column(String(20), default="active")
    hashed_password = Column(String(255))
    created_at = Column(DateTime, default=datetime.utcnow)

class LivestockBatch(Base):
    __tablename__ = "livestock_batches"

    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    type = Column(String(50), index=True)  # poultry, pig, fish
    name = Column(String(100)) # e.g. "Batch A" or derived from ID
    count = Column(Integer)  # Legacy field - use quantity instead
    quantity = Column(Integer)  # Standardized field for number of animals
    status = Column(String(20), default="active")  # active, completed, sold
    start_date = Column(DateTime, default=datetime.utcnow)
    
    # Additional fields for better tracking
    breed = Column(String(50))
    location = Column(String(100))
    notes = Column(Text, nullable=True)
    
    # Constraints
    __table_args__ = (
        CheckConstraint('quantity >= 0', name='check_quantity_positive'),
        CheckConstraint('count >= 0', name='check_count_positive'),
    )
    
    events = relationship("LivestockEvent", back_populates="batch", cascade="all, delete-orphan")

class LivestockEvent(Base):
    __tablename__ = "livestock_events"
    
    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, ForeignKey("livestock_batches.id", ondelete="CASCADE"))
    tenant_id = Column(String(50), index=True, default="default")
    type = Column(String(50))  # feeding, health_check, vaccination, mortality, harvest
    date = Column(DateTime, default=datetime.utcnow)
    details = Column(Text)
    performed_by = Column(String(100))
    cost = Column(Float, default=0.0)
    
    batch = relationship("LivestockBatch", back_populates="events")

class BreedingRecord(Base):
    __tablename__ = "breeding_records"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    dam_batch_id = Column(Integer, ForeignKey("livestock_batches.id"), nullable=True)
    sire_batch_id = Column(Integer, ForeignKey("livestock_batches.id"), nullable=True)
    animal_id = Column(String(50), nullable=True)
    breeding_date = Column(String(20))
    expected_birth_date = Column(String(20), nullable=True)
    status = Column(String(50), nullable=True)
    offspring_batch_id = Column(Integer, ForeignKey("livestock_batches.id"), nullable=True)
    notes = Column(Text)

class ComplianceRequirement(Base):
    __tablename__ = "compliance_requirements"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    standard = Column(String(100))
    section = Column(String(100))
    description = Column(Text)
    status = Column(String(20))
    last_audit_date = Column(String(20), nullable=True)
    auditor = Column(String(100), nullable=True)
    evidence_url = Column(String(255), nullable=True)

class Listing(Base):
    __tablename__ = "listings"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    seller_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String(200))
    description = Column(Text)
    category = Column(String(50))
    price = Column(Float)
    unit = Column(String(20))
    quantity = Column(Float)
    location = Column(String(100))
    status = Column(String(20), default="active")
    created_at = Column(String(30))

class Order(Base):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    listing_id = Column(Integer, ForeignKey("listings.id"))
    buyer_id = Column(Integer, ForeignKey("users.id"))
    quantity = Column(Float)
    total_price = Column(Float)
    status = Column(String(20), default="pending")
    created_at = Column(String(30))

class Customer(Base):
    __tablename__ = "customers"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    email = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    address = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)

class Contract(Base):
    __tablename__ = "contracts"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    grower_name = Column(String(100))
    crop = Column(String(50))
    acreage = Column(Float)
    agreed_price_per_kg = Column(Float)
    start_date = Column(String(20))
    end_date = Column(String(20))
    status = Column(String(20), default="Active")

class Budget(Base):
    __tablename__ = "budgets"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    category = Column(String(100))
    limit = Column(Float)
    period = Column(String(20)) # monthly, yearly
    year = Column(Integer)
    spent = Column(Float, default=0.0)

class Invoice(Base):
    __tablename__ = "invoices"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    invoice_number = Column(String(50), unique=True)
    customer_name = Column(String(100))
    amount = Column(Float)
    status = Column(String(20)) # unpaid, paid, overdue
    due_date = Column(String(20))
    items = Column(Text) # JSON string

class CostCenter(Base):
    __tablename__ = "cost_centers"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    description = Column(String(255))

class CostAllocation(Base):
    __tablename__ = "cost_allocations"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    transaction_id = Column(Integer, ForeignKey("financial_transactions.id"))
    cost_center_id = Column(Integer, ForeignKey("cost_centers.id"))
    amount = Column(Float)
    percentage = Column(Float)

class InventoryItem(Base):
    __tablename__ = "inventory_items"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100), index=True)
    category = Column(String(50))
    quantity = Column(Float)
    unit = Column(String(20))
    location = Column(String(100))
    low_stock_threshold = Column(Float, default=10.0)
    qr_code = Column(String(50), unique=True, index=True)

class InventoryTransaction(Base):
    __tablename__ = "inventory_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    item_id = Column(Integer, ForeignKey("inventory_items.id"))
    type = Column(String(20)) # in, out, adjustment
    quantity = Column(Float)
    reason = Column(String(255))
    date = Column(String(20))
    
    item = relationship("InventoryItem")

class Field(Base):
    __tablename__ = "fields"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    area = Column(Float)
    unit = Column(String(20))
    crop = Column(String(50))
    status = Column(String(50))

class FieldHistory(Base):
    __tablename__ = "field_history"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    field_id = Column(Integer, ForeignKey("fields.id"))
    action = Column(String(100))
    details = Column(Text)
    date = Column(String(20))
    
    field = relationship("Field")

class SoilHealthLog(Base):
    __tablename__ = "soil_health_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    field_id = Column(Integer, ForeignKey("fields.id"))
    date = Column(String(20))
    organic_matter_percent = Column(Float)
    ph = Column(Float)
    notes = Column(Text)
    
    field = relationship("Field")

class HarvestLog(Base):
    __tablename__ = "harvest_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    field_id = Column(Integer, ForeignKey("fields.id"))
    date = Column(String(20))
    crop = Column(String(50))
    yield_amount = Column(Float)
    unit = Column(String(20))
    target_yield = Column(Float, nullable=True)
    location_lat = Column(Float, nullable=True)
    location_lng = Column(Float, nullable=True)
    
    field = relationship("Field")

class RotationPlan(Base):
    __tablename__ = "rotation_plans"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    field_id = Column(Integer, ForeignKey("fields.id"))
    year = Column(Integer)
    season = Column(String(20))
    planned_crop = Column(String(50))
    notes = Column(Text)
    
    field = relationship("Field")

class ScoutingLog(Base):
    __tablename__ = "scouting_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    field_id = Column(Integer, ForeignKey("fields.id"))
    date = Column(String(20))
    observer = Column(String(100))
    pest_disease_name = Column(String(100))
    severity = Column(String(20))
    photo_url = Column(String(255), nullable=True)
    notes = Column(Text)
    location_lat = Column(Float, nullable=True)
    location_lng = Column(Float, nullable=True)
    
    field = relationship("Field")


class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    title = Column(String(200))
    description = Column(Text)
    assigned_to = Column(String(100))
    status = Column(String(50)) # pending, in_progress, completed
    priority = Column(String(20)) # low, medium, high
    due_date = Column(String(20))
    is_recurring = Column(Boolean, default=False)

class FinancialTransaction(Base):
    __tablename__ = "financial_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    type = Column(String(20)) # income, expense
    category = Column(String(50))
    amount = Column(Float)
    description = Column(String(255))
    date = Column(String(20))

class SOP(Base):
    __tablename__ = "sops"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    title = Column(String(200))
    content = Column(Text)
    role = Column(String(50))
    created_at = Column(String(20))

class SOPExecution(Base):
    __tablename__ = "sop_executions"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    sop_id = Column(Integer, ForeignKey("sops.id"))
    executed_by = Column(Integer, ForeignKey("users.id"))
    executed_at = Column(String(20))
    status = Column(String(20)) # completed, failed
    notes = Column(Text, nullable=True)
    
    sop = relationship("SOP")
    executor = relationship("User")

class Schedule(Base):
    __tablename__ = "schedules"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    user_id = Column(Integer, ForeignKey("users.id"))
    start_time = Column(String(20)) # ISO datetime
    end_time = Column(String(20)) # ISO datetime
    role = Column(String(50))
    notes = Column(Text, nullable=True)
    
    user = relationship("User")

class Timesheet(Base):
    __tablename__ = "timesheets"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    work_date = Column(String(20))
    hours_worked = Column(Float)
    task_description = Column(Text, nullable=True)
    status = Column(String(20), default="pending") # pending, approved, rejected
    approved_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", foreign_keys=[user_id])
    approver = relationship("User", foreign_keys=[approved_by])

class FeedIngredient(Base):
    __tablename__ = "feed_ingredients"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    protein_content = Column(Float) # Percent
    quantity_kg = Column(Float)
    cost_per_kg = Column(Float)
    notes = Column(Text, nullable=True)

# Advanced Features Models
class Equipment(Base):
    __tablename__ = "equipment"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100), index=True)
    location = Column(String(100))
    status = Column(String(20), default="healthy") # healthy, at_risk, critical, maintenance
    vibration_baseline = Column(Float, default=0.0)
    temperature_baseline = Column(Float, default=0.0)
    current_draw_baseline = Column(Float, default=0.0)
    last_maintenance = Column(DateTime, nullable=True)
    next_maintenance = Column(DateTime, nullable=True)

class MaintenanceLog(Base):
    __tablename__ = "maintenance_logs"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    equipment_id = Column(Integer, ForeignKey("equipment.id"))
    timestamp = Column(DateTime, default=datetime.utcnow)
    vibration = Column(Float)
    temperature = Column(Float)
    current_draw = Column(Float)
    risk_score = Column(Float)
    notes = Column(Text)

class CompostPile(Base):
    __tablename__ = "compost_piles"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    type = Column(String(50)) # Hot Compost, Cold Compost
    status = Column(String(20)) # OPTIMAL, SLOW, COMPLETED
    temperature_c = Column(Float)
    moisture_pct = Column(Float)
    ph = Column(Float)
    days_active = Column(Integer, default=0)
    last_turned = Column(DateTime)

class BSFCycle(Base):
    __tablename__ = "bsf_cycles"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    cycle_name = Column(String(100))
    start_date = Column(DateTime, default=datetime.utcnow)
    waste_input_kg = Column(Float)
    expected_yield_kg = Column(Float)
    actual_yield_kg = Column(Float, nullable=True)
    status = Column(String(20)) # active, completed

class SensorData(Base):
    __tablename__ = "sensor_data"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    timestamp = Column(DateTime, default=datetime.utcnow)
    sensor_type = Column(String(50)) # ph, dissolved_oxygen, temperature, ammonia
    value = Column(Float)
    unit = Column(String(20))
    location = Column(String(100))

class WaterQualityLog(Base):
    __tablename__ = "water_quality_logs"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    date = Column(String(20))
    source = Column(String(100))
    ph = Column(Float)
    dissolved_oxygen = Column(Float)
    turbidity = Column(Float)
    notes = Column(Text, nullable=True)

class FeedFormulation(Base):
    __tablename__ = "feed_formulations"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    target_protein = Column(Float)
    final_cost_per_kg = Column(Float)
    status = Column(String(20)) # active, archived
    created_at = Column(DateTime, default=datetime.utcnow)
    ingredients_json = Column(Text) # Store as JSON string for simplicity

class EnergyLoad(Base):
    __tablename__ = "energy_loads"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    location = Column(String(100))
    load_type = Column(String(50)) # cooling, heating, pump, lighting, security
    power_watts = Column(Float)
    is_essential = Column(Boolean, default=False)
    status = Column(String(20), default="off") # on, off
    priority = Column(Integer, default=5) # 1-10

class IrrigationZone(Base):
    __tablename__ = "irrigation_zones"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    field_id = Column(Integer, ForeignKey("fields.id"))
    moisture_threshold = Column(Float, default=30.0)
    current_moisture = Column(Float, default=0.0)
    status = Column(String(20), default="OPTIMAL") # DRY, OPTIMAL, WET

class IrrigationEvent(Base):
    __tablename__ = "irrigation_events"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    zone_id = Column(Integer, ForeignKey("irrigation_zones.id"))
    scheduled_time = Column(DateTime)
    duration_minutes = Column(Integer)
    status = Column(String(20)) # SCHEDULED, COMPLETED, AUTO_SKIPPED
    reason = Column(String(255), nullable=True)

class BiogasSystem(Base):
    __tablename__ = "biogas_systems"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    name = Column(String(100))
    total_capacity_m3 = Column(Float)
    current_pressure_bar = Column(Float, default=0.0)
    max_safe_pressure = Column(Float, default=1.5)
    min_safe_pressure = Column(Float, default=0.1)
    production_rate_m3h = Column(Float, default=0.0)
    consumption_rate_m3h = Column(Float, default=0.0)
    status = Column(String(20), default="normal") # normal, warning, critical
    leak_detection_enabled = Column(Boolean, default=True)
    last_maintenance = Column(DateTime, default=datetime.utcnow)

class BiogasZone(Base):
    __tablename__ = "biogas_zones"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    system_id = Column(Integer, ForeignKey("biogas_systems.id"))
    name = Column(String(100))
    zone_type = Column(String(50)) # digester, storage, pipeline
    current_pressure = Column(Float)
    flow_rate = Column(Float)
    valve_status = Column(String(20), default="open") # open, closed
    leak_sensor_status = Column(String(20), default="normal") # normal, warning, triggered
    pressure_drop_rate = Column(Float, default=0.0)
    isolation_possible = Column(Boolean, default=True)

class EnergyLog(Base):
    __tablename__ = "energy_logs"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    timestamp = Column(DateTime, default=datetime.utcnow)
    battery_voltage = Column(Float, nullable=True)
    battery_percentage = Column(Integer, nullable=True)
    consumption_watts = Column(Float, nullable=True)
    solar_generation_watts = Column(Float, nullable=True)
    grid_status = Column(String(20), default="connected") # connected, disconnected
    load_id = Column(Integer, ForeignKey("energy_loads.id"), nullable=True)
    consumption_kwh = Column(Float, nullable=True) # For specific load if load_id is set
    cost_estimate = Column(Float, nullable=True)

class QRInventoryItem(Base):
    __tablename__ = "qr_inventory_items"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    item_id = Column(Integer)
    item_type = Column(String(50)) # inventory, equipment, livestock
    qr_data = Column(Text)
    qr_image_url = Column(Text)
    generated_by = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

class QRScan(Base):
    __tablename__ = "qr_scans"
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(String(50), index=True, default="default")
    item_id = Column(Integer, nullable=True)
    item_type = Column(String(50))
    scan_type = Column(String(50)) # inventory_update, equipment_check, etc.
    scanned_by = Column(Integer, ForeignKey("users.id"))
    scan_data = Column(Text)
    scan_timestamp = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)

# We can add more models here as we migrate more modules
