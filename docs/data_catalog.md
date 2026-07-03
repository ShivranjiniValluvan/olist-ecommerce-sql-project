# Data Catalog — Olist E-Commerce Data Warehouse

## Gold Layer (Business-Ready Data)

---

### fact_orders
Central fact table containing one row per order item.

| Column | Type | Description |
|---|---|---|
| order_id | VARCHAR | Unique identifier for the order |
| customer_id | VARCHAR | Foreign key linking to dim_customers |
| product_id | VARCHAR | Foreign key linking to dim_products |
| seller_id | VARCHAR | Foreign key linking to dim_sellers |
| order_date | DATETIME | Timestamp when order was placed |
| order_status | VARCHAR | Current status (delivered, shipped, cancelled etc.) |
| price | FLOAT | Product price in Brazilian Real (BRL) |
| freight_value | FLOAT | Shipping cost in Brazilian Real (BRL) |
| delivery_days | INT | Number of days from order to delivery (NULL if not delivered) |
| late_flag | VARCHAR | Delivery status: 'On Time', 'Late', or 'N/A' (undelivered) |
| review_score | INT | Customer satisfaction score 1-5 (NULL if no review left) |

---

### dim_customers
Customer dimension table.

| Column | Type | Description |
|---|---|---|
| customer_id | VARCHAR | Unique customer identifier per order |
| customer_unique_id | VARCHAR | True unique customer identifier across all orders |
| customer_city | VARCHAR | City where customer is located (standardized lowercase) |
| customer_state | VARCHAR | Brazilian state code (e.g. SP, RJ, MG) |

---

### dim_products
Product dimension table.

| Column | Type | Description |
|---|---|---|
| product_id | VARCHAR | Unique product identifier |
| category_name | VARCHAR | Product category in English (translated from Portuguese) |
| product_weight_g | FLOAT | Product weight in grams (0 if unknown) |
| product_length_cm | FLOAT | Product length in cm (0 if unknown) |
| product_height_cm | FLOAT | Product height in cm (0 if unknown) |
| product_width_cm | FLOAT | Product width in cm (0 if unknown) |

---

### dim_sellers
Seller dimension table.

| Column | Type | Description |
|---|---|---|
| seller_id | VARCHAR | Unique seller identifier |
| seller_city | VARCHAR | City where seller is located (standardized lowercase) |
| seller_state | VARCHAR | Brazilian state code |

*Note: 2 sellers existed in order data but were missing from the source sellers file — added as placeholder records with 'Unknown' location.*

---

### dim_payments
Payment dimension table.

| Column | Type | Description |
|---|---|---|
| order_id | VARCHAR | Links to fact_orders |
| payment_type | VARCHAR | Payment method (credit_card, boleto, voucher, debit_card, Unknown) |
| payment_installments | INT | Number of installments chosen |
| payment_value | FLOAT | Total payment amount in Brazilian Real (BRL) |