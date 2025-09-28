CREATE TABLE readers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);


CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE
);


CREATE TABLE borrowings (
    iid SERIAL PRIMARY KEY,
    reader_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (reader_id) REFERENCES readers(id) ON DELETE CASCADE, 
    FOREIGN KEY (book_id) REFERENCES books(id)
);


CREATE TABLE reader_cards (
    id SERIAL PRIMARY KEY,
    reader_id INT,
    card_number VARCHAR(50) UNIQUE NOT NULL,
    issue_date DATE NOT NULL,
    FOREIGN KEY (reader_id) REFERENCES readers(id) ON DELETE SET NULL 
);


CREATE TABLE fines (
    id SERIAL PRIMARY KEY,
    reader_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason TEXT,
    FOREIGN KEY (reader_id) REFERENCES readers(id) ON DELETE RESTRICT 
);


CREATE TABLE faculties (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dean VARCHAR(100)
);


CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    faculty_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    head VARCHAR(100),
    FOREIGN KEY (faculty_id) REFERENCES faculties(id) ON DELETE CASCADE 
);


CREATE TABLE professors (
    id SERIAL PRIMARY KEY,
    department_id INT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL 
);


CREATE TABLE research_projects (
    id SERIAL PRIMARY KEY,
    professor_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    budget DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (professor_id) REFERENCES professors(id) ON DELETE RESTRICT 
);


CREATE TABLE publications (
    id SERIAL PRIMARY KEY,
    professor_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    journal VARCHAR(255),
    FOREIGN KEY (professor_id) REFERENCES professors(id) ON DELETE CASCADE
);


