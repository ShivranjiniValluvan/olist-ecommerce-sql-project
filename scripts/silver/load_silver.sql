CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    PRINT 'Loading Silver Layer';

    -- ============================================
    -- 1. CUSTOMERS
    -- ============================================
    TRUNCATE TABLE silver.customers;
    INSERT INTO silver.customers
    SELECT
        REPLACE(customer_id, '"', ''),
        REPLACE(customer_unique_id, '"', ''),
        REPLACE(customer_zip_code_prefix, '"', ''),
        LOWER(TRIM(customer_city)),
        UPPER(customer_state)
    FROM bronze.customers;
    PRINT 'Customers loaded successfully';

    -- ============================================
    -- 2. ORDERS
    -- ============================================
    TRUNCATE TABLE silver.orders;
    INSERT INTO silver.orders
    SELECT
        REPLACE(order_id, '"', ''),
        REPLACE(customer_id, '"', ''),
        order_status,
        TRY_CAST(order_purchase_timestamp AS DATETIME),
        TRY_CAST(order_approved_at AS DATETIME),
        TRY_CAST(order_delivered_carrier_date AS DATETIME),
        TRY_CAST(order_delivered_customer_date AS DATETIME),
        TRY_CAST(order_estimated_delivery_date AS DATETIME),
        CASE 
            WHEN order_delivered_customer_date IS NOT NULL 
            AND order_purchase_timestamp IS NOT NULL
            THEN DATEDIFF(day, 
                TRY_CAST(order_purchase_timestamp AS DATETIME), 
                TRY_CAST(order_delivered_customer_date AS DATETIME))
            ELSE NULL 
        END,
        CASE 
            WHEN order_delivered_customer_date IS NOT NULL 
            AND order_estimated_delivery_date IS NOT NULL
            THEN 
                CASE 
                    WHEN TRY_CAST(order_delivered_customer_date AS DATETIME) 
                       > TRY_CAST(order_estimated_delivery_date AS DATETIME)
                    THEN 'Late'
                    ELSE 'On Time'
                END
            ELSE 'N/A'
        END
    FROM bronze.orders;
    PRINT 'Orders loaded successfully';

    -- ============================================
    -- 3. ORDER ITEMS
    -- ============================================
    TRUNCATE TABLE silver.order_items;
    INSERT INTO silver.order_items
    SELECT
        REPLACE(order_id, '"', ''),
        order_item_id,
        REPLACE(product_id, '"', ''),
        REPLACE(seller_id, '"', ''),
        TRY_CAST(shipping_limit_date AS DATETIME),
        price,
        freight_value
    FROM bronze.order_items;
    PRINT 'Order Items loaded successfully';

    -- ============================================
    -- 4. ORDER PAYMENTS
    -- ============================================
    TRUNCATE TABLE silver.order_payments;
    INSERT INTO silver.order_payments
    SELECT
        REPLACE(order_id, '"', ''),
        payment_sequential,
        CASE 
            WHEN payment_type = 'not_defined' THEN 'Unknown'
            ELSE payment_type 
        END,
        payment_installments,
        payment_value
    FROM bronze.order_payments
    WHERE payment_value > 0;
    PRINT 'Order Payments loaded successfully';

    -- ============================================
    -- 5. PRODUCTS
    -- ============================================
    TRUNCATE TABLE silver.products;
    INSERT INTO silver.products
    SELECT
        REPLACE(p.product_id, '"', ''),
        ISNULL(p.product_category_name, 'Unknown'),
        ISNULL(t.product_category_name_english, 'Unknown'),
        ISNULL(p.product_name_length, 0),
        ISNULL(p.product_description_length, 0),
        ISNULL(p.product_photos_qty, 0),
        ISNULL(p.product_weight_g, 0),
        ISNULL(p.product_length_cm, 0),
        ISNULL(p.product_height_cm, 0),
        ISNULL(p.product_width_cm, 0)
    FROM bronze.products p
    LEFT JOIN bronze.category_translation t
        ON p.product_category_name = t.product_category_name;
    PRINT 'Products loaded successfully';

    -- ============================================
    -- 6. SELLERS
    -- ============================================
    TRUNCATE TABLE silver.sellers;
    INSERT INTO silver.sellers
    SELECT
        REPLACE(seller_id, '"', ''),
        REPLACE(seller_zip_code_prefix, '"', ''),
        CASE
            WHEN LOWER(TRIM(seller_city)) LIKE '%@%' THEN 'Unknown'
            ELSE LOWER(TRIM(seller_city))
        END,
        UPPER(seller_state)
    FROM bronze.sellers;

    -- Add placeholder for sellers referenced in orders but missing from source sellers data
    INSERT INTO silver.sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
    VALUES 
    ('723a46b89fd5c3ed78ccdf039e33ac63', 'Unknown', 'unknown', 'XX'),
    ('f9eedec3129e8cc6b6429c42d0808c5b', 'Unknown', 'unknown', 'XX');

    PRINT 'Sellers loaded successfully';

    -- ============================================
    -- 7. ORDER REVIEWS
    -- ============================================
    TRUNCATE TABLE silver.order_reviews;

    ;WITH ranked_reviews AS (
        SELECT
            REPLACE(review_id, '"', '') AS review_id,
            REPLACE(order_id, '"', '') AS order_id,
            TRY_CAST(review_score AS INT) AS review_score,
            ISNULL(review_comment_title, 'No Title') AS review_comment_title,
            ISNULL(review_comment_message, 'No Comment') AS review_comment_message,
            TRY_CAST(review_creation_date AS DATETIME) AS review_creation_date,
            TRY_CAST(review_answer_timestamp AS DATETIME) AS review_answer_timestamp,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY review_creation_date DESC
            ) AS rn
        FROM bronze.order_reviews
        WHERE order_id IS NOT NULL
        AND review_score IN ('1', '2', '3', '4', '5')
    )
    INSERT INTO silver.order_reviews
    SELECT 
        review_id, order_id, review_score, review_comment_title,
        review_comment_message, review_creation_date, review_answer_timestamp
    FROM ranked_reviews
    WHERE rn = 1;

    PRINT 'Order Reviews loaded successfully';

    -- ============================================
    -- 8. CATEGORY TRANSLATION
    -- ============================================
    TRUNCATE TABLE silver.category_translation;
    INSERT INTO silver.category_translation
    SELECT
        product_category_name,
        product_category_name_english
    FROM bronze.category_translation;
    PRINT 'Category Translation loaded successfully';

END
GO