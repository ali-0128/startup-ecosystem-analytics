# Power BI Dashboard Development
## Phase 4 — Power Query, Data Model, DAX Measures & Interactive Dashboard

**Crunchbase 2013 Startup Ecosystem Analysis**  
**NTI Data Analysis Track**  
*Ali Rabie - Bilal Mohamed - Asim Mohamed - Mohamed Rifaat - Kamal Ragab | 2026*

---

## Overview

This phase takes cleaned data from SQL Server and builds an interactive Power BI dashboard. The process includes:
1. **Data Import** — connecting to SQL Server and importing optimized queries
2. **Power Query** — transforming and validating data
3. **Data Modeling** — establishing relationships between dimensions and facts
4. **DAX Measures** — creating calculated columns and KPI measures
5. **Dashboard Design** — building visualizations and interactive reports

**Final Deliverable:** `startup_ecosystem_dashboard_preview.pdf` — Interactive Power BI dashboard

---

## Phase 1: Data Import from SQL Server

### Connection Setup

**Server Connection Details:**
- **Server Name:** localhost (or your SQL Server instance)
- **Database:** companies_startups
- **Connection Type:** SQL Server (Native)
- **Authentication:** Windows Authentication or SQL Login

### Data Import Process

**Step 1: Get Data → SQL Server**
1. Open Power BI Desktop
2. Click "Get Data" → "SQL Server"
3. Enter server name: `localhost`
4. Enter database: `companies_startups`
5. Select "Import" mode (loads data into memory for better performance)

**Step 2: Select Tables and Queries**

Import the following data sources from `2_select_queries_to_powerbi.sql`:

#### Fact Tables (Event-Level Data)
- **fac_funding_rounds** (52,680 rows)
  - Columns: id, funding_round_id, object_id, funded_at, funding_round_type, raised_amount_usd, pre_money_valuation_usd, post_money_valuation_usd, participants, is_first_round, is_last_round
  - Primary Key: id
  - Foreign Keys: object_id → dim_companies, funding_round_id → unique key

- **fac_investments** (80,902 rows)
  - Columns: id, funding_round_id, funded_object_id, investor_object_id
  - Primary Key: id
  - Foreign Keys: funded_object_id → dim_companies, investor_object_id → dim_investors

- **fac_acquisitions** (9,561 rows)
  - Columns: id, acquisition_id, acquiring_object_id, acquired_object_id, price_amount, acquired_at
  - Foreign Keys: acquiring_object_id, acquired_object_id → dim_companies

- **fac_ipos** (1,254 rows)
  - Columns: id, ipo_id, object_id, valuation_amount, raised_amount, public_at, stock_symbol
  - Foreign Key: object_id → dim_companies

#### Dimension Tables (Descriptive Attributes)
- **dim_companies** (196,553 rows)
  - Columns: id, name, category_code, status, founded_at, closed_at, country_code, city, region, funding_total_usd, funding_rounds, first_funding_at, last_funding_at, milestones, relationships
  - Primary Key: id

- **dim_people** (226,709 rows)
  - Columns: id, object_id, first_name, last_name, affiliation_name
  - Foreign Key: object_id → dim_companies

- **dim_investors** (derived from cleaned_objects where entity_type = 'Fund' or entity_type = 'Company')
  - Key investor entities for investment analysis

- **dim_relationships** (402,878 rows)
  - Columns: id, relationship_id, person_object_id, relationship_object_id, start_at, end_at, title, is_past
  - Links people to companies with job titles and tenure

### Data Load Performance

**Import Settings Optimized For:**
- **Total Records:** ~1.45 million
- **Model Size:** ~500 MB in memory
- **Load Time:** ~2-3 minutes for initial import
- **Refresh Strategy:** Scheduled weekly refresh (optional for live data)

---

## Phase 2: Power Query Transformations

### Data Cleaning in Power Query

**Applied Transformations:**

1. **Date Column Conversions**
   - Ensure all date columns are recognized as Date/DateTime type
   - Handle 47% nulls in fac_ipos[public_at] — kept as null (logical null = not yet IPO)

