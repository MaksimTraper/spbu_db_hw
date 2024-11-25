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