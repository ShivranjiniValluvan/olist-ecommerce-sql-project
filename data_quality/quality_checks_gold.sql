USE olist_dwh;
GO

-- ============================================
-- CHECK 1: Orphan records (foreign key integrity)
-- ============================================
SELECT f.customer_id
FROM gold.fact_orders f
LEFT JOIN gold.dim_customers c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT f.product_id
FROM gold.fact_orders f
LEFT JOIN gold.dim_products p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT f.seller_id
FROM gold.fact_orders f
LEFT JOIN gold.dim_sellers s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- ============================================
-- CHECK 2: Negative or invalid values
-- ============================================
SELECT COUNT(*) AS invalid_price
FROM gold.fact_orders
WHERE price < 0;

SELECT COUNT(*) AS invalid_freight
FROM gold.fact_orders
WHERE freight_value < 0;

-- ============================================
-- CHECK 3: Row count sanity check
-- ============================================
SELECT COUNT(*) AS fact_orders_count FROM gold.fact_orders;
SELECT COUNT(*) AS silver_order_items_count FROM silver.order_items;