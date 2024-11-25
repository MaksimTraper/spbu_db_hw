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