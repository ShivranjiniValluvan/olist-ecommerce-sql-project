USE olist_dwh;
GO

-- ============================================
-- EXPLORE BRONZE LAYER
-- ============================================

-- ============================================
-- 1. CUSTOMERS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.customers;

SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM bronze.customers;

SELECT customer_id, COUNT(*) AS count
FROM bronze.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ============================================
-- 2. ORDERS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.orders;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date
FROM bronze.orders;

SELECT order_status, COUNT(*) AS count
FROM bronze.orders
GROUP BY order_status
ORDER BY count DESC;

-- ============================================
-- 3. ORDER ITEMS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.order_items;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS invalid_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS invalid_freight
FROM bronze.order_items;

SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM bronze.order_items;

-- ============================================
-- 4. ORDER PAYMENTS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.order_payments;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value,
    SUM(CASE WHEN payment_value <= 0 THEN 1 ELSE 0 END) AS invalid_payment_value
FROM bronze.order_payments;

SELECT payment_type, COUNT(*) AS count
FROM bronze.order_payments
GROUP BY payment_type
ORDER BY count DESC;

-- ============================================
-- 5. PRODUCTS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.products;

SELECT 
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length
FROM bronze.products;

SELECT COUNT(DISTINCT product_category_name) AS total_categories
FROM bronze.products;

-- ============================================
-- 6. SELLERS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.sellers;

SELECT 
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM bronze.sellers;

SELECT DISTINCT seller_city
FROM bronze.sellers
ORDER BY seller_city;

-- ============================================
-- 7. ORDER REVIEWS TABLE
-- ============================================
SELECT TOP 10 * FROM bronze.order_reviews;

SELECT 
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_score,
    COUNT(DISTINCT review_score) AS distinct_scores
FROM bronze.order_reviews;

SELECT review_score, COUNT(*) AS count
FROM bronze.order_reviews
GROUP BY review_score
ORDER BY review_score;