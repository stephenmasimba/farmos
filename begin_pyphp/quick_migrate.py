
from sqlalchemy import create_engine, text
from backend.common.config import settings

def migrate():
    engine = create_engine(settings.DATABASE_URL)
    with engine.connect() as conn:
        print("Checking for missing columns in livestock_batches...")
        
        # Add quantity column if missing
        try:
            conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN quantity INTEGER AFTER count"))
            print("Added quantity column to livestock_batches")
        except Exception as e:
            if "Duplicate column name" in str(e):
                print("quantity column already exists")
            else:
                print(f"Error adding quantity: {e}")
        
        # Add breed column if missing
        try:
            conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN breed VARCHAR(50) AFTER start_date"))
            print("Added breed column to livestock_batches")
        except Exception as e:
            if "Duplicate column name" in str(e):
                print("breed column already exists")
            else:
                print(f"Error adding breed: {e}")

        # Add location column if missing
        try:
            conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN location VARCHAR(100) AFTER breed"))
            print("Added location column to livestock_batches")
        except Exception as e:
            if "Duplicate column name" in str(e):
                print("location column already exists")
            else:
                print(f"Error adding location: {e}")

        # Add notes column if missing
        try:
            conn.execute(text("ALTER TABLE livestock_batches ADD COLUMN notes TEXT AFTER location"))
            print("Added notes column to livestock_batches")
        except Exception as e:
            if "Duplicate column name" in str(e):
                print("notes column already exists")
            else:
                print(f"Error adding notes: {e}")
        
        conn.commit()
        print("Migration check complete.")

from dotenv import load_dotenv
import os

if __name__ == "__main__":
    # Explicitly load .env from current directory with override
    load_dotenv(dotenv_path=".env", override=True)
    
    # Check what's in os.environ vs settings
    db_url = os.environ.get("DATABASE_URL")
    print(f"Final DATABASE_URL to use: {db_url}")
    
    if not db_url:
        print("DATABASE_URL not found in environment!")
        exit(1)

    engine = create_engine(db_url)
    from backend.common.database import Base
    import backend.common.models as models # Ensure all models are registered

    with engine.connect() as conn:
        print("Dropping ALL tables to ensure a clean start...")
        res = conn.execute(text("SHOW TABLES"))
        tables = [row[0] for row in res]
        
        # Disable foreign key checks to drop everything
        conn.execute(text("SET FOREIGN_KEY_CHECKS = 0"))
        for table in tables:
            try:
                conn.execute(text(f"DROP TABLE IF EXISTS {table}"))
                print(f"Dropped {table}")
            except Exception as e:
                print(f"Error dropping {table}: {e}")
        conn.execute(text("SET FOREIGN_KEY_CHECKS = 1"))
        
        conn.commit()
        print("Dropped all tables successfully.")

    print("Recreating all tables from models...")
    Base.metadata.create_all(bind=engine)
    print("Tables recreated successfully.")