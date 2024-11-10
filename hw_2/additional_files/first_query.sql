/* Написать запрос, который покажет список всех студентов с их курсами. */
SELECT s.id, first_name, last_name, c.name
FROM students s JOIN student_courses sc
ON s.id = sc.student_id
JOIN courses c
ON sc.course_id = c.id;
LIMIT 10

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
LIMIT 10