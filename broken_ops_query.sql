-- =============================================================================
-- DEMO A: "Fix It" — Broken Loan Risk Query
-- =============================================================================
-- Paste this into a Snowsight worksheet before the demo.
-- It has one typo: LONS (missing the 'A').
-- Run it, get the error, then ask CoCo to fix it.
-- =============================================================================

USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;

SELECT
    b.branch_name,
    b.region,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.remaining_balance) AS total_exposure,
    AVG(l.interest_rate) AS avg_rate
FROM LONS l
JOIN BRANCHES b ON l.branch_id = b.branch_id
WHERE l.status IN ('Past Due', 'Watch List', 'Default')
GROUP BY b.branch_name, b.region
ORDER BY total_exposure DESC;
