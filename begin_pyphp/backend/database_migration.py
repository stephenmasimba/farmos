"""
Database Migration Script
Creates missing tables and updates existing table structures for all implemented features
"""

from sqlalchemy import create_engine, text, Column, Integer, String, Boolean, Float, ForeignKey, DateTime, Text, CheckConstraint
from sqlalchemy.orm import sessionmaker
from common.database import SQLALCHEMY_DATABASE_URL, Base
from common import models
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_missing_tables():
    """Create all missing tables from models"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    
    try:
        # Create all tables from models
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Created all missing tables from models")
        
        # Create additional tables for advanced features
        create_advanced_feature_tables(engine)
        
        # Update existing table structures
        update_existing_tables(engine)
        
        logger.info("✅ Database migration completed successfully")
        
    except Exception as e:
        logger.error(f"❌ Migration failed: {e}")
        session.rollback()
        raise
    finally:
        session.close()

def create_advanced_feature_tables(engine):
    """Create tables for advanced features not in models"""
    
    # Phase 1 - Foundation Tables
    create_cache_entries_table(engine)
    create_rate_limits_table(engine)
    create_api_versions_table(engine)
    
    # Phase 2 - Advanced Features Tables
    create_maintenance_predictions_table(engine)
    create_weather_data_table(engine)
    create_camera_streams_table(engine)
    
    # Phase 3 - Enterprise Features Tables
    create_crm_leads_table(engine)
    create_financial_budgets_table(engine)
    create_supply_chain_tables(engine)
    create_security_tables(engine)
    
    # Phase 4 - Scalability & Performance Tables
    create_microservices_tables(engine)
    create_cdn_tables(engine)
    create_load_testing_tables(engine)
    create_auto_scaling_tables(engine)

def create_cache_entries_table(engine):
    """Create cache entries table for Redis integration"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS cache_entries (
                id INT AUTO_INCREMENT PRIMARY KEY,
                cache_key VARCHAR(255) NOT NULL UNIQUE,
                cache_value LONGTEXT,
                cache_type VARCHAR(50) DEFAULT 'string',
                ttl_seconds INT DEFAULT 3600,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                expires_at DATETIME,
                access_count INT DEFAULT 0,
                last_accessed DATETIME,
                INDEX idx_cache_key (cache_key),
                INDEX idx_expires_at (expires_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created cache_entries table")

def create_rate_limits_table(engine):
    """Create rate limits table for API rate limiting"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS rate_limits (
                id INT AUTO_INCREMENT PRIMARY KEY,
                client_identifier VARCHAR(255) NOT NULL,
                endpoint VARCHAR(255) NOT NULL,
                request_count INT DEFAULT 0,
                window_start DATETIME DEFAULT CURRENT_TIMESTAMP,
                window_seconds INT DEFAULT 60,
                limit_per_window INT DEFAULT 100,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_client_endpoint (client_identifier, endpoint),
                INDEX idx_window_start (window_start)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created rate_limits table")

def create_api_versions_table(engine):
    """Create API versions table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS api_versions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                version VARCHAR(20) NOT NULL UNIQUE,
                status ENUM('active', 'deprecated', 'retired') DEFAULT 'active',
                description TEXT,
                deprecation_date DATETIME,
                retirement_date DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_version (version),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created api_versions table")

def create_maintenance_predictions_table(engine):
    """Create maintenance predictions table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS maintenance_predictions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                equipment_id INT NOT NULL,
                prediction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                failure_probability FLOAT DEFAULT 0.0,
                predicted_failure_date DATETIME,
                maintenance_type VARCHAR(100),
                priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
                confidence_score FLOAT DEFAULT 0.0,
                model_version VARCHAR(50),
                features_json JSON,
                status ENUM('pending', 'scheduled', 'completed', 'false_positive') DEFAULT 'pending',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_equipment_id (equipment_id),
                INDEX idx_predicted_date (predicted_failure_date),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created maintenance_predictions table")

def create_weather_data_table(engine):
    """Create weather data table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS weather_data (
                id INT AUTO_INCREMENT PRIMARY KEY,
                location VARCHAR(100) NOT NULL,
                latitude FLOAT,
                longitude FLOAT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                temperature_celsius FLOAT,
                humidity_percent FLOAT,
                pressure_hpa FLOAT,
                wind_speed_kmh FLOAT,
                wind_direction_degrees INT,
                precipitation_mm FLOAT,
                weather_condition VARCHAR(100),
                visibility_km FLOAT,
                uv_index FLOAT,
                data_source VARCHAR(50) DEFAULT 'openweathermap',
                forecast_hours_ahead INT DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_location_timestamp (location, timestamp),
                INDEX idx_forecast (forecast_hours_ahead)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created weather_data table")

def create_camera_streams_table(engine):
    """Create camera streams table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS camera_streams (
                id INT AUTO_INCREMENT PRIMARY KEY,
                camera_name VARCHAR(100) NOT NULL,
                location VARCHAR(100),
                stream_url VARCHAR(500),
                rtsp_url VARCHAR(500),
                status ENUM('online', 'offline', 'error') DEFAULT 'offline',
                resolution VARCHAR(20),
                fps INT DEFAULT 25,
                motion_detection_enabled BOOLEAN DEFAULT TRUE,
                recording_enabled BOOLEAN DEFAULT TRUE,
                storage_path VARCHAR(500),
                last_motion_detected DATETIME,
                motion_sensitivity INT DEFAULT 50,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_camera_name (camera_name),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created camera_streams table")

def create_crm_leads_table(engine):
    """Create CRM leads table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS crm_leads (
                id INT AUTO_INCREMENT PRIMARY KEY,
                lead_id VARCHAR(50) NOT NULL UNIQUE,
                first_name VARCHAR(100),
                last_name VARCHAR(100),
                email VARCHAR(255),
                phone VARCHAR(50),
                company VARCHAR(200),
                source VARCHAR(100),
                status ENUM('new', 'contacted', 'qualified', 'converted', 'lost') DEFAULT 'new',
                lead_score INT DEFAULT 0,
                estimated_value DECIMAL(15,2),
                probability_close INT DEFAULT 0,
                expected_close_date DATE,
                assigned_to VARCHAR(100),
                notes TEXT,
                tags JSON,
                custom_fields JSON,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_lead_id (lead_id),
                INDEX idx_status (status),
                INDEX idx_lead_score (lead_score)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created crm_leads table")

def create_financial_budgets_table(engine):
    """Create financial budgets table"""
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS financial_budgets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                budget_id VARCHAR(50) NOT NULL UNIQUE,
                name VARCHAR(200) NOT NULL,
                fiscal_year INT NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                total_budgeted_amount DECIMAL(15,2) NOT NULL,
                budget_categories JSON,
                variance_threshold DECIMAL(5,2) DEFAULT 10.0,
                status ENUM('draft', 'active', 'closed') DEFAULT 'draft',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_budget_id (budget_id),
                INDEX idx_fiscal_year (fiscal_year),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Create budget categories table
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS budget_categories (
                id INT AUTO_INCREMENT PRIMARY KEY,
                budget_id VARCHAR(50) NOT NULL,
                category_name VARCHAR(100) NOT NULL,
                budgeted_amount DECIMAL(15,2) NOT NULL,
                actual_amount DECIMAL(15,2) DEFAULT 0.0,
                variance DECIMAL(15,2) DEFAULT 0.0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_budget_id (budget_id),
                INDEX idx_category_name (category_name)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        logger.info("✅ Created financial_budgets table")

def create_supply_chain_tables(engine):
    """Create supply chain management tables"""
    with engine.connect() as conn:
        # Supply chain networks
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS supply_chain_networks (
                id INT AUTO_INCREMENT PRIMARY KEY,
                network_id VARCHAR(50) NOT NULL UNIQUE,
                network_name VARCHAR(200) NOT NULL,
                description TEXT,
                network_type VARCHAR(50) DEFAULT 'agricultural',
                stages JSON,
                locations JSON,
                status ENUM('active', 'inactive') DEFAULT 'active',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_network_id (network_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Supply chain nodes
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS supply_chain_nodes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                network_id VARCHAR(50) NOT NULL,
                node_id VARCHAR(50) NOT NULL,
                node_name VARCHAR(200) NOT NULL,
                node_type VARCHAR(100),
                location VARCHAR(200),
                capacity INT,
                current_stock INT DEFAULT 0,
                coordinates JSON,
                status ENUM('active', 'inactive') DEFAULT 'active',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_network_id (network_id),
                INDEX idx_node_id (node_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Product tracking
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS product_tracking (
                id INT AUTO_INCREMENT PRIMARY KEY,
                tracking_id VARCHAR(50) NOT NULL UNIQUE,
                product_id VARCHAR(50) NOT NULL,
                product_name VARCHAR(200),
                product_type VARCHAR(100),
                batch_number VARCHAR(100),
                origin_node_id VARCHAR(50),
                current_node_id VARCHAR(50),
                tracking_status ENUM('in_transit', 'delivered', 'lost') DEFAULT 'in_transit',
                quality_grade VARCHAR(50) DEFAULT 'standard',
                certifications JSON,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_tracking_id (tracking_id),
                INDEX idx_product_id (product_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Tracking QR codes
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS tracking_qr_codes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                tracking_id VARCHAR(50) NOT NULL,
                qr_data LONGTEXT NOT NULL,
                qr_image_base64 LONGTEXT,
                qr_url VARCHAR(500),
                generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                status ENUM('active', 'inactive') DEFAULT 'active',
                INDEX idx_tracking_id (tracking_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created supply chain tables")

def create_security_tables(engine):
    """Create security-related tables"""
    with engine.connect() as conn:
        # MFA setups
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS mfa_setups (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                mfa_type ENUM('totp', 'sms', 'email') DEFAULT 'totp',
                secret_key VARCHAR(255),
                is_enabled BOOLEAN DEFAULT FALSE,
                backup_codes JSON,
                setup_initiated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                verified_at DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_enabled (is_enabled)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Audit logs
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS audit_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                action VARCHAR(100) NOT NULL,
                resource_type VARCHAR(100),
                resource_id VARCHAR(100),
                old_values JSON,
                new_values JSON,
                ip_address VARCHAR(45),
                user_agent TEXT,
                session_id VARCHAR(255),
                success BOOLEAN DEFAULT TRUE,
                error_message TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_action (action),
                INDEX idx_resource (resource_type, resource_id),
                INDEX idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Data encryption
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS data_encryption (
                id INT AUTO_INCREMENT PRIMARY KEY,
                data_type VARCHAR(100) NOT NULL,
                encrypted_data LONGTEXT NOT NULL,
                encryption_algorithm VARCHAR(50) DEFAULT 'Fernet',
                key_version VARCHAR(20) DEFAULT '1.0',
                encrypted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_data_type (data_type),
                INDEX idx_encrypted_at (encrypted_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        # Security events
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS security_events (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT,
                event_type VARCHAR(100) NOT NULL,
                details JSON,
                severity ENUM('info', 'low', 'medium', 'high', 'critical') DEFAULT 'info',
                ip_address VARCHAR(45),
                user_agent TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_event_type (event_type),
                INDEX idx_severity (severity),
                INDEX idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created security tables")

def create_microservices_tables(engine):
    """Create microservices architecture tables"""
    with engine.connect() as conn:
        # Service registries
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS service_registries (
                id INT AUTO_INCREMENT PRIMARY KEY,
                service_id VARCHAR(100) NOT NULL UNIQUE,
                service_name VARCHAR(200) NOT NULL,
                host VARCHAR(255) NOT NULL,
                port INT NOT NULL,
                version VARCHAR(50) DEFAULT '1.0.0',
                status ENUM('healthy', 'unhealthy', 'degraded', 'maintenance') DEFAULT 'healthy',
                last_heartbeat DATETIME DEFAULT CURRENT_TIMESTAMP,
                metadata JSON,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_service_id (service_id),
                INDEX idx_service_name (service_name),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created microservices tables")

def create_cdn_tables(engine):
    """Create CDN integration tables"""
    with engine.connect() as conn:
        # CDN configurations
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS cdn_configurations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                provider_name VARCHAR(100) NOT NULL,
                provider_type ENUM('cloudflare', 'aws_cloudfront', 'azure_cdn', 'fastly', 'akamai') NOT NULL,
                api_key VARCHAR(500),
                api_secret VARCHAR(500),
                zone_id VARCHAR(100),
                distribution_id VARCHAR(100),
                endpoint VARCHAR(500),
                status ENUM('active', 'inactive') DEFAULT 'active',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_provider_name (provider_name),
                INDEX idx_provider_type (provider_type)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created CDN tables")

def create_load_testing_tables(engine):
    """Create load testing tables"""
    with engine.connect() as conn:
        # Load tests
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS load_tests (
                id INT AUTO_INCREMENT PRIMARY KEY,
                test_id VARCHAR(100) NOT NULL UNIQUE,
                test_name VARCHAR(200) NOT NULL,
                test_type ENUM('load_test', 'stress_test', 'spike_test', 'endurance_test', 'volume_test') NOT NULL,
                target_url VARCHAR(500) NOT NULL,
                method VARCHAR(10) DEFAULT 'GET',
                concurrent_users INT DEFAULT 10,
                duration_seconds INT DEFAULT 60,
                ramp_up_seconds INT DEFAULT 30,
                think_time_ms INT DEFAULT 1000,
                status ENUM('pending', 'running', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
                total_requests INT DEFAULT 0,
                successful_requests INT DEFAULT 0,
                failed_requests INT DEFAULT 0,
                average_response_time FLOAT DEFAULT 0.0,
                p95_response_time FLOAT DEFAULT 0.0,
                throughput FLOAT DEFAULT 0.0,
                error_rate FLOAT DEFAULT 0.0,
                start_time DATETIME,
                end_time DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_test_id (test_id),
                INDEX idx_test_type (test_type),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created load testing tables")

def create_auto_scaling_tables(engine):
    """Create auto-scaling tables"""
    with engine.connect() as conn:
        # Auto scaling configurations
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS auto_scaling_configs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                service_name VARCHAR(200) NOT NULL,
                provider_name VARCHAR(100) NOT NULL,
                min_instances INT DEFAULT 1,
                max_instances INT DEFAULT 10,
                scaling_policy ENUM('manual', 'scheduled', 'reactive', 'predictive') DEFAULT 'reactive',
                cpu_threshold_high FLOAT DEFAULT 80.0,
                cpu_threshold_low FLOAT DEFAULT 20.0,
                memory_threshold_high FLOAT DEFAULT 85.0,
                memory_threshold_low FLOAT DEFAULT 30.0,
                scale_up_cooldown_seconds INT DEFAULT 300,
                scale_down_cooldown_seconds INT DEFAULT 300,
                status ENUM('active', 'inactive') DEFAULT 'active',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_service_name (service_name),
                INDEX idx_provider_name (provider_name),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """))
        
        logger.info("✅ Created auto-scaling tables")

def update_existing_tables(engine):
    """Update existing table structures"""
    with engine.connect() as conn:
        # Add missing columns to existing tables
        
        # Update users table
        try:
            conn.execute(text("""
                ALTER TABLE users 
                ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN DEFAULT FALSE,
                ADD COLUMN IF NOT EXISTS mfa_enabled_at DATETIME,
                ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)
            """))
            logger.info("✅ Updated users table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update users table: {e}")
        
        # Update equipment table
        try:
            conn.execute(text("""
                ALTER TABLE equipment 
                ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(50) DEFAULT 'default',
                ADD COLUMN IF NOT EXISTS vibration_baseline FLOAT DEFAULT 0.0,
                ADD COLUMN IF NOT EXISTS temperature_baseline FLOAT DEFAULT 0.0,
                ADD COLUMN IF NOT EXISTS current_draw_baseline FLOAT DEFAULT 0.0,
                ADD COLUMN IF NOT EXISTS last_maintenance DATETIME,
                ADD COLUMN IF NOT EXISTS next_maintenance DATETIME
            """))
            logger.info("✅ Updated equipment table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update equipment table: {e}")
        
        # Update cost_centers table
        try:
            conn.execute(text("""
                ALTER TABLE cost_centers 
                ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(50) DEFAULT 'default'
            """))
            logger.info("✅ Updated cost_centers table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update cost_centers table: {e}")
        
        # Update inventory_transactions table
        try:
            conn.execute(text("""
                ALTER TABLE inventory_transactions 
                ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(50) DEFAULT 'default',
                ADD COLUMN IF NOT EXISTS type VARCHAR(20),
                ADD COLUMN IF NOT EXISTS date VARCHAR(20)
            """))
            logger.info("✅ Updated inventory_transactions table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update inventory_transactions table: {e}")
        
        # Update maintenance_logs table
        try:
            conn.execute(text("""
                ALTER TABLE maintenance_logs 
                ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(50) DEFAULT 'default',
                ADD COLUMN IF NOT EXISTS timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                ADD COLUMN IF NOT EXISTS vibration FLOAT,
                ADD COLUMN IF NOT EXISTS temperature FLOAT,
                ADD COLUMN IF NOT EXISTS current_draw FLOAT,
                ADD COLUMN IF NOT EXISTS risk_score FLOAT,
                ADD COLUMN IF NOT EXISTS notes TEXT
            """))
            logger.info("✅ Updated maintenance_logs table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update maintenance_logs table: {e}")
        
        # Update sensor_data table
        try:
            conn.execute(text("""
                ALTER TABLE sensor_data 
                ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(50) DEFAULT 'default'
            """))
            logger.info("✅ Updated sensor_data table")
        except Exception as e:
            logger.warning(f"⚠️ Could not update sensor_data table: {e}")

if __name__ == "__main__":
    create_missing_tables()
