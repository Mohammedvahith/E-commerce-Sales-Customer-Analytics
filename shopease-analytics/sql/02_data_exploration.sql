-- 1. TABLE OVERVIEW

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments;

-- Full Table in CUSTOMERS
SELECT * FROM customers;

-- 2. DATA COMPLETENESS

SELECT
    COUNT(*) AS total_customers,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(city IS NULL) AS missing_city,
    SUM(age IS NULL) AS missing_age
FROM customers;

-- 3. DUPLICATE CHECKS

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 4. DATA VALIDITY

SELECT *
FROM customers
WHERE age < 18 OR age > 64;


-- 5. RELATIONSHIP CHECKS

SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

