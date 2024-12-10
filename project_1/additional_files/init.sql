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