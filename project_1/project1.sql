-- Создание таблиц

-- Создание таблицы пользователей
-- Ввиду того, что поверх таблицы не создаётся сайт, у пароля и паспортных данных будет тип VARCHAR, чтобы не городить огромные строки
-- хотя по хорошему их тип должен быть CHAR

CREATE TYPE roles AS ENUM ('admin', 'user');

CREATE TABLE User_accounts (
    id SERIAL PRIMARY KEY,
    passport_hash VARCHAR(64) NOT NULL UNIQUE, -- Длина для SHA-256
    name VARCHAR(30) NOT NULL,
    surname VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30),
    login VARCHAR(30) NOT NULL UNIQUE,
    password_hash VARCHAR(60) NOT NULL, -- bcrypt использует до 60 символов
    email VARCHAR(50) NOT NULL UNIQUE,
    role roles NOT NULL,
    birthday DATE NOT NULL
);

-- Создание таблицы транспортных карт
CREATE TABLE Transport_cards (
    id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES User_accounts(id) ON UPDATE CASCADE ON DELETE CASCADE,
    balance NUMERIC(10, 2) CHECK (balance >= 0) DEFAULT 0,
    date_issue DATE NOT NULL DEFAULT CURRENT_DATE,
    num_days INT DEFAULT 0 CHECK (num_days >= 0)
);

-- Создание таблицы транспортных средств (абстрактные модели)
CREATE TABLE Transport_vehicles (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(30) NOT NULL,
    model VARCHAR(30) NOT NULL
);

CREATE TYPE types_parks AS ENUM ('автобусный', 'троллейбусный', 'трамвайный', 'трамвайно-троллейбусный');

-- Создание таблицы парков
CREATE TABLE Parks (
    id SERIAL PRIMARY KEY,
    number INT NOT NULL,
    type types_parks NOT NULL,
    CONSTRAINT unique_name_type UNIQUE (number, type)
);


