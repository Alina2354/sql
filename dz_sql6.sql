CREATE TABLE students (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(100) UNIQUE,
 faculty VARCHAR(50),
 year_of_study INTEGER,
 gpa DECIMAL(3,2),
 enrollment_date TIMESTAMP DEFAULT NOW(),
 is_active BOOLEAN DEFAULT true
 );
 
 CREATE TABLE courses (
 id SERIAL PRIMARY KEY,
 name VARCHAR(200) NOT NULL,
 faculty VARCHAR(50),
 credits INTEGER,
 difficulty_level VARCHAR(20),
 max_students INTEGER
 );
 
 CREATE TABLE enrollments (
 id SERIAL PRIMARY KEY,
 student_id INTEGER REFERENCES students(id),
 course_id INTEGER REFERENCES courses(id),
 enrollment_date TIMESTAMP DEFAULT NOW(),
 grade DECIMAL(3,2),
 status VARCHAR(20) DEFAULT 'enrolled'
 );
 
 CREATE TABLE grades (
 id SERIAL PRIMARY KEY,
 enrollment_id INTEGER REFERENCES enrollments(id),
 assignment_type VARCHAR(30),
 score DECIMAL(5,2),
 submission_date TIMESTAMP DEFAULT NOW()
 );
 
 INSERT INTO students (name, email, faculty, year_of_study, gpa, enrollment_date, is_active)
 SELECT 
'Студент_' || g,
 'student_' || g || '@university.edu',
 CASE WHEN g % 6 = 0 THEN 'Информатика'
 WHEN g % 6 = 1 THEN 'Экономика'
 WHEN g % 6 = 2 THEN 'Медицина'
 WHEN g % 6 = 3 THEN 'Юриспруденция'
 WHEN g % 6 = 4 THEN 'Физика'
 ELSE 'Химия' END,
 1 + (g % 4),
 (random() * 2 + 2)::decimal(3,2),
 NOW() - (random() * INTERVAL '1460 days'),
 CASE WHEN g % 20 = 0 THEN false ELSE true END
 FROM generate_series(1, 15000) AS g;-- 500 курсов
 INSERT INTO courses (name, faculty, credits, difficulty_level, max_students)
 SELECT 
'Курс_' || g || '_' || 
CASE WHEN g % 5 = 0 THEN 'Базовый'
 WHEN g % 5 = 1 THEN 'Продвинутый'
 WHEN g % 5 = 2 THEN 'Специализированный'
 WHEN g % 5 = 3 THEN 'Мастер-класс'
 ELSE 'Семинар' END,
 CASE WHEN g % 6 = 0 THEN 'Информатика'
 WHEN g % 6 = 1 THEN 'Экономика'
 WHEN g % 6 = 2 THEN 'Медицина'
 WHEN g % 6 = 3 THEN 'Юриспруденция'
 WHEN g % 6 = 4 THEN 'Физика'
 ELSE 'Химия' END,
 2 + (g % 4),
 CASE WHEN g % 3 = 0 THEN 'Легкий'
 WHEN g % 3 = 1 THEN 'Средний'
 ELSE 'Сложный' END,
 20 + (g % 30)
 FROM generate_series(1, 500) AS g;-- 100,000 записей на курсы
 INSERT INTO enrollments (student_id, course_id, enrollment_date, grade, status)
 SELECT 
(SELECT id FROM students ORDER BY random() LIMIT 1),
 (SELECT id FROM courses ORDER BY random() LIMIT 1),
 NOW() - (random() * INTERVAL '730 days'),
 CASE WHEN random() > 0.1 THEN (random() * 3 + 2)::decimal(3,2) ELSE NULL END,
 CASE WHEN random() > 0.05 THEN 'completed' 
WHEN random() > 0.5 THEN 'dropped' 
ELSE 'enrolled' END
 FROM generate_series(1, 100000) AS g;-- 300,000 оценок
 INSERT INTO grades (enrollment_id, assignment_type, score, submission_date)
 SELECT 
