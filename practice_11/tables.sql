CREATE DATABASE practice_11;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    country     VARCHAR(50)
);

CREATE TABLE publishers (
    publisher_id   SERIAL PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    city           VARCHAR(50)
);

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE customer_phones (
    customer_id  INT NOT NULL REFERENCES customers(customer_id),
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id, phone_number)
);

CREATE TABLE customer_addresses (
    customer_id  INT NOT NULL REFERENCES customers(customer_id),
    address_type VARCHAR(20) NOT NULL,
    city         VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id, address_type)
);

CREATE TABLE books (
    book_id      SERIAL PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    publisher_id INT NOT NULL REFERENCES publishers(publisher_id),
    category_id  INT NOT NULL REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    order_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_id INT NOT NULL REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT NOT NULL REFERENCES orders(order_id),
    book_id  INT NOT NULL REFERENCES books(book_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, book_id)
);
