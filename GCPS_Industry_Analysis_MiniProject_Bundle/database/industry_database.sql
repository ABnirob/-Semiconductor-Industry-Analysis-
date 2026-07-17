-- ==========================================
-- INDUSTRY ANALYSIS MINI-PROJECT SQL SCHEMA & QUERIES
-- Relational Model & Multi-dimensional Analytical Queries
-- Target Database: PostgreSQL / Cloud SQL
-- ==========================================

-- 1. DROP EXISTING TABLES (IF ANY) TO ENSURE IDEMPOTENCY
DROP TABLE IF EXISTS company_financials;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS industries;
DROP TABLE IF EXISTS countries;

-- 2. CREATE DIMENSION TABLES
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL,
    region VARCHAR(50),
    operating_cost_index NUMERIC(5,2), -- Relative scale (0-100)
    talent_index NUMERIC(5,2),
    regulatory_score NUMERIC(5,2)
);

CREATE TABLE industries (
    industry_id SERIAL PRIMARY KEY,
    industry_name VARCHAR(100) UNIQUE NOT NULL,
    risk_rating VARCHAR(10) CHECK (risk_rating IN ('Low', 'Medium', 'High')),
    annual_growth_rate NUMERIC(5,2),
    cogs_benchmark_pct NUMERIC(5,2) -- Sector benchmark COGS/Revenue ratio
);

CREATE TABLE companies (
    company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    industry_id INT REFERENCES industries(industry_id),
    country_id INT REFERENCES countries(country_id),
    employee_count INT,
    r_and_d_expense NUMERIC(15,2) -- in Millions USD
);

-- 3. CREATE FACT / FINANCIALS TABLE
CREATE TABLE company_financials (
    financial_id SERIAL PRIMARY KEY,
    company_id VARCHAR(10) REFERENCES companies(company_id) ON DELETE CASCADE,
    fiscal_year INT DEFAULT 2025,
    revenue NUMERIC(15,2) NOT NULL,      -- in Millions USD
    cogs NUMERIC(15,2) NOT NULL,         -- Cost of Goods Sold in Millions USD
    net_income NUMERIC(15,2) NOT NULL,   -- in Millions USD
    market_cap NUMERIC(15,2) NOT NULL,   -- in Millions USD
    CONSTRAINT check_financial_logical CHECK (revenue >= 0 AND cogs >= 0)
);

-- 4. SEED DATASET
INSERT INTO countries (country_name, region, operating_cost_index, talent_index, regulatory_score) VALUES
('United States', 'North America', 85.2, 95.0, 90.0),
('Taiwan', 'Asia-Pacific', 55.4, 88.0, 85.0),
('Germany', 'Europe', 90.1, 92.0, 88.0),
('Singapore', 'Asia-Pacific', 75.0, 94.0, 95.0),
('China', 'Asia', 45.0, 82.0, 65.0),
('South Korea', 'Asia-Pacific', 62.0, 89.0, 80.0),
('Japan', 'Asia-Pacific', 70.0, 91.0, 84.0),
('Netherlands', 'Europe', 82.0, 90.0, 91.0);

INSERT INTO industries (industry_name, risk_rating, annual_growth_rate, cogs_benchmark_pct) VALUES
('Semiconductors & Electronics', 'Medium', 14.50, 48.25),
('Pharmaceuticals & Biotech', 'High', 8.20, 26.99),
('Automotive & Electric Vehicles', 'Medium', 11.80, 83.21),
('E-Commerce & Digital Retail', 'Low', 12.10, 62.32),
('Renewable Energy & Cleantech', 'High', 18.40, 79.77);

