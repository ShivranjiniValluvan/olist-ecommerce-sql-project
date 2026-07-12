# 🏪 Olist E-Commerce SQL Project

## 📌 Overview

An end-to-end SQL project built on the Olist Brazilian E-Commerce Dataset, containing over 100,000 orders across multiple Brazilian marketplaces.
The project covers the full SQL analytics lifecycle — starting with a Data Warehouse built using Medallion Architecture (Bronze → Silver → Gold) to transform raw transactional data into a structured, analytics-ready Star Schema, followed by Exploratory Data Analysis (EDA) on the resulting Gold layer.

## 🏗️ Architecture

The data architecture follows three progressive layers:

**🟤 Bronze Layer** — Raw data ingested as-is from 8 CSV source files into SQL Server using stored procedures and BULK INSERT. No transformations applied.

**🥈 Silver Layer** — Data cleaned, standardized, and enriched. Includes duplicate removal, date casting, derived columns (delivery_days, late_flag), category translation (Portuguese → English), and data enrichment.

**🥇 Gold Layer** — Business-ready Star Schema built as SQL Views, optimized for analytical reporting.

![Architecture Diagram](docs/architecture.png)

## 📂 Repository Structure

```
olist-ecommerce-sql-project/
│
├── data_quality/
│   ├── quality_checks_gold.sql
│   └── quality_checks_silver.sql
│
├── docs/
│   ├── architecture.png
│   └── data_catalog.md
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   ├── explore_bronze.sql
│   │   └── load_silver.sql
│   │
│   ├── gold/
│   │   └── ddl_gold.sql
│   │
│   └── init_database.sql
│
├── eda/
│   ├── eda_queries.sql
│   ├── findings.md
│   └── README.md
│
└── README.md
```

## 📊 Dataset

Source: [Olist Brazilian E-Commerce Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| File | Description |
|---|---|
| olist_customers_dataset.csv | Customer information and location |
| olist_orders_dataset.csv | Order lifecycle and timestamps |
| olist_order_items_dataset.csv | Products purchased in each order |
| olist_order_payments_dataset.csv | Payment methods and values |
| olist_order_reviews_dataset.csv | Customer ratings and comments |
| olist_products_dataset.csv | Product details and categories |
| olist_sellers_dataset.csv | Seller information |
| product_category_name_translation.csv | Portuguese to English category mapping |

## 🥇 Gold Layer — Star Schema

```
dim_customers ─────┐
dim_products  ─────┤
                   ├──── fact_orders
dim_sellers   ─────┤
dim_payments  ─────┘
```

For full column descriptions → `docs/data_catalog.md`

## ✅ Data Quality

Validation checks include:
- Duplicate detection
- Null value checks
- Referential integrity
- Business rule validation

All checks are located in the `data_quality/` folder.

## 📊
Exploratory Data Analysis

SQL-based EDA performed on the Gold layer, covering database structure, dimensions, key measures, and business patterns such as revenue distribution and delivery performance.

📂 View Project → [`eda/`](./eda)

## ▶️ How to Run

**Prerequisites:**
- SQL Server Express
- SQL Server Management Studio (SSMS)

**Steps:**
1. Download dataset from Kaggle
2. Update file paths in `load_bronze.sql` to match your local dataset location
3. Run scripts in this order:
   - `scripts/init_database.sql`
   - `scripts/bronze/ddl_bronze.sql`
   - `scripts/bronze/load_bronze.sql`
   - `scripts/silver/ddl_silver.sql`
   - `scripts/silver/load_silver.sql`
   - `scripts/gold/ddl_gold.sql`
4. Run validation scripts in `data_quality/`
5. For EDA queries, run `eda/eda_queries.sql` after the Gold layer is built.

## 🛠️ Technologies Used

| Tool | Purpose |
|---|---|
| SQL Server Express | Database engine |
| SSMS | SQL development and execution |
| Draw.io | Architecture diagram |
| GitHub | Version control and portfolio |
