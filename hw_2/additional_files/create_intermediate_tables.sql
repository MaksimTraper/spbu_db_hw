CREATE TABLE student_courses (
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE group_courses (
    group_id INTEGER REFERENCES groups(id),
    course_id INTEGER REFERENCES courses(id),
    PRIMARY KEY (group_id, course_id)
);