2. **Currency Standardization**
   - All monetary amounts are in USD
   - Removed currency code columns (not needed for visualization)

3. **Category Code Mapping**
   - Software (largest category)
   - Filled 'unknown' category values for filtering

4. **Status Normalization**
   - operating, acquired, closed, ipo
   - Used for company status analysis

5. **Investor Entity Classification**
   - Filtered dim_investors to only include entity_type ≠ 'Person'
   - Focuses on institutional investors and VC firms

### Query Folding Optimization
- Queries are folded back to SQL Server when possible
- Complex transformations are applied in Power BI for better control
- No unnecessary columns retained from source

![Overview](/4_Data_Visualization_PowerBI/PowerQuery.png)

---

## Phase 3: Data Modeling

### Relationship Architecture

**Star Schema Design:**

```
dim_companies (center)
    ↓
    ├── fac_funding_rounds (1:N)
    ├── fac_investments (1:N via funded_object_id)
    ├── fac_acquisitions (1:N as acquirer or acquired)
    ├── fac_ipos (1:N)
    ├── dim_people (1:N via object_id)
    └── dim_relationships (1:N)

dim_date (dimension for all date fields)
    ├── fac_funding_rounds[funded_at] (1:N, inactive by default)
    ├── dim_companies[founded_at] (1:N, requires USERELATIONSHIP)
    ├── fac_acquisitions[acquired_at] (1:N, inactive)
    └── dim_relationships[start_at] (1:N, inactive)
```

### Key Relationships

| From Table | Column | To Table | Column | Type | Direction | Active |
|-----------|--------|----------|--------|------|-----------|--------|
| fac_funding_rounds | object_id | dim_companies | id | N:1 | Both | Yes |
| fac_investments | funded_object_id | dim_companies | id | N:1 | Both | Yes |
| fac_investments | investor_object_id | dim_investors | id | N:1 | Both | Yes |
| fac_acquisitions | acquiring_object_id | dim_companies | id | N:1 | Both | Yes |
| fac_acquisitions | acquired_object_id | dim_companies | id | N:1 | Both | Yes |
| fac_ipos | object_id | dim_companies | id | N:1 | Both | Yes |
| dim_people | object_id | dim_companies | id | N:1 | Both | No |
| dim_relationships | person_object_id | dim_companies | id | N:1 | Both | No |
| dim_relationships | relationship_object_id | dim_companies | id | N:1 | Both | No |
| fac_funding_rounds | funded_at | dim_date | Date | N:1 | Both | No (Use USERELATIONSHIP) |
| dim_companies | founded_at | dim_date | Date | N:1 | Both | No (Use USERELATIONSHIP) |

**Design Rationale:**
- Multiple inactive relationships avoid filter context ambiguity
- USERELATIONSHIP() enables selective relationship activation in measures
- 1:N cardinality optimizes performance and avoids aggregation errors

![Overview](/4_Data_Visualization_PowerBI/modeling.png)

---

## Phase 4: DAX Measures

### 4.1 Date Dimension

```dax
Dim_Date = 
ADDCOLUMNS(
    CALENDAR(DATE(1990, 1, 1), DATE(2013, 12, 31)),
    "Year",        YEAR([Date]),
    "Month Number", MONTH([Date]),
    "Month Name",  FORMAT([Date], "MMMM"),
    "Month Short", FORMAT([Date], "MMM"),
    "Quarter",     "Q" & QUARTER([Date]),
    "Quarter Number", QUARTER([Date]),
    "Year-Month",  FORMAT([Date], "YYYY-MM"),
    "Year-Quarter", YEAR([Date]) & " Q" & QUARTER([Date]),
    "Day",         DAY([Date]),
    "Day Name",    FORMAT([Date], "DDDD"),
    "Day Short",   FORMAT([Date], "DDD"),
    "Is Weekend",  IF(WEEKDAY([Date], 2) >= 6, TRUE(), FALSE()),
    "Decade",      YEAR([Date]) - MOD(YEAR([Date]), 10)
)
```

