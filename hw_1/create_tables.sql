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