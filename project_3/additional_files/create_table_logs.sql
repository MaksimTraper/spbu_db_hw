-- Создание таблицы для логирования
CREATE TABLE trigger_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50), -- Таблица, с которой взаимодействовали
    operation VARCHAR(50), -- Что делали
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Когда
    details TEXT, -- Детали (Что добавили, что удалили, что изменили)
	executed_by VARCHAR(50) -- Кто сделал (кого, если что, зарплаты лишать)
);