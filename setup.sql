-- =============================================================================
-- CUSTOMERS BANK x CORTEX CODE — DEMO ENVIRONMENT SETUP
-- =============================================================================
-- Run this script in a Snowsight worksheet to create the full demo environment.
-- Estimated runtime: ~2-3 minutes
-- =============================================================================

-- NOTE: Update the role below to match your environment.
-- Common options: SYSADMIN, ACCOUNTADMIN, or your team's role.
-- USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE CUSTOMERS_BANK_DEMO;

CREATE SCHEMA IF NOT EXISTS CUSTOMERS_BANK_DEMO.BANKING;
CREATE SCHEMA IF NOT EXISTS CUSTOMERS_BANK_DEMO.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS CUSTOMERS_BANK_DEMO.APPS;

USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;

-- =============================================================================
-- TABLE 1: BRANCHES
-- =============================================================================

CREATE OR REPLACE TABLE BRANCHES (
    BRANCH_ID       INT,
    BRANCH_NAME     VARCHAR(100),
    REGION          VARCHAR(50),
    STATE           VARCHAR(2),
    CITY            VARCHAR(100),
    BRANCH_TYPE     VARCHAR(50),
    OPEN_DATE       DATE
);

INSERT INTO BRANCHES VALUES
    (1,  'Main Street Flagship',      'Northeast', 'PA', 'Wyomissing',      'Flagship',       '1998-03-15'),
    (2,  'Center City Philadelphia',   'Northeast', 'PA', 'Philadelphia',    'Full-Service',   '2005-06-22'),
    (3,  'King of Prussia',            'Northeast', 'PA', 'King of Prussia', 'Full-Service',   '2008-09-10'),
    (4,  'Malvern Corporate',          'Northeast', 'PA', 'Malvern',         'Commercial',     '2010-01-18'),
    (5,  'Doylestown',                 'Northeast', 'PA', 'Doylestown',      'Community',       '2012-04-05'),
    (6,  'Manhattan Midtown',          'Northeast', 'NY', 'New York',        'Commercial',     '2015-11-12'),
    (7,  'Boston Financial District',  'Northeast', 'MA', 'Boston',          'Commercial',     '2018-07-01'),
    (8,  'Princeton',                  'Northeast', 'NJ', 'Princeton',       'Full-Service',   '2016-02-14'),
    (9,  'Wilmington',                 'Mid-Atlantic', 'DE', 'Wilmington',   'Full-Service',   '2014-08-20'),
    (10, 'Baltimore Inner Harbor',     'Mid-Atlantic', 'MD', 'Baltimore',    'Full-Service',   '2017-03-10'),
    (11, 'Providence',                 'Northeast', 'RI', 'Providence',      'Community',       '2019-05-10'),
    (12, 'Hartford',                   'Northeast', 'CT', 'Hartford',        'Full-Service',   '2020-01-22'),
    (13, 'Washington DC',              'Mid-Atlantic', 'DC', 'Washington',   'Commercial',     '2018-10-08'),
    (14, 'Tysons Corner',              'Mid-Atlantic', 'VA', 'Tysons',       'Full-Service',   '2021-06-15'),
    (15, 'Cherry Hill',                'Mid-Atlantic', 'NJ', 'Cherry Hill',  'Community',       '2019-09-01');

-- =============================================================================
-- TABLE 2: CUSTOMERS
-- =============================================================================

CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID     INT,
    CUSTOMER_TYPE   VARCHAR(20),
    CUSTOMER_SINCE  DATE,
    BRANCH_ID       INT,
    RISK_RATING     VARCHAR(10),
    ANNUAL_INCOME   NUMBER(12,2),
    CREDIT_SCORE    INT,
    SEGMENT         VARCHAR(30)
);

