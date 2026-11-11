-- ShopEase E-commerce Analytics
-- Database setup

CREATE DATABASE IF NOT EXISTS shopease;

-- Select the database
USE shopease;

-- Check the selected database
SELECT DATABASE();

-- =====================================
-- ShopEase Database Setup
-- =====================================

-- 1. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    signup_date DATETIME NOT NULL,
    email VARCHAR(255) NOT NULL
);

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    sub_category VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    profit_per_unit DECIMAL(12,2) NOT NULL
);

-- 3. ORDERS TABLE
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    orders_date DATETIME NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- 4. ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount INT NOT NULL,
    gross_amount DECIMAL(14,2) NOT NULL,
    discount_amount DECIMAL(14,2) NOT NULL,
    total_amount DECIMAL(14,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- 5. PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL UNIQUE,
    payment_date DATETIME NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    payment_amount DECIMAL(14,2) NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- Verify database
SELECT DATABASE();

-- Verify tables
SHOW TABLES;

DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE payments;