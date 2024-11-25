-- Задание 1. Придумайте временную таблицу с использованием группировки данных

-- Продажи товаров за последний месяц
CREATE TEMP TABLE current_month_sales AS
SELECT product_id, SUM(quantity) AS total_sales
FROM sales
WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE)
GROUP BY product_id;

-- Проверим данные
SELECT * FROM current_month_sales LIMIT 5;

DROP TABLE current_month_sales;

-- Views
CREATE VIEW sales_view AS
SELECT * FROM sales;

DROP VIEW sales_view;

-- Common Table Expressions
-- CTE для иерархического запроса сотрудников
-- Запрос для отображения иерархии сотрудников: менеджер и его подчиненные.
WITH employee_hierarchy AS (
    SELECT e1.name AS manager, e2.name AS employee
    FROM employees e1
    JOIN employees e2 ON e1.employee_id = e2.manager_id
)
SELECT * FROM employee_hierarchy LIMIT 5;

-- DROP TABLE employee_hierarchy;


-- Задание 2: CTE для вычисления средней зарплаты по отделам
-- Решение 1
WITH department_avg_salary AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT * FROM department_avg_salary;
-- ИНДЕКСЫ
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales';

-- Индекс для ускорения запросов по полю department
-- Индекс поможет быстрее выполнять запросы, которые фильтруют по отделам.
CREATE INDEX idx_department ON employees(department);

-- Пример запроса с использованием индекса
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales';

-- Удаление индекса
DROP INDEX idx_department;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales';

-- Индекс для ускорения запросов по полю department
-- Индекс поможет быстрее выполнять запросы, которые фильтруют по отделам.
CREATE INDEX idx_department ON employees(department);

-- Пример запроса с использованием индекса
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department = 'Sales';

-- Удаление индекса
DROP INDEX idx_department;


-- Трассировка запросов
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_sales
FROM sales
WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE)
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 5;


-- Задание 3:
-- Индекс для sales по полю sale_date
-- Сделать запрос продаж за выбранный период

CREATE INDEX idx_sale_date ON sales(sale_date);

-- Пример запроса для проверки индекса
SELECT * FROM sales WHERE sale_date BETWEEN '2024-11-01' AND '2024-11-30' LIMIT 5;


-- Домашнее задание  №3

-- Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве более 10 единиц за последние 7 дней.
-- Выведите данные из таблицы high_sales_products.

-- Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж для каждого сотрудника за последние 30 дней.
-- Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании.

-- Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру.
-- Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. В результатах должно быть указано, к какому месяцу относится каждая запись.

-- Создайте индекс для таблицы sales по полю employee_id и sale_date, чтобы ускорить запросы, которые фильтруют данные по сотрудникам и датам.
-- Проверьте, как наличие индекса влияет на производительность следующего запроса, используя EXPLAIN ANALYZE.

-- Используя EXPLAIN, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.