INSERT INTO CUSTOMERS (CUSTOMER_ID, CUSTOMER_TYPE, CUSTOMER_SINCE, BRANCH_ID, RISK_RATING, ANNUAL_INCOME, CREDIT_SCORE, SEGMENT)
WITH customer_gen AS (
    SELECT
        SEQ4() + 1 AS CUSTOMER_ID,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 75 THEN 'Individual'
            ELSE 'Business'
        END AS CUSTOMER_TYPE,
        DATEADD('day', -UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) AS CUSTOMER_SINCE,
        UNIFORM(1, 15, RANDOM()) AS BRANCH_ID,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Low'
            WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'Medium'
            ELSE 'High'
        END AS RISK_RATING,
        ROUND(UNIFORM(25000, 500000, RANDOM()), 2) AS ANNUAL_INCOME,
        UNIFORM(580, 850, RANDOM()) AS CREDIT_SCORE,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 20 THEN 'Premium'
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Standard'
            WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'Small Business'
            ELSE 'Commercial'
        END AS SEGMENT
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
)
SELECT * FROM customer_gen;

-- =============================================================================
-- TABLE 3: ACCOUNTS
-- =============================================================================

CREATE OR REPLACE TABLE ACCOUNTS (
    ACCOUNT_ID      INT,
    CUSTOMER_ID     INT,
    ACCOUNT_TYPE    VARCHAR(30),
    OPEN_DATE       DATE,
    CURRENT_BALANCE NUMBER(14,2),
    STATUS          VARCHAR(20),
    INTEREST_RATE   NUMBER(5,3)
);

INSERT INTO ACCOUNTS (ACCOUNT_ID, CUSTOMER_ID, ACCOUNT_TYPE, OPEN_DATE, CURRENT_BALANCE, STATUS, INTEREST_RATE)
WITH account_gen AS (
    SELECT
        SEQ4() + 1 AS ACCOUNT_ID,
        UNIFORM(1, 5000, RANDOM()) AS CUSTOMER_ID,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 35 THEN 'Checking'
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Savings'
            WHEN UNIFORM(1, 100, RANDOM()) <= 75 THEN 'Money Market'
            WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'CD'
            WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN 'Business Checking'
            ELSE 'Business Savings'
        END AS ACCOUNT_TYPE,
        DATEADD('day', -UNIFORM(30, 2000, RANDOM()), CURRENT_DATE()) AS OPEN_DATE,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 35 THEN ROUND(UNIFORM(500, 50000, RANDOM()), 2)
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN ROUND(UNIFORM(1000, 200000, RANDOM()), 2)
            WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN ROUND(UNIFORM(10000, 500000, RANDOM()), 2)
            ELSE ROUND(UNIFORM(50000, 2000000, RANDOM()), 2)
        END AS CURRENT_BALANCE,
        CASE WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN 'Active' ELSE 'Closed' END AS STATUS,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 35 THEN 0.010
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN ROUND(UNIFORM(3.5, 5.0, RANDOM())::NUMBER(5,3), 3)
            WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN ROUND(UNIFORM(4.0, 5.5, RANDOM())::NUMBER(5,3), 3)
            ELSE ROUND(UNIFORM(4.5, 5.25, RANDOM())::NUMBER(5,3), 3)
        END AS INTEREST_RATE
    FROM TABLE(GENERATOR(ROWCOUNT => 8000))
)
SELECT * FROM account_gen;

-- =============================================================================
-- TABLE 4: LOANS
-- =============================================================================

CREATE OR REPLACE TABLE LOANS (
    LOAN_ID         INT,
    CUSTOMER_ID     INT,
    LOAN_TYPE       VARCHAR(30),
    ORIGINATION_DATE DATE,
    PRINCIPAL       NUMBER(14,2),
    INTEREST_RATE   NUMBER(5,3),
    TERM_MONTHS     INT,
    REMAINING_BALANCE NUMBER(14,2),
    STATUS          VARCHAR(20),
    DAYS_PAST_DUE   INT,
    BRANCH_ID       INT
);

