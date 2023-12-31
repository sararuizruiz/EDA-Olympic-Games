import mysql
import mysql.connector as connection
from mysql.connector import Error

def create_db_connection(host_name, user_name, user_password, db_name):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("MySQL Database connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection

def execute_transaction_query(connection, query):
    cursor = connection.cursor(buffered=True)
    try:
        cursor.execute(query)
        connection.commit()
        print("Query successful")
    except Error as err:
        print(f"Error: '{err}'")

def execute_fetchall_query(connection, query):
    cursor = connection.cursor(buffered=True)
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        for row in result:
            print(row)
    except Error as err:
        print(f"Error: '{err}'")   