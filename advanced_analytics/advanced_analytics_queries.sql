USE olist_dwh;
GO

-- Q1: Repeat customer revenue split (first purchase vs repeat purchase)
-- customer_unique_id used instead of customer_id since customer_id 
-- is actually per-order in this dataset, not per-person

WITH customer_order_sequence AS (
    SELECT 
        f.order_id,
        c.customer_unique_id,
        f.order_date,
        f.price,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY f.order_date
        ) AS purchase_number
    FROM gold.fact_orders f
    JOIN gold.dim_customers c ON f.customer_id = c.customer_id
    WHERE f.order_status = 'delivered'
),
purchase_type AS (
    SELECT *,
        CASE WHEN purchase_number = 1 THEN 'First Purchase' ELSE 'Repeat Purchase' END AS order_type
    FROM customer_order_sequence
)
SELECT 
    order_type,
    COUNT(DISTINCT customer_unique_id) AS num_customers,
    COUNT(order_id) AS num_orders,
    SUM(price) AS total_revenue,
    CAST(SUM(price) * 100.0 / SUM(SUM(price)) OVER () AS DECIMAL(5,2)) AS pct_of_total_revenue
FROM purchase_type
GROUP BY order_type;


-- Q1 (extended): repeat rate by first-purchase cohort month
-- note: later cohorts have had less time to repeat (right-censoring)

