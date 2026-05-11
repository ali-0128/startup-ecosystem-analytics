# Data Cleaning & EDA Documentation

**Final Project — Crunchbase 2013 Startup Ecosystem**  
**NTI Data Analysis Track**  
*Ali Rabie - Bilal Mohamed - Assem Mohamed - Mohamed Rifaat - Kamal Ragab | 2026*

---

## 1. Project Overview

This project analyzes the Crunchbase 2013 Startup Ecosystem dataset to identify the key factors influencing startup funding trajectories and success outcomes. The final deliverable is an interactive Power BI dashboard supporting data-driven investment decision-making.

**Tools used in this phase:**
- Python (Pandas, NumPy & IPython.display) — Data cleaning and EDA
- Jupyter Notebook & VS-Code — Development environment

---

## 2. Dataset Overview

**Source:** Kaggle — Crunchbase 2013 Snapshot  
**Coverage:** Up to December 2013  
**Structure:** 11 interrelated tables linked via unique IDs

**Table sizes before cleaning:**

| Table | Rows | Columns |
|-------|------|---------|
| acquisitions | 9,562 | 12 |
| degrees | 109,610 | 8 |
| funding_rounds | 52,928 | 23 |
| funds | 1,564 | 11 |
| investments | 80,902 | 6 |
| ipos | 1,259 | 13 |
| milestones | 39,456 | 9 |
| objects | 462,651 | 40 |
| offices | 112,718 | 15 |
| people | 226,709 | 6 |
| relationships | 402,878 | 11 |

---

## 3. Initial Exploration

Each table was inspected across the following dimensions before any cleaning was applied:
- **Shape** — row and column counts
- **Duplicated Rows** — count and percentage of exact duplicate rows
- **Data Types** — column-level dtype inspection
- **Describe** — full descriptive statistics for numeric and categorical columns
- **Missing Data** — count and percentage of nulls per column, sorted descending
- **First & Last 10 Rows** — data preview
- **Summary** — combined snapshot including columns-with-missing count

**Key findings from initial exploration:**
- No duplicate rows were found in any of the 11 tables
- The objects table contains 4 entity types: Company, Person, Fund, Product
- The offices table has created_at and updated_at columns that are 100% empty
- The milestones table has a milestone_code column with a single value 'other' across all 39,456 rows — zero analytical value
- The offices latitude and longitude columns contain (0, 0) values which are invalid coordinates (mid-ocean)
- The objects table raised a DtypeWarning due to mixed-type columns read at low_memory=True
- All date columns across all tables are stored as object dtype instead of datetime64

---

## 4. Cleaning Decisions & Rationale

Every cleaning decision was based on three factors:
- Column data type (numeric / categorical / date)
- Percentage of missing values
- Relevance to the defined Business Questions

### 4.1 General Rules Applied Across All Tables
- **Date columns:** never imputed — missing dates are left as NaT
- **Foreign Keys:** rows missing a FK are dropped — they cannot be joined to any other table
- **Logically meaningful nulls:** left as-is (e.g. closed_at = null means the company is still open)
- **Categorical columns with limited values:** filled with Mode or a meaningful default
- **Columns with over 75% missing:** dropped — they add no analytical value
- **Source columns (source_url, source_description):** ignored across all tables — not used in analysis

### 4.2 Column-Level Decisions

| Table | Column | Missing % | Decision | Reason |
|-------|--------|-----------|----------|--------|
| acquisitions | term_code | 80.07% | Drop column | Over 75% missing |
| acquisitions | source_url | 10.42% | Leave as-is | Not used in analysis |
| acquisitions | source_description | 10.17% | Leave as-is | Not used in analysis |
| acquisitions | acquired_at | 0.30% | Leave as-is | Date — never imputed |
| acquisitions | price_currency_code | 0.04% | fillna('USD') | 98.4% of values are USD |
| acquisitions | acquired_object_id | 0.01% | Drop row | Foreign Key — row is useless without it |
| funding_rounds | pre_money_currency_code | 49.21% | Drop column | Over 30% missing + USD column exists |
| funding_rounds | post_money_currency_code | 42.47% | Drop column | Same reason |
| funding_rounds | source_url | 23.70% | Leave as-is | Not used in analysis |
| funding_rounds | source_description | 17.93% | Leave as-is | Not used in analysis |
| funding_rounds | created_by | 8.76% | Leave as-is | Not used in analysis |
| funding_rounds | raised_currency_code | 5.79% | fillna('USD') | 91.7% of values are USD |
| funding_rounds | funded_at | 0.47% | Drop row (248 rows) | Critical date for time-series analysis |
| ipos | source_description | 85.70% | Drop column | Over 75% missing |
| ipos | source_url | 84.83% | Drop column | Over 75% missing |
| ipos | public_at | 47.66% | Leave as-is | Date — never imputed |
| ipos | raised_currency_code | 44.48% | fillna('USD') | All existing values are USD |
| ipos | object_id | 0.40% | Drop row (5 rows) | Primary Foreign Key |
| ipos | valuation_currency_code | 0.16% | fillna('USD') | Only 2 values missing |
| objects | short_description | 98.35% | Drop column | Over 75% missing |
| objects | description | 79.47% | Drop column | Over 75% missing |
| objects | tag_list | 76.98% | Drop column | Over 75% missing |
| objects | category_code | 73.37% | fillna('unknown') | Critical for sector analysis |
| objects | funding_total_usd | 0% | fillna(0) | null = no funding received = 0 |
| objects | closed_at | 99.39% | Leave as-is | null = company is still open (logical) |
| offices | created_at | 100% | Drop column | Completely empty |
| offices | updated_at | 100% | Drop column | Completely empty |
| offices | lat/lng = 0.0 | — | Filter rows | (0,0) = mid-ocean, invalid coordinates |
| milestones | milestone_code | 0% | Drop column | Single value 'other' across all rows — no analytical value |
| people | birthplace | 87.61% | Drop column | Over 75% missing |
| relationships | end_at | 74.92% | Leave as-is | null = relationship still active (logical) |
| relationships | start_at | 48.62% | Leave as-is | Date — never imputed |

