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