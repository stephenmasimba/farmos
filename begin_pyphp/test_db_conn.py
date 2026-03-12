import pymysql
import os
from dotenv import load_dotenv

load_dotenv()
# DATABASE_URL: mysql+pymysql://root:@localhost/begin_masimba_farm
host = "localhost"
user = "root"
password = ""
database = "begin_masimba_farm"

try:
    connection = pymysql.connect(
        host=host,
        user=user,
        password=password,
        database=database,
        connect_timeout=5
    )
    print("Connection successful!")
    with connection.cursor() as cursor:
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        print(f"Tables: {tables}")
        try:
            cursor.execute("DESCRIBE timesheets")
            desc = cursor.fetchall()
            print("Timesheets schema:")
            for row in desc:
                print(row)
        except Exception as e:
            print(f"DESCRIBE timesheets failed: {e}")
    connection.close()
except Exception as e:
    print(f"Connection failed: {e}")
