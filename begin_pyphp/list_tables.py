from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

def list_tables():
    load_dotenv(".env", override=True)
    db_url = os.environ.get("DATABASE_URL")
    engine = create_engine(db_url)
    with engine.connect() as conn:
        print("Listing all tables in 'farmos' database...")
        res = conn.execute(text("SHOW TABLES"))
        for row in res:
            print(row[0])

if __name__ == "__main__":
    list_tables()