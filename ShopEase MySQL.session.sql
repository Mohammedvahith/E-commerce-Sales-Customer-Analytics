USE shopease;

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

select count(*)
from customers
where age <= 30 and city="dubai";
