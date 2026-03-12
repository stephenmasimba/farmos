from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

def check_equipment_schema():
    load_dotenv(".env", override=True)
    db_url = os.environ.get("DATABASE_URL")
    engine = create_engine(db_url)
    with engine.connect() as conn:
        print("Checking schema for 'equipment' table...")
        res = conn.execute(text("DESCRIBE equipment"))
        for row in res:
            print(row)

if __name__ == "__main__":
    check_equipment_schema()