INSERT INTO LOANS (LOAN_ID, CUSTOMER_ID, LOAN_TYPE, ORIGINATION_DATE, PRINCIPAL, INTEREST_RATE, TERM_MONTHS, REMAINING_BALANCE, STATUS, DAYS_PAST_DUE, BRANCH_ID)
WITH loan_gen AS (
    SELECT
        SEQ4() + 1 AS LOAN_ID,
        UNIFORM(1, 5000, RANDOM()) AS CUSTOMER_ID,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN 'Mortgage'
            WHEN UNIFORM(1, 100, RANDOM()) <= 45 THEN 'Commercial Real Estate'
            WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Business Line of Credit'
            WHEN UNIFORM(1, 100, RANDOM()) <= 75 THEN 'Auto Loan'
            WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'Personal Loan'
            WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN 'SBA Loan'
            ELSE 'Construction Loan'
        END AS LOAN_TYPE,
        DATEADD('day', -UNIFORM(30, 1800, RANDOM()), CURRENT_DATE()) AS ORIGINATION_DATE,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN ROUND(UNIFORM(150000, 800000, RANDOM()), 2)
            WHEN UNIFORM(1, 100, RANDOM()) <= 50 THEN ROUND(UNIFORM(500000, 5000000, RANDOM()), 2)
            WHEN UNIFORM(1, 100, RANDOM()) <= 70 THEN ROUND(UNIFORM(50000, 500000, RANDOM()), 2)
            ELSE ROUND(UNIFORM(10000, 100000, RANDOM()), 2)
        END AS PRINCIPAL,
        ROUND(UNIFORM(3.5, 9.5, RANDOM())::NUMBER(5,3), 3) AS INTEREST_RATE,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN 360
            WHEN UNIFORM(1, 100, RANDOM()) <= 50 THEN 240
            WHEN UNIFORM(1, 100, RANDOM()) <= 75 THEN 60
            ELSE 36
        END AS TERM_MONTHS,
        NULL AS REMAINING_BALANCE,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN 'Current'
            WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN 'Past Due'
            WHEN UNIFORM(1, 100, RANDOM()) <= 97 THEN 'Watch List'
            ELSE 'Default'
        END AS STATUS,
        CASE
            WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN 0
            WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN UNIFORM(1, 30, RANDOM())
            WHEN UNIFORM(1, 100, RANDOM()) <= 97 THEN UNIFORM(31, 90, RANDOM())
            ELSE UNIFORM(91, 180, RANDOM())
        END AS DAYS_PAST_DUE,
        UNIFORM(1, 15, RANDOM()) AS BRANCH_ID
    FROM TABLE(GENERATOR(ROWCOUNT => 3000))
)
SELECT
    LOAN_ID, CUSTOMER_ID, LOAN_TYPE, ORIGINATION_DATE, PRINCIPAL, INTEREST_RATE, TERM_MONTHS,
    ROUND(PRINCIPAL * UNIFORM(0.3, 0.95, RANDOM()), 2) AS REMAINING_BALANCE,
    STATUS, DAYS_PAST_DUE, BRANCH_ID
FROM loan_gen;

-- =============================================================================
-- TABLE 5: TRANSACTIONS (~200K rows over 6 months)
-- =============================================================================

CREATE OR REPLACE TABLE TRANSACTIONS (
    TRANSACTION_ID      INT AUTOINCREMENT START 1 INCREMENT 1,
    ACCOUNT_ID          INT,
    TRANSACTION_DATE    DATE,
    TRANSACTION_DATETIME TIMESTAMP_NTZ,
    TRANSACTION_TYPE    VARCHAR(30),
    AMOUNT              NUMBER(12,2),
    CHANNEL             VARCHAR(30),
    DESCRIPTION         VARCHAR(200)
);

