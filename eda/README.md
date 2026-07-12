# Exploratory Data Analysis (EDA)

This folder contains the EDA phase of the Olist E-Commerce SQL Project. It builds on
the Gold layer views created in the data warehouse project and explores the data to
understand its structure, key measures, and business patterns before moving into
advanced analytics.

## What's in this folder

| File | Description |
|---|---|
| `eda_queries.sql` | All EDA queries, organized into 6 sections: Database Exploration, Dimensions Exploration, Date Range Exploration, Measures Exploration, Magnitude Exploration, and Ranking Exploration |
| `findings.md` | Summary of key observations and patterns found while running the queries |

## Approach

The analysis follows a structured EDA flow, moving from understanding the database
itself to exploring specific business patterns:

1. **Database Exploration** — what tables/views exist and their structure
2. **Dimensions Exploration** — distinct values in key categorical columns
3. **Date Range Exploration** — the time period the data covers
4. **Measures Exploration** — overall totals and averages
5. **Magnitude Exploration** — how revenue breaks down across states and categories
6. **Ranking Exploration** — top sellers and delivery performance by state

## Prerequisite

Requires the `olist_dwh` database and Gold layer views, which are built in the
[data warehouse project](../) (Project 1).

Full findings and key insights are documented in [`findings.md`](./findings.md).
