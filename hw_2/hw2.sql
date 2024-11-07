CREATE TABLE student_courses (
	id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    UNIQUE (student_id, course_id)
);

CREATE TABLE group_courses (
	id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id),
    course_id INTEGER REFERENCES courses(id),
    UNIQUE (group_id, course_id)
);

-- Заполнение таблицы student_courses в соответствии с исходными данными hw1
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2), (2, 3),
(3, 2), (3, 4),
(4, 1), (4, 3), (4, 4),
(5, 1), (5, 3), (5, 4),
(6, 1), (6, 3), (6, 4);

-- Заполнение таблицы group_courses в соответствии с исходными данными hw1
INSERT INTO group_courses (group_id, course_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 2), (2, 4),
(3, 1), (3, 3), (3, 4);

ALTER TABLE students
DROP COLUMN courses_ids;

ALTER TABLE groups
DROP COLUMN students_ids;

ALTER TABLE courses
ADD CONSTRAINT unique_course_name UNIQUE (name);

/* Создание индекса на поле group_id в таблице students 
 Индексы помогают быстрее организовывать поиск по данным благодаря использованию эффективных
структур данных. Но занимают больше места, и медленнее при изменении данных */
CREATE INDEX idx_students_group_id ON students(group_id);

/* Написать запрос, который покажет список всех студентов с их курсами. */
SELECT s.id, first_name, last_name, c.name
FROM students s JOIN student_courses sc
ON s.id = sc.student_id
JOIN courses c
ON sc.course_id = c.id;

/* Найти студентов, у которых средняя оценка по курсам выше, чем у любого другого студента в их группе. */
WITH avg_grade_std AS
(SELECT student_id, s.first_name, s.last_name, group_id, AVG(grade) avg_grade
FROM (students s JOIN course_grades cg ON s.id = cg.student_id)
GROUP BY student_id, first_name, last_name, group_id)

SELECT student_id, first_name, last_name, ROUND(avg_grade,2) grade, group_id 
FROM (SELECT * FROM
		(SELECT MAX(avg_grade)
		FROM avg_grade_std ags 
		JOIN students s
		ON ags.student_id = s.id
		GROUP BY ags.group_id) max_grade 
	JOIN avg_grade_std ags
	ON max_grade.max = ags.avg_grade)

-- Подсчитать количество студентов на каждом курсе. --
SELECT course_id, COUNT(student_id) count_students
FROM student_courses
GROUP BY course_id
ORDER BY count_students DESC;

-- Найти среднюю оценку на каждом курсе. --
SELECT course_id, name, avg_grade
FROM 
(SELECT course_id, ROUND(AVG(grade), 2) avg_grade 
FROM course_grades
GROUP BY course_id) ag JOIN courses c
ON ag.course_id = c.id