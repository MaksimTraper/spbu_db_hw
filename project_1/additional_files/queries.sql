-- Средний и максимальный баланс по пользователям с каждой ролью
SELECT ua.role, ROUND(AVG(tc.balance),2) AS avg_balance, ROUND(MAX(tc.balance),2) AS max_balance
FROM User_accounts ua
JOIN Transport_cards tc ON ua.id = tc.owner_id
GROUP BY ua.role
LIMIT 200;

-- Количество пользователей, у которых день рождения в каждом месяце
SELECT EXTRACT(MONTH FROM birthday) AS birth_month, COUNT(*) AS user_count
FROM User_accounts
GROUP BY EXTRACT(MONTH FROM birthday)
ORDER BY birth_month
LIMIT 200;
	
-- Список маршрутов с указанием числа поездок по каждому маршруту
SELECT r.id, r.start_point, r.end_point, COUNT(t.id) AS trip_count
FROM Routes r
LEFT JOIN Trips t ON r.id = t.route_id
GROUP BY r.id, r.start_point, r.end_point
ORDER BY trip_count DESC
LIMIT 200;
	
-- Водители и количество транспортных средств, которые они ведут
SELECT d.name, d.surname, COUNT(t.vehicle_id) AS transport_count
FROM Drivers d
LEFT JOIN Transport t ON d.id = t.driver_id
GROUP BY d.id, d.name, d.surname
ORDER BY transport_count DESC
LIMIT 200;
	
-- Средний баланс на транспортной карте для пользователей старше 30 лет
SELECT ROUND(AVG(tc.balance),2) AS avg_balance
FROM User_accounts ua
JOIN Transport_cards tc ON ua.id = tc.owner_id
WHERE AGE(ua.birthday) > INTERVAL '30 years'
LIMIT 200;

-- Самые популярные маршруты по числу поездок с информацией о водителях
SELECT 
    r.id AS route_id,
    r.start_point,
    r.end_point,
    COUNT(t.id) AS trip_count,
    d.name AS driver_name,
    d.surname AS driver_surname
FROM Routes r
JOIN Trips t ON r.id = t.route_id
LEFT JOIN Transport tr ON t.transport_id = tr.vehicle_id
LEFT JOIN Drivers d ON tr.driver_id = d.id
GROUP BY r.id, r.start_point, r.end_point, d.id, d.name, d.surname
ORDER BY trip_count DESC
LIMIT 10;

-- Средний баланс и общее количество карт для пользователей по возрастным группам
SELECT 
    CASE 
        WHEN AGE(ua.birthday) < INTERVAL '18 years' THEN 'До 18'
        WHEN AGE(ua.birthday) BETWEEN INTERVAL '18 years' AND INTERVAL '30 years' THEN '18-30'
        WHEN AGE(ua.birthday) BETWEEN INTERVAL '30 years' AND INTERVAL '50 years' THEN '30-50'
        ELSE '50+'
    END AS age_group,
    ROUND(AVG(tc.balance),2) AS avg_balance,
    COUNT(tc.id) AS card_count
FROM User_accounts ua
LEFT JOIN Transport_cards tc ON ua.id = tc.owner_id
GROUP BY age_group
ORDER BY age_group;

-- Список пользователей, которые потратили больше всего на пополнение карт и покупку дней
SELECT 
    ua.name,
    ua.surname,
    SUM(p.price) AS total_spent,
    COUNT(p.id) AS total_purchases
FROM User_accounts ua
JOIN Transport_cards tc ON ua.id = tc.owner_id
JOIN Purchases p ON tc.id = p.card_id
GROUP BY ua.id, ua.name, ua.surname
HAVING SUM(p.price) > 1000
ORDER BY total_spent DESC;


-- Маршруты с максимальной и минимальной загрузкой (по количеству поездок)
WITH RouteLoad AS (
    SELECT 
        r.id AS route_id,
        r.start_point,
        r.end_point,
        COUNT(t.id) AS trip_count
    FROM Routes r
    LEFT JOIN Trips t ON r.id = t.route_id
    GROUP BY r.id, r.start_point, r.end_point
)
SELECT 
    route_id,
    start_point,
    end_point,
    trip_count,
    CASE 
        WHEN trip_count = (SELECT MAX(trip_count) FROM RouteLoad) THEN 'Максимальная загрузка'
        WHEN trip_count = (SELECT MIN(trip_count) FROM RouteLoad) THEN 'Минимальная загрузка'
    END AS load_type
FROM RouteLoad
WHERE trip_count = (SELECT MAX(trip_count) FROM RouteLoad)
   OR trip_count = (SELECT MIN(trip_count) FROM RouteLoad);


-- Пользователи, совершившие наибольшее количество поездок за 23 год
SELECT 
    ua.name,
    ua.surname,
    COUNT(t.id) AS trip_count
FROM User_accounts ua
JOIN Transport_cards tc ON ua.id = tc.owner_id
JOIN Trips t ON tc.id = t.card_id
WHERE t.time_pay BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY ua.id, ua.name, ua.surname
ORDER BY trip_count DESC
LIMIT 10;