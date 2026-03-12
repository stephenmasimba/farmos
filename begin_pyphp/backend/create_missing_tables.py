"""
Create Missing Critical Tables
Complete database synchronization with reference system
"""

from sqlalchemy import create_engine, text
from common.database import SQLALCHEMY_DATABASE_URL
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_missing_tables():
    """Create all missing critical tables with simplified MySQL-compatible syntax"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    tables_to_create = [
        # 1. Feed Ingredients Enhanced
        """
        CREATE TABLE IF NOT EXISTS feed_ingredients_enhanced (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            ingredient_name VARCHAR(255) NOT NULL,
            ingredient_type VARCHAR(50),
            unit_cost DECIMAL(10, 2),
            availability VARCHAR(20),
            supplier VARCHAR(255),
            origin VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_ingredients_tenant (tenant_id),
            INDEX idx_ingredients_type (ingredient_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 2. Feed Formulations Enhanced
        """
        CREATE TABLE IF NOT EXISTS feed_formulations_enhanced (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            formulation_code VARCHAR(50) NOT NULL,
            formulation_name VARCHAR(255),
            target_animal VARCHAR(50) NOT NULL,
            target_stage VARCHAR(50),
            protein_target DECIMAL(5, 2),
            fat_target DECIMAL(5, 2),
            fiber_target DECIMAL(5, 2),
            ingredients TEXT NOT NULL,
            total_batch_kg DECIMAL(10, 2),
            unit_cost DECIMAL(10, 2),
            nutritional_analysis TEXT,
            status VARCHAR(20) DEFAULT 'active',
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_formulations_tenant (tenant_id),
            INDEX idx_formulations_animal (target_animal)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 3. Breeding Records Enhanced
        """
        CREATE TABLE IF NOT EXISTS breeding_records_enhanced (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            dam_batch_id INT,
            sire_batch_id INT,
            animal_id VARCHAR(50),
            breeding_date DATE,
            expected_birth_date DATE,
            actual_birth_date DATE,
            status VARCHAR(50),
            offspring_batch_id INT,
            genetic_markers TEXT,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_breeding_tenant (tenant_id),
            INDEX idx_breeding_date (breeding_date)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 4. Quality Checks
        """
        CREATE TABLE IF NOT EXISTS quality_checks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            check_type VARCHAR(50),
            reference_id INT,
            reference_type VARCHAR(50),
            check_date DATE,
            result VARCHAR(20),
            parameters TEXT,
            performed_by VARCHAR(100),
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_quality_tenant (tenant_id),
            INDEX idx_quality_date (check_date),
            INDEX idx_quality_type (check_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 5. Blockchain Transactions
        """
        CREATE TABLE IF NOT EXISTS blockchain_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            transaction_hash VARCHAR(64),
            block_number BIGINT,
            transaction_type VARCHAR(50),
            reference_id INT,
            reference_type VARCHAR(50),
            data TEXT,
            timestamp TIMESTAMP,
            confirmed BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_blockchain_tenant (tenant_id),
            INDEX idx_blockchain_hash (transaction_hash),
            INDEX idx_blockchain_reference (reference_id, reference_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 6. QR Codes Enhanced
        """
        CREATE TABLE IF NOT EXISTS qr_codes_enhanced (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            qr_code VARCHAR(255) UNIQUE NOT NULL,
            reference_id INT,
            reference_type VARCHAR(50),
            product_info TEXT,
            supply_chain_data TEXT,
            generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP,
            is_active BOOLEAN DEFAULT TRUE,
            INDEX idx_qr_tenant (tenant_id),
            INDEX idx_qr_reference (reference_id, reference_type),
            INDEX idx_qr_code (qr_code)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 7. Automation Rules
        """
        CREATE TABLE IF NOT EXISTS automation_rules (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            rule_name VARCHAR(255) NOT NULL,
            trigger_type VARCHAR(50),
            trigger_conditions TEXT,
            actions TEXT,
            is_active BOOLEAN DEFAULT TRUE,
            priority INT DEFAULT 1,
            last_triggered TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_automation_tenant (tenant_id),
            INDEX idx_automation_active (is_active)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 8. Performance Metrics
        """
        CREATE TABLE IF NOT EXISTS performance_metrics (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            metric_type VARCHAR(50),
            reference_id INT,
            reference_type VARCHAR(50),
            metric_date DATE,
            metrics TEXT,
            calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_performance_tenant (tenant_id),
            INDEX idx_performance_type (metric_type),
            INDEX idx_performance_date (metric_date)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """,
        
        # 9. Sensor Data Partitioned (Simplified)
        """
        CREATE TABLE IF NOT EXISTS sensor_data_partitioned (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            tenant_id VARCHAR(50) NOT NULL DEFAULT 'default',
            timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            sensor_type VARCHAR(50) NOT NULL,
            value DECIMAL(10, 3) NOT NULL,
            unit VARCHAR(50) NOT NULL,
            location VARCHAR(100),
            device_id VARCHAR(50),
            status VARCHAR(20) DEFAULT 'ok',
            threshold_min DECIMAL(10, 3),
            threshold_max DECIMAL(10, 3),
            automation_triggered BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_sensor_tenant (tenant_id),
            INDEX idx_sensor_device_timestamp (device_id, timestamp),
            INDEX idx_sensor_type (sensor_type),
            INDEX idx_sensor_location (location)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    ]
    
    print('🚀 CREATING MISSING CRITICAL TABLES...')
    print('=' * 60)
    
    try:
        with engine.connect() as conn:
            created = 0
            for i, table_sql in enumerate(tables_to_create):
                try:
                    conn.execute(text(table_sql))
                    conn.commit()
                    created += 1
                    table_name = table_sql.split()[5]  # Extract table name
                    print(f'✅ Table {i+1}/{len(tables_to_create)}: {table_name} created')
                except Exception as e:
                    if 'already exists' not in str(e).lower():
                        print(f'⚠️  Table {i+1} failed: {e}')
                    else:
                        print(f'✅ Table {i+1}/{len(tables_to_create)} already exists')
                        created += 1
            
            print(f'\n🎯 Successfully created {created}/{len(tables_to_create)} tables!')
            
    except Exception as e:
        print(f'❌ Error creating tables: {e}')
        logger.error(f'Table creation failed: {e}')
        return False
    
    print('\n' + '=' * 60)
    print('📊 MISSING TABLES CREATION COMPLETED!')
    print('🔧 Database synchronization improved significantly!')
    print('✅ Ready for advanced features implementation!')
    print('=' * 60)
    
    return True

if __name__ == "__main__":
    create_missing_tables()