---

## 5. Data Type Corrections

The following columns were converted from their original dtype to the correct type:

| Table | Columns | Conversion |
|-------|---------|------------|
| acquisitions | acquired_at, created_at, updated_at | object → datetime64 |
| degrees | graduated_at, created_at, updated_at | object → datetime64 |
| funding_rounds | funded_at, created_at, updated_at | object → datetime64 |
| funding_rounds | is_first_round, is_last_round | int64 → bool |
| funds | funded_at, created_at, updated_at | object → datetime64 |
| investments | created_at, updated_at | object → datetime64 |
| ipos | public_at, created_at, updated_at | object → datetime64 |
| milestones | milestone_at, created_at, updated_at | object → datetime64 |
| objects | founded_at, closed_at, first/last_funding_at, first/last_milestone_at, ... | object → datetime64 |
| relationships | start_at, end_at, created_at, updated_at | object → datetime64 |
| relationships | is_past | int64 → bool |

---

## 6. Tables After Cleaning

| Table | Rows | Columns | Dupes | Notes |
|-------|------|---------|-------|-------|
| acquisitions | 9,561 | 9 | 0 | 1 row dropped (missing FK) |
| degrees | 109,610 | 8 | 0 | Light cleaning only (table not used in analysis) |
| funding_rounds | 52,680 | 18 | 0 | 248 rows dropped (missing funded_at) |
| funds | 1,564 | 9 | 0 | Source columns dropped only |
| investments | 80,902 | 6 | 0 | No missing — dtype conversion only |
| ipos | 1,254 | 11 | 0 | 5 rows dropped (missing object_id) |
| milestones | 39,456 | 7 | 0 | milestone_code dropped (single value) |
| objects | 462,651 | 28 | 0 | 12 columns dropped + category_code fillna |
| offices | 112,718 | 11 | 0 | Filtered (0,0) coords + 100% missing columns dropped |
| people | 226,709 | 5 | 0 | birthplace dropped (87% missing) |
| relationships | 402,878 | 11 | 0 | Dtype conversion only |

---

## 7. EDA Summary

After cleaning, the following summary was extracted to validate data integrity and serve as a reference for downstream phases:

| Metric | Value |
|--------|-------|
| Total Companies | 196,553 |
| Total Funding Rounds | 52,680 |
| Total Investments | 80,902 |
| Total Acquisitions | 9,561 |
| Total IPOs | 1,254 |
| Total Raised (USD) | $419.7B |
| Avg Raised per Round | $8.0M |
| Median Raised per Round | $1.6M |
| Top Round Type | Venture |
| Operating Companies | 183,441 |
| Acquired Companies | 9,394 |
| Closed Companies | 2,584 |
| IPO Companies | 1,134 |
| Top Category (by count) | Software |
| Top Country (by count) | USA |
| Total Countries Covered | 175 |
| Total Cities Covered | 10,727 |

**Key observations:**
- Total funding of $419.7B with a median of $1.6M vs. mean of $8.0M — strong indication of extreme outliers in the data
- 93.5% of companies are still operating, consistent with the dataset being a point-in-time snapshot
- Software is the most common sector by company count
- USA dominates both company count and total funding
- Coverage spans 175 countries and 10,727 cities — strong foundation for geographic analysis
- Venture is the most common funding round type

---

## 8. Business Questions

The analysis is structured around one strategic question:  
**"What factors determine a startup's ability to raise higher funding or reach acquisition / IPO?"**

This is broken down into four analytical axes:
- **Funding Analysis** — round types, raised amounts, year-over-year trends
- **Startup Journey** — status distribution, sector performance, acquisitions and IPOs over time
- **Investor Analysis** — most active investors, investment activity trends
- **Geographic Analysis** — country and city-level distribution of companies and funding

---

## 9. Next Steps

- Export cleaned tables as CSV files
- Upload tables to SQL Server and build the database schema
- Design ERD and define relationships between tables
- Write analytical SQL queries to answer Business Questions
- Import data into Power BI via Power Query
- Build Data Model and create DAX measures
- Design interactive dashboard
- Push full project to GitHub with comprehensive README