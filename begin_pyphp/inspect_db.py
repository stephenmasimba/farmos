from sqlalchemy import create_engine, inspect
import os
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL", "mysql+pymysql://root:@localhost/begin_masimba_farm")
engine = create_engine(db_url)
inspector = inspect(engine)
tables = inspector.get_table_names()
print(f"Tables in database: {tables}")

for table in tables:
    columns = inspector.get_columns(table)
    print(f"\nTable: {table}")
    for column in columns:
        print(f"  - {column['name']} ({column['type']})")
