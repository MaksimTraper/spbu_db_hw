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