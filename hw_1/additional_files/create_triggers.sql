--Проверка в таблице course_grades вхождения grade студента в диапазон [min_grade;max_grade] course--
CREATE OR REPLACE FUNCTION validate_grade()
RETURNS TRIGGER AS $$
DECLARE
    course_min_grade INTEGER;
    course_max_grade INTEGER;
BEGIN
    SELECT min_grade, max_grade INTO course_min_grade, course_max_grade
    FROM courses
    WHERE id = NEW.course_id;

    IF NEW.grade < course_min_grade OR NEW.grade > course_max_grade THEN
        RAISE EXCEPTION 'Оценка % выходит из диапазона оценок курса ID % (должен быть между % и %)',
            NEW.grade, NEW.course_id, course_min_grade, course_max_grade;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_grade_trigger
BEFORE INSERT OR UPDATE ON course_grades
FOR EACH ROW
EXECUTE FUNCTION validate_grade();



--Проверка существования courses, указанных в courses_ids в строках таблицы students--
CREATE OR REPLACE FUNCTION clean_nonexistent_courses()
RETURNS TRIGGER AS $$
DECLARE
    valid_courses INTEGER[];
    course_id INTEGER;
BEGIN
	IF NEW.courses_ids IS NULL OR array_length(NEW.courses_ids, 1) = 0 THEN
		RETURN NEW;
	END IF;
	
    valid_courses := '{}';

    FOREACH course_id IN ARRAY NEW.courses_ids
    LOOP
        IF EXISTS (SELECT 1 FROM courses WHERE id = course_id) THEN
            valid_courses := array_append(valid_courses, course_id);
        ELSE
            RAISE NOTICE 'Курса с ID % не существует в таблице courses и будет удален из массива courses_ids', course_id;
        END IF;
    END LOOP;

	IF array_length(valid_courses, 1) > 0 THEN
    	NEW.courses_ids := valid_courses;
	ELSE
		NEW.courses_ids := NULL;
	END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_nonexistent_students_trigger
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
EXECUTE FUNCTION clean_nonexistent_courses();


--Проверка существования student, указанных в students_ids в строках таблицы groups--
CREATE OR REPLACE FUNCTION clean_nonexistent_students()
RETURNS TRIGGER AS $$
DECLARE
    valid_students INTEGER[];
    student_id INTEGER;
BEGIN
	IF NEW.students_ids IS NULL OR array_length(NEW.students_ids, 1) = 0 THEN
		RETURN NEW;
	END IF;
	
    valid_students := '{}';

    FOREACH student_id IN ARRAY NEW.students_ids
    LOOP
        IF EXISTS (SELECT 1 FROM students WHERE id = student_id) THEN
            valid_students := array_append(valid_students, student_id);
        ELSE
            RAISE NOTICE 'Студента с ID % не существует в таблице students и будет удален из массива students_ids', student_id;
        END IF;
    END LOOP;

	IF array_length(valid_students, 1) > 0 THEN
    	NEW.students_ids := valid_students;
	ELSE
		NEW.students_ids := NULL;
	END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_nonexistent_students_trigger
BEFORE INSERT OR UPDATE ON groups
FOR EACH ROW
EXECUTE FUNCTION clean_nonexistent_students();