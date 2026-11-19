
USE shopease;

-- =====================================================
-- 04. CUSTOMER ANALYSIS
-- =====================================================


-- =====================================================
-- 1. CUSTOMERS WITHOUT DELIVERED PURCHASES
-- Business Question:
-- Which customers placed orders but have no delivered orders?
-- =====================================================

SELECT
    c.customer_id,
    c.first_name,
    c.city,
    COUNT(o.order_id) AS total_orders

FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.city

HAVING
    COUNT(o.order_id) >= 1
    AND
    SUM(
        CASE
            WHEN o.order_status = 'Delivered' THEN 1
            ELSE 0
        END
    ) = 0;


-- =====================================================
-- 2. CUSTOMER PURCHASE FREQUENCY
-- Business Question:
-- How many customers are one-time and repeat purchasers?
-- Based on all order statuses.
-- =====================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS repeat_customer_rate

FROM customer_orders;


-- =====================================================
-- 3. TOP 10 CUSTOMERS BY DELIVERED SPENDING
-- Business Question:
-- Which customers generate the highest delivered revenue?
-- =====================================================

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(total_amount) AS total_amount_per_order
    FROM order_items
    GROUP BY order_id
),

customer_spending AS (
    SELECT
        o.customer_id,
        c.first_name,
        c.city,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.total_amount_per_order) AS total_spent

    FROM orders o
    INNER JOIN order_revenue oi
        ON o.order_id = oi.order_id
    INNER JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'Delivered'

    GROUP BY
        o.customer_id,
        c.first_name,
        c.city
)

SELECT
    customer_id,
    first_name,
    city,
    total_orders,
    ROUND(total_spent, 2) AS total_spent

FROM customer_spending
ORDER BY total_spent DESC
LIMIT 10;


-- =====================================================
-- 4. TOP-SPENDING CUSTOMER IN EACH CITY
-- Business Question:
-- Who is the highest-spending customer in each city?
-- Based on delivered orders.
-- =====================================================

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(total_amount) AS total_amount_per_order
    FROM order_items
    GROUP BY order_id
),

customer_spending AS (
    SELECT
        o.customer_id,
        c.first_name,
        c.city,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.total_amount_per_order) AS total_spent

    FROM orders o
    INNER JOIN order_revenue oi
        ON o.order_id = oi.order_id
    INNER JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'Delivered'

    GROUP BY
        o.customer_id,
        c.first_name,
        c.city
),

customer_ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_spent DESC, customer_id
        ) AS customer_rank
    FROM customer_spending
)

SELECT
    customer_id,
    first_name,
    city,
    total_orders,
    ROUND(total_spent, 2) AS total_spent

FROM customer_ranking
WHERE customer_rank = 1
ORDER BY city;
