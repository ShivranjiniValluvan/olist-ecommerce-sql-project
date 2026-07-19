# 🧠 Advanced Analytics

This folder contains the Advanced Analytics phase of the Olist E-Commerce SQL Project. It builds on
the Gold layer star schema from the data warehouse project and the patterns found in the EDA phase,
using CTEs and window functions to answer 6 business questions across customer behavior, seller
performance, delivery, product trends, and payments.

## ❓ Business questions covered

1. Are customers coming back? (repeat purchase behavior)
2. Which sellers are reliable long-term vs. one-hit wonders?
3. Is delivery getting better or worse, and where?
4. Which product categories are rising and which are dying?
5. Who are the actual high-value customers?
6. Does payment method say anything about spend?

## 🛠️ Techniques used

* CTEs (single and chained)
* `ROW_NUMBER()` — sequencing customer orders chronologically
* `RANK()` — ranking sellers, states, and categories
* `LAG()` — month-over-month and year-over-year comparisons
* Running/moving aggregates — `SUM() OVER()`, `AVG() OVER()` for cumulative and moving-average calculations
* `CASE WHEN` — segmentation logic (seller reliability tiers, customer RFM segments)

## 📂 What's in this folder

| File | Description |
| ---- | ----------- |
| `advanced_analytics_queries.sql` | All 6 queries, in order |
| `findings.md` | Write-up of results for each question |

## ⚙️ Prerequisite

Requires the `olist_dwh` database and Gold layer views, which are built in the [data warehouse project](https://github.com/ShivranjiniValluvan/olist-ecommerce-sql-project).

📄 Full findings and key insights are documented in [`findings.md`](https://github.com/ShivranjiniValluvan/olist-ecommerce-sql-project/blob/main/advanced_analytics/findings.md).
