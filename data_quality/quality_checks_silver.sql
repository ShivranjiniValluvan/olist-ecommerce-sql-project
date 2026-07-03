USE olist_dwh;
GO

-- Any nulls left in customers?
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city
FROM silver.customers;

-- Any duplicate customers?
SELECT customer_id, COUNT(*) 
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Any invalid review scores left?
SELECT DISTINCT review_score 
FROM silver.order_reviews
ORDER BY review_score;

-- Any payment_value <= 0 left?
SELECT COUNT(*) AS invalid_payments
FROM silver.order_payments
WHERE payment_value <= 0;

-- late_flag distribution
SELECT late_flag, COUNT(*) AS count
FROM silver.orders
GROUP BY late_flag;

-- Any email addresses left in seller_city?
SELECT seller_city
FROM silver.sellers
WHERE seller_city LIKE '%@%';