**Purpose:** Time dimension for time-series analysis  
**Usage:** Year-over-year comparisons, monthly trends, quarterly analysis

---

### 4.2 Funding Metrics

#### Total Raised USD
```dax
Total Raised USD = SUM(fac_funding_rounds[raised_amount_usd])
```
**Description:** Total capital invested across all funding rounds  
**Context:** Responds to filters on company, round type, year, country  
**Example:** "$419.7B total raised across entire ecosystem"

#### Avg Raised per Round
```dax
Avg Raised per Round = AVERAGE(fac_funding_rounds[raised_amount_usd])
```
**Description:** Average funding amount per round  
**Insight:** $8.0M average indicates presence of mega-rounds (outliers)

#### Median Raised
```dax
Median Raised = MEDIAN(fac_funding_rounds[raised_amount_usd])
```
**Description:** Median funding per round (50th percentile)  
**Insight:** $1.6M median vs $8.0M mean shows extreme outliers  
**Use:** More robust measure than mean for skewed distributions

#### Number of Rounds
```dax
Number of Rounds = COUNTROWS(fac_funding_rounds)
```
**Description:** Count of distinct funding events  
**Usage:** Track total rounds in selected time period/region

#### YoY Funding Growth
```dax
YoY Funding Growth = 
VAR CurrentYear = SUM(fac_funding_rounds[raised_amount_usd])
VAR PrevYear =
    CALCULATE(
        SUM(fac_funding_rounds[raised_amount_usd]),
        DATEADD(dim_date[Date], -1, YEAR)
    )
RETURN DIVIDE(CurrentYear - PrevYear, PrevYear, 0)
```
**Description:** Year-over-year percentage change in total funding  
**Logic:** (Current Year $ - Previous Year $) / Previous Year $  
**Visualization:** Trend charts, growth cards  
**Note:** Returns 0 if previous year has no data (avoids errors)

#### YoY Growth Label
```dax
YoY Growth Label = 
VAR CurrentYear = 
    CALCULATE(SUM(fac_funding_rounds[raised_amount_usd]))
VAR PrevYear =
    CALCULATE(
        SUM(fac_funding_rounds[raised_amount_usd]),
        DATEADD(dim_date[Date], -1, YEAR)
    )
VAR GrowthPct = DIVIDE(CurrentYear - PrevYear, PrevYear, 0)
RETURN
    IF(
        PrevYear = 0,
        "N/A",
        FORMAT(GrowthPct, "+0.0%;-0.0%;0.0%")
    )
```
**Description:** Formatted YoY growth as text with +/- symbol  
**Output Format:** "+15.3%" or "-8.2%" or "0.0%"  
**Usage:** Labels on cards and charts for user-friendly display

---

### 4.3 Company Metrics

#### Total Companies
```dax
Total Companies = COUNTROWS(dim_companies)
```
**Description:** Distinct count of all company entities (196,553)  
**Usage:** Total ecosystem size metric

#### Operating Companies
```dax
Operating Companies = 
CALCULATE(COUNTROWS(dim_companies), dim_companies[status] = "operating")
```
**Description:** Companies still in business  
**Result:** ~183,441 (93.5% of total)

#### Acquired Companies
```dax
Acquired Companies = 
CALCULATE(COUNTROWS(dim_companies), dim_companies[status] = "acquired")
```
**Description:** Companies purchased by others  
**Result:** ~9,394 successful exits

#### IPO Companies
```dax
IPO Companies = 
CALCULATE(COUNTROWS(dim_companies), dim_companies[status] = "ipo")
```
**Description:** Companies gone public  
**Result:** ~1,134 IPO exits

#### Closed Companies
```dax
Closed Companies = 
CALCULATE(COUNTROWS(dim_companies), dim_companies[status] = "closed")
```
**Description:** Failed/defunct companies  
**Result:** ~2,584

