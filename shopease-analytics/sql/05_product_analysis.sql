-- Top 10 Products by Delivered Revenue

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.total_amount), 2) AS delivered_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY delivered_revenue DESC
LIMIT 10;

-- Top-performing product in each category

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.total_amount) AS delivered_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
product_ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY delivered_revenue DESC, product_id
        ) AS product_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    total_units_sold,
    ROUND(delivered_revenue, 2) AS delivered_revenue
FROM product_ranking
WHERE product_rank = 1
ORDER BY category;