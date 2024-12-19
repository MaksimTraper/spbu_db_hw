-- Создание таблицы для логирования
CREATE TABLE trigger_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50), -- Таблица, с которой взаимодействовали
    operation VARCHAR(50), -- Что делали
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Когда
    details TEXT, -- Детали (Что добавили, что удалили, что изменили)
	executed_by VARCHAR(50) -- Кто сделал (кого, если что, зарплаты лишать)
);

-- Универсальная триггерная функция
CREATE OR REPLACE FUNCTION universal_logging_trigger()
RETURNS TRIGGER AS $$
DECLARE
    operation_details TEXT;
BEGIN
    -- Исключаем таблицу логов из обработки, чтобы избежать рекурсии
    IF TG_TABLE_NAME = 'trigger_logs' THEN
        RETURN NULL;
    END IF;

    IF TG_OP = 'INSERT' THEN
        operation_details := 'Inserted record: ' || row_to_json(NEW)::TEXT;
    ELSIF TG_OP = 'UPDATE' THEN
        operation_details := 'Updated record: OLD=' || row_to_json(OLD)::TEXT || ', NEW=' || row_to_json(NEW)::TEXT;
    ELSIF TG_OP = 'DELETE' THEN
        operation_details := 'Deleted record: ' || row_to_json(OLD)::TEXT;
    END IF;

    INSERT INTO trigger_logs (table_name, operation, details, executed_by)
    VALUES (TG_TABLE_NAME, TG_OP, operation_details, SESSION_USER);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Далее логгирование для каждой таблицы "включаю" через psycopg2. Внутри additional_files есть скрипт
-- Сделал просто для того, чтобы не плодить одинаковый код

-- Для каждой новой таблицы будет автоматически включаться логгирование
CREATE OR REPLACE FUNCTION auto_add_trigger()
RETURNS event_trigger AS $$
DECLARE
    new_table_name TEXT;
BEGIN
    FOR new_table_name IN
        SELECT objid::regclass::text
        FROM pg_event_trigger_ddl_commands()
        WHERE command_tag = 'CREATE TABLE'
    LOOP
        EXECUTE format(
            'CREATE TRIGGER universal_%I_trigger AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION universal_logging_trigger();',
            new_table_name, new_table_name
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER add_trigger_on_new_table
ON ddl_command_end
WHEN TAG IN ('CREATE TABLE')
EXECUTE FUNCTION auto_add_trigger();


-- Вообще, есть внутреннее логгирование, PGAudit. Может это не лучший вариант). Хотя, такая табличка(-и), если их организовать правильно
-- могут являться дополнительным полезным инструментом отслеживания работы БД, что очень полезно (скорее всего, хорошо бы, как минимум
-- организовать логгирование в Hadoop (parquet) или Spark, чтобы бд не падала от возможного переизбытка логов)







-- Уведомление, что создан круговой маршрут, чтобы ошибок не возникло, если что
CREATE OR REPLACE FUNCTION check_route_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_point = NEW.end_point THEN
        RAISE NOTICE 'Создан круговой маршрут с ID: %, начальная и конечная точка: %', NEW.id, NEW.start_point;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_route_insert_check
BEFORE INSERT ON routes
FOR EACH ROW
EXECUTE FUNCTION check_route_data();


-- Функция и триггер логгирования действий по очистке таблиц в специально созданную служебную таблицу
-- и в журнал PostgreSQL
CREATE OR REPLACE FUNCTION log_truncate()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO truncate_logs (table_name, truncated_at)
    VALUES (tg_table_name, CURRENT_TIMESTAMP);

    RAISE NOTICE 'Table "%", was truncated at %', tg_table_name, CURRENT_TIMESTAMP;

    RETURN NULL; -- Триггер FOR EACH STATEMENT возвращает NULL
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_truncate_trigger
AFTER TRUNCATE ON sales
FOR EACH STATEMENT
EXECUTE FUNCTION log_truncate();


-- Автоматическое пополнение баланса транспортной карты при покупке:
CREATE OR REPLACE FUNCTION replenish_balance_after_purchase()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM transport_cards WHERE id = NEW.card_id) THEN
    	RAISE EXCEPTION 'Карта с ID % не найдена.', NEW.card_id;
	END IF;

	
    UPDATE transport_cards
    SET balance = balance + (NEW.price * NEW.amount)
    WHERE id = NEW.card_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_purchase_insert
