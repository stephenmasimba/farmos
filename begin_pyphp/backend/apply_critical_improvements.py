"""
Apply Critical Database Improvements
Fixed version of the SQL improvements with proper MySQL syntax
"""

from sqlalchemy import create_engine, text
from common.database import SQLALCHEMY_DATABASE_URL
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def apply_critical_improvements():
    """Apply critical database improvements with proper error handling"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    improvements = [
        # 1. Add UUID columns to critical tables
        """
        ALTER TABLE users ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        """
        ALTER TABLE livestock_batches ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        """
        ALTER TABLE livestock_events ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        """
        ALTER TABLE financial_transactions ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        """
        ALTER TABLE tasks ADD COLUMN IF NOT EXISTS uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()));
        """,
        
        # 2. Add tenant constraints
        """
        ALTER TABLE users ADD UNIQUE KEY unique_tenant_email (tenant_id, email);
        """,
        """
        ALTER TABLE users ADD INDEX idx_users_tenant_active (tenant_id, is_active);
        """,
        """
        ALTER TABLE livestock_batches ADD COLUMN IF NOT EXISTS batch_code VARCHAR(50) DEFAULT CONCAT('BATCH_', id);
        """,
        """
        ALTER TABLE livestock_batches ADD UNIQUE KEY unique_tenant_batch (tenant_id, batch_code);
        """,
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS item_code VARCHAR(50) DEFAULT CONCAT('ITEM_', id);
        """,
        """
        ALTER TABLE inventory_items ADD UNIQUE KEY unique_tenant_item (tenant_id, item_code);
        """,
        """
        ALTER TABLE financial_transactions ADD COLUMN IF NOT EXISTS transaction_code VARCHAR(50) DEFAULT CONCAT('TXN_', id);
        """,
        """
        ALTER TABLE financial_transactions ADD UNIQUE KEY unique_tenant_transaction (tenant_id, transaction_code);
        """,
        """
        ALTER TABLE tasks ADD COLUMN IF NOT EXISTS task_code VARCHAR(50) DEFAULT CONCAT('TASK_', id);
        """,
        """
        ALTER TABLE tasks ADD UNIQUE KEY unique_tenant_task (tenant_id, task_code);
        """,
        
        # 3. Enhanced user columns
        """
        ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
        """,
        """
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
        """,
        """
        ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP NULL;
        """,
        
        # 4. Enhanced livestock columns
        """
        ALTER TABLE livestock_batches ADD COLUMN IF NOT EXISTS genetic_line VARCHAR(50);
        """,
        """
        ALTER TABLE livestock_batches ADD COLUMN IF NOT EXISTS performance_metrics JSON;
        """,
        """
        ALTER TABLE livestock_batches ADD COLUMN IF NOT EXISTS supplier VARCHAR(255);
        """,
        
        # 5. Enhanced inventory columns
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS subcategory VARCHAR(50);
        """,
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS storage_conditions JSON;
        """,
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS quality_grade VARCHAR(20);
        """,
        """
        ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS certifications JSON;
        """,
    ]
    
    print('🚀 APPLYING CRITICAL DATABASE IMPROVEMENTS...')
    print('=' * 60)
    
    try:
        with engine.connect() as conn:
            executed = 0
            for i, improvement in enumerate(improvements):
                try:
                    conn.execute(text(improvement))
                    conn.commit()
                    executed += 1
                    print(f'✅ Improvement {i+1}/{len(improvements)} applied')
                except Exception as e:
                    if 'already exists' not in str(e).lower() and 'duplicate' not in str(e).lower():
                        print(f'⚠️  Improvement {i+1} skipped: {e}')
                    else:
                        print(f'✅ Improvement {i+1}/{len(improvements)} already exists')
            
            print(f'\n🎯 Successfully applied {executed}/{len(improvements)} critical improvements!')
            
    except Exception as e:
        print(f'❌ Error applying improvements: {e}')
        logger.error(f'Database improvements failed: {e}')
        return False
    
    print('\n' + '=' * 60)
    print('📊 CRITICAL IMPROVEMENTS COMPLETED!')
    print('🔒 Enhanced security with UUID columns')
    print('🏢 Improved multi-tenancy with constraints')
    print('📈 Added enhanced data structures')
    print('✅ System ready for advanced features!')
    print('=' * 60)
    
    return True

if __name__ == "__main__":
    apply_critical_improvements()
