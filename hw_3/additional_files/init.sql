-- Создание таблицы сотрудников employees
-- Эта таблица хранит данные о сотрудниках:
-- идентификатор,
-- имя,
-- должность,
-- отдел,
-- зарплату и идентификатор руководителя.

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);;

SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);