(SELECT id FROM enrollments ORDER BY random() LIMIT 1),
 CASE WHEN g % 4 = 0 THEN 'Домашнее задание'
 WHEN g % 4 = 1 THEN 'Экзамен'
WHEN g % 4 = 2 THEN 'Курсовая работа'
 ELSE 'Тест' END,
 (random() * 100)::decimal(5,2),
 NOW() - (random() * INTERVAL '365 days')
 FROM generate_series(1, 300000) AS g;

-- Составной индекс для студентов по факультету и году обучения
 CREATE INDEX idx_students_faculty_year ON students(faculty, year_of_study);-- Частичный индекс только для активных студентов
 CREATE INDEX idx_students_active_gpa ON students(gpa) WHERE is_active = true;-- Составной индекс для курсов
 CREATE INDEX idx_courses_faculty_difficulty ON courses(faculty, difficulty_level);-- Составной индекс для записей на курсы
 CREATE INDEX idx_enrollments_student_status ON enrollments(student_id, status);-- Частичный индекс только для завершенных курсов
 CREATE INDEX idx_enrollments_completed_grade ON enrollments(grade) WHERE status = 'completed';-- Индекс для оценок по типу задания
 CREATE INDEX idx_grades_type_score ON grades(assignment_type, score);

  EXPLAIN (ANALYZE, BUFFERS) 
SELECT faculty, name, gpa, year_of_study
 FROM students 
WHERE is_active = true
 ORDER BY faculty, gpa DESC, year_of_study;-- Запрос 2: Статистика по курсам
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT c.faculty, c.difficulty_level, 
COUNT(e.id) as enrollments,
 AVG(e.grade) as avg_grade
 FROM courses c 
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'completed'
 GROUP BY c.faculty, c.difficulty_level
 ORDER BY c.faculty, c.difficulty_level;-- Запрос 3: Анализ успеваемости
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT s.faculty, s.year_of_study,
 COUNT(e.id) as total_enrollments,
 COUNT(CASE WHEN e.grade >= 4.0 THEN 1 END) as good_grades,
 AVG(e.grade) as avg_grade
 FROM students s 
JOIN enrollments e ON s.id = e.student_id
 WHERE e.status = 'completed' AND s.is_active = true
GROUP BY s.faculty, s.year_of_study
 ORDER BY s.faculty, s.year_of_study;





CREATE TABLE users (
 id SERIAL PRIMARY KEY,
 username VARCHAR(50) UNIQUE NOT NULL,
 email VARCHAR(100),
 role VARCHAR(20),
 created_at TIMESTAMP DEFAULT NOW()
 );
 CREATE TABLE events (
 id SERIAL PRIMARY KEY,
 user_id INTEGER REFERENCES users(id),
 event_type VARCHAR(50),
 description TEXT,
 ip_address INET,
 user_agent TEXT,
 created_at TIMESTAMP DEFAULT NOW()
 );
 
 CREATE TABLE sessions (
 id SERIAL PRIMARY KEY,
 user_id INTEGER REFERENCES users(id),
 session_token VARCHAR(100) UNIQUE,
 started_at TIMESTAMP DEFAULT NOW(),
 ended_at TIMESTAMP,
 is_active BOOLEAN DEFAULT true
 );
 
 CREATE TABLE errors (
 id SERIAL PRIMARY KEY,
 error_type VARCHAR(50),
 message TEXT,
 stack_trace TEXT,
 user_id INTEGER REFERENCES users(id),
 created_at TIMESTAMP DEFAULT NOW(),
 severity VARCHAR(20)
 );

 INSERT INTO users (username, email, role, created_at)
 SELECT 
'user_' || g,
 'user_' || g || '@app.com',
 CASE WHEN g % 10 = 0 THEN 'admin'
 WHEN g % 10 = 1 THEN 'moderator'
 ELSE 'user' END,
NOW() - (random() * INTERVAL '365 days')
 FROM generate_series(1, 5000) AS g;-- 500,000 событий
 INSERT INTO events (user_id, event_type, description, ip_address, user_agent, created_at)
 SELECT 
