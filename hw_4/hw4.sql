-- Задание №1
-- Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры

-- Функция и триггер, обновляющий manager_id, если у самого менеджера сменился id
CREATE OR REPLACE FUNCTION update_emp_id()
RETURNS TRIGGER AS $$
BEGIN
	IF (OLD.employee_id != NEW.employee_id) THEN
		FOR EACH ROW
			IF (OLD.manager_id = OLD.employee_id) THEN
				NEW.manager_id = NEW.employee_id;
			END IF;
	END IF;
	RETURN NEW;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER update_emp_id_trigger
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_emp_id
-- P.S: у триггера есть проблема - при любом изменении ID (пусть это вцелом единичные случаи), будет проход
-- по n^2 строк, что при большом размере таблицы накладно. Лучше было бы это вынести в отдельную таблицу
-- В любой операции с узкими местами (FOR EACH ROW, любой проход по каждой строке, ...) можно ПОПРОБОВАТЬ
-- сделать ассинхронным средствами, допустим, Python, используя в SQL лишь уведомления (NOTIFY, LISTEN).
-- Но этим надо пользоваться ОЧЕНЬ осторожно, помня про уровни изоляции транзакций и различные ошибки обновления ...


	
-- Триггер проверки, существует ли указанный менеджер. Если нет, то выводится сообщение
-- об ошибке и транзакция откатывается
CREATE OR REPLACE FUNCTION check_exists_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.manager_id IS NOT NULL AND
        NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = NEW.manager_id)) THEN
        RAISE EXCEPTION 'Указанного менеджера не существует';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_exists_manager_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
WHEN (NEW.manager_id IS NOT NULL)
EXECUTE FUNCTION check_exists_manager();






-- Вновь работаем с менеджером. Если он вдруг "уходит" и удаляется из базы (плохой сценарий, лучше завести
-- доп. бинарную колонку - работает/не работает), то во избежание оказий, необходимо удалить его как менеджера
-- у других
CREATE OR REPLACE FUNCTION delete_manager_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Устанавливаем NULL для всех записей, где удалённый менеджер был указан
    UPDATE employees
    SET manager_id = NULL
    WHERE manager_id = OLD.employee_id;

    -- Возвращаем старую запись (для логов или других операций)
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER delete_manager_id_trigger
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION delete_manager_id




	
-- Создаём представление всех продаж работников
CREATE VIEW employee_sales AS
SELECT 
    e.employee_id,
    e.name AS employee_name,
    s.product_id,
    s.quantity,
    s.sale_date
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id;

-- Так мы позволяем условному пользователю работать непосредственно с созданным представлением
-- и если в него будут поданы новые данные (о продаже или о сотруднике), то эти данные будут добавлены
-- и в исходные таблицы
CREATE OR REPLACE FUNCTION insert_into_employee_sales()
RETURNS TRIGGER AS $$
BEGIN
    -- Вставляем сотрудника, если его нет
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = NEW.employee_id) THEN
		RAISE NOTICE 'В таблицу employees добавлен новый сотрудник % %', NEW.employee_id, NEW.name;
        INSERT INTO employees (employee_id, name) VALUES (NEW.employee_id, NEW.employee_name);
    END IF;

    -- Вставляем данные о продаже
    INSERT INTO sales (employee_id, product_id, quantity, sale_date)
    VALUES (NEW.employee_id, NEW.product_id, NEW.quantity, NEW.sale_date);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER instead_of_insert_trigger
INSTEAD OF INSERT ON employee_sales
FOR EACH ROW
EXECUTE FUNCTION insert_into_employee_sales();





-- Тут дополнительно выполняю задание №3
-- Попробовать использовать RAISE внутри триггеров для логирования

-- Таблица для хранения логов об очистке таблицы
CREATE TABLE truncate_logs (
    table_name TEXT,
    truncated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функция и триггер логгирования действий по очистке таблиц в специально созданную служебную таблицу
-- и в журнал PostgreSQL
CREATE OR REPLACE FUNCTION log_truncate()
RETURNS TRIGGER AS $$
BEGIN
    -- Логирование в таблицу
    INSERT INTO truncate_logs (table_name, truncated_at)
    VALUES (TG_TABLE_NAME, CURRENT_TIMESTAMP);

    -- Логирование в журнал PostgreSQL
    RAISE NOTICE 'Table "%", was truncated at %', TG_TABLE_NAME, CURRENT_TIMESTAMP;

    RETURN NULL; -- Триггер FOR EACH STATEMENT возвращает NULL
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_truncate_trigger
AFTER TRUNCATE ON sales
FOR EACH STATEMENT
EXECUTE FUNCTION log_truncate();







-- Представление для хранения метрик
CREATE VIEW sales_metrics AS
SELECT COUNT(*) AS total_sales
FROM sales;

-- Функция для обновления метрик продаж
CREATE OR REPLACE FUNCTION update_sales_metrics()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE sales_metrics
    SET total_sales = (SELECT COUNT(*) FROM sales);

    RETURN NULL; -- FOR EACH STATEMENT всегда возвращает NULL
END;
$$ LANGUAGE plpgsql;

-- Триггер на добавление строк в представление sales
CREATE TRIGGER after_insert_sales_trigger
AFTER INSERT ON sales
FOR EACH STATEMENT
EXECUTE FUNCTION update_sales_metrics();





-- Задание №2
-- Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)

-- Вставляем нового сотрудника
INSERT INTO employees (employee_id, name, position, department, salary, manager_id) 
VALUES (68, 'Ivan Petrov', 'Cleaner', 'Cleaning', 20000, NULL);
-- Транзакция выполнится успешно, ибо все ограничения по типам переменных, по уникальности ключей выполнены

-- Можно зафиксировать транзакцию
COMMIT;

-- Эта транзакция не пройдёт, ибо PK уже существует, а также не существует менеджера с ID 1000, так что сработает
-- созданный триггер
INSERT INTO employees (employee_id, name, position, department, salary, manager_id) 
VALUES (68, 'Ivan Petrov', 'Cleaner', 'Cleaning', 20000, 1000);

-- Ручной откат, хотя по идее откат происходит в Postgre автоматически (в том числе успешный INSERT)
ROLLBACK