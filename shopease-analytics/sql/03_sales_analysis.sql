
USE shopease;

-- =====================================================
-- 03. SALES ANALYSIS
-- =====================================================


-- =====================================================
-- 1. REVENUE BY CATEGORY
-- Business Question:
-- Which product category generates the highest total amount?
-- Includes all order statuses.
-- =====================================================

SELECT
    p.category,
    ROUND(SUM(oi.total_amount), 2) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- =====================================================
-- 2. CATEGORY REVENUE CONTRIBUTION
-- Business Question:
-- What percentage of total revenue does each category contribute?
-- Includes all order statuses.
-- =====================================================

WITH revenue_per_category AS (
    SELECT
        p.category,
        SUM(oi.total_amount) AS category_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.category
),

category_total_revenue AS (
    SELECT
        SUM(category_revenue) AS total_revenue
    FROM revenue_per_category
),

category_percentage_contribution AS (
    SELECT
        r.category,
        (r.category_revenue / cr.total_revenue) * 100 AS contribution
    FROM revenue_per_category r
    CROSS JOIN category_total_revenue cr
)

SELECT
    category,
    ROUND(contribution, 2) AS contribution_percentage,
    CASE
        WHEN contribution > 20 THEN 'High Contribution'
        WHEN contribution > 19 THEN 'Moderate Contribution'
        ELSE 'Low Contribution'
    END AS contribution_level
FROM category_percentage_contribution
ORDER BY contribution DESC;


-- =====================================================
-- 3. MONTHLY REVENUE AND MONTH-OVER-MONTH GROWTH
-- Business Question:
-- How does revenue change from one month to another?
-- Includes all order statuses.
-- =====================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.orders_date, '%Y-%m') AS sales_month,
        SUM(oi.total_amount) AS monthly_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.orders_date, '%Y-%m')
),

previous_revenue AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_revenue
    FROM monthly_revenue
)

SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        ((monthly_revenue - previous_revenue)
        / previous_revenue) * 100,
        2
    ) AS MoM_growth
FROM previous_revenue
ORDER BY sales_month;


-- =====================================================
-- 4. ORDER STATUS KPI ANALYSIS
-- Business Question:
-- What percentage of orders are delivered, cancelled,
-- returned and pending?
-- =====================================================

SELECT
    a.total_orders,
    a.delivered_orders,
    a.cancelled_orders,
    a.returned_orders,
    a.pending_orders,

    ROUND(
        a.delivered_orders / a.total_orders * 100, 2
    ) AS completion_rate,

    ROUND(
        a.cancelled_orders / a.total_orders * 100, 2
    ) AS cancellation_rate,

    ROUND(
        a.returned_orders / a.total_orders * 100, 2
    ) AS return_rate,

    ROUND(
        a.pending_orders / a.total_orders * 100, 2
    ) AS pending_rate

FROM (
    SELECT
        COUNT(*) AS total_orders,

        SUM(CASE
            WHEN order_status = 'Delivered' THEN 1
            ELSE 0
        END) AS delivered_orders,

        SUM(CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END) AS cancelled_orders,

        SUM(CASE
            WHEN order_status = 'Returned' THEN 1
            ELSE 0
        END) AS returned_orders,

        SUM(CASE
            WHEN order_status = 'Pending' THEN 1
            ELSE 0
        END) AS pending_orders

    FROM orders
) AS a;


-- =====================================================
-- 5. REVENUE CONTRIBUTION BY ORDER STATUS
-- Business Question:
-- How much revenue value is associated with each order status?
-- =====================================================

SELECT
    o.order_status,
    ROUND(SUM(oi.total_amount), 2) AS status_revenue,

    ROUND(
        SUM(oi.total_amount)
        / SUM(SUM(oi.total_amount)) OVER() * 100,
        2
    ) AS revenue_percentage

FROM orders o
INNER JOIN (
    SELECT
        order_id,
        SUM(total_amount) AS total_amount
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id

GROUP BY o.order_status
ORDER BY status_revenue DESC;


-- =====================================================
-- 6. AVERAGE ORDER VALUE (AOV)
-- Business Question:
-- What is the average order value overall and
-- for delivered orders?
-- =====================================================

SELECT
    ROUND(
        SUM(oi.total_amount) / COUNT(o.order_id),
        2
    ) AS overall_AOV,

    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN oi.total_amount
                ELSE 0
            END
        )
        /
        SUM(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN 1
                ELSE 0
            END
        ),
        2
    ) AS delivered_AOV

FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        SUM(total_amount) AS total_amount
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id;


-- =====================================================
-- 7. CATEGORY-WISE RETURN RATE ANALYSIS
-- Business Question:
-- Which product category has the highest return rate?
-- Return rate = Returned Orders / (Delivered + Returned Orders)
-- =====================================================

WITH category_orders AS (
    SELECT
        p.category,

        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_id
        END) AS delivered_orders,

        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Returned'
            THEN o.order_id
        END) AS returned_orders

    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY p.category
)

SELECT
    category,
    delivered_orders,
    returned_orders,

    ROUND(
        returned_orders * 100.0
        / NULLIF(delivered_orders + returned_orders, 0),
        2
    ) AS return_rate

FROM category_orders
ORDER BY return_rate DESC;
