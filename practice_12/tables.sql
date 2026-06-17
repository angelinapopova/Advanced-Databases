CREATE DATABASE practice_12;

DROP TABLE IF EXISTS deliveries  CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders      CASCADE;
DROP TABLE IF EXISTS menu_items  CASCADE;
DROP TABLE IF EXISTS couriers    CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS categories  CASCADE;
DROP TABLE IF EXISTS customers   CASCADE;


CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20)  NOT NULL UNIQUE,
    rating NUMERIC(2,1) DEFAULT 0.0 CHECK (rating BETWEEN 0.0 AND 5.0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    category_id   INT NOT NULL REFERENCES categories(category_id),
    name VARCHAR(150) NOT NULL,
    description  TEXT,
    price NUMERIC(8,2) NOT NULL CHECK (price > 0),
    is_available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id  SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
            CHECK (status IN ('pending','confirmed','preparing','in_delivery','delivered','cancelled')),
    total_amount  NUMERIC(10,2) NOT NULL CHECK (total_amount > 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES menu_items(item_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(8,2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE couriers (
    courier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(20) NOT NULL CHECK (vehicle_type IN ('bike','scooter','car','foot')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES orders(order_id),
    courier_id INT NOT NULL REFERENCES couriers(courier_id),
    assigned_at TIMESTAMP   NOT NULL DEFAULT NOW(),
    delivered_at TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'assigned'
             CHECK (status IN ('assigned','picked_up','delivered','failed'))
);
