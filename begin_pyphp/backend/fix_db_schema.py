from sqlalchemy import text, inspect
from backend.common.database import engine, SessionLocal
from backend.common import models
# from passlib.context import CryptContext
import bcrypt

# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    # return pwd_context.hash(password)
    # Use bcrypt directly to avoid passlib/bcrypt version mismatch issues
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def fix_users_table():
    inspector = inspect(engine)
    columns = [c['name'] for c in inspector.get_columns('users')]
    print(f"Current columns in users: {columns}")
    
    with engine.connect() as conn:
        if 'role' not in columns:
            print("Adding role column...")
            conn.execute(text("ALTER TABLE users ADD COLUMN role VARCHAR(20)"))
        
        if 'tenant_id' not in columns:
            print("Adding tenant_id column...")
            conn.execute(text("ALTER TABLE users ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
            # Check index existence before creating to avoid error
            # For simplicity in this script, just try/except or ignore if exists
            try:
                conn.execute(text("CREATE INDEX ix_users_tenant_id ON users (tenant_id)"))
            except Exception as e:
                print(f"Index creation skipped: {e}")

        if 'status' not in columns:
            print("Adding status column...")
            conn.execute(text("ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active'"))
            
        if 'hashed_password' not in columns:
            print("Adding hashed_password column...")
            conn.execute(text("ALTER TABLE users ADD COLUMN hashed_password VARCHAR(255)"))
            
        if 'created_at' not in columns:
             print("Adding created_at column...")
             conn.execute(text("ALTER TABLE users ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP"))

        # Check Inventory Items for qr_code
        try:
            inv_columns = [c['name'] for c in inspector.get_columns('inventory_items')]
            if 'qr_code' not in inv_columns:
                print("Adding qr_code to inventory_items...")
                conn.execute(text("ALTER TABLE inventory_items ADD COLUMN qr_code VARCHAR(50)"))
                conn.execute(text("CREATE UNIQUE INDEX ix_inventory_items_qr_code ON inventory_items (qr_code)"))
        except Exception:
            # Table might not exist yet if create_all wasn't called or failed
            pass

        # Check Tasks for is_recurring
        try:
            task_columns = [c['name'] for c in inspector.get_columns('tasks')]
            if 'is_recurring' not in task_columns:
                print("Adding is_recurring to tasks...")
                conn.execute(text("ALTER TABLE tasks ADD COLUMN is_recurring BOOLEAN DEFAULT FALSE"))
        except Exception:
            pass

        # Check Livestock Batches for type, breed, location, quantity
        try:
            ls_columns = [c['name'] for c in inspector.get_columns('livestock_batches')]
            if 'type' not in ls_columns:
                print("Adding type to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN type VARCHAR(50)"))
                conn.execute(text("CREATE INDEX ix_livestock_batches_type ON livestock_batches (type)"))
            if 'breed' not in ls_columns:
                print("Adding breed to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN breed VARCHAR(50)"))
            if 'location' not in ls_columns:
                print("Adding location to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN location VARCHAR(100)"))
            if 'quantity' not in ls_columns:
                print("Adding quantity to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN quantity INTEGER"))
            if 'name' not in ls_columns:
                print("Adding name to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN name VARCHAR(100)"))
            if 'count' not in ls_columns:
                print("Adding count to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN count INTEGER"))
            if 'start_date' not in ls_columns:
                print("Adding start_date to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN start_date VARCHAR(20)"))
            if 'status' not in ls_columns:
                print("Adding status to livestock_batches...")
                conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN status VARCHAR(20)"))
        except Exception:
            pass

        # Check Fields for name, area, unit, crop, status
        try:
            field_columns = [c['name'] for c in inspector.get_columns('fields')]
            if 'name' not in field_columns:
                print("Adding name to fields...")
                conn.execute(text("ALTER TABLE fields ADD COLUMN name VARCHAR(100)"))
            if 'area' not in field_columns:
                print("Adding area to fields...")
                conn.execute(text("ALTER TABLE fields ADD COLUMN area FLOAT"))
            if 'unit' not in field_columns:
                print("Adding unit to fields...")
                conn.execute(text("ALTER TABLE fields ADD COLUMN unit VARCHAR(20)"))
            if 'crop' not in field_columns:
                print("Adding crop to fields...")
                conn.execute(text("ALTER TABLE fields ADD COLUMN crop VARCHAR(50)"))
            if 'status' not in field_columns:
                print("Adding status to fields...")
                conn.execute(text("ALTER TABLE fields ADD COLUMN status VARCHAR(50)"))
        except Exception:
            pass
        
        # 4. Add tenant_id to all tables if missing
        tables = ['fields', 'tasks', 'inventory_items', 'livestock_batches', 'financial_transactions', 'sops', 'sop_executions', 'schedules', 'feed_ingredients']
        for table in tables:
            try:
                cols = [c['name'] for c in inspector.get_columns(table)]
                if 'tenant_id' not in cols:
                    print(f"Adding tenant_id to {table}...")
                    conn.execute(text(f"ALTER TABLE {table} ADD COLUMN tenant_id VARCHAR(50) DEFAULT 'default'"))
                    try:
                        conn.execute(text(f"CREATE INDEX ix_{table}_tenant_id ON {table} (tenant_id)"))
                    except Exception:
                        pass
            except Exception:
                pass

        conn.commit()
    print("Database schema fixed.")

    # Fix User Data (Passwords and Roles)
    db = SessionLocal()
    try:
        # Check users
        users = db.query(models.User).all()
        print(f"Found {len(users)} users: {[u.email for u in users]}")

        # Force update/create admin password for testing
        admin = db.query(models.User).filter(models.User.email == "admin@example.com").first()
        if not admin:
            print("Creating admin user...")
            admin = models.User(
                name="Admin User",
                email="admin@example.com",
                role="admin",
                status="active",
                hashed_password=get_password_hash("password123")
            )
            db.add(admin)
            db.commit()
        else:
             print("Resetting admin password...")
             admin.hashed_password = get_password_hash("password123")
             db.commit()

        users = db.query(models.User).filter(models.User.hashed_password is None).all()
        if users:
            print(f"Found {len(users)} users with missing hashed_password. Updating...")
            default_hash = get_password_hash("password123")
            for user in users:
                user.hashed_password = default_hash
                if not user.role:
                    # Infer role or default to worker
                    if "admin" in user.email:
                        user.role = "admin"
                    elif "manager" in user.email:
                        user.role = "manager"
                    else:
                        user.role = "worker"
            db.commit()
            print("Users updated with default password 'password123' and roles.")
    except Exception as e:
        print(f"Error updating users: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    fix_users_table()
