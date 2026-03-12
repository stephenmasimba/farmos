"""
Column Fixes Script
Fixes column updates for existing tables using MySQL-compatible syntax
"""

from sqlalchemy import create_engine, text, inspect
from common.database import SQLALCHEMY_DATABASE_URL
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def fix_table_columns():
    """Fix column issues in existing tables"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    inspector = inspect(engine)
    
    with engine.connect() as conn:
        # Get existing columns for each table
        existing_tables = inspector.get_table_names()
        
        # Fix users table
        if 'users' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('users')]
            
            if 'mfa_enabled' not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN DEFAULT FALSE"))
                logger.info("✅ Added mfa_enabled to users table")
            
            if 'mfa_enabled_at' not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN mfa_enabled_at DATETIME"))
                logger.info("✅ Added mfa_enabled_at to users table")
            
            if 'password_hash' not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255)"))
                logger.info("✅ Added password_hash to users table")
        
        # Fix equipment table
        if 'equipment' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('equipment')]
            
            if 'tenant_id' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                logger.info("✅ Added tenant_id to equipment table")
            
            if 'vibration_baseline' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN vibration_baseline FLOAT DEFAULT 0.0"))
                logger.info("✅ Added vibration_baseline to equipment table")
            
            if 'temperature_baseline' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN temperature_baseline FLOAT DEFAULT 0.0"))
                logger.info("✅ Added temperature_baseline to equipment table")
            
            if 'current_draw_baseline' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN current_draw_baseline FLOAT DEFAULT 0.0"))
                logger.info("✅ Added current_draw_baseline to equipment table")
            
            if 'last_maintenance' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN last_maintenance DATETIME"))
                logger.info("✅ Added last_maintenance to equipment table")
            
            if 'next_maintenance' not in columns:
                conn.execute(text("ALTER TABLE equipment ADD COLUMN next_maintenance DATETIME"))
                logger.info("✅ Added next_maintenance to equipment table")
        
        # Fix cost_centers table
        if 'cost_centers' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('cost_centers')]
            
            if 'tenant_id' not in columns:
                conn.execute(text("ALTER TABLE cost_centers ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                logger.info("✅ Added tenant_id to cost_centers table")
        
        # Fix inventory_transactions table
        if 'inventory_transactions' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('inventory_transactions')]
            
            if 'tenant_id' not in columns:
                conn.execute(text("ALTER TABLE inventory_transactions ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                logger.info("✅ Added tenant_id to inventory_transactions table")
            
            if 'type' not in columns:
                conn.execute(text("ALTER TABLE inventory_transactions ADD COLUMN type VARCHAR(20)"))
                logger.info("✅ Added type to inventory_transactions table")
            
            if 'date' not in columns:
                conn.execute(text("ALTER TABLE inventory_transactions ADD COLUMN date VARCHAR(20)"))
                logger.info("✅ Added date to inventory_transactions table")
        
        # Fix maintenance_logs table
        if 'maintenance_logs' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('maintenance_logs')]
            
            if 'tenant_id' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                logger.info("✅ Added tenant_id to maintenance_logs table")
            
            if 'timestamp' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN timestamp DATETIME DEFAULT CURRENT_TIMESTAMP"))
                logger.info("✅ Added timestamp to maintenance_logs table")
            
            if 'vibration' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN vibration FLOAT"))
                logger.info("✅ Added vibration to maintenance_logs table")
            
            if 'temperature' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN temperature FLOAT"))
                logger.info("✅ Added temperature to maintenance_logs table")
            
            if 'current_draw' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN current_draw FLOAT"))
                logger.info("✅ Added current_draw to maintenance_logs table")
            
            if 'risk_score' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN risk_score FLOAT"))
                logger.info("✅ Added risk_score to maintenance_logs table")
            
            if 'notes' not in columns:
                conn.execute(text("ALTER TABLE maintenance_logs ADD COLUMN notes TEXT"))
                logger.info("✅ Added notes to maintenance_logs table")
        
        # Fix sensor_data table
        if 'sensor_data' in existing_tables:
            columns = [col['name'] for col in inspector.get_columns('sensor_data')]
            
            if 'tenant_id' not in columns:
                conn.execute(text("ALTER TABLE sensor_data ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                logger.info("✅ Added tenant_id to sensor_data table")
        
        logger.info("✅ All column fixes completed successfully")

if __name__ == "__main__":
    fix_table_columns()
