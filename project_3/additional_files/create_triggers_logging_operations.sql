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


-- Далее логгирование для каждой таблицы "включаю" через psycopg2

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