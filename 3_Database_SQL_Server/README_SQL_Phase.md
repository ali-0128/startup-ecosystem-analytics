# SQL Server Database Setup & Schema

**Phase 3 — Database Design & Implementation**  
**Crunchbase 2013 Startup Ecosystem Analysis**  
**NTI Data Analysis Track**  
*Ali Rabie - Bilal Mohamed - Asim Mohamed - Mohamed Rifaat - Kamal Ragab | 2026*

---

## Overview

This phase implements the complete database schema in SQL Server, establishes relationships between tables, enforces referential integrity, and creates optimized queries for Power BI consumption. The database serves as the single source of truth for all downstream analytics.

---

## Database Architecture

### Hub-and-Spoke Design

The schema follows a **hub-and-spoke architecture** with `cleaned_objects` as the central dimension table:

- **Central Hub:** `cleaned_objects` (462,651 records)
  - Contains 4 entity types: Company, Person, Fund, Product
  - All other tables reference this table via Foreign Keys

- **Fact Tables:** (Event-level data)
  - `cleaned_funding_rounds` (52,680 records) — Every funding event
  - `cleaned_investments` (80,902 records) — Investor-to-round junction
  - `cleaned_acquisitions` (9,561 records) — M&A transactions
  - `cleaned_ipos` (1,254 records) — Public offerings
  - `cleaned_funds` (1,564 records) — VC fund records

- **Dimension Tables:** (Descriptive attributes)
  - `cleaned_people` (226,709 records) — Individual profiles
  - `cleaned_relationships` (402,878 records) — Person-to-company roles
  - `cleaned_offices` (112,718 records) — Office locations
  - `cleaned_milestones` (39,456 records) — Company/person events
  - `cleaned_degrees` (109,610 records) — Educational credentials

### Entity Relationship Diagram

![Database Schema](/3_Database_SQL_Server/daigram.png)

The ERD shows:
- Yellow connection points: One-to-Many relationships
- Central yellow hub: `cleaned_objects`
- Blue-bordered tables: Key dimensions and facts
- All arrows indicate FK dependencies

---

## Implementation Steps

### 1. Database Creation

```sql
CREATE DATABASE companies_startups;
USE companies_startups;
```

**Purpose:** Create dedicated database for the Crunchbase dataset  
**Isolation:** Separate schema from other projects  
**Scalability:** Ready for future data additions (2014+, other datasets)

---

### 2. Data Inspection

Initial queries validate table structures and data:

```sql
SELECT * FROM cleaned_objects;
SELECT * FROM cleaned_acquisitions;
-- ... (all 11 tables)

EXEC sp_help cleaned_objects;
EXEC sp_help cleaned_acquisitions;
```

**Validation:** Confirm all tables loaded with expected columns and data types

---

### 3. Data Integrity Cleaning

#### Step 3a: Remove Orphan Records

Records without a matching Foreign Key in the primary table cannot be joined. These are deleted:

**Orphan Records Removed:**

| Table | Orphan Rows | Reason |
|-------|-------------|--------|
| cleaned_people | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_acquisitions | Rows where `acquiring_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_acquisitions | Rows where `acquired_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_funding_rounds | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_investments | Rows where `funded_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_investments | Rows where `investor_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_relationships | Rows where `person_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_relationships | Rows where `relationship_object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_degrees | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_ipos | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_milestones | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |
| cleaned_funds | Rows where `object_id` ∉ cleaned_objects.id | Broken FK |

**Example Query:**
```sql
DELETE FROM cleaned_people 
WHERE object_id NOT IN (SELECT id FROM cleaned_objects);
```

#### Step 3b: Prepare Key Columns

Ensure `funding_round_id` is suitable for FK referencing:

```sql
ALTER TABLE cleaned_funding_rounds 
ALTER COLUMN funding_round_id INT NOT NULL;

ALTER TABLE cleaned_funding_rounds 
ADD CONSTRAINT uq_fundingroundid UNIQUE (funding_round_id);
```

**Purpose:** funding_round_id must be unique to allow FK references from cleaned_investments

Clean invalid round IDs:
```sql
DELETE FROM cleaned_investments 
WHERE funding_round_id NOT IN (SELECT funding_round_id FROM cleaned_funding_rounds);
```

---

### 4. Foreign Key Constraints

#### 4a: Acquisition Links
```sql
ALTER TABLE cleaned_acquisitions 
ADD CONSTRAINT fk_cleaned_acquisitions_acquiring 
FOREIGN KEY (acquiring_object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_acquisitions 
ADD CONSTRAINT fk_cleaned_acquisitions_acquired 
FOREIGN KEY (acquired_object_id) REFERENCES cleaned_objects(id);
```

#### 4b: Dimension Links
```sql
ALTER TABLE cleaned_degrees 
ADD CONSTRAINT fk_cleaned_degrees_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_funding_rounds 
ADD CONSTRAINT fk_cleaned_fundingrounds_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_funds 
ADD CONSTRAINT fk_cleaned_funds_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_ipos 
ADD CONSTRAINT fk_cleaned_ipos_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_milestones 
ADD CONSTRAINT fk_cleaned_milestones_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_offices 
ADD CONSTRAINT fk_cleaned_offices_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_people 
ADD CONSTRAINT fk_cleaned_people_object 
FOREIGN KEY (object_id) REFERENCES cleaned_objects(id);
```

