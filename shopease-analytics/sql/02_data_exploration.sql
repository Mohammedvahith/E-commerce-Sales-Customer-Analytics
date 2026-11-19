
USE shopease;

-- ==========================================
-- 1. TABLE OVERVIEW / ROW COUNT VALIDATION
-- ==========================================

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments;


-- ==========================================
-- 2. DATA COMPLETENESS / NULL CHECKS
-- ==========================================

SELECT
    COUNT(*) AS total_customers,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(first_name IS NULL) AS missing_first_name,
    SUM(city IS NULL) AS missing_city,
    SUM(age IS NULL) AS missing_age
FROM customers;

SELECT
    COUNT(*) AS total_orders,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(orders_date IS NULL) AS missing_order_date
FROM orders;

SELECT
    COUNT(*) AS total_order_items,
    SUM(order_item_id IS NULL) AS missing_item_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id
FROM order_items;


-- ==========================================
-- 3. DUPLICATE PRIMARY KEY CHECKS
-- ==========================================

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT payment_id, COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- ==========================================
-- 4. DATA VALIDITY CHECKS
-- ==========================================

-- Customer ages outside the expected range
SELECT *
FROM customers
WHERE age < 18 OR age > 64;


-- ==========================================
-- 5. REFERENTIAL INTEGRITY CHECKS
-- ==========================================

-- Orders without a matching customer
SELECT COUNT(*) AS invalid_customer_references
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items without a matching product
SELECT COUNT(*) AS invalid_product_references
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order items without a matching order
SELECT COUNT(*) AS invalid_order_references
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Orders without a matching payment
SELECT COUNT(*) AS orders_without_payments
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;
