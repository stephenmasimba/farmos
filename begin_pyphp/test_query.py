from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

def test_query():
    load_dotenv(".env", override=True)
    db_url = os.environ.get("DATABASE_URL")
    engine = create_engine(db_url)
    with engine.connect() as conn:
        print("Testing SELECT location FROM equipment...")
        try:
            res = conn.execute(text("SELECT location FROM equipment"))
            print("Query successful!")
        except Exception as e:
            print(f"Query failed: {e}")

if __name__ == "__main__":
    test_query()
