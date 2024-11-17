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