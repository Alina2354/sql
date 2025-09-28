CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    passport_issue_date DATE
);


CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2)
);


CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);


INSERT INTO students (student_name, city, passport_issue_date) VALUES
('Alice Smith', 'Moscow', '2023-05-10'),
('Bob Johnson', 'Saint Petersburg', '2023-02-15'),
('Charlie Brown', 'Moscow', '2023-03-20'),
('David Williams', 'Moscow', '2023-04-01'),
('Eve Davis', 'Kazan', '2024-01-05');


INSERT INTO courses (course_name, price) VALUES
('Mathematics 101', 15000.00),
('History 201', 22000.00),
('Computer Science 301', 28000.00),
('Physics 101', 18000.00),
('English Literature 101', 12000.00);


INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2023-06-01', 90),
(1, 2, '2023-05-25', 85),  
(2, 1, '2023-03-10', 78),   
(2, 3, '2023-04-05', 92),
(3, 2, '2023-04-01', NULL),
(3, 3, '2023-03-15', 88),   
(4, 1, '2023-05-05', 95),   
(5, 4, '2024-02-10', 70),
(5, 5, '2024-01-20', 80);

SELECT c.course_name, MIN(e.grade) AS min_grade, MAX(e.grade) AS max_grade
FROM courses c
JOIN enrollments e ON c.id = e.course_id
WHERE e.grade IS NOT NULL
GROUP BY c.course_name
HAVING COUNT(e.grade) > 0;

SELECT s.student_name
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.enrollment_date >= '2024-02-01' AND e.enrollment_date < '2024-03-01';

SELECT
    EXTRACT(MONTH FROM e.enrollment_date) AS month,
    COUNT(*) AS enrollment_count
FROM
    enrollments e
GROUP BY
    EXTRACT(MONTH FROM e.enrollment_date)
ORDER BY
    EXTRACT(MONTH FROM e.enrollment_date);

SELECT c.course_name
FROM courses c
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    WHERE e.course_id = c.id AND s.city <> 'Moscow'
);

SELECT s.student_name
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE EXTRACT(MONTH FROM s.passport_issue_date) = EXTRACT(MONTH FROM e.enrollment_date)
  AND EXTRACT(YEAR FROM s.passport_issue_date) = EXTRACT(YEAR FROM e.enrollment_date);

SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.course_name
ORDER BY student_count DESC
LIMIT 3;

WITH RankedEnrollments AS (
    SELECT
        e.student_id,
        c.course_name,
        c.price,
        ROW_NUMBER() OVER (PARTITION BY e.student_id ORDER BY c.price DESC) AS rank
    FROM
        enrollments e
    JOIN
        courses c ON e.course_id = c.id
)
SELECT
    s.student_name,
    re.course_name,
    re.price
FROM
    RankedEnrollments re
JOIN
    students s ON re.student_id = s.id
WHERE
    re.rank = 1;

SELECT s.student_name
FROM students s
WHERE NOT EXISTS (
    SELECT 1
    FROM courses c
    WHERE c.price > 20000
      AND NOT EXISTS (
          SELECT 1
          FROM enrollments e
          WHERE e.student_id = s.id AND e.course_id = c.id
      )
);

SELECT s.city, AVG(e.grade) AS average_grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.grade IS NOT NULL
GROUP BY s.city;

SELECT s.student_name
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.enrollment_date BETWEEN s.passport_issue_date AND s.passport_issue_date + INTERVAL '7 days';


