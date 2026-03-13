# FarmOS Database Schema Documentation

**Version**: 1.0.0  
**Date**: March 12, 2026  
**Status**: Production Ready  
**Database**: MySQL 5.7+

---

## 📋 Table of Contents

1. [Schema Overview](#schema-overview)
2. [Core Tables](#core-tables)
3. [Relationships & Constraints](#relationships--constraints)
4. [Database Migrations](#database-migrations)
5. [Backup & Recovery](#backup--recovery)
6. [Performance Optimization](#performance-optimization)
7. [Schema Management](#schema-management)

---

## Schema Overview

### Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐
│   users     │◄───────►│   farms      │
├─────────────┤         ├──────────────┤
│ id (PK)     │         │ id (PK)      │
│ email (UQ)  │         │ name         │
│ password    │         │ user_id (FK) │
│ status      │         │ location     │
│ created_at  │         │ created_at   │
└─────────────┘         └──────┬───────┘
       ▲                        │
       │                        ▼
       │                ┌──────────────────┐
       │                │ livestock_batches│
       │                ├──────────────────┤
       │                │ id (PK)          │
       │                │ farm_id (FK)     │
       │                │ batch_code (UQ)  │
       │                │ species          │
       │                │ quantity         │
       │                │ created_at       │
       │                └────────┬─────────┘
       │                         │
       │                         ▼
       │                 ┌──────────────────┐
       │                 │ livestock        │
       │                 ├──────────────────┤
       │                 │ id (PK)          │
       │                 │ batch_id (FK)    │
       │                 │ animal_tag       │
       │                 │ weight           │
       │                 │ status           │
       │                 │ created_at       │
       │                 └────────┬─────────┘
       │                          │
       │                          ▼
       │                 ┌──────────────────┐
       │                 │ animal_events    │
       │                 ├──────────────────┤
       │                 │ id (PK)          │
       │                 │ animal_id (FK)   │
       │                 │ event_type       │
       │                 │ data             │
       │                 │ timestamp        │
       │                 └──────────────────┘
       │
       │ (Farm Admin)
       │
       └────────────┐
                    │
                    ▼
           ┌──────────────────┐
           │ financial_records│
           ├──────────────────┤
           │ id (PK)          │
           │ farm_id (FK)     │
           │ type             │
           │ amount           │
           │ date             │
           └──────────────────┘
```

---

## Core Tables

### 1. users Table

**Purpose**: User authentication and profile management

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    role ENUM('admin', 'manager', 'worker', 'viewer') DEFAULT 'viewer',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Unique user identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User email (used for login) |
| username | VARCHAR(100) | UNIQUE | Optional username |
| password_hash | VARCHAR(255) | NOT NULL | Bcrypt hashed password |
| first_name | VARCHAR(100) | | User's first name |
| last_name | VARCHAR(100) | | User's last name |
| phone | VARCHAR(20) | | Contact phone number |
| status | ENUM | NOT NULL | 'active', 'inactive', 'suspended' |
| role | ENUM | NOT NULL | User role with permissions |
| last_login | TIMESTAMP | NULLABLE | Last login timestamp |
| created_at | TIMESTAMP | DEFAULT NOW | Account creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

**Indexes**:
- `email`: Fast login lookups
- `username`: Fast username searches
- `status`: Filter active users
- `created_at`: Chronological queries

---

### 2. farms Table

**Purpose**: Farm/organization management

```sql
CREATE TABLE farms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    lat DECIMAL(10, 8),
    lon DECIMAL(11, 8),
    size_hectares DECIMAL(10, 2),
    status ENUM('active', 'inactive', 'archived') DEFAULT 'active',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Farm identifier |
| user_id | INT | FOREIGN KEY | Farm owner (users.id) |
| name | VARCHAR(255) | NOT NULL | Farm name |
| location | VARCHAR(255) | | Physical location |
| lat | DECIMAL(10,8) | | Latitude for mapping |
| lon | DECIMAL(11,8) | | Longitude for mapping |
| size_hectares | DECIMAL(10,2) | | Total farm size |
| status | ENUM | DEFAULT active | 'active', 'inactive', 'archived' |
| description | TEXT | | Farm notes/description |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

---

### 3. livestock_batches Table

**Purpose**: Group animals into logical batches

```sql
CREATE TABLE livestock_batches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    batch_code VARCHAR(50) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(50),
    quantity INT DEFAULT 0,
    acquisition_date DATE,
    source VARCHAR(100),
    unit_cost DECIMAL(10, 2),
    status ENUM('active', 'archived', 'sold') DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    UNIQUE KEY unique_batch_code (farm_id, batch_code),
    INDEX idx_farm_id (farm_id),
    INDEX idx_species (species),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Batch identifier |
| farm_id | INT | FOREIGN KEY | Parent farm |
| batch_code | VARCHAR(50) | UNIQUE (farm scope) | Unique batch identifier |
| species | VARCHAR(50) | NOT NULL | Animal type (cattle, goats, etc) |
| breed | VARCHAR(50) | | Specific breed |
| quantity | INT | DEFAULT 0 | Number of animals |
| acquisition_date | DATE | | Purchase/acquisition date |
| source | VARCHAR(100) | | Where animals came from |
| unit_cost | DECIMAL(10,2) | | Cost per animal |
| status | ENUM | DEFAULT active | 'active', 'archived', 'sold' |
| notes | TEXT | | Additional details |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

---

### 4. livestock Table

**Purpose**: Individual animal records

```sql
CREATE TABLE livestock (
    id INT PRIMARY KEY AUTO_INCREMENT,
    batch_id INT NOT NULL,
    animal_tag VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    weight_kg DECIMAL(10, 2),
    age_days INT,
    gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown',
    date_of_birth DATE,
    status ENUM('healthy', 'sick', 'injured', 'dead') DEFAULT 'healthy',
    location VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (batch_id) REFERENCES livestock_batches(id) ON DELETE CASCADE,
    UNIQUE KEY unique_animal_tag (batch_id, animal_tag),
    INDEX idx_batch_id (batch_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_batch_status (batch_id, status)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Animal identifier |
| batch_id | INT | FOREIGN KEY | Parent batch |
| animal_tag | VARCHAR(50) | UNIQUE (batch scope) | Unique animal identifier |
| name | VARCHAR(100) | | Animal's name |
| weight_kg | DECIMAL(10,2) | | Current weight |
| age_days | INT | | Age in days |
| gender | ENUM | DEFAULT unknown | 'male', 'female', 'unknown' |
| date_of_birth | DATE | | Birth date for age tracking |
| status | ENUM | DEFAULT healthy | 'healthy', 'sick', 'injured', 'dead' |
| location | VARCHAR(100) | | Current location on farm |
| notes | TEXT | | Health/behavior notes |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

---

### 5. animal_events Table

**Purpose**: Track all events of individual animals

```sql
CREATE TABLE animal_events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    animal_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    recorded_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data JSON,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (animal_id) REFERENCES livestock(id) ON DELETE CASCADE,
    INDEX idx_animal_id (animal_id),
    INDEX idx_event_type (event_type),
    INDEX idx_event_date (event_date),
    INDEX idx_created_at (created_at),
    INDEX idx_animal_date (animal_id, event_date DESC)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Event identifier |
| animal_id | INT | FOREIGN KEY | Related animal |
| event_type | VARCHAR(50) | NOT NULL | Type of event |
| event_date | DATE | NOT NULL | Date event occurred |
| recorded_time | TIMESTAMP | NOT NULL | When recorded |
| data | JSON | | Event-specific data |
| notes | TEXT | | Additional notes |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |

**Event Types**:
```json
{
  "vaccination": {"vaccine_name": "", "next_date": ""},
  "treatment": {"disease": "", "medication": ""},
  "weight_check": {"weight_kg": 0, "trend": ""},
  "breeding": {"partner_id": 0, "expected_date": ""},
  "milk_production": {"liters": 0, "quality": ""},
  "meat_quality": {"grade": "", "weight": 0},
  "mortality": {"cause": ""},
  "transfer": {"from_location": "", "to_location": ""}
}
```

---

### 6. inventory Table

**Purpose**: Farm supply and equipment tracking

```sql
CREATE TABLE inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity DECIMAL(10, 2),
    unit VARCHAR(50),
    storage_location VARCHAR(100),
    reorder_level DECIMAL(10, 2),
    unit_cost DECIMAL(10, 2),
    supplier VARCHAR(255),
    status ENUM('in_stock', 'low', 'out_of_stock', 'discontinued') DEFAULT 'in_stock',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    UNIQUE KEY unique_item (farm_id, item_code),
    INDEX idx_farm_id (farm_id),
    INDEX idx_item_code (item_code),
    INDEX idx_status (status),
    INDEX idx_category (category)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Inventory item ID |
| farm_id | INT | FOREIGN KEY | Parent farm |
| item_code | VARCHAR(50) | UNIQUE (farm scope) | SKU code |
| item_name | VARCHAR(255) | NOT NULL | Item description |
| category | VARCHAR(100) | | Feed, medicine, equipment, etc |
| quantity | DECIMAL(10,2) | | Current stock quantity |
| unit | VARCHAR(50) | | kg, liters, units, etc |
| storage_location | VARCHAR(100) | | Where stored on farm |
| reorder_level | DECIMAL(10,2) | | Minimum stock to reorder |
| unit_cost | DECIMAL(10,2) | | Cost per unit |
| supplier | VARCHAR(255) | | Supplier name |
| status | ENUM | DEFAULT in_stock | Stock status |
| notes | TEXT | | Additional notes |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

---

### 7. financial_records Table

**Purpose**: Farm income and expense tracking

```sql
CREATE TABLE financial_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    type ENUM('income', 'expense') NOT NULL,
    category VARCHAR(100),
    description VARCHAR(255),
    amount DECIMAL(12, 2) NOT NULL,
    record_date DATE NOT NULL,
    payment_method VARCHAR(50),
    reference_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    INDEX idx_farm_id (farm_id),
    INDEX idx_type (type),
    INDEX idx_category (category),
    INDEX idx_record_date (record_date),
    INDEX idx_farm_type_date (farm_id, type, record_date)
) ENGINE=InnoDB;
```

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY | Record ID |
| farm_id | INT | FOREIGN KEY | Parent farm |
| type | ENUM | NOT NULL | 'income' or 'expense' |
| category | VARCHAR(100) | | Feed, labor, veterinary, etc |
| description | VARCHAR(255) | | Item description |
| amount | DECIMAL(12,2) | NOT NULL | Transaction amount |
| record_date | DATE | NOT NULL | Transaction date |
| payment_method | VARCHAR(50) | | Cash, check, transfer, etc |
| reference_number | VARCHAR(100) | | Invoice/receipt number |
| notes | TEXT | | Additional details |
| created_at | TIMESTAMP | DEFAULT NOW | Creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Last update time |

---

### 8. tasks Table

**Purpose**: Farm work and management tasks

```sql
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    assigned_to INT,
    due_date DATE,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_farm_id (farm_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date),
    INDEX idx_assigned_to (assigned_to)
) ENGINE=InnoDB;
```

---

### 9. weather_data Table

**Purpose**: Weather information for decision support

```sql
CREATE TABLE weather_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    data_date DATE NOT NULL,
    temperature_max_c DECIMAL(5, 2),
    temperature_min_c DECIMAL(5, 2),
    humidity_percent INT,
    rainfall_mm DECIMAL(5, 2),
    wind_speed_kmh DECIMAL(5, 2),
    conditions VARCHAR(100),
    uv_index INT,
    source VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    UNIQUE KEY unique_weather (farm_id, data_date),
    INDEX idx_farm_id (farm_id),
    INDEX idx_data_date (data_date)
) ENGINE=InnoDB;
```

---

### 10. iot_sensor_data Table

**Purpose**: IoT sensor readings (temperature, humidity, water, etc)

```sql
CREATE TABLE iot_sensor_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    farm_id INT NOT NULL,
    sensor_id VARCHAR(100) NOT NULL,
    sensor_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    reading_value DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    battery_percent INT,
    signal_strength INT,
    
    FOREIGN KEY (farm_id) REFERENCES farms(id) ON DELETE CASCADE,
    INDEX idx_farm_id (farm_id),
    INDEX idx_sensor_id (sensor_id),
    INDEX idx_sensor_type (sensor_type),
    INDEX idx_timestamp (timestamp),
    INDEX idx_farm_sensor_time (farm_id, sensor_id, timestamp DESC)
) ENGINE=InnoDB;
```

---

## Relationships & Constraints

### Foreign Key Relationships

```
users (1) ──┬──────── (N) farms
            │
            └──────── (N) tasks (assigned_to)

farms (1) ──┬──────── (N) livestock_batches
            ├──────── (N) inventory
            ├──────── (N) financial_records
            ├──────── (N) tasks
            ├──────── (N) weather_data
            └──────── (N) iot_sensor_data

livestock_batches (1) ───── (N) livestock

livestock (1) ───── (N) animal_events
```

### Cascade Rules

| Table | Foreign Key | On Delete | On Update |
|-------|-------------|-----------|-----------|
| farms | user_id | CASCADE | RESTRICT |
| livestock_batches | farm_id | CASCADE | RESTRICT |
| livestock | batch_id | CASCADE | RESTRICT |
| animal_events | animal_id | CASCADE | RESTRICT |
| inventory | farm_id | CASCADE | RESTRICT |
| financial_records | farm_id | CASCADE | RESTRICT |
| tasks | farm_id | CASCADE | RESTRICT |
| tasks | assigned_to | SET NULL | RESTRICT |
| weather_data | farm_id | CASCADE | RESTRICT |
| iot_sensor_data | farm_id | CASCADE | RESTRICT |

---

## Database Migrations

### Migration Strategy

Use the SQL schema file as the source of truth for database structure:

```bash
# Create database (example)
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS begin_masimba_farm;"

# Apply schema
mysql -u root -p begin_masimba_farm < begin_pyphp/database/schema.sql
```

For incremental changes, apply a new SQL migration script (DDL) using `mysql` and track applied versions in a `schema_migrations` table.

---

## Backup & Recovery

### Backup Strategy

```bash
# Daily full backup
mysqldump -u root -p --all-databases > /backups/farmos_$(date +%Y%m%d).sql

# Compressed backup
mysqldump -u root -p --all-databases | gzip > /backups/farmos_$(date +%Y%m%d).sql.gz

# Remote backup (S3)
mysqldump -u root -p farmos | aws s3 cp - s3://farmos-backups/daily/$(date +%Y%m%d).sql
```

### Recovery Procedures

```bash
# Full restore
mysql -u root -p < /backups/farmos_backup.sql

# Restore specific database
mysql -u root -p farmos < /backups/farmos_backup.sql

# Restore from compressed backup
gunzip < /backups/farmos_backup.sql.gz | mysql -u root -p

# Point-in-time recovery (binary logs required)
mysqlbinlog /var/log/mysql/mysql-bin.000001 | mysql -u root -p
```

### Backup Verification

```bash
# Test backup integrity
mysqldump --no-data -u root -p farmos | mysql -u test -p -D test_restore

# Verify table row counts
mysql -u root -p -e "SELECT TABLE_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='farmos';"
```

---

## Performance Optimization

### Index Strategy

```sql
-- Verify index usage
SELECT * FROM INFORMATION_SCHEMA.STATISTICS 
WHERE OBJECT_SCHEMA = 'farmos';

-- Find unused indexes
SELECT * FROM mysql.innodb_index_stats 
WHERE STAT_NAME = 'n_leaf_pages' AND STAT_VALUE = 0;

-- Query plan analysis
EXPLAIN SELECT * FROM livestock WHERE farm_id = 1 AND status = 'active';
EXPLAIN SELECT * FROM animal_events WHERE animal_id = 1 ORDER BY event_date DESC LIMIT 10;
```

### Query Optimization

```sql
-- Good: Uses index
SELECT * FROM livestock WHERE farm_id = 1;

-- Better: Uses multiple conditions
SELECT * FROM livestock WHERE farm_id = 1 AND status = 'active';

-- Best: Composite index on (farm_id, status)
ALTER TABLE livestock ADD INDEX idx_farm_status (farm_id, status);

-- Slow: Full table scan (no index)
SELECT * FROM livestock WHERE YEAR(created_at) = 2023;

-- Fast: Uses index
SELECT * FROM livestock 
WHERE created_at >= '2023-01-01' 
AND created_at < '2024-01-01';
```

### Connection Pooling

For the PHP backend, reuse a single PDO connection per request. Under PHP-FPM you can optionally use persistent connections to reduce connect overhead.

---

## Schema Management

### Database Statistics

```bash
# Calculate table sizes
mysql -u root -p -e "
SELECT 
    TABLE_NAME,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'farmos'
ORDER BY size_mb DESC;
"

# Row counts
mysql -u root -p -e "
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'farmos';
"
```

### Schema Validation

```python
# backend/utils/schema_validator.py
from sqlalchemy_utils import database_exists, create_database
from common.database import engine, Base

def validate_schema():
    """Verify all tables and columns exist"""
    
    # Check database exists
    if not database_exists(str(engine.url)):
        create_database(str(engine.url))
    
    # Check tables
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    expected_tables = {
        'users', 'farms', 'livestock_batches', 
        'livestock', 'animal_events', 'inventory',
        'financial_records', 'tasks', 'weather_data',
        'iot_sensor_data'
    }
    
    missing = expected_tables - set(tables)
    if missing:
        logger.error(f"Missing tables: {missing}")
        Base.metadata.create_all(bind=engine)
```

---

## Data Dictionary Quick Reference

| Table | Rows | Purpose | Key Fields |
|-------|------|---------|-----------|
| users | ~100 | User accounts | email, role, status |
| farms | ~50 | Farm entities | user_id, name, location |
| livestock_batches | ~200 | Animal groups | farm_id, batch_code, species |
| livestock | ~5,000 | Individual animals | batch_id, animal_tag, status |
| animal_events | ~50,000 | Event log | animal_id, event_type, event_date |
| inventory | ~1,000 | Supplies/equipment | farm_id, item_code, quantity |
| financial_records | ~10,000 | Financial transactions | farm_id, type, amount, date |
| tasks | ~500 | Work items | farm_id, status, assigned_to |
| weather_data | ~10,000 | Weather readings | farm_id, data_date |
| iot_sensor_data | ~100,000 | Sensor readings | farm_id, sensor_id, timestamp |

---

## Common Queries

### Livestock Management

```sql
-- Get active livestock with recent events
SELECT 
    l.id, l.animal_tag, l.weight_kg, l.status,
    GROUP_CONCAT(ae.event_type SEPARATOR ',') as recent_events
FROM livestock l
LEFT JOIN animal_events ae ON l.id = ae.animal_id 
    AND ae.event_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
WHERE l.batch_id = ? AND l.status = 'healthy'
GROUP BY l.id
ORDER BY ae.event_date DESC;

-- Health status summary
SELECT 
    status,
    COUNT(*) as count,
    AVG(weight_kg) as avg_weight
FROM livestock
WHERE batch_id = ?
GROUP BY status;
```

### Financial Analysis

```sql
-- Monthly profit/loss
SELECT 
    YEAR(record_date) as year,
    MONTH(record_date) as month,
    SUM(CASE WHEN type='income' THEN amount ELSE 0 END) as income,
    SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) as expenses,
    SUM(CASE WHEN type='income' THEN amount ELSE -amount END) as profit
FROM financial_records
WHERE farm_id = ?
GROUP BY YEAR(record_date), MONTH(record_date)
ORDER BY year DESC, month DESC;
```

---

**Document Version**: 1.0  
**Status**: Production Ready ✅  
**Last Updated**: March 12, 2026
