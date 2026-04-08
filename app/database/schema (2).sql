-- Roles Table
CREATE TABLE IF NOT EXISTS roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

-- Insert default roles if they don't exist
INSERT IGNORE INTO roles (name) VALUES ('admin'), ('manager'), ('general_hand');

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id INT,
  phone VARCHAR(20),
  last_login DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Transactions Table (Financials)
CREATE TABLE IF NOT EXISTS transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_code VARCHAR(50) UNIQUE,
  transaction_type ENUM('income', 'expense') NOT NULL,
  category VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description TEXT,
  transaction_date DATE NOT NULL,
  payment_method VARCHAR(50),
  reference_id VARCHAR(50),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Livestock Batches Table
CREATE TABLE IF NOT EXISTS livestock_batches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  batch_code VARCHAR(50) NOT NULL UNIQUE,
  animal_type VARCHAR(50) NOT NULL,
  breed VARCHAR(50),
  initial_quantity INT NOT NULL,
  current_quantity INT NOT NULL,
  birth_date DATE,
  acquisition_date DATE,
  expected_harvest_date DATE,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Animal Events Table
CREATE TABLE IF NOT EXISTS animal_events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  batch_id INT NOT NULL,
  event_type VARCHAR(50) NOT NULL, -- 'vaccination', 'mortality', 'weighing', 'feed'
  description TEXT,
  event_date DATE NOT NULL,
  performed_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (batch_id) REFERENCES livestock_batches(id),
  FOREIGN KEY (performed_by) REFERENCES users(id)
);

-- Sensor Data Table
CREATE TABLE IF NOT EXISTS sensor_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sensor_type VARCHAR(50) NOT NULL,
  value DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(10),
  location VARCHAR(50),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory/Low Stock
CREATE TABLE IF NOT EXISTS inventory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  quantity DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(20) NOT NULL,
  reorder_level DECIMAL(10, 2) NOT NULL,
  cost_per_unit DECIMAL(10, 2),
  supplier_id INT,
  description TEXT,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Suppliers Table
CREATE TABLE IF NOT EXISTS suppliers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  contact_person VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory Transactions (Stock Movement)
CREATE TABLE IF NOT EXISTS inventory_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_id INT NOT NULL,
  transaction_type ENUM('in', 'out', 'adjustment') NOT NULL,
  quantity DECIMAL(10, 2) NOT NULL,
  unit_price DECIMAL(10, 2),
  total_cost DECIMAL(10, 2),
  reason VARCHAR(100), -- 'purchase', 'usage', 'loss', 'return'
  reference_id VARCHAR(50), -- Invoice # or Usage Log #
  performed_by INT,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (item_id) REFERENCES inventory(id),
  FOREIGN KEY (performed_by) REFERENCES users(id)
);

-- Equipment Table
CREATE TABLE IF NOT EXISTS equipment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  serial_number VARCHAR(50),
  purchase_date DATE,
  purchase_price DECIMAL(10, 2),
  status ENUM('active', 'maintenance', 'retired') DEFAULT 'active',
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance Logs
CREATE TABLE IF NOT EXISTS maintenance_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  equipment_id INT NOT NULL,
  maintenance_date DATE NOT NULL,
  description TEXT NOT NULL,
  cost DECIMAL(10, 2),
  performed_by VARCHAR(100), -- External or internal name
  next_maintenance_due DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (equipment_id) REFERENCES equipment(id)
);

