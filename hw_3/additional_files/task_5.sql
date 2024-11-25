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