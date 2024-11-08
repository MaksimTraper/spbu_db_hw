CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    is_exam BOOLEAN NOT NULL,
    min_grade INTEGER,
    max_grade INTEGER
);

CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    students_ids INTEGER[]
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    group_id INTEGER REFERENCES groups(id),
    courses_ids INTEGER[]
);

CREATE TABLE course_grades (
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    grade INTEGER,
    grade_str VARCHAR(20)
);

--Проверка в таблице course_grades вхождения grade студента в диапазон [min_grade;max_grade] course--
CREATE OR REPLACE FUNCTION validate_grade()
RETURNS TRIGGER AS $$
DECLARE
    course_min_grade INTEGER;
    course_max_grade INTEGER;
BEGIN
    SELECT min_grade, max_grade INTO course_min_grade, course_max_grade
    FROM courses
    WHERE id = NEW.course_id;

    IF NEW.grade < course_min_grade OR NEW.grade > course_max_grade THEN
        RAISE EXCEPTION 'Оценка % выходит из диапазона оценок курса ID % (должен быть между % и %)',
            NEW.grade, NEW.course_id, course_min_grade, course_max_grade;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_grade_trigger
BEFORE INSERT OR UPDATE ON course_grades
FOR EACH ROW
EXECUTE FUNCTION validate_grade();

INSERT INTO courses (name, is_exam, min_grade, max_grade)
VALUES
('Mathematics', TRUE, 60, 100),
('Physics', TRUE, 40, 100),
('Chemistry', TRUE, 50, 100),
('History', FALSE, 40, 100);

INSERT INTO groups (full_name, short_name, students_ids)
VALUES
('Искусственный интеллект и наука о данных', 'ИИНоД', ARRAY[1, 2, 3]),
('Программная инженерия', 'ПИ', ARRAY[4]),
('Физика', 'ФЗ', ARRAY[5, 6]),
('Международный бизнес', 'МБ', NULL);

INSERT INTO students (first_name, last_name, group_id, courses_ids)
VALUES
('Максим', 'Трапер', 1, ARRAY[1, 2]),
('Михаил', 'Минаев', 1, ARRAY[1, 2, 3]),
('Всеволод', 'Битепаж', 2, ARRAY[2, 4]),
('Александра', 'Решетникова', 3, ARRAY[1, 3, 4]),
('Георгий', 'Пономарёв', 3, ARRAY[1, 3, 4]),
('Артём', 'Пышный', 3, ARRAY[1, 3, 4]);

INSERT INTO course_grades (student_id, course_id, grade, grade_str)
VALUES
(1, 1, 85, 'отлично'),
(2, 3, 75, 'хорошо'),
(3, 2, 65, 'удовлетворительно'),
(2, 2, 55, 'удовлетворительно'),
(4, 2, 80, 'хорошо'),
(4, 1, 90, 'отлично');

-- Максимальное количество человек в одной группе --
SELECT MAX(array_length(students_ids, 1)) AS student_count 
FROM groups;

-- Аналогичный верхнему запрос по подсчёту количества студентов в группе --
-- но с применением не только агрегации, но и группировки --
SELECT group_id, COUNT(id)
FROM students
GROUP BY group_id
ORDER BY group_id ASC;

-- Выводим только "отлично" --
SELECT *
FROM course_grades
WHERE grade_str='отлично';

-- Выводим средний балл каждого студента --
SELECT student_id, ROUND(AVG(grade), 0)
FROM course_grades
GROUP BY student_id;

-- Выводим курсы, заканчивающиеся на 'cs' --
SELECT *
FROM courses
WHERE name LIKE '%cs'