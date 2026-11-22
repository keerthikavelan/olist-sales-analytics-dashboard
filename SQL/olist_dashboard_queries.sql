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

/* Creation of
	Fact Table: fact_order_items
    Dimension Table: dim_customer, dim_seller, dim_product, dim_date*/
DROP TABLE fact_order_items;
CREATE TABLE fact_order_items AS

SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_unique_id,

    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value

FROM order_items i
LEFT JOIN orders o
ON i.order_id = o.order_id

LEFT JOIN customers c
ON o.customer_id = c.customer_id;

ALTER TABLE fact_order_items
MODIFY order_purchase_timestamp DATETIME,
MODIFY order_delivered_customer_date DATETIME;

DROP TABLE dim_customer;
CREATE TABLE dim_customer AS

SELECT 
    customer_id,
    customer_city,
    customer_state

FROM customers;

DROP TABLE dim_product;
CREATE TABLE dim_product AS

SELECT 
    product_id,
    product_category_name

FROM products;

DROP TABLE dim_seller;
CREATE TABLE dim_seller AS

SELECT 
    seller_id,
    seller_city,
    seller_state

FROM sellers;

DROP TABLE dim_date;
CREATE TABLE dim_date AS
WITH RECURSIVE calendar AS (
    SELECT DATE('2016-09-04') AS order_date
    UNION ALL
    SELECT DATE_ADD(order_date, INTERVAL 1 DAY)
    FROM calendar
    WHERE order_date < '2018-10-17'
)
SELECT
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    CONCAT('Q', QUARTER(order_date)) AS quarter,
    DAY(order_date) AS day_number,
    DAYNAME(order_date) AS day_name,
    WEEK(order_date) AS week_number
FROM calendar;
