# Startup Ecosystem Analytics
### End-to-End Data Analysis Pipeline | Crunchbase 2013

> **Analyzing $419.7B in startup funding across 196K companies, 175 countries, and 52K funding rounds to answer: What factors determine a startup's ability to raise higher funding or reach Acquisition / IPO?**

---

## Project Background

This project was developed as a **Final Graduation Project** for the **NTI (National Telecommunications Institute) — Data Analysis Track**, Egypt.

It performs a complete end-to-end data analysis of the global startup ecosystem using the [Crunchbase 2013 Snapshot](https://www.kaggle.com/) dataset — covering real startup activity from 1990 up to December 2013.

---

## Team

| Name | Role |
|---|---|
| Ali Rabie | Data Pipeline Lead |
| Bilal Mohamed | SQL & Database Design |
| Assem Mohamed | Power BI & DAX |
| Mohamed Rifaat | Data Cleaning & EDA |
| Kamal Ragab | Dashboard Design |

---

## Strategic Question

> *"What factors determine a startup's ability to raise higher funding or reach Acquisition / IPO?"*

Broken into **4 analytical axes:**

| Axis | Business Question |
|---|---|
| Funding Analysis | Which sectors attract the most capital? What round types yield the highest amounts? |
| Startup Journey | What % of startups reach exit? How long from founding to first funding? |
| Investor Analysis | Who are the most active investors? Where do they focus? |
| Geographic Analysis | Which countries and cities dominate? Is Silicon Valley still king? |

---

## Key Findings

| Metric | Value |
|---|---|
| Total Funding Analyzed | $419.7B |
| Companies | 196,553 |
| Funding Rounds | 52,680 |
| Investments | 80,902 |
| Acquisitions | 9,561 |
| IPOs | 1,254 |
| Countries | 175 |
| Cities | 10,727 |
| Success Rate (IPO + Acquired) | 5.36% |
| Top Funded Sector | Biotech ($67B) |
| Most Active Investor | Intel Capital (527 deals) |
| Top Country by Funding | USA ($310B) |


---

## Repository Structure

```
startup-ecosystem-analytics/
│
├── 1_Data/
│   ├── raw/                        # 11 original CSV files from Kaggle
│   └── cleaned/                    # 6 cleaned tables exported from Python
│
├── 2_Data_Preparation_Python/
│   └── 01_data_cleaning_eda.ipynb  # Full cleaning pipeline + EDA summary
│
├── 3_Database_SQL_Server/
│   ├── 01_database_setup.sql       # CREATE DATABASE + inspection queries
│   ├── 02_data_cleaning.sql        # Orphan cleanup + FK constraints
│   └── 03_analytical_queries.sql   # SELECT queries used as Power BI source
│
├── 4_Data_Visualization_PowerBI/
│   └── startup_ecosystem.pbix      # Power BI file — model + DAX + dashboard
│
├── Project_Overview.pdf            # Full project documentation
└── README.md
```

---

## Pipeline Overview

```
Raw CSV (Kaggle)
      ↓
Python — 11 tables cleaned, zero duplicates, dtypes corrected
      ↓
SQL Server — Star schema, 15 FK constraints, ERD verified
      ↓
Power Query — Type corrections, date extraction, null handling
      ↓
Power BI — Star schema model, 11 DAX measures, 6-page dashboard
      ↓
GitHub — Documented repository
```

---

## Data Cleaning Highlights

- **11 tables** processed — **zero duplicate rows** across all tables
- **Date columns**: never imputed — missing dates preserve logical meaning
- **Foreign Key nulls**: rows dropped — cannot be joined to any table
- **Columns > 75% null**: dropped — no analytical value
- **category_code nulls** → filled with `'unknown'` (required for chart grouping)
- **funding_total_usd nulls** → filled with `0` (null = no funding = $0)
- **offices (0,0) coordinates** → filtered (invalid mid-ocean coordinates)

Full cleaning documentation: `Project_Overview.pdf`

---

## Database Schema

**Star Schema in SQL Server & Power BI:**

![Overview](/3_Database_SQL_Server/daigram.png)

![Overview](/4_Data_Visualization_PowerBI/modeling.png)


- **15 Foreign Key constraints** established in SQL Server
- **Inactive relationships** handled with `USERELATIONSHIP()` in DAX
- **Self-join** on `cleaned_objects.parent_id` for subsidiary hierarchy

---

## DAX Measures

| Measure | Description |
|---|---|
| `Total Raised USD` | SUM of raised_amount_usd |
| `Avg Raised per Round` | AVERAGE per round |
| `Median Raised` | MEDIAN — robust to outliers |
| `YoY Funding Growth` | Year-over-year % using DATEADD |
| `Success Rate %` | DIVIDE(Acquired + IPO, Total Companies) |
| `Avg Days to First Funding` | AVERAGEX with DATEDIFF |
| `Total Investments` | COUNTROWS(fac_investments) |
| `Investments by Investor` | CALCULATE + USERELATIONSHIP |
| `Avg Funding per Company` | DIVIDE(SUM, COUNTROWS) |
| `% of Total Funding` | DIVIDE with ALL() |
| `Round Size Category` | SWITCH on raised_amount_usd ranges |

---

## Dashboard Pages

| Page | Objective |
|---|---|
| **Overview** | High-level snapshot — KPIs, funding trend, category distribution |
| **Funding Dynamics** | Round types, amounts, YoY growth, treemap by sector |
| **Startup Journey** | Success rate, acquisitions, IPOs, time-to-funding |
| **Investor Network** | Top investors, activity trend, sector focus |
| **Geographic** | Country/city distribution, avg funding per company |
| **Strategic Insights** | 4 key findings with business value |

![Overview](/4_Data_Visualization_PowerBI/Dashboard_Screenshot/1.png)
![Funding](/4_Data_Visualization_PowerBI/Dashboard_Screenshot/2.png)
![Journey](/4_Data_Visualization_PowerBI/Dashboard_Screenshot/3.png)
![Investor](/4_Data_Visualization_PowerBI/Dashboard_Screenshot/4.png)
![Geographic](/4_Data_Visualization_PowerBI/Dashboard_Screenshot/5.png)

---

## Documentation

| File | Description |
|---|---|
| `Project_Overview.pdf` | Full project briefing — pipeline, decisions, findings |
| `Data Dictionary` | Raw + cleaned column definitions across all 11 tables |
| `README_Cleaning_EDA` | Detailed cleaning decisions and EDA summary |

---

## How to Reproduce

**1. Python Cleaning**
```bash
# Open notebooks/01_data_cleaning_eda.ipynb
# Place raw CSV files in 1_Data/raw/
# Run all cells
```

**2. SQL Server**
```sql
-- Run in order:
-- 3_Database_SQL_Server/01_database_setup.sql
-- 3_Database_SQL_Server/02_data_cleaning.sql
-- 3_Database_SQL_Server/03_analytical_queries.sql
```

**3. Power BI**
```
-- Open 4_Data_Visualization_PowerBI/startup_ecosystem.pbix
-- Update SQL Server connection string to your local instance
```

---

## Dataset

- **Source:** [Kaggle — Crunchbase 2013 Snapshot](https://www.kaggle.com/)
- **License:** © 2013 Crunchbase — for educational use only
- **Coverage:** Up to December 2013

---

## Academic Context

> This project was developed as the **Final Graduation Project** for the
> **NTI (National Telecommunications Institute) — Data Analysis Track**
> Benisuef, Egypt — 2026

---

*Built with  by the Startup Analytics Team — NTI 2026*
