-- Multi-tenancy support for Begin Masimba FarmOS
-- This allows multiple farms/organizations to use the same system with data isolation

-- Tenants table to store farm/organization information
CREATE TABLE IF NOT EXISTS tenants (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  subdomain VARCHAR(100) UNIQUE,
  domain VARCHAR(255),
  description TEXT,
  address TEXT,
  phone VARCHAR(20),
  email VARCHAR(255),
  logo_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  subscription_plan VARCHAR(50) DEFAULT 'basic',
  subscription_expires DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add tenant_id to all major tables for data isolation
ALTER TABLE users ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE livestock_batches ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE transactions ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE inventory_items ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE tasks ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE fields ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE weather_logs ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE iot_devices ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE sensor_readings ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE alerts ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE timesheets ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE sales_orders ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE equipment ADD COLUMN tenant_id INT, ADD FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- Create indexes for tenant isolation
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_livestock_tenant ON livestock_batches(tenant_id);
CREATE INDEX idx_transactions_tenant ON transactions(tenant_id);
CREATE INDEX idx_inventory_tenant ON inventory_items(tenant_id);
CREATE INDEX idx_tasks_tenant ON tasks(tenant_id);
CREATE INDEX idx_fields_tenant ON fields(tenant_id);
CREATE INDEX idx_weather_tenant ON weather_logs(tenant_id);
CREATE INDEX idx_iot_devices_tenant ON iot_devices(tenant_id);
CREATE INDEX idx_sensor_readings_tenant ON sensor_readings(tenant_id);
CREATE INDEX idx_alerts_tenant ON alerts(tenant_id);
CREATE INDEX idx_timesheets_tenant ON timesheets(tenant_id);
CREATE INDEX idx_sales_orders_tenant ON sales_orders(tenant_id);
CREATE INDEX idx_equipment_tenant ON equipment(tenant_id);

-- Tenant settings table for customizable configurations
CREATE TABLE IF NOT EXISTS tenant_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tenant_id INT NOT NULL,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  UNIQUE KEY unique_tenant_setting (tenant_id, setting_key)
);

-- Insert default tenant (Begin Masimba Farm)
INSERT INTO tenants (name, subdomain, description, is_active) VALUES
('Begin Masimba Farm', 'beginmasimba', 'Primary farm for Begin Masimba operations', TRUE);

-- Update existing data to belong to default tenant
SET @default_tenant_id = (SELECT id FROM tenants WHERE subdomain = 'beginmasimba' LIMIT 1);
UPDATE users SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE livestock_batches SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE transactions SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE inventory_items SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE tasks SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE fields SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE weather_logs SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE iot_devices SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE sensor_readings SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE alerts SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE timesheets SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE sales_orders SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;
UPDATE equipment SET tenant_id = @default_tenant_id WHERE tenant_id IS NULL;