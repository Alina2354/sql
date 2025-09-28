 CREATE TABLE readers (
 id SERIAL PRIMARY KEY,
 name VARCHAR(50) NOT NULL,
 email VARCHAR(100) UNIQUE,
 city VARCHAR(30),
 registration_date TIMESTAMP DEFAULT NOW(),
 is_active BOOLEAN DEFAULT true
 );
 CREATE TABLE books (
 id SERIAL PRIMARY KEY,
 title VARCHAR(200) NOT NULL,
 author VARCHAR(100),
 category VARCHAR(50),
 isbn VARCHAR(20),
 published_year INTEGER,
 price DECIMAL(10,2)
 );
 CREATE TABLE borrowings (
 id SERIAL PRIMARY KEY,
 reader_id INTEGER REFERENCES readers(id),
 book_id INTEGER REFERENCES books(id),
 borrow_date TIMESTAMP DEFAULT NOW(),
 return_date TIMESTAMP,
 status VARCHAR(20) DEFAULT 'borrowed'
 );

  INSERT INTO readers (name, email, city, registration_date, is_active)
 SELECT 
'Читатель_' || g,
 'reader_' || g || '@library.com',
 CASE WHEN g % 5 = 0 THEN 'Москва'
 WHEN g % 5 = 1 THEN 'СПб'
 WHEN g % 5 = 2 THEN 'Новосибирск'
 WHEN g % 5 = 3 THEN 'Екатеринбург'
 ELSE 'Казань' END,
 NOW() - (random() * INTERVAL '365 days'),
CASE WHEN g % 10 = 0 THEN false ELSE true END
 FROM generate_series(1, 10000) AS g;-- 5,000 книг
 INSERT INTO books (title, author, category, isbn, published_year, price)
 SELECT 
'Книга_' || g || '_' || 
CASE WHEN g % 4 = 0 THEN 'Роман'
 WHEN g % 4 = 1 THEN 'Детектив'
 WHEN g % 4 = 2 THEN 'Фантастика'
 ELSE 'Учебник' END,
 'Автор_' || (g % 100),
 CASE WHEN g % 4 = 0 THEN 'Художественная'
 WHEN g % 4 = 1 THEN 'Детектив'
 WHEN g % 4 = 2 THEN 'Фантастика'
 ELSE 'Учебная' END,
 'ISBN-' || g,
 1990 + (g % 34),
 (random() * 2000 + 100)::decimal(10,2)
 FROM generate_series(1, 5000) AS g;-- 50,000 выдач
 INSERT INTO borrowings (reader_id, book_id, borrow_date, return_date, status)
 SELECT 
(SELECT id FROM readers ORDER BY random() LIMIT 1),
 (SELECT id FROM books ORDER BY random() LIMIT 1),
 NOW() - (random() * INTERVAL '365 days'),
 CASE WHEN random() > 0.3 THEN NOW() - (random() * INTERVAL '30 days') ELSE NULL END,
 CASE WHEN random() > 0.3 THEN 'returned' ELSE 'borrowed' END
 FROM generate_series(1, 50000) AS g;


 -- Запрос 1: Читатели по городу
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM readers WHERE city = 'Москва';-- Запрос 2: Книги по категории
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM books WHERE category = 'Художественная';-- Запрос 3: Активные выдачи
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT r.name, b.title, br.borrow_date
 FROM readers r 
