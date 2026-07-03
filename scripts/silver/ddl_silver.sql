USE olist_dwh;
GO

CREATE TABLE silver.customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
GO

CREATE TABLE silver.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    delivery_days INT,
    late_flag VARCHAR(10)
);
GO

CREATE TABLE silver.order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT
);
GO

CREATE TABLE silver.order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value FLOAT
);
GO

CREATE TABLE silver.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(500),
    review_comment_message VARCHAR(MAX),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);
GO

CREATE TABLE silver.products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);
GO

CREATE TABLE silver.sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);
GO

CREATE TABLE silver.category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);
GO