-- Seed Companies & Financials using Common Table Expressions or Direct Lookups
-- We write them out using direct subqueries for maximum SQL portability
INSERT INTO companies (company_id, company_name, industry_id, country_id, employee_count, r_and_d_expense) VALUES
('SC01', 'Nvidia Corp', (SELECT industry_id FROM industries WHERE industry_name = 'Semiconductors & Electronics'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 29600, 11200.00),
('SC02', 'TSMC', (SELECT industry_id FROM industries WHERE industry_name = 'Semiconductors & Electronics'), (SELECT country_id FROM countries WHERE country_name = 'Taiwan'), 76000, 5800.00),
('SC03', 'Intel Corp', (SELECT industry_id FROM industries WHERE industry_name = 'Semiconductors & Electronics'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 124800, 16500.00),
('SC04', 'Samsung Electronics', (SELECT industry_id FROM industries WHERE industry_name = 'Semiconductors & Electronics'), (SELECT country_id FROM countries WHERE country_name = 'South Korea'), 270000, 22100.00),
('SC05', 'ASML Holding', (SELECT industry_id FROM industries WHERE industry_name = 'Semiconductors & Electronics'), (SELECT country_id FROM countries WHERE country_name = 'Netherlands'), 42400, 4100.00),
('PH01', 'Eli Lilly & Co', (SELECT industry_id FROM industries WHERE industry_name = 'Pharmaceuticals & Biotech'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 43000, 9300.00),
('PH02', 'Novo Nordisk', (SELECT industry_id FROM industries WHERE industry_name = 'Pharmaceuticals & Biotech'), (SELECT country_id FROM countries WHERE country_name = 'Netherlands'), 64000, 4800.00),
('AV01', 'Tesla Inc', (SELECT industry_id FROM industries WHERE industry_name = 'Automotive & Electric Vehicles'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 140000, 3960.00),
('AV02', 'Toyota Motor', (SELECT industry_id FROM industries WHERE industry_name = 'Automotive & Electric Vehicles'), (SELECT country_id FROM countries WHERE country_name = 'Japan'), 375000, 8900.00),
('EC01', 'Amazon.com Inc', (SELECT industry_id FROM industries WHERE industry_name = 'E-Commerce & Digital Retail'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 1525000, 85200.00),
('RE01', 'NextEra Energy', (SELECT industry_id FROM industries WHERE industry_name = 'Renewable Energy & Cleantech'), (SELECT country_id FROM countries WHERE country_name = 'United States'), 16800, 300.00);

INSERT INTO company_financials (company_id, revenue, cogs, net_income, market_cap) VALUES
('SC01', 96310.00, 23890.00, 52990.00, 3120000.00),
('SC02', 75880.00, 34150.00, 30120.00, 840000.00),
('SC03', 54200.00, 32520.00, 1680.00, 110000.00),
('SC04', 198500.00, 136200.00, 11400.00, 360000.00),
('SC05', 29600.00, 14450.00, 8430.00, 380000.00),
('PH01', 34120.00, 7120.00, 6240.00, 810000.00),
('PH02', 33700.00, 5390.00, 12100.00, 590000.00),
('AV01', 96770.00, 79120.00, 15000.00, 740000.00),
('AV02', 295000.00, 236000.00, 33100.00, 290000.00),
('EC01', 574800.00, 304600.00, 30400.00, 1950000.00),
('RE01', 28100.00, 12400.00, 7310.00, 148000.00);


-- ==========================================
-- ANALYTICAL QUERIES FOR MINI-PROJECT REPORT
-- ==========================================

-- TOPIC 1 (PART 1): THE IMPACT OF 1% SAVING OF COGS ON NET INCOME
-- This query models a 1% reduction in Cost of Goods Sold (COGS) and computes:
-- 1. Absolute COGS Savings ($M)
-- 2. New Pro Forma Net Income ($M)
-- 3. Percent Increase in Net Income (Leverage effect)
-- 4. Leverage Multiplier (Sensitivity factor: % Increase in Net Income / % Decrease in COGS)

SELECT 
    c.company_name,
    i.industry_name,
    f.revenue,
    f.cogs,
    f.net_income AS current_net_income,
    -- 1% saving of COGS
    ROUND(f.cogs * 0.01, 2) AS cogs_savings,
    -- New net income assuming all savings flow directly to bottom line (pre-tax simplified)
    ROUND(f.net_income + (f.cogs * 0.01), 2) AS pro_forma_net_income,
    -- Percentage change in net income
    CASE 
        WHEN f.net_income <= 0 THEN NULL -- Handle negative income/loss
        ELSE ROUND(((f.cogs * 0.01) / f.net_income) * 100.0, 2)
    END AS net_income_increase_pct,
    -- Leverage Multiplier: how sensitive is the bottom line to COGS optimization
    CASE 
        WHEN f.net_income <= 0 THEN NULL
        ELSE ROUND((f.cogs * 0.01 / f.net_income) / 0.01, 2)
    END AS cogs_leverage_multiplier
FROM company_financials f
JOIN companies c ON f.company_id = c.company_id
JOIN industries i ON c.industry_id = i.industry_id
ORDER BY cogs_leverage_multiplier DESC NULLS LAST;


-- TOPIC 1 (PART 2): CORRELATION STATISTICS (MARKET CAP VS NET INCOME)
-- Computes statistical summaries for each industry:
-- 1. Total Market Capitalization
-- 2. Total Net Income
-- 3. Average Valuation Multiple (Price-to-Earnings or MC/NI Ratio)
-- 4. Sector Concentration (using Gini-like ratio or top player dominance)

SELECT 
    i.industry_name,
    COUNT(c.company_id) AS company_count,
    ROUND(SUM(f.revenue), 2) AS total_revenue_m,
    ROUND(SUM(f.net_income), 2) AS total_net_income_m,
    ROUND(SUM(f.market_cap), 2) AS total_market_cap_m,
    -- Sector Price to Earnings ratio
    CASE 
        WHEN SUM(f.net_income) <= 0 THEN NULL
        ELSE ROUND(SUM(f.market_cap) / SUM(f.net_income), 2)
    END AS industry_pe_multiple,
    -- Average profit margin
    ROUND((SUM(f.net_income) / SUM(f.revenue)) * 100.0, 2) AS industry_profit_margin_pct
FROM industries i
JOIN companies c ON i.industry_id = c.industry_id
JOIN company_financials f ON c.company_id = f.company_id
GROUP BY i.industry_name, i.risk_rating, i.annual_growth_rate
ORDER BY total_market_cap_m DESC;


-- TOPIC 2 (PART 1): GLOBAL SITE SELECTION MATRIX
-- Computes a Location Fitness Score for each country based on operating cost (inverse),
-- talent supply (weighted 40%), and regulatory ease (weighted 30%).

SELECT 
    country_name,
    region,
    operating_cost_index,
    talent_index,
    regulatory_score,
    -- Location Fitness Score (Weighted Average, lower operating cost index is better, so we use (100 - operating_cost_index))
    ROUND(
        ((100 - operating_cost_index) * 0.30) + 
        (talent_index * 0.40) + 
        (regulatory_score * 0.30),
        2
    ) AS location_fitness_score
FROM countries
ORDER BY location_fitness_score DESC;