AFTER INSERT ON purchases
FOR EACH ROW
EXECUTE FUNCTION replenish_balance_after_purchase();


-- Проверяем, чтобы пополнение карты не было отрицательным
-- Вообще такая проверка должна проводиться на бэкенде, но такой триггер, как
-- доп. проверка наверное ок (а может лишняя нагрузка, не знаю) )
CREATE OR REPLACE FUNCTION check_price_non_negative()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.price < 0 THEN
        RAISE EXCEPTION 'Цена (price) не может быть отрицательной: %', NEW.price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_purchase_insert_or_update
BEFORE INSERT OR UPDATE ON purchases
FOR EACH ROW
EXECUTE FUNCTION check_price_non_negative();



-- Запрет на удаление поездок
CREATE OR REPLACE FUNCTION prevent_trip_deletion()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Удаление записей из таблицы trips запрещено!';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_trip_delete
BEFORE DELETE ON trips
FOR EACH ROW
EXECUTE FUNCTION prevent_trip_deletion();




-- Создаём отдельное представление пользователей, где не будет доступна личная информация
-- о, например, паспортных данных
CREATE VIEW users_transports_cards AS
SELECT
	ua.name,
	ua.surname,
	ua.patronymic,
	ua.email,
	ua.birthday,
	tc.balance,
	tc.data_issue,
	tc.num_days
FROM user_accounts ua FULL OUTER JOIN transports_cards tc ON ua.id = tc.owner_id;

-- Запрещает всем пользователям просматривать user_accounts
REVOKE SELECT ON user_accounts FROM PUBLIC;
-- Разрешает просмотр через представление.
GRANT SELECT ON users_transports_cards TO PUBLIC;
	

-- Запрещаем смотреть user_accounts для предотвращения "диверсий" от злых сотрудников :)
CREATE OR REPLACE FUNCTION prevent_user_accounts_select()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Прямой просмотр таблицы user_accounts запрещён. Используйте представление users_transports_cards.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_user_accounts_select
BEFORE SELECT ON user_accounts
FOR EACH STATEMENT
EXECUTE FUNCTION prevent_user_accounts_select();

-- Ограничиваем таблицу на всех уровнях, в общем



-- Триггер на уменьшение баланса при удалении информации о транзакции
-- Допустим, произошла ситуация, когда есть необходимость вернуть деньги пользователю, а запись о покупке уже есть
-- Значит мы откатывает и транзакцию, и уменьшаем баланс
CREATE OR REPLACE FUNCTION adjust_balance_after_purchase_delete()
RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE 'Баланс карты % уменьшен на %', OLD.card_id, OLD.price*OLD.amount
    -- Уменьшаем баланс на транспортной карте
    UPDATE transport_cards
    SET balance = balance - OLD.price * OLD.amount
    WHERE id = OLD.card_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_purchase_delete
AFTER DELETE ON purchases
FOR EACH ROW
EXECUTE FUNCTION adjust_balance_after_purchase_delete();

-- Это дополнительный к прошлому триггер, что откатывать мы можем только последнюю транзакцию пользователя
-- А то удалив какую-нибудь старую транзакцию, может возникнуть недопонимания с балансом
CREATE OR REPLACE FUNCTION allow_delete_last_topup()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, является ли удаляемая запись последним пополнением пользователя
    IF OLD.id != (SELECT MAX(id) 
                  FROM purchases 
                  WHERE card_id = OLD.card_id) THEN
        RAISE EXCEPTION 'Удаление невозможно: можно удалить только последнее пополнение для карты %', OLD.card_id;
    END IF;

    -- Если проверка пройдена, разрешаем удаление
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_purchase_delete
BEFORE DELETE ON purchases
FOR EACH ROW
EXECUTE FUNCTION allow_delete_last_topup();


INSERT INTO purchases (card_id, price, amount) 
	VALUES (1, 10.5, 2); -- корректный случай
INSERT INTO purchases (card_id, price, amount) 
	VALUES (2, -10.5, 2); -- ошибка
INSERT INTO purchases (card_id, price, amount) 
	VALUES (999, 10.5, 2); -- ошибка, если card_id нет
SELECT * FROM user_accounts; -- ошибка