-- Livestock Growth/Weight Tracking
CREATE TABLE IF NOT EXISTS livestock_growth (
  id INT AUTO_INCREMENT PRIMARY KEY,
  batch_id INT NOT NULL,
  record_date DATE NOT NULL,
  average_weight DECIMAL(10, 2), -- kg
  average_height DECIMAL(10, 2), -- cm
  notes TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (batch_id) REFERENCES livestock_batches(id),
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Feed Logs
CREATE TABLE IF NOT EXISTS feed_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  batch_id INT NOT NULL,
  feed_item_id INT, -- Link to inventory
  quantity DECIMAL(10, 2) NOT NULL,
  cost DECIMAL(10, 2),
  feeding_date DATE NOT NULL,
  notes TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (batch_id) REFERENCES livestock_batches(id),
  FOREIGN KEY (feed_item_id) REFERENCES inventory(id),
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Health Records
CREATE TABLE IF NOT EXISTS health_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  batch_id INT NOT NULL,
  record_date DATE NOT NULL,
  condition_name VARCHAR(100),
  diagnosis TEXT,
  treatment TEXT,
  medication_used VARCHAR(100),
  cost DECIMAL(10, 2),
  veterinarian VARCHAR(100),
  outcome TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (batch_id) REFERENCES livestock_batches(id),
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Breeding Records
CREATE TABLE IF NOT EXISTS breeding_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dam_id VARCHAR(50), -- Mother ID/Tag
  sire_id VARCHAR(50), -- Father ID/Tag
  breeding_date DATE NOT NULL,
  expected_birthing_date DATE,
  actual_birthing_date DATE,
  outcome TEXT, -- 'live', 'stillborn'
  offspring_count INT,
  notes TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type ENUM('info', 'warning', 'success', 'error', 'email', 'sms') NOT NULL DEFAULT 'info',
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- System Settings Table
CREATE TABLE IF NOT EXISTS system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  setting_type VARCHAR(20) DEFAULT 'string', -- string, number, boolean, json
  category VARCHAR(50) DEFAULT 'general',
  description TEXT,
  updated_by INT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Insert default system settings
INSERT IGNORE INTO system_settings (setting_key, setting_value, setting_type, category, description) VALUES
('farm_name', 'Begin Masimba Farm', 'string', 'farm', 'Name of the farm'),
('farm_location', 'Zimbabwe', 'string', 'farm', 'Location of the farm'),
('farm_size', '100', 'number', 'farm', 'Size of the farm in hectares'),
('backup_frequency', 'daily', 'string', 'backup', 'How often to backup data'),
('email_provider', 'smtp', 'string', 'notifications', 'Email service provider'),
('sms_provider', 'none', 'string', 'notifications', 'SMS service provider');

-- User Activity Log Table
CREATE TABLE IF NOT EXISTS user_activity_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  action VARCHAR(100) NOT NULL,
  details TEXT,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- User Invitations Table
CREATE TABLE IF NOT EXISTS user_invitations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) NOT NULL UNIQUE,
  role_id INT,
  invited_by INT NOT NULL,
  invitation_token VARCHAR(190) UNIQUE,
  status ENUM('pending', 'accepted', 'expired') DEFAULT 'pending',
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  FOREIGN KEY (invited_by) REFERENCES users(id)
);

-- Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  assigned_to INT,
  status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  due_date DATE,
  completed_at TIMESTAMP NULL,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Fields Table (Crop Management)
CREATE TABLE IF NOT EXISTS fields (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  area_size DECIMAL(10, 2), -- in hectares
  location_coordinates VARCHAR(255),
  current_crop VARCHAR(100),
  planting_date DATE,
  expected_harvest_date DATE,
  status ENUM('fallow', 'planted', 'harvested', 'prepared') DEFAULT 'fallow',
  soil_type VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crop Rotation History
CREATE TABLE IF NOT EXISTS crop_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  field_id INT NOT NULL,
  crop_name VARCHAR(100) NOT NULL,
  planting_date DATE,
  harvest_date DATE,
  yield_amount DECIMAL(10, 2),
  yield_unit VARCHAR(20),
  notes TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (field_id) REFERENCES fields(id),
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Timesheets (Labor Management)
CREATE TABLE IF NOT EXISTS timesheets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  work_date DATE NOT NULL,
  hours_worked DECIMAL(5, 2) NOT NULL,
  task_description TEXT,
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  approved_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- IoT Devices Table
CREATE TABLE IF NOT EXISTS iot_devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_id VARCHAR(100) UNIQUE NOT NULL,
  device_name VARCHAR(100) NOT NULL,
  device_type VARCHAR(50) NOT NULL, -- 'temperature', 'humidity', 'ph', 'water_level', 'weight', 'ammonia'
  location VARCHAR(100),
  status ENUM('active', 'inactive', 'maintenance', 'offline') DEFAULT 'active',
  last_seen TIMESTAMP NULL,
  battery_level DECIMAL(5, 2) NULL, -- percentage
  firmware_version VARCHAR(20),
  configuration JSON,
  registered_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (registered_by) REFERENCES users(id)
);

-- IoT Alerts Table
CREATE TABLE IF NOT EXISTS iot_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_id INT NOT NULL,
  alert_type VARCHAR(50) NOT NULL, -- 'threshold_exceeded', 'device_offline', 'battery_low', 'sensor_error'
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  message TEXT NOT NULL,
  sensor_value DECIMAL(10, 2) NULL,
  threshold_value DECIMAL(10, 2) NULL,
  status ENUM('active', 'acknowledged', 'resolved') DEFAULT 'active',
  acknowledged_by INT NULL,
  acknowledged_at TIMESTAMP NULL,
  resolved_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_id) REFERENCES iot_devices(id),
  FOREIGN KEY (acknowledged_by) REFERENCES users(id)
);

-- Alert Rules Table
CREATE TABLE IF NOT EXISTS alert_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_type VARCHAR(50) NOT NULL,
  sensor_type VARCHAR(50) NOT NULL,
  condition_type ENUM('above', 'below', 'equals', 'between') NOT NULL,
  threshold_min DECIMAL(10, 2) NULL,
  threshold_max DECIMAL(10, 2) NULL,
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  enabled BOOLEAN DEFAULT TRUE,
  notification_channels JSON, -- ['email', 'sms', 'in_app']
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);
