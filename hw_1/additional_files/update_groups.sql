UPDATE groups SET students_ids = ARRAY[1, 2, 3] WHERE full_name = 'Искусственный интеллект и наука о данных';
UPDATE groups SET students_ids = ARRAY[4] WHERE full_name = 'Программная инженерия';
UPDATE groups SET students_ids = ARRAY[5,6] WHERE full_name = 'Физика';