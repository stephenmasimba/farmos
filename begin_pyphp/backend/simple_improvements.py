"""
Simple Database Improvements - MySQL Compatible
Apply essential improvements without complex syntax
"""

from sqlalchemy import create_engine, text, inspect
from common.database import SQLALCHEMY_DATABASE_URL
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def apply_simple_improvements():
    """Apply simple, compatible database improvements"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    inspector = inspect(engine)
    
    print('🚀 APPLYING SIMPLE DATABASE IMPROVEMENTS...')
    print('=' * 60)
    
    try:
        with engine.connect() as conn:
            # Get existing tables
            existing_tables = inspector.get_table_names()
            
            improvements_applied = 0
            
            # 1. Add UUID columns to main tables
            if 'users' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('users')]
                if 'uuid_id' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE users ADD COLUMN uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()))"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added uuid_id to users table')
                    except Exception as e:
                        print(f'⚠️  Could not add uuid_id to users: {e}')
            
            if 'livestock_batches' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('livestock_batches')]
                if 'uuid_id' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()))"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added uuid_id to livestock_batches table')
                    except Exception as e:
                        print(f'⚠️  Could not add uuid_id to livestock_batches: {e}')
            
            if 'inventory_items' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('inventory_items')]
                if 'uuid_id' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN uuid_id BINARY(16) DEFAULT (UUID_TO_BIN(UUID()))"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added uuid_id to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add uuid_id to inventory_items: {e}')
            
            # 2. Add tenant constraints
            if 'users' in existing_tables:
                indexes = inspector.get_indexes('users')
                index_names = [idx['name'] for idx in indexes]
                if 'unique_tenant_email' not in index_names:
                    try:
                        conn.execute(text("ALTER TABLE users ADD UNIQUE KEY unique_tenant_email (tenant_id, email)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added tenant email constraint to users')
                    except Exception as e:
                        print(f'⚠️  Could not add tenant email constraint: {e}')
            
            # 3. Add enhanced columns to users
            if 'users' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('users')]
                if 'is_active' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added is_active to users table')
                    except Exception as e:
                        print(f'⚠️  Could not add is_active to users: {e}')
                
                if 'phone' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE users ADD COLUMN phone VARCHAR(20)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added phone to users table')
                    except Exception as e:
                        print(f'⚠️  Could not add phone to users: {e}')
            
            # 4. Add enhanced columns to livestock_batches
            if 'livestock_batches' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('livestock_batches')]
                if 'batch_code' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN batch_code VARCHAR(50)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added batch_code to livestock_batches table')
                    except Exception as e:
                        print(f'⚠️  Could not add batch_code to livestock_batches: {e}')
                
                if 'genetic_line' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN genetic_line VARCHAR(50)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added genetic_line to livestock_batches table')
                    except Exception as e:
                        print(f'⚠️  Could not add genetic_line to livestock_batches: {e}')
                
                if 'performance_metrics' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN performance_metrics JSON"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added performance_metrics to livestock_batches table')
                    except Exception as e:
                        print(f'⚠️  Could not add performance_metrics to livestock_batches: {e}')
            
            # 5. Add enhanced columns to inventory_items
            if 'inventory_items' in existing_tables:
                columns = [col['name'] for col in inspector.get_columns('inventory_items')]
                if 'item_code' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN item_code VARCHAR(50)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added item_code to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add item_code to inventory_items: {e}')
                
                if 'subcategory' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN subcategory VARCHAR(50)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added subcategory to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add subcategory to inventory_items: {e}')
                
                if 'storage_conditions' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN storage_conditions JSON"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added storage_conditions to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add storage_conditions to inventory_items: {e}')
                
                if 'quality_grade' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN quality_grade VARCHAR(20)"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added quality_grade to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add quality_grade to inventory_items: {e}')
                
                if 'certifications' not in columns:
                    try:
                        conn.execute(text("ALTER TABLE inventory_items ADD COLUMN certifications JSON"))
                        conn.commit()
                        improvements_applied += 1
                        print('✅ Added certifications to inventory_items table')
                    except Exception as e:
                        print(f'⚠️  Could not add certifications to inventory_items: {e}')
            
            print(f'\n🎯 Successfully applied {improvements_applied} database improvements!')
            
    except Exception as e:
        print(f'❌ Error applying improvements: {e}')
        logger.error(f'Database improvements failed: {e}')
        return False
    
    print('\n' + '=' * 60)
    print('📊 DATABASE IMPROVEMENTS COMPLETED!')
    print('🔒 Enhanced security with UUID columns')
    print('🏢 Improved multi-tenancy with constraints')
    print('📈 Added enhanced data structures')
    print('✅ System ready for advanced features!')
    print('=' * 60)
    
    return True

if __name__ == "__main__":
    apply_simple_improvements()
