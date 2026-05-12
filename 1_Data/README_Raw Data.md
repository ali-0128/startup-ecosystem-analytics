# Data Dictionary 
## Crunchbase 2013 — Startup Ecosystem Analysis

**crunchbase-startup-ecosystem-analysis**

*NTI Data Analysis Track | Ali Rabie - Bilal Mohamed - Assem Mohamed - Mohamed Rifaat - Kamal Ragab | 2026*

---

## Document Summary

| Property | Value |
|----------|-------|
| **Dataset Source** | Kaggle — Crunchbase 2013 Snapshot © Crunchbase |
| **Coverage** | Up to December 2013 |
| **Total Tables** | 11 tables |
| **Total Raw Records** | ~1,450,000 records across all tables |
| **Central Table** | objects (cleaned: cleaned_objects) — backbone of the entire schema |
| **Cleaning Tool** | Python( Pandas, Numpy & IPython.display ) Jupyter Notebook - VS-Code |
| **Database** | SQL Server — companies_startups |
| **Key Convention** | PK = Primary Key · FK = Foreign Key · — = Regular column · NaT = Logical null date |

---
**Datasts link**
https://drive.google.com/drive/folders/1DtKK2Y_vkZXZmcFR5XQJ6lIGfxG3XB3B?usp=drive_link

---

# Raw Data Description

The following tables describe the dataset exactly as downloaded from Kaggle — before any cleaning, transformation, or column removal. Data types shown are as inferred by Pandas on import.

| Table | Rows | Columns | Entity Types / Notes |
|-------|------|---------|----------------------|
| acquisitions | 9,562 | 12 | Fact — acquisition deals |
| degrees | 109,610 | 8 | Dimension — person credentials |
| funding_rounds | 52,928 | 23 | Fact — funding events |
| funds | 1,564 | 11 | Fact — VC fund records |
| investments | 80,902 | 6 | Fact — investor-to-round links |
| ipos | 1,259 | 13 | Fact — IPO records |
| milestones | 39,456 | 9 | Dimension — company events |
| objects | 462,651 | 40 | Central hub — 4 entity types: Company, Person, Fund, Product |
| offices | 112,718 | 15 | Dimension — office locations |
| people | 226,709 | 6 | Dimension — individual profiles |
| relationships | 402,878 | 11 | Dimension — person-to-company roles |

**Note:** The objects table contains a DtypeWarning on import due to mixed-type columns. This is resolved by specifying low_memory=False in pd.read_csv().

---

## acquisitions

**Type:** Raw  
**Rows:** 9,562 | **Columns:** 12  
**PK:** id | **FK →** acquiring_object_id, acquired_object_id → objects.id

**Description:** Every acquisition deal recorded on Crunchbase — who bought whom, price, and date.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| acquisition_id | INT | — | Crunchbase internal acquisition identifier |
| acquiring_object_id | OBJECT | FK | ID of the acquiring company → objects.id |
| acquired_object_id | OBJECT | FK | ID of the acquired company → objects.id |
| term_code | OBJECT | — | Deal structure type (cash / stock / cash_and_stock). 80.07% null |
| price_amount | FLOAT | — | Deal value in price_currency_code. 0 where not disclosed |
| price_currency_code | OBJECT | — | Currency of the deal. 0.04% null |
| acquired_at | OBJECT | — | Date the deal was completed. 0.30% null |
| source_url | OBJECT | — | News source URL. 10.42% null |
| source_description | OBJECT | — | News source label. 10.17% null |
| created_at | OBJECT | — | Record creation timestamp in Crunchbase |
| updated_at | OBJECT | — | Record last update timestamp |

---

## degrees

**Type:** Raw  
**Rows:** 109,610 | **Columns:** 8  
**PK:** id | **FK →** object_id → objects.id

**Description:** Academic credentials of individuals. Linked to Person entities in objects.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| object_id | OBJECT | FK | Person entity ID → objects.id |
| degree_type | OBJECT | — | Degree level (BS, MS, MBA, PhD…). 10.24% null |
| subject | OBJECT | — | Field of study. 25.83% null |
| institution | OBJECT | — | University or institution name. 0.05% null |
| graduated_at | OBJECT | — | Graduation date. 47.04% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## funding_rounds

**Type:** Raw  
**Rows:** 52,928 | **Columns:** 23  
**PK:** id | **FK →** object_id → objects.id

