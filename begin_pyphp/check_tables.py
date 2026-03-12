import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def list_tables():
    load_dotenv(".env", override=True)
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("Error: DATABASE_URL not found in environment.")
        return

    try:
        engine = create_engine(db_url)
        with engine.connect() as conn:
            result = conn.execute(text("SHOW TABLES"))
            tables = [row[0] for row in result]
            print("--- DATABASE TABLES ---")
            for table in tables:
                print(table)
            print("-----------------------")
    except Exception as e:
        print(f"Error connecting to database: {e}")

if __name__ == "__main__":
    list_tables()
