import pyodbc

def get_connection():
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=SmartAssistantDB;"
        "UID=sa;"
        "PWD=YourPassword123;"
        "TrustServerCertificate=yes;"
    )

    return conn