**Description:** Every funding round received by a startup — the primary financial fact table.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| funding_round_id | INT | PK/FK | Unique round ID — referenced by investments table |
| object_id | OBJECT | FK | Company that received this funding → objects.id |
| funded_at | OBJECT | — | Date the round closed. 0.47% null |
| funding_round_type | OBJECT | — | Round category: venture, angel, series-a/b/c, private-equity, post-ipo, crowdfunding, other |
| funding_round_code | OBJECT | — | Specific code: a, b, c, seed, angel, unattributed, debt_round, partial |
| raised_amount_usd | FLOAT | — | Amount raised in USD. 0 where not disclosed |
| raised_amount | FLOAT | — | Amount in original currency |
| raised_currency_code | OBJECT | — | Original currency. 5.79% null |
| pre_money_valuation_usd | FLOAT | — | Valuation before the round in USD. 0 where not disclosed |
| pre_money_valuation | FLOAT | — | Valuation before in original currency |
| pre_money_currency_code | OBJECT | — | Currency of pre-money valuation. 49.21% null |
| post_money_valuation_usd | FLOAT | — | Valuation after the round in USD. 0 where not disclosed |
| post_money_valuation | FLOAT | — | Valuation after in original currency |
| post_money_currency_code | OBJECT | — | Currency of post-money valuation. 42.47% null |
| participants | INT | — | Number of investors in this round |
| is_first_round | INT | — | 1 if this is the company's first round |
| is_last_round | INT | — | 1 if this is the company's most recent round |
| source_url | OBJECT | — | News source URL. 23.70% null |
| source_description | OBJECT | — | News source label. 17.93% null |
| created_by | OBJECT | — | Crunchbase user who created this record. 8.76% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## funds

**Type:** Raw  
**Rows:** 1,564 | **Columns:** 11  
**PK:** id | **FK →** object_id → objects.id

**Description:** Investment funds raised by VC firms to deploy into startups.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| fund_id | INT | — | Crunchbase internal fund identifier |
| object_id | OBJECT | FK | VC firm that owns this fund → objects.id |
| name | OBJECT | — | Fund name (e.g. Fund I, Fund II) |
| funded_at | OBJECT | — | Date the fund was established. 7.35% null |
| raised_amount | FLOAT | — | Total capital raised. 0 where not disclosed |
| raised_currency_code | OBJECT | — | Currency of the fund |
| source_url | OBJECT | — | News source URL. 18.67% null |
| source_description | OBJECT | — | News source label. 22.12% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## investments

**Type:** Raw  
**Rows:** 80,902 | **Columns:** 6  
**PK:** id | **FK →** funding_round_id → funding_rounds, funded_object_id → objects.id, investor_object_id → objects.id

**Description:** Junction table linking investors to funding rounds. Zero missing values.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| funding_round_id | INT | FK | The round being invested in → funding_rounds.funding_round_id |
| funded_object_id | OBJECT | FK | The company receiving investment → objects.id |
| investor_object_id | OBJECT | FK | The entity making the investment → objects.id |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## ipos

**Type:** Raw  
**Rows:** 1,259 | **Columns:** 13  
**PK:** id | **FK →** object_id → objects.id

**Description:** Initial Public Offerings — companies that went public on a stock exchange.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| ipo_id | INT | — | Crunchbase internal IPO identifier |
| object_id | OBJECT | FK | The company that went public → objects.id. 0.40% null |
| valuation_amount | FLOAT | — | Company valuation at IPO. 0 where not disclosed |
| valuation_currency_code | OBJECT | — | Currency of valuation. 0.16% null |
| raised_amount | FLOAT | — | Amount raised from the IPO. 0 where not disclosed |
| raised_currency_code | OBJECT | — | Currency of raised amount. 44.48% null |
| public_at | OBJECT | — | IPO date. 47.66% null |
| stock_symbol | OBJECT | — | Exchange:Ticker (e.g. NASDAQ:AAPL) |
| source_url | OBJECT | — | News source URL. 84.83% null |
| source_description | OBJECT | — | News source label. 85.70% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## milestones

**Type:** Raw  
**Rows:** 39,456 | **Columns:** 9  
**PK:** id | **FK →** object_id → objects.id

**Description:** Significant events in a company or person's history.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| object_id | OBJECT | FK | Entity that achieved the milestone → objects.id |
| milestone_at | OBJECT | — | Date of the milestone event |
| milestone_code | OBJECT | — | Event category. Contains only 'other' across all 39,456 rows |
| description | OBJECT | — | Free-text description of the event |
| source_url | OBJECT | — | News source URL. 20.42% null |
| source_description | OBJECT | — | News source label. 25.82% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

---

## objects

**Type:** Raw  
**Rows:** 462,651 | **Columns:** 40  
**PK:** id | **FK →** Self-join: parent_id → objects.id

