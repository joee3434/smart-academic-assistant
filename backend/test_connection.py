from db.connection import get_connection

try:
    conn = get_connection()
    print("DATABASE CONNECTED")
    conn.close()

except Exception as e:
    print(e)
