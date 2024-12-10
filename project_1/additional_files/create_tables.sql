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