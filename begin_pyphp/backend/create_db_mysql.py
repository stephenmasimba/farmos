import pymysql

# Connect to MySQL server (no database selected)
connection = pymysql.connect(
    host='localhost',
    user='root',
    password='',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

try:
    with connection.cursor() as cursor:
        # Create database if it doesn't exist
        sql = "CREATE DATABASE IF NOT EXISTS farmos"
        cursor.execute(sql)
        print("Database 'farmos' created or already exists.")
finally:
    connection.close()
