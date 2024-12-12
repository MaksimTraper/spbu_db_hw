-- Анализ по месяцам, количество впервые использовавших транспортную карту
-- Подобный запрос полезен для графика динамики роста новых активных пользователей
EXPLAIN ANALYZE
WITH top_passengers AS (
    SELECT 
        *,
        DENSE_RANK() OVER (PARTITION BY card_id ORDER BY time_pay DESC) AS trip_rank,
        EXTRACT(YEAR FROM time_pay) AS year_pay,
        EXTRACT(MONTH FROM time_pay) AS month_number
    FROM 
        (transport_cards tc JOIN trips t ON tc.id = t.card_id) 
    			  			JOIN user_accounts ua ON ua.id = tc.owner_id
)
SELECT 
    year_pay, 
    TO_CHAR(MIN(time_pay), 'Month') AS month_pay,
    COUNT(owner_id) AS count_new_active_passengers
FROM top_passengers
WHERE trip_rank = 1
GROUP BY year_pay, month_number
ORDER BY year_pay, month_number;
-- В первый запуск planning time \approx 4ms, exec.time = 0.2ms
-- Далее они сравнялись
-- Для ускорения можно было бы применить материализованные представления
-- для подобной аналитики, где исторические данные не меняются - это лучшая
-- стратегия, особенно при большом кол-ве данных (но уже сделал так, как сделал. Оставлю так :))
-- А так, запрос выполняется быстро (на такой-то маленькой БД), но можно было бы навесить
-- доп.индексы (id, card_id, time_pay)






-- Самые доходные маршруты (но не прибыльные, для этого нужны данные
-- о длине маршрута, среднем кол-ве затрачиваемого топлива)
WITH trip_revenue AS (
    SELECT 
        t.route_id,
        SUM(p.price) AS total_revenue
    FROM trips t JOIN purchases p ON t.id = p.card_id
    GROUP BY t.route_id
)
SELECT 
    r.start_point, 
    r.end_point, 
    tr.total_revenue
FROM routes r
JOIN trip_revenue tr ON r.id = tr.route_id
ORDER BY tr.total_revenue DESC;
LIMIT 10




	

-- Количество поездок и водителей в каждом парке
CREATE VIEW park_statistics AS
SELECT 
    p.id AS park_id,
    p.type AS park_type,
    COUNT(DISTINCT t.id) AS total_trips,
    COUNT(DISTINCT d.id) AS total_drivers
FROM parks p LEFT JOIN brigades b ON p.id = b.park_id
			LEFT JOIN drivers d ON b.id = d.brigade_id
			LEFT JOIN trips t ON d.id = t.driver_id
GROUP BY p.id, p.type;

-- Запрос к созданному представлению
SELECT * FROM park_statistics;





-- Вывод самой популярной покупки у каждого пользователя (пополнение баланса или покупка проездного)
-- Полезно для аналитики
WITH user_actions AS (
    SELECT 
        ua.id AS user_id,
        ua.name AS user_name,
        ua.surname AS user_surname,
        COUNT(CASE WHEN p.name = 'add balance' THEN 1 END) AS add_balance_count,
        COUNT(CASE WHEN p.name = 'buy days' THEN 1 END) AS buy_days_count
    FROM user_accounts ua JOIN transport_cards tc ON ua.id = tc.owner_id
    				   	JOIN purchases p ON tc.id = p.card_id
    GROUP BY ua.id, ua.name, ua.surname
)
SELECT 
    user_id,
    user_name,
    user_surname,
    CASE 
        WHEN add_balance_count > buy_days_count THEN 'Add Balance'
        WHEN buy_days_count > add_balance_count THEN 'Buy Days'
        ELSE 'Equal Frequency'
    END AS most_frequent_action,
    add_balance_count,
    buy_days_count
FROM user_actions
ORDER BY user_id;
LIMIT 100




	

-- Это запросы с аналитикой по пользователям с самыми редкими именами
-- Это можно интерпретировать, как аналитика по иностранцам. Может чтобы
-- посмотреть, нужно ли повышать популярность транспортных карт
WITH name_rarity AS (
    SELECT 
        ua.name,
        COUNT(*) AS name_count,
        RANK() OVER (ORDER BY COUNT(*) ASC) AS rarity_rank
    FROM user_accounts ua
    GROUP BY ua.name
),
rare_users AS (
    SELECT 
        nr.name,
        AVG(p.price) AS avg_spending,
        nr.rarity_rank
    FROM name_rarity nr JOIN user_accounts ua ON ua.name = nr.name
					    JOIN transport_cards tc ON ua.id = tc.owner_id
					    JOIN purchases p ON tc.id = p.card_id
    GROUP BY nr.name, nr.rarity_rank
)
SELECT 
    name,
    avg_spending,
    rarity_rank
FROM rare_users
ORDER BY rarity_rank, avg_spending DESC
LIMIT 100;




-- Полученный от пользователя доход (его траты)
CREATE OR REPLACE FUNCTION calculate_user_revenue(user_id_input INT)
RETURNS NUMERIC AS $$
DECLARE
    total_revenue NUMERIC;
BEGIN
    SELECT 
        COALESCE(SUM(p.price), 0) INTO total_revenue
    FROM user_accounts ua 
    JOIN transport_cards tc ON ua.id = tc.owner_id
    JOIN purchases p ON tc.id = p.card_id
    WHERE ua.id = user_id_input;

    RETURN total_revenue;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Ошибка при вычислении дохода пользователя с ID = %: %', user_id_input, SQLERRM;
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

EXPLAIN ANALYZE
SELECT calculate_user_revenue(4); -- Рассчитать доход для пользователя с ID = 4
-- Execution time = 0.4ms. Причём на каждой итерации. В абсолютных числах, конечно, ни о чём, но по сравнению с
-- первым запросом, где огромное множество операций и время выполнения в среднем меньше раза в два, это удивительно



-- Статистика по маршрутам в виде материализованного представления. Такие данные наверняка полезны во многих
-- запросах, поэтому абсолютно оправдано закэшировать результаты такого запроса и, допустим, по расписанию его
-- пересчитывать
CREATE MATERIALIZED VIEW route_statistics AS
SELECT 
    r.id AS route_id,
    r.start_point,
    r.end_point,
    COUNT(t.id) AS total_trips,
    SUM(p.price) AS total_revenue
FROM routes r LEFT JOIN trips t ON r.id = t.route_id
				LEFT JOIN purchases p ON t.id = p.card_id 
GROUP BY r.id, r.start_point, r.end_point;

EXPLAIN ANALYZE
-- Обновление представления при изменении данных
REFRESH MATERIALIZED VIEW route_statistics;

-- Запрос к материализованному представлению
SELECT 
    route_id,
    start_point,
    end_point,
    total_trips,
    total_revenue
FROM route_statistics
WHERE total_trips > 10000 
ORDER BY total_revenue DESC;
-- Без REFRESH exec.time = 0.05ms, planning time = 0.07ms
-- После REFRESH exec.time = 0.021ms, planning time = 0.3ms
-- Ну в общем без REFRESH суммарно быстрее, но запрос дольше выполняется, видимо из-за того, что когда происходит
-- обновление представление, там кэшируются какие-то данные и сам запрос выполняется быстрее