JOIN borrowings br ON r.id = br.reader_id
 JOIN books b ON br.book_id = b.id
 WHERE br.status = 'borrowed'
 ORDER BY br.borrow_date DESC
 LIMIT 100;

 CREATE INDEX idx_readers_city ON readers(city);
 CREATE INDEX idx_readers_active ON readers(is_active) WHERE is_active = true;
 CREATE INDEX idx_books_category ON books(category);
 CREATE INDEX idx_books_author ON books(author);
 CREATE INDEX idx_borrowings_reader ON borrowings(reader_id);
 CREATE INDEX idx_borrowings_status ON borrowings(status);
 CREATE INDEX idx_borrowings_date ON borrowings(borrow_date);



 CREATE TABLE customers (
 id SERIAL PRIMARY KEY,
 name VARCHAR(50) NOT NULL,
 email VARCHAR(100),
 city VARCHAR(30),
 registration_date TIMESTAMP DEFAULT NOW(),
 total_purchases DECIMAL(10,2) DEFAULT 0
 );
 CREATE TABLE categories (
 id SERIAL PRIMARY KEY,
 name VARCHAR(50) NOT NULL,
 description TEXT
 );
 CREATE TABLE items (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 category_id INTEGER REFERENCES categories(id),
 price DECIMAL(10,2),
 stock_quantity INTEGER,
 created_at TIMESTAMP DEFAULT NOW()
 );
 CREATE TABLE sales (
 id SERIAL PRIMARY KEY,
 customer_id INTEGER REFERENCES customers(id),
 item_id INTEGER REFERENCES items(id),
 quantity INTEGER,
 price DECIMAL(10,2),
 sale_date TIMESTAMP DEFAULT NOW()
 );


 -- 5 категорий
 INSERT INTO categories (name, description) VALUES
('Электроника', 'Электронные устройства'),
 ('Одежда', 'Мужская и женская одежда'),
 ('Книги', 'Художественная и учебная литература'),
 ('Спорт', 'Спортивные товары'),
 ('Дом', 'Товары для дома');-- 8,000 клиентов
 INSERT INTO customers (name, email, city, registration_date)
 SELECT 
'Клиент_' || g,
 'customer_' || g || '@shop.com',
 CASE WHEN g % 4 = 0 THEN 'Москва'
 WHEN g % 4 = 1 THEN 'СПб'
 WHEN g % 4 = 2 THEN 'Новосибирск'
 ELSE 'Екатеринбург' END,
 NOW() - (random() * INTERVAL '730 days')
 FROM generate_series(1, 8000) AS g;-- 3,000 товаров
 INSERT INTO items (name, category_id, price, stock_quantity, created_at)
 SELECT 
'Товар_' || g || '_' || 
CASE WHEN g % 5 = 0 THEN 'Премиум'
 WHEN g % 5 = 1 THEN 'Стандарт'
 WHEN g % 5 = 2 THEN 'Бюджет'
 WHEN g % 5 = 3 THEN 'Эксклюзив'
 ELSE 'Обычный' END,
 (g % 5) + 1,
 (random() * 5000 + 100)::decimal(10,2),
 (random() * 100)::integer,
 NOW() - (random() * INTERVAL '365 days')
 FROM generate_series(1, 3000) AS g;-- 100,000 продаж
 INSERT INTO sales (customer_id, item_id, quantity, price, sale_date)
 SELECT 
(SELECT id FROM customers ORDER BY random() LIMIT 1),
 (SELECT id FROM items ORDER BY random() LIMIT 1),
 (random() * 5 + 1)::integer,
 (random() * 2000 + 50)::decimal(10,2),
 NOW() - (random() * INTERVAL '365 days')
 FROM generate_series(1, 100000) AS g;



 -- Запрос 1: Топ клиентов по покупкам
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT c.name, COUNT(s.id) as purchases, SUM(s.price * s.quantity) as total_spent
 FROM customers c 
JOIN sales s ON c.id = s.customer_id
 GROUP BY c.id, c.name
 ORDER BY total_spent DESC
 LIMIT 20;-- Запрос 2: Продажи по категориям
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT cat.name, COUNT(s.id) as sales_count, AVG(s.price) as avg_price
FROM categories cat 
JOIN items i ON cat.id = i.category_id
 JOIN sales s ON i.id = s.item_id
 GROUP BY cat.id, cat.name
 ORDER BY sales_count DESC;-- Запрос 3: Товары с низким остатком
 EXPLAIN (ANALYZE, BUFFERS) 
SELECT i.name, i.stock_quantity, cat.name as category
 FROM items i 
JOIN categories cat ON i.category_id = cat.id
 WHERE i.stock_quantity < 10
 ORDER BY i.stock_quantity;


CREATE INDEX idx_sales_customer_id ON sales (customer_id); 
CREATE INDEX idx_sales_price_quantity ON sales (price, quantity); 
CREATE INDEX idx_items_category_id ON items (category_id); 
CREATE INDEX idx_sales_item_id ON sales (item_id);     
CREATE INDEX idx_items_stock_quantity ON items (stock_quantity); 