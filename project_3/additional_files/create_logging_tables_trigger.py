import os
import string
from datetime import datetime, timedelta
import random
from dotenv import load_dotenv

import psycopg2
from psycopg2 import sql
import numpy as np

load_dotenv()
letters = list(string.ascii_uppercase)

class DBInteractions:
    def __init__(self):
        self.db_user = os.getenv('DB_USER')
        self.db_password = os.getenv('DB_PASSWORD')
        self.db_host = os.getenv('DB_HOST')
        self.db_port = os.getenv('DB_PORT', '5432')

        self.conn = None
        self.cursor = None
        self.tables = None

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

    def create_trigger_for_table(self, table_name):
        try:
            trigger_name = f"universal_logging_{table_name}_trigger"
            create_trigger_query = sql.SQL("""
                CREATE TRIGGER {trigger_name}
                AFTER INSERT OR UPDATE OR DELETE ON {table_name}
                FOR EACH ROW
                EXECUTE FUNCTION universal_logging_trigger();
            """).format(
                trigger_name=sql.Identifier(trigger_name),
                table_name=sql.Identifier(table_name)
            )
            self.cursor.execute(create_trigger_query)
            print(f"Триггер создан для таблицы {table_name}")
        except Exception as e:
            print(f"Ошибка создания триггера для таблицы {table_name}: {e}")


    def get_all_tables(self):
        self.cursor.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
        """)
        self.tables = self.cursor.fetchall()

    def commit(self):
        self.conn.commit()
        return

    def close_connection(self):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("Соединение закрыто")

db = DBInteractions()
db.load_database(db_name='project')

db.get_all_tables()

# Создание триггеров для всех таблиц
for table in db.tables:
    db.create_trigger_for_table(table[0])

db.commit()

db.close_connection()