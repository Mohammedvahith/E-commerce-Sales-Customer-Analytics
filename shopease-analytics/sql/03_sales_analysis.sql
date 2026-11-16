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
