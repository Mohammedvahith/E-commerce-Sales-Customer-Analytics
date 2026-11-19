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

-- Customer Purchase Frequency and Repeat Customer Rate
with customer_orders as (
    select 
        customer_id,
        count(order_id) as total_orders
    from orders
    group by customer_id
)

select 
    count(*) as Total_Customer,
    sum(
        case
            when total_orders = 1 then 1
            else 0
        end
    ) as one_time_customers,
    sum(
        case
            when total_orders > 1 then 1
            else 0
        end
    ) as repeat_customers,
    round(
        (
        sum(
            case
                when total_orders > 1 then 1
                else 0
            end
            )
        )
        /
        count(*)
        *100,
        2
        )AS repeat_customers_rate
from customer_orders

-- Top 10 Customers by Delivered Spending

with total_orders_items as (
    select 
        order_id,
        round(sum(total_amount),2) as total_amount_per_order
    from order_items
    group by order_id
),
order_detail as (
    select 
        o.customer_id,
        c.first_name,
        c.city,
        count(o.order_id) as total_orders,
        round(sum(total_amount_per_order),2) as total_spent
    from orders as o 
    inner join total_orders_items as toi 
        on o.order_id = toi.order_id
    inner join customers as c 
        on o.customer_id = c.customer_id
    where o.order_status = "Delivered"
    group by 
        o.customer_id,
        c.first_name,
        c.city
)

select * 
from order_detail
order by total_spent DESC
limit 10;