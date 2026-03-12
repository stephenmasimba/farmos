"""
Database Analysis Script
Compares existing database tables with required tables for all implemented features
"""

from sqlalchemy import create_engine, inspect, text
from common.database import SQLALCHEMY_DATABASE_URL
from common import models

def analyze_database():
    """Analyze database structure and identify missing tables/columns"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    inspector = inspect(engine)
    
    # Get existing tables
    existing_tables = set(inspector.get_table_names())
    
    # Get required tables from models
    required_tables = set()
    model_classes = []
    
    for attr_name in dir(models):
        attr = getattr(models, attr_name)
        if hasattr(attr, '__tablename__') and hasattr(attr, '__table__'):
            required_tables.add(attr.__tablename__)
            model_classes.append(attr)
    
    print("=== DATABASE ANALYSIS REPORT ===\n")
    
    # Missing tables
    missing_tables = required_tables - existing_tables
    if missing_tables:
        print(f"❌ MISSING TABLES ({len(missing_tables)}):")
        for table in sorted(missing_tables):
            print(f"  - {table}")
    else:
        print("✅ All required tables exist!")
    
    # Extra tables
    extra_tables = existing_tables - required_tables
    if extra_tables:
        print(f"\n⚠️  EXTRA TABLES ({len(extra_tables)}):")
        for table in sorted(extra_tables):
            print(f"  - {table}")
    
    # Check column structures for existing tables
    print(f"\n=== COLUMN ANALYSIS ===")
    common_tables = existing_tables & required_tables
    
    for model_class in model_classes:
        table_name = model_class.__tablename__
        if table_name in common_tables:
            existing_columns = {col['name']: col for col in inspector.get_columns(table_name)}
            required_columns = {col.name: col for col in model_class.__table__.columns}
            
            missing_columns = set(required_columns.keys()) - set(existing_columns.keys())
            extra_columns = set(existing_columns.keys()) - set(required_columns.keys())
            
            if missing_columns or extra_columns:
                print(f"\n📋 TABLE: {table_name}")
                
                if missing_columns:
                    print(f"  ❌ Missing columns: {', '.join(sorted(missing_columns))}")
                
                if extra_columns:
                    print(f"  ⚠️  Extra columns: {', '.join(sorted(extra_columns))}")
            else:
                print(f"✅ {table_name}: All columns match")
    
    # Check for specific advanced feature tables
    print(f"\n=== ADVANCED FEATURE TABLES ANALYSIS ===")
    
    # Tables needed for Phase 1-4 features
    advanced_feature_tables = {
        # Phase 1 - Foundation
        'cache_entries': 'Redis caching integration',
        'rate_limits': 'API rate limiting',
        'api_versions': 'API versioning',
        
        # Phase 2 - Advanced Features
        'maintenance_predictions': 'Predictive maintenance',
        'weather_data': 'Weather integration',
        'iot_devices': 'IoT integration',
        'camera_streams': 'Camera integration',
        
        # Phase 3 - Enterprise Features
        'crm_leads': 'Enhanced CRM',
        'financial_budgets': 'Advanced financial management',
        'supply_chain_networks': 'Supply chain management',
        'mfa_setups': 'Advanced security',
        'audit_logs': 'Advanced security',
        'data_encryption': 'Advanced security',
        'security_events': 'Advanced security',
        
        # Phase 4 - Scalability & Performance
        'service_registries': 'Microservices',
        'cdn_configurations': 'CDN integration',
        'load_tests': 'Load testing',
        'auto_scaling_configs': 'Auto-scaling'
    }
    
    missing_advanced = []
    for table, description in advanced_feature_tables.items():
        if table not in existing_tables:
            missing_advanced.append((table, description))
    
    if missing_advanced:
        print(f"❌ MISSING ADVANCED FEATURE TABLES ({len(missing_advanced)}):")
        for table, description in missing_advanced:
            print(f"  - {table}: {description}")
    else:
        print("✅ All advanced feature tables exist!")
    
    # Generate migration suggestions
    print(f"\n=== MIGRATION SUGGESTIONS ===")
    
    if missing_tables:
        print("1. Create missing tables:")
        for table in sorted(missing_tables):
            print(f"   CREATE TABLE {table} ...")
    
    if missing_advanced:
        print("\n2. Create advanced feature tables:")
        for table, description in missing_advanced:
            print(f"   CREATE TABLE {table} -- {description}")
    
    print("\n3. Consider migrating data from extra tables if needed")
    
    return {
        'existing_tables': len(existing_tables),
        'required_tables': len(required_tables),
        'missing_tables': len(missing_tables),
        'missing_advanced': len(missing_advanced),
        'extra_tables': len(extra_tables)
    }

if __name__ == "__main__":
    analyze_database()
