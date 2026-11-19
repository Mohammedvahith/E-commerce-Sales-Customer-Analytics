-- Row Count Validation

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments;

-- Duplicate ID Checks

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

-- NULL Value Checks

SELECT
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(first_name IS NULL) AS missing_first_names,
    SUM(city IS NULL) AS missing_cities
FROM customers;

SELECT
    SUM(order_id IS NULL) AS missing_order_ids,
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(orders_date IS NULL) AS missing_order_dates
FROM orders;

SELECT
    SUM(order_item_id IS NULL) AS missing_item_ids,
    SUM(order_id IS NULL) AS missing_order_ids,
    SUM(product_id IS NULL) AS missing_product_ids
FROM order_items;

