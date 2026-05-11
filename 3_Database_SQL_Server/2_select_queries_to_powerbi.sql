-- Q1: Companies
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


-- Q2: Funding Rounds
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

-- Q3: Investments 
SELECT
    id,
    funding_round_id,
    funded_object_id,
    investor_object_id
FROM cleaned_investments;

-- Q4: Acquisitions 
SELECT
    id,
    acquiring_object_id,
    acquired_object_id,
    price_amount,
    price_currency_code,
    acquired_at
FROM cleaned_acquisitions;

-- Q5: IPOs
SELECT
    id,
    object_id,
    valuation_amount,
    valuation_currency_code,
    raised_amount,
    raised_currency_code,
    public_at,
    stock_symbol
FROM cleaned_ipos;

-- Q6: Investors 
SELECT
    id,
    name,
    entity_type,
    category_code,
    country_code,
    city,
    investment_rounds,
    invested_companies
FROM cleaned_objects
WHERE investment_rounds > 0;

-- Q7: Offices - Geographic 
SELECT
    id,
    object_id,
    country_code,
    city,
    region,
    latitude,
    longitude
FROM cleaned_offices
WHERE latitude != 0 AND longitude != 0;