WITH customer_order_sequence AS (
    SELECT 
        f.order_id,
        c.customer_unique_id,
        f.order_date,
        f.price,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY f.order_date
        ) AS purchase_number
    FROM gold.fact_orders f
    JOIN gold.dim_customers c ON f.customer_id = c.customer_id
    WHERE f.order_status = 'delivered'
),
customer_cohort AS (
    SELECT 
        customer_unique_id,
        MIN(order_date) AS first_purchase_date,
        FORMAT(MIN(order_date), 'yyyy-MM') AS cohort_month,
        MAX(purchase_number) AS total_purchases
    FROM customer_order_sequence
    GROUP BY customer_unique_id
)
SELECT 
    cohort_month,
    COUNT(customer_unique_id) AS cohort_size,
    SUM(CASE WHEN total_purchases > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    CAST(SUM(CASE WHEN total_purchases > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(customer_unique_id) AS DECIMAL(5,2)) AS repeat_rate_pct
FROM customer_cohort
GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================


-- Q2: Seller reliability tiers (based on active months + revenue consistency)

WITH seller_monthly_revenue AS (
    SELECT 
        f.seller_id,
        FORMAT(f.order_date, 'yyyy-MM') AS order_month,
        SUM(f.price) AS monthly_revenue
    FROM gold.fact_orders f
    WHERE f.order_status = 'delivered'
    GROUP BY f.seller_id, FORMAT(f.order_date, 'yyyy-MM')
),
seller_reliability AS (
    SELECT 
        seller_id,
        COUNT(order_month) AS active_months,
        SUM(monthly_revenue) AS total_revenue,
        AVG(monthly_revenue) AS avg_monthly_revenue,
        STDEV(monthly_revenue) AS revenue_stdev,
        CASE 
            WHEN AVG(monthly_revenue) = 0 THEN NULL
            ELSE STDEV(monthly_revenue) / AVG(monthly_revenue) 
        END AS coefficient_of_variation
    FROM seller_monthly_revenue
    GROUP BY seller_id
),
seller_tier AS (
    SELECT *,
        CASE 
            WHEN active_months <= 2 THEN 'One-Hit Wonder'
            WHEN coefficient_of_variation IS NULL THEN 'One-Hit Wonder'
            WHEN coefficient_of_variation < 0.5 THEN 'Reliable'
            WHEN coefficient_of_variation < 0.8 THEN 'Moderate'
            ELSE 'Volatile'
        END AS reliability_tier
    FROM seller_reliability
)
SELECT 
    reliability_tier,
    COUNT(*) AS num_sellers,
    SUM(total_revenue) AS tier_total_revenue,
    CAST(AVG(active_months) AS DECIMAL(5,1)) AS avg_active_months
FROM seller_tier
GROUP BY reliability_tier
ORDER BY tier_total_revenue DESC;


-- ============================================


-- Q3: Monthly delivery trend (MoM change + 3-month moving average)

WITH monthly_delivery AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS order_month,
        AVG(CAST(delivery_days AS FLOAT)) AS avg_delivery_days,
        SUM(CASE WHEN late_flag = 'Late' THEN 1 ELSE 0 END) * 100.0 
            / NULLIF(SUM(CASE WHEN late_flag IN ('Late','On Time') THEN 1 ELSE 0 END), 0) AS late_pct
    FROM gold.fact_orders
    WHERE order_status = 'delivered'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)
SELECT 
    order_month,
    avg_delivery_days,
    LAG(avg_delivery_days) OVER (ORDER BY order_month) AS prev_month_delivery_days,
    avg_delivery_days - LAG(avg_delivery_days) OVER (ORDER BY order_month) AS mom_change,
    AVG(avg_delivery_days) OVER (
        ORDER BY order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3month,
    late_pct
FROM monthly_delivery
ORDER BY order_month;


-- Q3 (extended): late delivery rate ranked by state

SELECT 
    c.customer_state,
    COUNT(*) AS num_orders,
    AVG(CAST(f.delivery_days AS FLOAT)) AS avg_delivery_days,
    SUM(CASE WHEN f.late_flag = 'Late' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(SUM(CASE WHEN f.late_flag IN ('Late','On Time') THEN 1 ELSE 0 END), 0) AS late_pct,
    RANK() OVER (ORDER BY 
        SUM(CASE WHEN f.late_flag = 'Late' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(SUM(CASE WHEN f.late_flag IN ('Late','On Time') THEN 1 ELSE 0 END), 0) DESC
    ) AS worst_delivery_rank
FROM gold.fact_orders f
JOIN gold.dim_customers c ON f.customer_id = c.customer_id
WHERE f.order_status = 'delivered'
GROUP BY c.customer_state
HAVING COUNT(*) >= 50   -- filter out low-volume states, % isn't reliable below this
ORDER BY late_pct DESC;


-- ============================================


-- Q4: Category revenue growth, 2018 vs 2017, ranked
-- note: categories with a tiny 2017 base can show inflated % growth

WITH category_yearly_revenue AS (
    SELECT 
        p.category_name,
        YEAR(f.order_date) AS order_year,
        SUM(f.price) AS total_revenue,
        COUNT(*) AS num_orders
    FROM gold.fact_orders f
    JOIN gold.dim_products p ON f.product_id = p.product_id
    WHERE f.order_status = 'delivered'
    GROUP BY p.category_name, YEAR(f.order_date)
),
category_growth AS (
    SELECT 
        category_name,
        order_year,
        total_revenue,
        num_orders,
        LAG(total_revenue) OVER (PARTITION BY category_name ORDER BY order_year) AS prev_year_revenue,
        CASE 
            WHEN LAG(total_revenue) OVER (PARTITION BY category_name ORDER BY order_year) IS NULL THEN NULL
            WHEN LAG(total_revenue) OVER (PARTITION BY category_name ORDER BY order_year) = 0 THEN NULL
            ELSE (total_revenue - LAG(total_revenue) OVER (PARTITION BY category_name ORDER BY order_year)) 
                 * 100.0 / LAG(total_revenue) OVER (PARTITION BY category_name ORDER BY order_year)
        END AS yoy_growth_pct
    FROM category_yearly_revenue
)
SELECT 
    category_name,
    total_revenue AS revenue_2018,
    prev_year_revenue AS revenue_2017,
    yoy_growth_pct,
    RANK() OVER (ORDER BY yoy_growth_pct DESC) AS growth_rank
FROM category_growth
WHERE order_year = 2018 
    AND num_orders >= 20   -- filter out tiny categories, % growth is just noise below this
ORDER BY yoy_growth_pct DESC;


-- ============================================


-- Q5: Customer segmentation using RFM (Recency, Frequency, Monetary)

-- using the latest order date in the data as "today" since this is historical data, not GETDATE()
WITH latest_date AS (
    SELECT MAX(order_date) AS max_order_date
    FROM gold.fact_orders
    WHERE order_status = 'delivered'
),
customer_rfm AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF(DAY, MAX(f.order_date), (SELECT max_order_date FROM latest_date)) AS recency_days,
        COUNT(DISTINCT f.order_id) AS frequency,
        SUM(f.price) AS monetary
    FROM gold.fact_orders f
    JOIN gold.dim_customers c ON f.customer_id = c.customer_id
    WHERE f.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_segment AS (
    SELECT *,
        CASE 
            WHEN frequency >= 2 AND recency_days <= 180 THEN 'Champion'
            WHEN frequency >= 2 AND recency_days > 180 THEN 'At Risk (Repeat but inactive)'
            WHEN frequency = 1 AND recency_days <= 90 THEN 'New Customer'
            WHEN frequency = 1 AND recency_days > 90 AND monetary >= 500 THEN 'High-Value One-Timer'
            ELSE 'Lost / Low-Value'
        END AS customer_segment
    FROM customer_rfm
)
SELECT 
    customer_segment,
    COUNT(*) AS num_customers,
    SUM(monetary) AS total_revenue,
    CAST(AVG(monetary) AS DECIMAL(10,2)) AS avg_monetary,
    CAST(AVG(recency_days) AS DECIMAL(10,1)) AS avg_recency_days
FROM customer_segment
GROUP BY customer_segment
ORDER BY total_revenue DESC;


-- ============================================


-- Q6: Revenue and order value by payment type

WITH payment_summary AS (
    SELECT 
        pay.payment_type,
        COUNT(*) AS num_orders,
        SUM(pay.payment_value) AS total_revenue,
        AVG(pay.payment_value) AS avg_order_value,
        AVG(CAST(pay.payment_installments AS FLOAT)) AS avg_installments
    FROM gold.dim_payments pay
    GROUP BY pay.payment_type
)
SELECT 
    payment_type,
    num_orders,
    total_revenue,
    avg_order_value,
    avg_installments,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS pct_of_total_revenue
FROM payment_summary
ORDER BY total_revenue DESC;


-- Q6 (extended): avg order value by installment count, credit card only
-- reliable for installments 1-10, noisy above that (small sample sizes)

SELECT 
    payment_installments,
    COUNT(*) AS num_orders,
    AVG(payment_value) AS avg_order_value
FROM gold.dim_payments
WHERE payment_type = 'credit_card'
GROUP BY payment_installments
ORDER BY payment_installments;
