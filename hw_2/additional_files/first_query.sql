/* Написать запрос, который покажет список всех студентов с их курсами. */
SELECT s.id, first_name, last_name, c.name
FROM students s JOIN student_courses sc
ON s.id = sc.student_id
JOIN courses c
ON sc.course_id = c.id;
LIMIT 10

/* Найти студентов, у которых средняя оценка по курсам выше, чем у любого другого студента в их группе.
P.S: надеюсь, ворох CTE - не проблема. По идее, как я читал, это обычно способствует 
повышению производительности + запросы становятся более читаемыми */

WITH avg_grade_std AS (
SELECT s.first_name, s.last_name, s.group_id, s.id student_id, AVG(cg.grade) AS avg_grade
FROM students s
JOIN course_grades cg ON s.id = cg.student_id
GROUP BY s.id, s.first_name, s.last_name, s.group_id),
	
max_avg_grade_std AS (
SELECT group_id, MAX(avg_grade) AS max_avg_grade
FROM avg_grade_std
GROUP BY group_id),
	
top_students AS (
SELECT ags.student_id, ags.first_name, ags.last_name, ags.group_id, ags.avg_grade
FROM avg_grade_std AS ags
JOIN max_avg_grade_std AS mags 
ON ags.group_id = mags.group_id AND ags.avg_grade = mags.max_avg_grade)

SELECT *
FROM top_students
GROUP BY group_id, student_id, first_name, last_name, avg_grade
HAVING COUNT(student_id) = 1
LIMIT 10;