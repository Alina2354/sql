CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    created_at TIMESTAMP NOT NULL
);


INSERT INTO products (name, category, price, stock_quantity, created_at)
SELECT
    'Товар ' || g,
    CASE WHEN g % 3 = 0 THEN 'Электроника'
         WHEN g % 3 = 1 THEN 'Одежда'
         ELSE 'Книги' END,
    (random() * 10000)::numeric, 
    (random() * 100)::integer,   
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 1500) AS g;


EXPLAIN SELECT * FROM products WHERE category = 'Электроника';
EXPLAIN SELECT * FROM products WHERE price BETWEEN 1000 AND 5000;
EXPLAIN SELECT * FROM products ORDER BY created_at DESC LIMIT 10;
EXPLAIN SELECT * FROM products WHERE name LIKE '%телефон%';


CREATE INDEX idx_products_category ON products (category);
CREATE INDEX idx_products_price ON products (price);
CREATE INDEX idx_products_category_price ON products (category, price);
CREATE INDEX idx_products_created_at ON products (created_at DESC);
CREATE INDEX idx_products_stock_quantity_gt_0 ON products (stock_quantity) WHERE stock_quantity > 0;
CREATE INDEX idx_products_name_gin ON products USING GIN (to_tsvector('russian', name));


CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    registration_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL
);


CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);


CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);


CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL
);


INSERT INTO customers (name, email, registration_date, status)
SELECT
    'Customer ' || g,
    'customer' || g || '@example.com',
    NOW() - (random() * INTERVAL '730 days'), 
    CASE WHEN random() < 0.8 THEN 'active' ELSE 'inactive' END
FROM generate_series(1, 200) AS g;

INSERT INTO products (name, category, price, stock_quantity, created_at)
SELECT
    'Product ' || g::TEXT,
    CASE WHEN g % 4 = 0 THEN 'Electronics'
         WHEN g % 4 = 1 THEN 'Clothing'
         WHEN g % 4 = 2 THEN 'Books'
         ELSE 'Home Goods' END,
    (random() * 500)::DECIMAL(10, 2),
    (random() * 100)::INTEGER,
    NOW()  
FROM generate_series(1, 50) AS g;



INSERT INTO orders (customer_id, order_date, total_amount, status)
SELECT
    (random() * 199 + 1)::INT,  
    NOW() - (random() * INTERVAL '90 days'), 
    (random() * 500 + 50)::DECIMAL(10, 2),
    CASE WHEN random() < 0.9 THEN 'completed' ELSE 'pending' END
FROM generate_series(1, 600) AS g;


INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT
    (random() * 599 + 1)::INT,  
    (random() * 49 + 1)::INT,   
    (random() * 5 + 1)::INT,    
    p.price
FROM generate_series(1, 1200) AS g
JOIN products p ON p.id = (random() * 49 + 1)::INT; 

SELECT c.name, o.order_date, o.total_amount
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 month'
ORDER BY o.total_amount DESC;


CREATE INDEX idx_orders_order_date ON orders (order_date);
CREATE INDEX idx_orders_total_amount ON orders (total_amount DESC);
CREATE INDEX idx_orders_customer_id ON orders (customer_id); 

SELECT p.name, SUM(oi.quantity) as total_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'completed'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;


CREATE INDEX idx_order_items_product_id ON order_items (product_id);
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_orders_status ON orders (status);
CREATE INDEX idx_order_items_product_id_quantity ON order_items (product_id, quantity);

