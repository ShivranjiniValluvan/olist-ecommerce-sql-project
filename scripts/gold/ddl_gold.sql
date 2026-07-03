USE olist_dwh;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM silver.customers;
GO

CREATE VIEW gold.dim_products AS
SELECT
    product_id,
    product_category_name_english AS category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM silver.products;
GO

CREATE VIEW gold.dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state
FROM silver.sellers;
GO

CREATE VIEW gold.dim_payments AS
SELECT
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM silver.order_payments;
GO

CREATE VIEW gold.fact_orders AS
SELECT
    oi.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_purchase_timestamp AS order_date,
    o.order_status,
    oi.price,
    oi.freight_value,
    o.delivery_days,
    o.late_flag,
    r.review_score
FROM silver.order_items oi
LEFT JOIN silver.orders o
    ON oi.order_id = o.order_id
LEFT JOIN silver.order_reviews r
    ON oi.order_id = r.order_id;
GO