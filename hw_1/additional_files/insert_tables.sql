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