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

WITH revenue_per_category AS (
    SELECT p.category,ROUND(SUM(oi.total_amount),2) As category_revenue
    FROM order_items oi 
    LEFT JOIN products p 
    ON oi.product_id = p.product_id
    GROUP BY p.category
),
category_total_revenue AS (
    SELECT ROUND(SUM(category_revenue),2) as total_revenue
    FROM revenue_per_category
),
category_percentage_contribution AS (
    SELECT r.category,(r.category_revenue/cr.total_revenue)*100 AS contribution
    FROM revenue_per_category r
    CROSS JOIN category_total_revenue cr
),
contribute_level AS (
    SELECT 
        category, 
        contribution AS contribution_percentage,
        CASE 
            WHEN contribution > 20 THEN "High Contribution"
            WHEN contribution < 20 AND contribution > 19 THEN "Moderate Contribution"
            ELSE "Low Contribution"
        END AS "contribution_level"
    FROM category_percentage_contribution
)

SELECT * FROM contribute_level;

-- MoM Growth 
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.orders_date, '%Y-%m') AS sales_month,
        SUM(oi.total_amount) AS monthly_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.orders_date, '%Y-%m')
),
previous_revenue as (
    select
        sales_month,
        lag(monthly_revenue) over(
        order by sales_month) as previous_revenue
    from monthly_revenue
)

select 
    m.sales_month,
    m.monthly_revenue,
    p.previous_revenue,
    ROUND(((m.monthly_revenue-p.previous_revenue)/p.previous_revenue)*100,2) as MoM_growt
from monthly_revenue m 
INNER join previous_revenue p 
on m.sales_month = p.sales_month
order by m.sales_month
limit 5;

-- Order Status KPI Analysis
-- Total Orders, Delivered, Cancelled, Returned and Pending Rates

SELECT
    a.total_orders,
    a.delivered_orders,
    a.cancelled_orders,
    a.returned_orders,
    a.pending_orders,

    ROUND((a.delivered_orders / a.total_orders) * 100, 2)
        AS completion_rate,

    ROUND((a.cancelled_orders / a.total_orders) * 100, 2)
        AS cancellation_rate,

    ROUND((a.returned_orders / a.total_orders) * 100, 2)
        AS return_rate,

    ROUND((a.pending_orders / a.total_orders) * 100, 2)
        AS pending_rate

FROM (
    SELECT
        COUNT(*) AS total_orders,

        SUM(CASE WHEN order_status = 'Delivered'
            THEN 1 ELSE 0 END) AS delivered_orders,

        SUM(CASE WHEN order_status = 'Cancelled'
            THEN 1 ELSE 0 END) AS cancelled_orders,

        SUM(CASE WHEN order_status = 'Returned'
            THEN 1 ELSE 0 END) AS returned_orders,

        SUM(CASE WHEN order_status = 'Pending'
            THEN 1 ELSE 0 END) AS pending_orders

    FROM orders
) AS a;

-- Average Order Value (AOV)

select 
    round(sum(oi.total_amount)
        /
        count(o.order_id),
        2
        ) as overall_AOV,
    round(SUM(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN oi.total_amount
                ELSE 0
            END
        )
        /
        sum(
            case
                 when o.order_status = "Delivered"
                 then 1 
                 else 0
            end
        ),
        2
    ) as delivered_AOV
from orders o
left join (select order_id,round(sum(total_amount))as total_amount
from order_items
group by order_id) oi 
on o.order_id = oi.order_id;

-- Category-wise Return Rate Analysis

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
        returned_orders * 100.0 /
        NULLIF(delivered_orders + returned_orders, 0),
        2
    ) AS return_rate

FROM category_orders
ORDER BY return_rate DESC;