#### Success Rate %
```dax
Success Rate % = 
DIVIDE(
    [Acquired Companies] + [IPO Companies],
    [Total Companies],
    0
) * 100
```
**Description:** Percentage of companies with successful exit  
**Calculation:** (Acquired + IPO) / Total Companies × 100  
**Result:** ~5.7% exit rate (realistic for startup ecosystem)

#### Funded Companies %
```dax
Funded Companies % = 
DIVIDE(
    CALCULATE(COUNTROWS(Dim_Companies), 
              Dim_Companies[funding_total_usd] > 0),
    COUNTROWS(Dim_Companies)
) * 100
```
**Description:** Percentage of companies that received external funding  
**Insight:** Most startups rely on bootstrapping or angel investors not in dataset

#### Companies Founded by Year
```dax
Companies Founded by Year = 
CALCULATE(
    COUNTROWS(Dim_Companies),
    USERELATIONSHIP(Dim_Date[Date], Dim_Companies[founded_at])
)
```
**Description:** Company count by founding year  
**Note:** Uses USERELATIONSHIP because founded_at relationship is inactive by default  
**Visualization:** Line chart showing startup activity over time

#### Avg Funding per Company
```dax
Avg Funding per Company = 
DIVIDE(
    SUM(Dim_Companies[funding_total_usd]),
    COUNTROWS(Dim_Companies)
)
```
**Description:** Average total funding received per company  
**Usage:** Geographic and sector comparisons

#### % of Total Funding
```dax
% of Total Funding = 
DIVIDE(
    SUM(dim_companies[funding_total_usd]),
    CALCULATE(SUM(dim_companies[funding_total_usd]), ALL(dim_companies)),
    0
) * 100
```
**Description:** Share of total ecosystem funding by selected group  
**Usage:** Pie charts showing funding concentration by country/sector

---

### 4.4 Investment Metrics

#### Total Investments
```dax
Total Investments = COUNTROWS(fac_investments)
```
**Description:** Total investor-to-round participation records (80,902)

#### Unique Companies Funded
```dax
Unique Companies Funded = 
DISTINCTCOUNT(fac_investments[funded_object_id])
```
**Description:** Count of distinct companies that received investment  
**Usage:** Market penetration metric

#### Unique Investors
```dax
Unique Investors = 
DISTINCTCOUNT(Fac_Investments[investor_object_id])
```
**Description:** Distinct investor entities in the ecosystem  
**Usage:** Investor diversity analysis

#### Investments by Investor
```dax
Investments by Investor = 
CALCULATE(
    COUNTROWS(fac_investments),
    USERELATIONSHIP(fac_investments[investor_object_id], dim_investors[id]))
```
**Description:** Investment count per investor  
**Usage:** Top investor identification  
**Example:** Sequoia Capital > 500 investments

#### Top Invested Category
```dax
Top Invested Category = 
CALCULATE(
    COUNTROWS(Fac_Investments),
    TOPN(
        1,
        VALUES(Dim_Companies[category_code]),
        CALCULATE(COUNTROWS(Fac_Investments))
    )
)
```
**Description:** Category with highest investment count  
**Result:** Software (majority of investment)

---

### 4.5 Geographic Metrics

#### Companies by Country
```dax
Companies by Country = 
CALCULATE(COUNTROWS(dim_companies), ALLEXCEPT(dim_companies, dim_companies[country_code]))
```
**Description:** Company distribution by country  
**Usage:** Geographic heatmaps and rankings

#### Funding by Country
```dax
Funding by Country = 
CALCULATE(SUM(dim_companies[funding_total_usd]))
```
**Description:** Total funding by country  
**Insight:** USA dominates with ~60% of total funding

---

### 4.6 Time-to-Success Metrics

#### Avg Funding by Founded Year
```dax
Avg Funding by Founded Year = 
CALCULATE(
    AVERAGE(Dim_Companies[funding_total_usd]),
    USERELATIONSHIP(Dim_Date[Date], Dim_Companies[founded_at]),
    Dim_Companies[funding_total_usd] > 0
)
```
**Description:** Average funding amount per company cohort  
**Usage:** Trend analysis showing funding levels by vintage year

