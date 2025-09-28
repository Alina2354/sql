CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL 
);


CREATE TABLE profiles (
  id SERIAL PRIMARY KEY,
  user_id INT UNIQUE NOT NULL, 
  email VARCHAR(100) NOT NULL,
  full_name VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES users(id)
);



INSERT INTO users (username, password) VALUES
('john_doe', 'password123'),
('jane_smith', 'secure_pass'),
('peter_jones', 'another_pass');


INSERT INTO profiles (user_id, email, full_name) VALUES
(1, 'john.doe@example.com', 'John Doe'),
(2, 'jane.smith@example.com', 'Jane Smith'),
(3, 'peter.jones@example.com', 'Peter Jones');



SELECT u.username, p.email
FROM users u
JOIN profiles p ON u.id = p.user_id;


CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  author_name VARCHAR(100) NOT NULL
);


CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author_id INT NOT NULL,
  FOREIGN KEY (author_id) REFERENCES authors(id)
);


INSERT INTO authors (author_name) VALUES
('Jane Austen'),
('Lev Tolstoy');

INSERT INTO books (title, author_id) VALUES
('Pride and Prejudice', 1),
('Sense and Sensibility', 1),
('Emma', 1),
('War and Peace', 2),
('Anna Karenina', 2);



SELECT b.title
FROM books b
JOIN authors a ON b.author_id = a.id
WHERE a.author_name = 'Jane Austen';  


CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL
);


CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  course_name VARCHAR(100) NOT NULL
);


CREATE TABLE enrollments (
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  PRIMARY KEY (student_id, course_id), 
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);


INSERT INTO students (student_name) VALUES
('Alice Smith'),
('Bob Johnson'),
('Charlie Brown');


INSERT INTO courses (course_name) VALUES
('Mathematics 101'),
('History 201'),
('Computer Science 301');


INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), 
(1, 2), 
(2, 1), 
(2, 3), 
(3, 2), 
(3, 3); 

SELECT s.student_name, string_agg(c.course_name, ', ' ORDER BY c.course_name) AS courses
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
GROUP BY s.student_name;