INSERT INTO TRANSACTIONS (ACCOUNT_ID, TRANSACTION_DATE, TRANSACTION_DATETIME, TRANSACTION_TYPE, AMOUNT, CHANNEL, DESCRIPTION)
WITH date_range AS (
    SELECT DATEADD('day', SEQ4(), '2025-09-01')::DATE AS TXN_DATE
    FROM TABLE(GENERATOR(ROWCOUNT => 180))
),
account_dates AS (
    SELECT
        a.ACCOUNT_ID,
        d.TXN_DATE,
        CASE
            WHEN a.ACCOUNT_TYPE IN ('Checking', 'Business Checking') THEN 8
            WHEN a.ACCOUNT_TYPE = 'Savings' THEN 2
            ELSE 1
        END AS BASE_DAILY_TXNS
    FROM ACCOUNTS a
    CROSS JOIN date_range d
    WHERE a.STATUS = 'Active'
    AND UNIFORM(1, 100, RANDOM()) <= CASE
        WHEN a.ACCOUNT_TYPE IN ('Checking', 'Business Checking') THEN 60
        WHEN a.ACCOUNT_TYPE = 'Savings' THEN 15
        ELSE 5
    END
),
expanded AS (
    SELECT
        ad.ACCOUNT_ID,
        ad.TXN_DATE,
        ROW_NUMBER() OVER (PARTITION BY ad.ACCOUNT_ID, ad.TXN_DATE ORDER BY RANDOM()) AS RN,
        ad.BASE_DAILY_TXNS
    FROM account_dates ad,
    TABLE(GENERATOR(ROWCOUNT => 10)) g
),
filtered AS (
    SELECT ACCOUNT_ID, TXN_DATE FROM expanded WHERE RN <= BASE_DAILY_TXNS
)
SELECT
    f.ACCOUNT_ID,
    f.TXN_DATE,
    DATEADD('second',
        UNIFORM(28800, 64800, RANDOM()),
        f.TXN_DATE::TIMESTAMP_NTZ
    ) AS TRANSACTION_DATETIME,
    CASE
        WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN 'Deposit'
        WHEN UNIFORM(1, 100, RANDOM()) <= 50 THEN 'Withdrawal'
        WHEN UNIFORM(1, 100, RANDOM()) <= 70 THEN 'Transfer'
        WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'ACH'
        WHEN UNIFORM(1, 100, RANDOM()) <= 92 THEN 'Wire'
        WHEN UNIFORM(1, 100, RANDOM()) <= 97 THEN 'Check'
        ELSE 'Fee'
    END AS TRANSACTION_TYPE,
    CASE
        WHEN UNIFORM(1, 100, RANDOM()) <= 50 THEN ROUND(UNIFORM(10, 2000, RANDOM()), 2)
        WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN ROUND(UNIFORM(2000, 25000, RANDOM()), 2)
        ELSE ROUND(UNIFORM(25000, 250000, RANDOM()), 2)
    END AS AMOUNT,
    CASE
        WHEN UNIFORM(1, 100, RANDOM()) <= 40 THEN 'Online Banking'
        WHEN UNIFORM(1, 100, RANDOM()) <= 65 THEN 'Mobile App'
        WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN 'In-Branch'
        WHEN UNIFORM(1, 100, RANDOM()) <= 92 THEN 'ATM'
        ELSE 'Phone'
    END AS CHANNEL,
    CASE
        WHEN UNIFORM(1, 100, RANDOM()) <= 20 THEN 'Payroll Direct Deposit'
        WHEN UNIFORM(1, 100, RANDOM()) <= 35 THEN 'Vendor Payment'
        WHEN UNIFORM(1, 100, RANDOM()) <= 50 THEN 'Account Transfer'
        WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Bill Payment'
        WHEN UNIFORM(1, 100, RANDOM()) <= 70 THEN 'Wire Transfer'
        WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN 'ATM Withdrawal'
        WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN 'Check Deposit'
        ELSE 'Service Fee'
    END AS DESCRIPTION
FROM filtered f;

-- =============================================================================
-- VERIFY
-- =============================================================================

SELECT 'BRANCHES' AS TBL, COUNT(*) AS ROW_COUNT FROM BRANCHES
UNION ALL SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
ORDER BY TBL;
