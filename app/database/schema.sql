-- Begin Masimba FarmOS Database Schema
-- PostgreSQL + TimeScaleDB

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "timescaledb" CASCADE;

-- ============================================================
-- USERS & ROLES
-- ============================================================

CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  role_id INTEGER REFERENCES roles(id),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

-- ============================================================
-- LIVESTOCK MANAGEMENT
-- ============================================================

CREATE TABLE livestock_batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  batch_code VARCHAR(50) UNIQUE NOT NULL,
  animal_type VARCHAR(50) NOT NULL,  -- 'broiler', 'layer', 'pig', 'fish', 'duck'
  location VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  expected_harvest_date DATE,
  initial_quantity INTEGER NOT NULL,
  current_quantity INTEGER NOT NULL,
  unit_cost DECIMAL(10, 2),
  supplier VARCHAR(255),
  notes TEXT,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'harvested', 'failed'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE animal_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  batch_id UUID NOT NULL REFERENCES livestock_batches(id),
  event_type VARCHAR(50) NOT NULL, -- 'mortality', 'illness', 'vaccination', 'treatment', 'feeding', 'weight'
  quantity_affected INTEGER,
  value DECIMAL(10, 2),
  unit VARCHAR(50), -- 'kg', 'count', etc
  description TEXT,
  created_by UUID REFERENCES users(id),
  event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_event_type CHECK (event_type IN ('mortality', 'illness', 'vaccination', 'treatment', 'feeding', 'weight'))
);

-- ============================================================
-- CROPS & FARMING
-- ============================================================

CREATE TABLE crops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  crop_code VARCHAR(50) UNIQUE NOT NULL,
  crop_name VARCHAR(255) NOT NULL, -- 'maize', 'soybean', 'sunflower', 'greens', etc
  plot_location VARCHAR(255),
  plot_size_sqm DECIMAL(10, 2),
  planting_date DATE NOT NULL,
  expected_harvest_date DATE,
  variety VARCHAR(255),
  seed_cost DECIMAL(10, 2),
  fertilizer_type VARCHAR(255),
  expected_yield_kg DECIMAL(10, 2),
  actual_yield_kg DECIMAL(10, 2),
  notes TEXT,
  status VARCHAR(20) DEFAULT 'growing', -- 'planning', 'growing', 'harvesting', 'harvested', 'failed'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- INVENTORY & STOCK
-- ============================================================

CREATE TABLE inventory_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_code VARCHAR(50) UNIQUE NOT NULL,
  item_name VARCHAR(255) NOT NULL,
  category VARCHAR(50), -- 'feed', 'fertilizer', 'medicine', 'tools', 'supplies'
  quantity DECIMAL(10, 3) NOT NULL DEFAULT 0,
  unit VARCHAR(50) NOT NULL, -- 'kg', 'liters', 'units', etc
  unit_cost DECIMAL(10, 2),
  reorder_level DECIMAL(10, 3),
  supplier VARCHAR(255),
  expiry_date DATE,
  location VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id),
  transaction_type VARCHAR(20) NOT NULL, -- 'in', 'out', 'adjustment'
  quantity DECIMAL(10, 3) NOT NULL,
  reference_code VARCHAR(50), -- PO number, batch code, etc
  notes TEXT,
  created_by UUID REFERENCES users(id),
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- FEED FORMULATION
-- ============================================================

CREATE TABLE feed_ingredients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ingredient_name VARCHAR(255) NOT NULL,
  ingredient_type VARCHAR(50), -- 'grain', 'protein', 'vitamin', 'mineral'
  unit_cost DECIMAL(10, 2),
  availability VARCHAR(20), -- 'on_farm', 'purchased', 'both'
  nutritional_content JSONB, -- { protein: 16, fat: 5, fiber: 8, ... }
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE feed_formulations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  formulation_code VARCHAR(50) UNIQUE NOT NULL,
  target_animal VARCHAR(50) NOT NULL, -- 'broiler', 'layer', 'pig', 'fish'
  target_stage VARCHAR(50), -- 'starter', 'grower', 'finisher'
  protein_target DECIMAL(5, 2),
  fat_target DECIMAL(5, 2),
  fiber_target DECIMAL(5, 2),
  ingredients JSONB NOT NULL, -- array of {ingredient_id, percentage, quantity_kg}
  total_batch_kg DECIMAL(10, 2),
  unit_cost DECIMAL(10, 2),
  created_by UUID REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- FINANCIAL TRACKING
-- ============================================================

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_code VARCHAR(50) UNIQUE NOT NULL,
  transaction_type VARCHAR(20) NOT NULL, -- 'income', 'expense'
  category VARCHAR(50) NOT NULL, -- 'sales', 'feed', 'labor', 'utilities', 'maintenance'
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(255),
  reference_id UUID, -- References batch, crop, or other entity
  payment_method VARCHAR(50), -- 'cash', 'bank_transfer', 'mobile_money'
  created_by UUID REFERENCES users(id),
  transaction_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_type CHECK (transaction_type IN ('income', 'expense'))
);

