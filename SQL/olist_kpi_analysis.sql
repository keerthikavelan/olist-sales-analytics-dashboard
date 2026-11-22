/*Dashboard creation before load data using python*/

create database olistdashboard_db;
show databases;
use olistdashboard_db;
show tables;

/* KPI analysis */
CREATE OR REPLACE VIEW order_items_view AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,

    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value

FROM orders o
LEFT JOIN order_items i
ON o.order_id = i.order_id;

SELECT *
FROM order_items_view
LIMIT 10;

/*KPI 1: Total Revenue*/
SELECT 
    ROUND(SUM(price),2) AS total_revenue
FROM order_items_view;

/*KPI 2: Delivery & Logistics Performance*/
SELECT 
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days
FROM order_items_view
WHERE order_delivered_customer_date IS NOT NULL;

/*KPI 3: Customer Behavior (Retention & Value)*/
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM order_items_view;

/*KPI 4: Product & Seller Performance */
SELECT 
    product_id,
    ROUND(SUM(price),2) AS total_product_revenue
FROM order_items_view
GROUP BY product_id
ORDER BY total_product_revenue DESC
LIMIT 1;

/*KPI 5: Order Status Analysis (Operational Insight).*/
SELECT 
    ROUND(
        (SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) 
        / COUNT(DISTINCT order_id)) * 100,
        2
    ) AS delivery_success_rate
FROM orders;

/*KPI 6: Geographic Analysis*/
SELECT 
    customer_state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 1;
