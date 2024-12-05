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