#### 4c: Investment Links
```sql
-- Link investments to funding rounds
ALTER TABLE cleaned_investments 
ADD CONSTRAINT fk_final_investments_round 
FOREIGN KEY (funding_round_id) REFERENCES cleaned_funding_rounds(funding_round_id);

-- Link to companies receiving funding
ALTER TABLE cleaned_investments 
ADD CONSTRAINT fk_cleaned_investments_fundedobject 
FOREIGN KEY (funded_object_id) REFERENCES cleaned_objects(id);

-- Link to investors making the investment
ALTER TABLE cleaned_investments 
ADD CONSTRAINT fk_cleaned_investments_investorobject 
FOREIGN KEY (investor_object_id) REFERENCES cleaned_objects(id);
```

#### 4d: Relationship Links
```sql
ALTER TABLE cleaned_relationships 
ADD CONSTRAINT fk_cleaned_relationships_person 
FOREIGN KEY (person_object_id) REFERENCES cleaned_objects(id);

ALTER TABLE cleaned_relationships 
ADD CONSTRAINT fk_cleaned_relationships_entity 
FOREIGN KEY (relationship_object_id) REFERENCES cleaned_objects(id);
```

#### 4e: Self-Join for Company Hierarchy
```sql
-- Handle subsidiary-to-parent company relationships
ALTER TABLE cleaned_objects 
ADD parent_id NVARCHAR(100);

UPDATE cleaned_objects 
SET parent_id = NULL WHERE parent_id NOT IN (SELECT id FROM cleaned_objects);

ALTER TABLE cleaned_objects 
ADD CONSTRAINT fk_cleaned_objects_parent 
FOREIGN KEY (parent_id) REFERENCES cleaned_objects(id);
```

---

## Query Views for Power BI

Optimized SELECT queries prepare data for Power BI:

### Q1: Companies (Dimension)
```sql
SELECT
    id,
    name,
    category_code,
    status,
    founded_at,
    closed_at,
    country_code,
    city,
    region,
    funding_total_usd,
    funding_rounds,
    first_funding_at,
    last_funding_at,
    milestones,
    relationships
FROM cleaned_objects
WHERE entity_type = 'Company';
```

**Purpose:** Dimension table for company analysis  
**Records:** 196,553 companies  
**Usage:** Slicing by sector, country, status, founding year

### Q2: Funding Rounds (Fact)
```sql
SELECT
    id,
    funding_round_id,
    object_id,
    funded_at,
    funding_round_type,
    funding_round_code,
    raised_amount_usd,
    pre_money_valuation_usd,
    post_money_valuation_usd,
    participants,
    is_first_round,
    is_last_round
FROM cleaned_funding_rounds;
```

**Purpose:** Fact table for financial analysis  
**Records:** 52,680 funding events  
**Key Metrics:** Amount raised, valuation, round sequence

### Q3: Investments (Fact)
```sql
SELECT
    id,
    funding_round_id,
    funded_object_id,
    investor_object_id
FROM cleaned_investments;
```

**Purpose:** Junction table linking investors to rounds  
**Records:** 80,902 investment records  
**Key Analysis:** Investor activity, co-investment patterns

---

## Database Statistics

After setup, the database contains:

| Entity | Count |
|--------|-------|
| Companies | 196,553 |
| People | 226,709 |
| Funding Rounds | 52,680 |
| Investments | 80,902 |
| Acquisitions | 9,561 |
| IPOs | 1,254 |
| Funds | 1,564 |
| Offices | 112,718 |
| Relationships | 402,878 |
| Milestones | 39,456 |
| Educational Degrees | 109,610 |
| **Total Records** | **~1.45M** |

---

## Key Design Decisions

### 1. Referential Integrity Enforcement
- All ForeignKey constraints are **NOT NULL** by default
- Orphan records are removed before FK creation
- Prevents invalid joins at query time

### 2. Hub-and-Spoke Pattern
- `cleaned_objects` is the single source of truth for entities
- Eliminates data duplication across fact and dimension tables
- Simplifies company/person hierarchy via self-join

### 3. Unique Constraint on funding_round_id
- `funding_round_id` must be unique in `cleaned_funding_rounds`
- Allows `cleaned_investments` to reference specific rounds
- Creates 1:N relationship (1 round → many investments)

### 4. Logical Nulls Preserved
- `closed_at = NULL` means company is still operating
- `parent_id = NULL` means no parent company (is a parent)
- `end_at = NULL` in relationships means relationship is still active
- These nulls carry analytical meaning and are preserved

---

**Completed:**
- Database created with 11 tables
- Orphan records removed
- Foreign Key constraints established
- Self-join configured for company hierarchy
- Query views defined for Power BI