-- ============================================================
-- SALES & PRODUCTION OUTPUT
-- ============================================================

CREATE TABLE sales_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_code VARCHAR(50) UNIQUE NOT NULL,
  customer_name VARCHAR(255) NOT NULL,
  product_type VARCHAR(50) NOT NULL, -- 'broiler', 'eggs', 'fish', 'pork', 'vegetables'
  quantity DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(50) NOT NULL, -- 'kg', 'units', 'crates'
  unit_price DECIMAL(10, 2) NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  order_date DATE NOT NULL,
  delivery_date DATE,
  delivery_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'delivered', 'cancelled'
  payment_status VARCHAR(20) DEFAULT 'unpaid', -- 'unpaid', 'partial', 'paid'
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- IOT SENSORS (TimescaleDB Hypertable)
-- ============================================================

CREATE TABLE sensor_readings (
  time TIMESTAMP NOT NULL,
  sensor_id VARCHAR(50) NOT NULL,
  sensor_type VARCHAR(50) NOT NULL, -- 'temperature', 'humidity', 'ph', 'ammonia', 'water_level', 'energy'
  location VARCHAR(100) NOT NULL,
  value DECIMAL(10, 3) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'ok', -- 'ok', 'warning', 'critical'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create hypertable for sensor readings (TimescaleDB)
SELECT create_hypertable('sensor_readings', 'time', if_not_exists => TRUE);

-- ============================================================
-- ALERTS & NOTIFICATIONS
-- ============================================================

CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_type VARCHAR(50) NOT NULL, -- 'stock_low', 'sensor_alert', 'mortality', 'deadline'
  severity VARCHAR(20) NOT NULL DEFAULT 'info', -- 'info', 'warning', 'critical'
  title VARCHAR(255) NOT NULL,
  description TEXT,
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP
);

-- ============================================================
-- TASK MANAGEMENT
-- ============================================================

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_code VARCHAR(50) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  assigned_to UUID REFERENCES users(id),
  priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'cancelled'
  due_date DATE,
  completed_at TIMESTAMP,
  related_batch_id UUID REFERENCES livestock_batches(id),
  related_crop_id UUID REFERENCES crops(id),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_livestock_batches_status ON livestock_batches(status);
CREATE INDEX idx_livestock_batches_type ON livestock_batches(animal_type);
CREATE INDEX idx_animal_events_batch_id ON animal_events(batch_id);
CREATE INDEX idx_crops_status ON crops(status);
CREATE INDEX idx_inventory_items_category ON inventory_items(category);
CREATE INDEX idx_inventory_transactions_item_id ON inventory_transactions(inventory_item_id);
CREATE INDEX idx_transactions_category ON transactions(category);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_sales_orders_status ON sales_orders(delivery_status);
CREATE INDEX idx_sensor_readings_sensor_id ON sensor_readings(sensor_id, time DESC);
CREATE INDEX idx_alerts_is_read ON alerts(is_read);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);

-- ============================================================
-- VIEWS FOR ANALYTICS
-- ============================================================

-- Monthly Financial Summary
CREATE VIEW monthly_financial_summary AS
SELECT
  DATE_TRUNC('month', transaction_date) AS month,
  SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) AS total_income,
  SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) AS total_expense,
  SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE -amount END) AS gross_profit
FROM transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month DESC;

-- Livestock Batch Summary
CREATE VIEW livestock_summary AS
SELECT
  lb.animal_type,
  COUNT(DISTINCT lb.id) AS active_batches,
  SUM(lb.current_quantity) AS total_animals,
  AVG(lb.current_quantity) AS avg_batch_size,
  COUNT(ae.id) FILTER (WHERE ae.event_type = 'mortality') AS total_mortality_events
FROM livestock_batches lb
LEFT JOIN animal_events ae ON lb.id = ae.batch_id
WHERE lb.status = 'active'
GROUP BY lb.animal_type;

-- Inventory Low Stock Alert
CREATE VIEW low_stock_inventory AS
SELECT
  id,
  item_name,
  category,
  quantity,
  unit,
  reorder_level,
  (reorder_level - quantity) AS additional_units_needed
FROM inventory_items
WHERE quantity <= reorder_level
ORDER BY additional_units_needed DESC;

-- Daily Dashboard Metrics
CREATE VIEW daily_metrics AS
SELECT
  CURRENT_DATE AS metric_date,
  (SELECT COUNT(*) FROM livestock_batches WHERE status = 'active') AS active_livestock_batches,
  (SELECT COUNT(*) FROM crops WHERE status IN ('growing', 'harvesting')) AS active_crops,
  (SELECT COUNT(*) FROM inventory_items WHERE quantity <= reorder_level) AS low_stock_items,
  (SELECT SUM(amount) FROM transactions WHERE transaction_date = CURRENT_DATE AND transaction_type = 'income') AS today_income,
  (SELECT SUM(amount) FROM transactions WHERE transaction_date = CURRENT_DATE AND transaction_type = 'expense') AS today_expense;