#### Avg Rounds Before Exit
```dax
Avg Rounds Before Exit = 
CALCULATE(
    AVERAGE(Dim_Companies[funding_rounds]),
    Dim_Companies[status] IN {"acquired", "ipo"}
)
```
**Description:** Average number of funding rounds for exit companies  
**Result:** ~4.2 rounds average for successful companies  
**Insight:** Companies typically take 4+ rounds to reach exit stage

#### Avg Time to First Funding (Days)
```dax
Avg Time to First Funding (Days) = 
AVERAGEX(
    FILTER(dim_companies, dim_companies[first_funding_at] <> BLANK()),
    DATEDIFF(dim_companies[founded_at], dim_companies[first_funding_at], DAY)
)
```
**Description:** Average days from founding to first funding  
**Calculation:** founded_at → first_funding_at (in days)  
**Result:** ~500-600 days average  
**Usage:** Founder runway analysis

---

## Phase 5: Dashboard Design

### Dashboard Name & Theme
**File:** `startup_ecosystem_dashboard_preview.pdf`  
**Title:** Crunchbase 2013 Startup Ecosystem Analysis  
**Theme:** Professional corporate blue with accent orange  
**Dimensions:** 16:9 widescreen format

### Dashboard Structure

**Page 1: Executive Summary**
- Total Companies, Total Raised, Total Investments (KPI cards)
- Success Rate %, Operating Companies, Acquired Companies
- YoY Funding Growth trend
- Status distribution pie chart

**Page 2: Funding Analysis**
- Total Raised by Year (line chart)
- YoY Growth Rate (column chart with growth % labels)
- Avg Raised per Round trend
- Median vs Average comparison
- Funding by Round Type (bar chart)

**Page 3: Geographic Analysis**
- Map visualization: Companies by Country (with size = funding amount)
- Top 10 Countries by funding (table)
- Top 10 Cities by company count
- Country filter slicer

**Page 4: Investor Landscape**
- Top 20 Investors by investment count (horizontal bar)
- Unique Investors over time (line chart)
- Investments by Investor (filtered view)
- Investor name filter slicer

**Page 5: Startup Journey**
- Companies Founded by Year (area chart)
- Status distribution (stacked bar: operating/acquired/closed/ipo)
- Success Rate % trend
- Avg Funding by Founded Year (combo chart)
- Avg Rounds Before Exit vs. Total Rounds

**Page 6: Category & Sector Analysis**
- Companies by Category (bar chart, top 15)
- Top Invested Category
- Funding by Category (pie chart)
- Avg Funding per Company by Category
- Category filter slicer

### Interactivity Features

**Slicers Implemented:**
- Year (multi-select)
- Country (multi-select)
- Funding Round Type (multi-select)
- Company Status (multi-select)
- Category Code (multi-select)
- Founded Year (range slider)

**Cross-Filtering:**
- All cards, charts, and tables filter based on selected slicers
- Sync slicers across all pages for consistent user experience

**Tooltips:**
- Detailed information on hover (showing filtered values)
- Context-aware labels with thousands separators and currency symbols

### Key Performance Indicators (KPI Cards)

| KPI | Value | Trend |
|-----|-------|-------|
| Total Companies | 196,553 | — |
| Total Raised (USD) | $419.7B | ↑ (YoY) |
| Total Investments | 80,902 | ↑ |
| Success Rate | 5.7% | Stable |
| Avg Funding | $2.1M | Varies by year |
| Operating Companies | 183,441 | 93.5% |

---

## Phase 6: Dashboard Export

### PDF Export Settings
- **Format:** PDF (read-only)
- **Filename:** `startup_ecosystem_dashboard_preview.pdf`
- **Pages:** 6 pages (one per dashboard section)
- **Quality:** High resolution (300 DPI)
- **Interactivity:** Static PDF (no filters in exported version)

### Publishing 
1. **Publish to Power BI Service** — Full interactivity online
2. **Share as PBIX file** — Full editing capability
3. **Export as PDF** — Current approach