-- Создание таблицы бригад
CREATE TABLE Brigades (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    size INT CHECK (size > 0),
    park_id INT NOT NULL REFERENCES Parks(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создание таблицы водителей
CREATE TABLE Drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    surname VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30),
    brigade_id INT REFERENCES Brigades(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Создание таблицы транспорта
CREATE TABLE Transport (
    vehicle_id VARCHAR(9) PRIMARY KEY,
    model INT NOT NULL REFERENCES Transport_vehicles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    driver_id INT REFERENCES Drivers(id) ON UPDATE CASCADE ON DELETE SET NULL -- Водитель может быть необязательным
);

-- Создание таблицы маршрутов
CREATE TABLE Routes (
    id SERIAL PRIMARY KEY,
    start_point VARCHAR(30) NOT NULL,
    end_point VARCHAR(30) NOT NULL
);

-- Создание таблицы поездок
CREATE TABLE Trips (
    id SERIAL PRIMARY KEY,
    transport_id VARCHAR(9) REFERENCES Transport(vehicle_id) ON DELETE SET NULL ON UPDATE CASCADE,
    card_id INT REFERENCES Transport_cards(id) ON DELETE SET NULL ON UPDATE CASCADE,
    driver_id INT REFERENCES Drivers(id) ON DELETE SET NULL ON UPDATE CASCADE,
    time_pay TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    route_id INT REFERENCES Routes(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TYPE operations AS ENUM ('add balance', 'buy days');

-- Создание таблицы покупок
CREATE TABLE Purchases (
    id SERIAL PRIMARY KEY,
    card_id INT REFERENCES Transport_cards(id) ON DELETE SET NULL ON UPDATE CASCADE,
    name operations NOT NULL CHECK (name IN ('add balance', 'buy days')),
    price NUMERIC(9, 2) NOT NULL CHECK (price >= 0),
    amount INT DEFAULT 0
);




-- Заполнение таблиц

INSERT INTO Transport_vehicles (brand, model) VALUES
('Volgabus', '5270'),
('Nefaz', '5299'),
('Volgabus', '4298'),
('Maz', '303'),
('Golden Dragon', 'XML6155');

INSERT INTO User_accounts (passport_hash, name, surname, patronymic, login, password_hash, email, role, birthday) VALUES
('e99a18c428cb38d5f260853678922e03', 'Maksim', 'Traper', 'Konstantinovich', 'MaksudUchiha', '$2a$10$z8rH7kN2Bv77Ds0', 'dekstor235@gmail.com', 'admin', '2002-08-07'),
('ad0234829205b9033196ba818f7a872b', 'Viktor', 'Blud', 'Antonovich', 'viktorblud', '$2a$10$kirovgrad12345', 'novayapochta1246@yandex.ru', 'user', '1956-09-25'),
('5d41402abc4b2a76b9719d911017c592', 'Anton', 'Blud', 'Vitalyevich', 'antoshkabluuud', '$2a$10$y@bed@@@', 'bestboy228@gmail.com', 'user', '2003-03-05'),
('7b8b965ad4bca0e41ab51de7b31363a1', 'Kirill', 'Ston', 'Mikhaylovich', 'gazgaz', '$2a$10$gazgazpass123', 'gazgazgaz@inbox.com', 'user', '1992-03-05'),
('6c8349cc7260ae62e3b1396831a8398f', 'Stepan', 'Pyrin', 'Ahmatovich', 'styopamr', '$2a$10$qwerty1234pass', 'misterx@mail.ru', 'user', '2006-04-17'),
('93db85ed909c13838ff95ccfa94cebd9', 'Kim', 'Luon', 'Kuoy', 'KimLuKu', '$2a$10$panthers1423', 'torch@gmail.com', 'user', '1985-12-04');

INSERT INTO Transport_cards (owner_id, balance, date_issue, num_days) VALUES
(1, 5678.44, '2023-12-24', 0),
(2, 456.13, '2021-06-16', 3),
(3, 500.00, '2018-02-08', 0),
(4, 123.78, '2023-10-31', 10),
(5, 12578.78, '2022-05-05', 0),
(6, 1365.42, '2020-08-14', 0);

INSERT INTO Drivers (name, surname, patronymic) VALUES
('Petr', 'Sidorov', 'Ivanovich'),
('Viktor', 'Kot', 'Stepanovich'),
('Maksim', 'Traper', 'Konstantinovich'),
('Leonid', 'Vorobyev', 'Alexeevich'),
('Andrey', 'Kirillov', 'Ivanovich');

INSERT INTO Transport (vehicle_id, model, driver_id) VALUES
('Л416СП78', 1, 3),
('Р564АЦ78', 3, 1),
('П647ПО178', 1, 5),
('А536ПП178', 4, 4),
('Я124ПО78', 1, 1),
('У578АЦ178', 2, 2),
('К235ПК78', 1, 2),
('А923ММ98', 1, 3),
('М435ЕР98', 3, 5);

INSERT INTO Routes (id, start_point, end_point) VALUES
(191, 'Ст.м.Петроградская', 'Ст.м.Улица Дыбенко'),
(40, 'Улица кораблестроителей', 'Тихорецкий проспект'),
(35, 'Станция Сортировочная', 'Проспект Героев'),
(21, 'Ст.м.Ладожская', 'Финляндский вокзал'),
(100, 'Ст.м.Проспект просвещения', 'Ст.м.Гражданский проспект'),
(3, 'Финляндский вокзал', 'Площадь Репина');

INSERT INTO Trips (transport_id, card_id, driver_id, time_pay, route_id) VALUES
('А536ПП178', 5, 1, '2023-01-08 16:49:13', 3),
('Л416СП78', 5, 2, '2023-01-08 22:23:13', 3),
('П647ПО178', 3, 4, '2023-01-08 16:14:46', 191),
('А923ММ98', 2, 5, '2022-01-08 14:34:32', 100),
('А536ПП178', 1, 2, '2022-01-08 11:23:47', 3),
('А923ММ98', 1, 2, '2023-01-08 08:45:14', 191),
('П647ПО178', 3, 3, '2023-01-08 07:17:57', 100),
('А536ПП178', 4, 4, '2022-01-08 07:42:21', 3),
('К235ПК78', 4, 5, '2023-01-08 14:13:04', 40),
('К235ПК78', 1, 5, '2021-01-08 18:03:21', 3),
('Я124ПО78', 1, 1, '2023-01-08 12:14:45', 191),
('М435ЕР98', 1, 2, '2023-01-08 04:56:11', 21),
('Я124ПО78', 2, 3, '2021-01-08 05:00:35', 21),
('П647ПО178', 3, 1, '2022-01-08 18:56:01', 191);

INSERT INTO Purchases (card_id, name, price, amount) VALUES
(2, 'buy days', 250, 3),
(4, 'buy days', 750, 10),
(1, 'add balance', 5678.44, 0);

INSERT INTO Parks (number, type) VALUES
(3, 'автобусный'),
(2, 'троллейбусный'),
(3, 'трамвайный'),
(1, 'трамвайно-троллейбусный');

-- Заполнение таблицы Brigades
INSERT INTO Brigades (name, size, park_id) VALUES
('Бригада А', 10, 1),
('Бригада Б', 8, 2),
('Бригада В', 12, 3);

UPDATE Drivers
SET brigade_id = 1 WHERE id IN (1, 2);
UPDATE Drivers
SET brigade_id = 2 WHERE id = 3;
UPDATE Drivers
SET brigade_id = 3 WHERE id IN (4, 5);



-- Создание индексов для ускорения
CREATE UNIQUE INDEX idx_parks_name_type ON Parks(number, type);

CREATE INDEX idx_transport_cards_owner_id ON Transport_cards(owner_id);

CREATE INDEX idx_brigades_park_id ON Brigades(park_id);

CREATE INDEX idx_drivers_brigade_id ON Drivers(brigade_id);

CREATE INDEX idx_transport_model ON Transport(model);

CREATE INDEX idx_transport_driver_id ON Transport(driver_id);

CREATE INDEX idx_trips_transport_id ON Trips(transport_id);

CREATE INDEX idx_trips_card_id ON Trips(card_id);

CREATE INDEX idx_trips_route_id ON Trips(route_id);

CREATE INDEX idx_purchases_card_id ON Purchases(card_id);



-- Запросы

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