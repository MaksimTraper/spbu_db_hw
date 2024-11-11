/* Если честно, я не уверен в необходимости создавать в данных таблицах PK - id.
Мне кажется, можно было бы оставить в каждой таблице по два поля и сделать составные ключи.
Просто потому что при обращении к таблицам, мы не будем использовать ID.*/

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