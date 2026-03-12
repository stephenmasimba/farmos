CREATE TABLE IF NOT EXISTS api_keys (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  key_hash VARCHAR(255) NOT NULL,
  prefix VARCHAR(10) NOT NULL,
  status ENUM('active', 'revoked') DEFAULT 'active',
  created_by INT,
  last_used_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);
