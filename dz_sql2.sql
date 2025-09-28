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