import psycopg2
import os
from dotenv import load_dotenv
import numpy as np
import string
from datetime import datetime, timedelta
import random

load_dotenv()
letters = list(string.ascii_uppercase)

def generate_random_date():
    current_date = datetime.now()
    start_date = current_date - timedelta(days=30)
    random_days = random.randint(0, 30)
    random_date = start_date + timedelta(days=random_days)
    formatted_date = random_date.strftime('%Y-%m-%d')
    return formatted_date

class DBInteractions:
    def __init__(self):
        self.db_user = os.getenv('DB_USER')
        self.db_password = os.getenv('DB_PASSWORD')
        self.db_host = os.getenv('DB_HOST')
        self.db_port = os.getenv('DB_PORT', '5432')

        self.conn = None
        self.cursor = None

    def load_database(self, db_name: str):
        try:
            self.conn = psycopg2.connect(dbname = db_name,
                                    user = self.db_user,
                                    password = self.db_password,
                                    host = self.db_host,
                                    port = self.db_port)
            self.cursor = self.conn.cursor()
            print(f'Успешное подключение к БД {db_name}')
        except Exception as e:
            print(f'Ошибка подключения к БД: {e}')

    def check_conn(self):
        if self.cursor is None:
            print('Нет подключения')
            return False
        return True

    def execute_select_query(self, query: str) -> list[tuple]:
        if self.check_conn() is False:
            return []

        if 'select' not in query.lower():
            print('Это не запрос SELECT')
            return

        try:
            self.cursor.execute(query)
            results = self.cursor.fetchall()
            return results
        except Exception as e:
            print(f'Ошибка выполнения запроса: {e}')
            self.conn.rollback()
            return []

    def execute_insert_query(self, query: str, verbose: bool = True) -> list[tuple]:
        if self.check_conn() is False:
            return 

        if 'insert' not in query.lower():
            print('Это не запрос INSERT')
            return

        try:
            self.cursor.execute(query)
            
            confirmation = 'Y'
            if verbose:
                table = query.split()[2]

                # не круто, что выводится вся таблица
                results = self.execute_select_query(query=f'SELECT * FROM {table}')
                for row in results:
                    print(row)

                confirmation = input('Подтвердите изменения? (Y/N): ').strip().upper()
            if confirmation == "Y":
                self.conn.commit()
                print('Изменения сохранены')
            else:
                self.conn.rollback()
        except Exception as e:
            print(f'Ошибка выполнения запроса: {e}')
            self.conn.rollback()

    def close_connection(self):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("Соединение закрыто")

db = DBInteractions()
db.load_database(db_name='employees')
"""
# Создать продукты
query_template = "INSERT INTO products (name, price) VALUES ('Product {name}', {price})"
for letter in letters[3:15]:
    price = np.around(np.random.randint(10, 1500), decimals=-1)
    query = query_template.format(name=letter, price=price)
    db.execute_insert_query(query=query, verbose=True)
"""
# Создать продажи
query_template = "INSERT INTO sales (employee_id, product_id, quantity, sale_date) \
                VALUES ({employee_id}, {product_id}, {quantity}, '{sale_date}')"
for i in range(1000):
    employee_id = np.random.randint(1, 67)
    product_id = np.random.randint(1, 15)
    quantity = np.random.randint(1, 30)
    sale_date = generate_random_date()

    query = query_template.format(employee_id=employee_id, 
                                  product_id=product_id,
                                  quantity=quantity,
                                  sale_date=sale_date)
    db.execute_insert_query(query=query, verbose=False)

db.close_connection()