(SELECT id FROM users ORDER BY random() LIMIT 1),
 CASE WHEN g % 8 = 0 THEN 'login'
 WHEN g % 8 = 1 THEN 'logout'
 WHEN g % 8 = 2 THEN 'page_view'
 WHEN g % 8 = 3 THEN 'search'
 WHEN g % 8 = 4 THEN 'download'
 WHEN g % 8 = 5 THEN 'upload'
 WHEN g % 8 = 6 THEN 'comment'
 ELSE 'like' END,
 'Описание события ' || g,
 '192.168.' || (g % 255) || '.' || (g % 255)::text,
 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/' || g,
 NOW() - (random() * INTERVAL '30 days')
 FROM generate_series(1, 500000) AS g;-- 50,000 сессий
 INSERT INTO sessions (user_id, session_token, started_at, ended_at, is_active)
 SELECT 
(SELECT id FROM users ORDER BY random() LIMIT 1),
 'token_' || g || '_' || (random() * 1000000)::integer,
 NOW() - (random() * INTERVAL '30 days'),
 CASE WHEN random() > 0.3 THEN NOW() - (random() * INTERVAL '24 hours') ELSE NULL END,
 CASE WHEN random() > 0.3 THEN false ELSE true END
 FROM generate_series(1, 50000) AS g;-- 10,000 ошибок
 INSERT INTO errors (error_type, message, stack_trace, user_id, created_at, severity)
 SELECT 
CASE WHEN g % 5 = 0 THEN 'DatabaseError'
 WHEN g % 5 = 1 THEN 'ValidationError'
 WHEN g % 5 = 2 THEN 'AuthenticationError'
 WHEN g % 5 = 3 THEN 'PermissionError'
 ELSE 'SystemError' END,
 'Ошибка ' || g || ': ' || CASE WHEN g % 3 = 0 THEN 'Неверные данные'
 WHEN g % 3 = 1 THEN 'Соединение потеряно'
 ELSE 'Таймаут операции' END,
 'Stack trace для ошибки ' || g,
 CASE WHEN g % 10 = 0 THEN NULL ELSE (SELECT id FROM users ORDER BY random() LIMIT 1) END,
 NOW() - (random() * INTERVAL '30 days'),
 CASE WHEN g % 10 = 0 THEN 'critical'
 WHEN g % 10 = 1 THEN 'error'
 WHEN g % 10 = 2 THEN 'warning'
 ELSE 'info' END
 FROM generate_series(1, 10000) AS g;


 -- Индекс по времени создания событий
 CREATE INDEX idx_events_created_at ON events(created_at);-- Частичный индекс для критических ошибок
CREATE INDEX idx_errors_critical ON errors(created_at) WHERE severity = 'critical';-- Составной индекс для событий пользователя
 CREATE INDEX idx_events_user_time ON events(user_id, created_at);-- Индекс для активных сессий
 CREATE INDEX idx_sessions_active ON sessions(started_at) WHERE is_active = true;



 -- Запрос 1: События за последние 24 часа
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT event_type, COUNT(*) as count
 FROM events 
WHERE created_at >= NOW() - INTERVAL '24 hours'
 GROUP BY event_type
 ORDER BY count DESC;-- Запрос 2: Активные пользователи за неделю
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT u.username, COUNT(e.id) as events_count
 FROM users u 
JOIN events e ON u.id = e.user_id
 WHERE e.created_at >= NOW() - INTERVAL '7 days'
 GROUP BY u.id, u.username
 HAVING COUNT(e.id) > 10
 ORDER BY events_count DESC
 LIMIT 50;-- Запрос 3: Критические ошибки по дням
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT DATE(created_at) as error_date,
 COUNT(*) as critical_errors
 FROM errors 
WHERE severity = 'critical' 
AND created_at >= NOW() - INTERVAL '30 days'
 GROUP BY DATE(created_at)
 ORDER BY error_date DESC