**Description:** Central hub containing all entities: Company, Person, Fund, Product. Every other table links here.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | OBJECT | PK | Unique entity ID. Prefix: c: = company, p: = person, f: = fund, r: = product |
| entity_type | OBJECT | — | Entity category: Company, Person, Fund, Product |
| entity_id | INT | — | Numeric ID within the entity type |
| parent_id | OBJECT | FK | Parent company ID for subsidiaries. 94.01% null |
| name | OBJECT | — | Display name. 0.00% null |
| normalized_name | OBJECT | — | Lowercase standardized name. 0.01% null |
| permalink | OBJECT | — | Unique URL slug (e.g. /company/facebook) |
| category_code | OBJECT | — | Industry sector. 73.37% null |
| status | OBJECT | — | Current state: operating, acquired, closed, ipo |
| founded_at | OBJECT | — | Company founding date. 78.29% null |
| closed_at | OBJECT | — | Shutdown date. 99.39% null |
| domain | OBJECT | — | Website domain. 62.19% null |
| homepage_url | OBJECT | — | Full website URL. 62.19% null |
| twitter_username | OBJECT | — | Twitter handle. 72.75% null |
| logo_url | OBJECT | — | Logo image URL. 54.86% null |
| logo_width | INT | — | Logo width in pixels |
| logo_height | INT | — | Logo height in pixels |
| short_description | OBJECT | — | Brief description. 98.35% null |
| description | OBJECT | — | Full description. 79.47% null |
| overview | OBJECT | — | Overview text. 49.15% null |
| tag_list | OBJECT | — | Comma-separated tags. 76.98% null |
| country_code | OBJECT | — | ISO country code. 79.46% null |
| state_code | OBJECT | — | State/region code. 88.16% null |
| city | OBJECT | — | City name. 80.40% null |
| region | OBJECT | — | Geographic region |
| first_investment_at | OBJECT | — | Date of first outgoing investment. 96.34% null |
| last_investment_at | OBJECT | — | Date of most recent outgoing investment. 96.34% null |
| investment_rounds | INT | — | Count of investment rounds as investor |
| invested_companies | INT | — | Count of distinct companies invested in |
| first_funding_at | OBJECT | — | Date of first received funding. 93.19% null |
| last_funding_at | OBJECT | — | Date of most recent received funding. 93.19% null |
| funding_rounds | INT | — | Total funding rounds received |
| funding_total_usd | FLOAT | — | Total funding in USD |
| first_milestone_at | OBJECT | — | Date of first milestone. 78.31% null |
| last_milestone_at | OBJECT | — | Date of most recent milestone. 78.31% null |
| milestones | INT | — | Total milestone count |
| relationships | INT | — | Count of linked relationships |
| created_by | OBJECT | — | Crunchbase user who created this record. 26.62% null |
| created_at | OBJECT | — | Record creation timestamp. 0.01% null |
| updated_at | OBJECT | — | Record last update timestamp |

---

## offices

**Type:** Raw  
**Rows:** 112,718 | **Columns:** 15  
**PK:** id | **FK →** object_id → objects.id

**Description:** Physical office locations with geographic coordinates.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| object_id | OBJECT | FK | Company that owns this office → objects.id |
| office_id | INT | — | Crunchbase internal office identifier |
| description | OBJECT | — | Office label (e.g. HQ). 39.20% null |
| region | OBJECT | — | Geographic region (e.g. SF Bay, London) |
| address1 | OBJECT | — | Street address line 1. 16.22% null |
| address2 | OBJECT | — | Street address line 2. 60.50% null |
| city | OBJECT | — | City name. 4.58% null |
| zip_code | OBJECT | — | Postal code. 17.29% null |
| state_code | OBJECT | — | State or province code. 44.98% null |
| country_code | OBJECT | — | ISO country code |
| latitude | FLOAT | — | Geographic latitude. Contains invalid (0,0) values |
| longitude | FLOAT | — | Geographic longitude. Contains invalid (0,0) values |
| created_at | FLOAT | — | 100% null — completely empty column |
| updated_at | FLOAT | — | 100% null — completely empty column |

---

## people

**Type:** Raw  
**Rows:** 226,709 | **Columns:** 6  
**PK:** id | **FK →** object_id → objects.id

**Description:** Individual profiles — founders, executives, and investors.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| object_id | OBJECT | FK | Person entity → objects.id |
| first_name | OBJECT | — | First name. 0.00% null |
| last_name | OBJECT | — | Last name. 0.00% null |
| birthplace | OBJECT | — | City or country of birth. 87.61% null |
| affiliation_name | OBJECT | — | Primary company affiliation. 0.01% null |

---

## relationships

**Type:** Raw  
**Rows:** 402,878 | **Columns:** 11  
**PK:** id | **FK →** person_object_id → objects.id, relationship_object_id → objects.id

**Description:** Maps people to companies with professional roles and tenure.

| Column Name | Data Type | Key | Description |
|-------------|-----------|-----|-------------|
| id | INT | PK | Sequential surrogate key |
| relationship_id | INT | — | Crunchbase internal relationship ID |
| person_object_id | OBJECT | FK | The person → objects.id |
| relationship_object_id | OBJECT | FK | The company or entity → objects.id |
| start_at | OBJECT | — | Role start date. 48.62% null |
| end_at | OBJECT | — | Role end date. 74.92% null (null = still active) |
| is_past | INT | — | 1 if relationship ended, 0 if still active |
| sequence | INT | — | Ordering of multiple roles at the same company |
| title | OBJECT | — | Job title (e.g. CEO, Co-Founder). 3.31% null |
| created_at | OBJECT | — | Record creation timestamp |
| updated_at | OBJECT | — | Record last update timestamp |

