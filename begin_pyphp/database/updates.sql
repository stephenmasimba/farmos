
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
