-- Подсчитать количество студентов на каждом курсе. --
SELECT course_id, COUNT(student_id) count_students
FROM student_courses
GROUP BY course_id
ORDER BY count_students DESC
LIMIT 10;

-- Найти среднюю оценку на каждом курсе. --
SELECT course_id, name, avg_grade
FROM 
(SELECT course_id, ROUND(AVG(grade), 2) avg_grade 
FROM course_grades
GROUP BY course_id) ag JOIN courses c
ON ag.course_id = c.id
LIMIT 10