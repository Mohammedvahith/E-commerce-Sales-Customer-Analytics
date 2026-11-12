-- Business Question:
-- Which product category generates the highest total amount?

SELECT
    p.category AS Category,
    ROUND(SUM(oi.total_amount), 2) AS Total_Amount
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY Total_Amount DESC;