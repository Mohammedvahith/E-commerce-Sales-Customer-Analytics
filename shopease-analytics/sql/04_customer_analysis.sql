-- Customers without delivered purchases

SELECT 
    c.customer_id AS customer_id,
    c.first_name AS first_name,
    c.city AS city,
    COUNT(o.order_id) As total_orders
FROM customers c 
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING 
    COUNT(o.order_id) >= 1
    AND 
    SUM(
        CASE
            WHEN o.order_status = "Delivered" THEN 1
            ELSE 0
        END
    ) = 0;