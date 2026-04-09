
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

-- Mobile Feature Support: Task comments
CREATE TABLE IF NOT EXISTS task_comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_task_comments_task (task_id, created_at),
  INDEX idx_task_comments_user (user_id)
);

-- Mobile Feature Support: Livestock weight tracking
CREATE TABLE IF NOT EXISTS livestock_weights (
  id INT AUTO_INCREMENT PRIMARY KEY,
  livestock_id INT NOT NULL,
  weight_kg DECIMAL(10,2) NOT NULL,
  date DATETIME NOT NULL,
  notes TEXT NULL,
  created_by INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_livestock_weights_livestock (livestock_id, date)
);

-- Mobile Feature Support: Financial attachments
CREATE TABLE IF NOT EXISTS financial_attachments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT NOT NULL,
  file_url VARCHAR(255) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NULL,
  created_by INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_financial_attachments_txn (transaction_id, created_at)
);

-- Mobile Feature Support: Weather alerts
CREATE TABLE IF NOT EXISTS weather_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  severity VARCHAR(20) NOT NULL DEFAULT 'info',
  location VARCHAR(255) NULL,
  issued_at DATETIME NOT NULL,
  expires_at DATETIME NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  acknowledged TINYINT(1) NOT NULL DEFAULT 0,
  acknowledged_by INT NULL,
  acknowledged_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_weather_alerts_active (status, type, issued_at)
);

-- Mobile Feature Support: Push device tokens
CREATE TABLE IF NOT EXISTS mobile_device_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_token VARCHAR(255) NOT NULL,
  platform VARCHAR(30) NOT NULL DEFAULT 'mobile',
  last_seen_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_device_token (device_token),
  INDEX idx_mobile_tokens_user (user_id)
);

-- Seed weather alerts (idempotent bootstrap data)
INSERT INTO weather_alerts (type, message, severity, location, issued_at, expires_at, status)
SELECT 'frost', 'Frost risk expected overnight. Protect sensitive crops.', 'warning', 'North Field', NOW(), DATE_ADD(NOW(), INTERVAL 12 HOUR), 'active'
WHERE NOT EXISTS (
  SELECT 1 FROM weather_alerts
  WHERE type = 'frost' AND status = 'active'
);

INSERT INTO weather_alerts (type, message, severity, location, issued_at, expires_at, status)
SELECT 'heavy_rain', 'Heavy rain expected within 24 hours. Check drainage channels.', 'warning', 'South Pasture', NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR), 'active'
WHERE NOT EXISTS (
  SELECT 1 FROM weather_alerts
  WHERE type = 'heavy_rain' AND status = 'active'
);

INSERT INTO weather_alerts (type, message, severity, location, issued_at, expires_at, status)
SELECT 'high_wind', 'High wind advisory active. Secure loose structures.', 'info', 'Equipment Yard', NOW(), DATE_ADD(NOW(), INTERVAL 10 HOUR), 'active'
WHERE NOT EXISTS (
  SELECT 1 FROM weather_alerts
  WHERE type = 'high_wind' AND status = 'active'
);
