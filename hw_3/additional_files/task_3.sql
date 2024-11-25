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