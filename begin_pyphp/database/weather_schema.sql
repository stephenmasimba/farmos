CREATE TABLE IF NOT EXISTS weather_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  log_date DATE NOT NULL,
  temperature_c DECIMAL(5,2),
  humidity_percent DECIMAL(5,2),
  rainfall_mm DECIMAL(6,2) DEFAULT 0,
  wind_speed_kph DECIMAL(5,2),
  conditions VARCHAR(50),
  notes TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (recorded_by) REFERENCES users(id)
);
