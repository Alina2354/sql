CREATE TABLE books (
	id SERIAL PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	author VARCHAR(255) NOT NULL,
	year INT
);


SELECT * FROM books;

INSERT INTO books (title, author, year) 
VALUES
('Война и мир', 'Толстой', 1869),
('Анна Каренина', 'Толстой', 1877),
('Элирм', 'Посмыгаев', 1877);


SELECT title, year
FROM books
WHERE author = 'Толстой';

