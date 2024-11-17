-- Задание №1
/* Создайте временную таблицу high_sales_products, которая будет содержать продукты, 
проданные в количестве более 10 единиц за последние 7 дней.*/

-- P.S: я убавил до 2+ продаж, ибо значений немного

CREATE TEMP TABLE high_sales_products AS
SELECT p.*, t.count_products
FROM (SELECT product_id, COUNT(product_id) count_products
		FROM sales s
		WHERE sale_date >= CURRENT_DATE - INTERVAL '7 days'
		GROUP BY product_id
		HAVING COUNT(product_id) > 2) t JOIN products p
ON t.product_id = p.product_id;

-- Выведите данные из таблицы high_sales_products.
SELECT * FROM high_sales_products LIMIT 10;

--DROP TABLE high_sales_products




/* Задание №2

Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее 
количество продаж для каждого сотрудника за последние 30 дней.*/

WITH employee_sales_stats AS
(
SELECT employee_id, ROUND(COUNT(product_id), 2) count_sales, ROUND(COUNT(product_id)/30.0, 5) avg_sales_in_day
FROM sales s
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY employee_id);

SELECT * FROM employee_sales_stats;

-- Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании.
WITH count_sales_employee AS
(
SELECT t.employee_id, count_sales, name, position, department, salary, manager_id
FROM(
SELECT s.employee_id, COUNT(product_id) count_sales
FROM sales s JOIN employees e ON s.employee_id = e.employee_id
GROUP BY s.employee_id) t JOIN employees e ON t.employee_id = e.employee_id
),
avg_sales_department AS
(
SELECT department, ROUND(AVG(count_sales), 2) avg_sales
FROM 
(SELECT department, count_sales FROM count_sales_employee) t
GROUP BY department
)

SELECT employee_id, name, d.department, position, avg_sales avg_saled_in_dep, count_sales count_sales_emp
FROM avg_sales_department d JOIN count_sales_employee e
ON d.department = e.department
WHERE count_sales > avg_sales
ORDER BY e.count_sales DESC
LIMIT 10



-- Задание №3

-- Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру.

WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, name, position, salary, manager_id, 1 AS depth
    FROM employees
    WHERE employee_id = 1

    UNION ALL

    SELECT e.employee_id, e.name, e.position, e.salary, e.manager_id, (e_h.depth + 1) depth
    FROM employees e JOIN employee_hierarchy e_h
	ON e.manager_id = e_h.employee_id
)
/* Смотрим, нужно ли ограничивать вывод. Сколько строк
SELECT COUNT(employee_id)
FROM employee_hierarchy
*/

SELECT * 
FROM employee_hierarchy 
ORDER BY depth, employee_id;

/* Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. 
В результатах должно быть указано, к какому месяцу относится каждая запись.*/

-- С DATE_TRUNC остаётся timestamp. Использовать такую функцию правильнее. Полностью запрос писать не буду
SELECT DATE_TRUNC('month', sale_date) AS month, product_id, COUNT(sale_id)
FROM sales s
GROUP BY DATE_TRUNC('month', sale_date), product_id;

-- Тут не остаётся timestamp. Вид вывода лучше, но это строка
WITH ranked_data AS (
    SELECT product_id, TO_CHAR(sale_date, 'YYYY-MM') AS month,
        ROW_NUMBER() OVER (PARTITION BY TO_CHAR(sale_date, 'YYYY-MM') ORDER BY COUNT(sale_id) DESC) AS rank,
		COUNT(sale_id)
    FROM sales
	GROUP BY TO_CHAR(sale_date, 'YYYY-MM'), product_id
)
SELECT month, rank, r_d.product_id, name, price
FROM ranked_data r_d JOIN products p
ON r_d.product_id = p.product_id
WHERE rank <= 3
ORDER BY month, rank;


-- На этом этапе я узнал о возможности внутренней генерации
-- Увеличиваем кол-во данных для экспериментов
INSERT INTO sales(employee_id, product_id, quantity, sale_date)
SELECT 
	(random() * 66 + 1)::INT,
	(random() * 15 + 1)::INT,
	(random() * 30 + 1)::INT,
	CURRENT_DATE - (random() * 365)::INT * INTERVAL '1 day'
FROM generate_series(1, 50000);

/* Задание №4
Создайте индекс для таблицы sales по полю employee_id и sale_date, чтобы ускорить запросы, которые фильтруют 
данные по сотрудникам и датам.
Проверьте, как наличие индекса влияет на производительность следующего запроса, используя EXPLAIN ANALYZE*/

-- Planing time: 0.201 ms, 0.116 ms, 0.203 ms
-- Execution time: 0.181 ms, 0.106 ms, 0.123 ms
EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE employee_id BETWEEN 1 AND 30 
	AND sale_date = '17-11-2024'
LIMIT 10;

/*
CREATE INDEX idx_empl_day
ON sales(employee_id, sale_date);
*/

-- Planing time: 0.051 ms, 0.124 ms, 0.079 ms
-- Execution time: 0.053 ms, 0.131 ms, 0.113 ms
EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE employee_id BETWEEN 1 AND 30 
	AND sale_date = '17-11-2024'
LIMIT 10;

-- В среднем, запросы с индексом планируются и выполняются быстрее
-- но не всегда




-- Задание №5

-- Используя EXPLAIN, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.

--CREATE INDEX idx_product_id 
--ON sales(product_id);

EXPLAIN ANALYZE
SELECT product_id, SUM(quantity)
FROM sales
GROUP BY product_id
ORDER BY COUNT(sale_id) DESC;

/* Seq Scan - стоимость до 14762, до 583794 строк :0, каждая 12 байт, итого до 6.68 мб
На самом деле actual time=0.014..61.059 rows=467035
По всем остальным операциям (GroupAggregate, Merge, Sort, HashAggregate) стоимость оценивается почти однозначно
Parallel Seq Scan вероятно проводится из-за большого количества данных
*/