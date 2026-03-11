# Customers Bank x Cortex Code — Quickstart Guide

A self-paced, end-to-end walkthrough for using Cortex Code (CoCo) with Customers Bank demo data. Follow every step in order or jump to the exercise that interests you most.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Setup: Create the Demo Environment](#2-setup-create-the-demo-environment)
3. [Enable Cortex Code in Snowsight](#3-enable-cortex-code-in-snowsight)
4. [Understand the Demo Data](#4-understand-the-demo-data)
5. [Exercise 1: Fix Broken SQL with Natural Language](#5-exercise-1-fix-broken-sql-with-natural-language)
6. [Exercise 2: Build a Loan Risk Analysis Notebook](#6-exercise-2-build-a-loan-risk-analysis-notebook)
7. [Exercise 3: Create a Dynamic Table for Branch Risk Monitoring](#7-exercise-3-create-a-dynamic-table-for-branch-risk-monitoring)
8. [Exercise 4: Deploy a Streamlit Dashboard](#8-exercise-4-deploy-a-streamlit-dashboard)
9. [Bonus Exercises](#9-bonus-exercises)
10. [Tips and Troubleshooting](#10-tips-and-troubleshooting)

---

## 1. Prerequisites

Before you begin, confirm the following:

- [ ] You have access to a **Snowflake account** with Snowsight
- [ ] You have a **role** that can create databases (e.g., SYSADMIN, ACCOUNTADMIN, or an equivalent custom role)
- [ ] You have access to a **warehouse** (any size — XSMALL works fine)
- [ ] Your account has **Cortex Code** enabled (available on most Snowflake Enterprise+ accounts)

> **Not sure about your role or warehouse?** Run this in a Snowsight worksheet:
> ```sql
> SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE();
> ```
> If the warehouse is `NULL`, set one:
> ```sql
> USE WAREHOUSE <YOUR_WAREHOUSE_NAME>;
> ```

---

## 2. Setup: Create the Demo Environment

This step creates the `CUSTOMERS_BANK_DEMO` database with five tables of realistic banking data — branches, customers, accounts, loans, and transactions.

### Steps

1. Open **Snowsight** and create a new **SQL Worksheet**
2. Copy the entire contents of [`setup.sql`](setup.sql) and paste it into the worksheet
3. At the top of the script, set the role that has `CREATE DATABASE` privileges:
   ```sql
   USE ROLE SYSADMIN; -- or ACCOUNTADMIN, or your team's role
   ```
4. Click **Run All** (or select all and press `Ctrl+Enter` / `Cmd+Enter`)
5. The script takes about 2-3 minutes. When it finishes, verify the data loaded:

```sql
USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;

SELECT 'BRANCHES' AS tbl, COUNT(*) AS rows FROM BRANCHES
UNION ALL SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS;
```

**Expected results:**

| Table | Approximate Rows |
|-------|-----------------|
| BRANCHES | 15 |
| CUSTOMERS | 5,000 |
| ACCOUNTS | 8,000 |
| LOANS | 3,000 |
| TRANSACTIONS | ~200K+ |

> **Troubleshooting:** If you get a `CREATE DATABASE` error, you likely need a different role. Try `USE ROLE ACCOUNTADMIN;` or ask your Snowflake admin which role has this privilege.

---

## 3. Enable Cortex Code in Snowsight

Cortex Code (CoCo) is the AI assistant panel built into Snowsight. It writes SQL, Python, and Streamlit code from natural language prompts.

### How to open it

1. Go to **Snowsight** (the Snowflake web UI)
2. Open any **SQL Worksheet** or **Notebook**
3. Look for the **CoCo panel** on the right side of the screen — it has a chat-style interface. Click the chat icon if the panel is collapsed.

### If you don't see it

CoCo is enabled by default on most Snowflake Enterprise+ accounts. If you don't see the panel:
- Make sure you're in a **SQL Worksheet** or **Notebook** (not the home page)
- Try refreshing Snowsight
- Contact your Snowflake admin — CoCo may need to be enabled at the account level via the `CORTEX_ENABLED` parameter

> **Tip:** CoCo works in both SQL Worksheets and Snowflake Notebooks. It can also read errors, so if something breaks, just paste the error and ask it to fix it.

---

## 4. Understand the Demo Data

All banking data lives in `CUSTOMERS_BANK_DEMO.BANKING`. Two additional schemas (`ANALYTICS` and `APPS`) are empty — you will populate them during the exercises.

### Tables at a Glance

| Table | What It Contains |
|-------|-----------------|
| `BRANCHES` | 15 branch locations across Northeast and Mid-Atlantic — Flagship, Full-Service, Commercial, Community types |
| `CUSTOMERS` | 5,000 customers — Individual and Business, with credit scores, income, risk ratings, and segments (Premium, Standard, Small Business, Commercial) |
| `ACCOUNTS` | 8,000 accounts — Checking, Savings, Money Market, CD, Business Checking/Savings with balances and interest rates |
| `LOANS` | 3,000 loans — Mortgage, CRE, Business LOC, Auto, Personal, SBA, Construction with status and days past due |
| `TRANSACTIONS` | ~200K+ transactions over 6 months — deposits, withdrawals, transfers, ACH, wires, checks, fees across channels |

### Key Columns to Know

**LOANS**
- `LOAN_ID` — unique loan identifier
- `LOAN_TYPE` — Mortgage, Commercial Real Estate, Business Line of Credit, Auto, Personal, SBA, Construction
- `STATUS` — Current, Past Due, Watch List, Default
- `DAYS_PAST_DUE` — 0 for current, 1-30 early, 31-90 concerning, 90+ severe
- `PRINCIPAL`, `REMAINING_BALANCE`, `INTEREST_RATE`
- `BRANCH_ID` — originating branch

**CUSTOMERS**
- `CUSTOMER_ID`, `CUSTOMER_TYPE` (Individual/Business)
- `RISK_RATING` — Low, Medium, High
- `CREDIT_SCORE`, `ANNUAL_INCOME`, `SEGMENT`

**TRANSACTIONS**
- `ACCOUNT_ID`, `TRANSACTION_DATE`, `TRANSACTION_TYPE`
- `CHANNEL` — Online Banking, Mobile App, In-Branch, ATM, Phone
- `AMOUNT`, `DESCRIPTION`

### Quick Explore (Optional)

Try these in a worksheet or ask CoCo to write them for you:

```sql
-- See all branches
SELECT * FROM CUSTOMERS_BANK_DEMO.BANKING.BRANCHES ORDER BY REGION, STATE;

-- Loan status summary
SELECT STATUS, COUNT(*) AS LOAN_COUNT, SUM(REMAINING_BALANCE) AS TOTAL_EXPOSURE
FROM CUSTOMERS_BANK_DEMO.BANKING.LOANS GROUP BY STATUS ORDER BY TOTAL_EXPOSURE DESC;

-- Transaction volume by channel
SELECT CHANNEL, COUNT(*) AS TXN_COUNT, SUM(AMOUNT) AS TOTAL_VOLUME
FROM CUSTOMERS_BANK_DEMO.BANKING.TRANSACTIONS GROUP BY CHANNEL ORDER BY TXN_COUNT DESC;
```

---

## 5. Exercise 1: Fix Broken SQL with Natural Language

**Time:** ~5 minutes
**Skill level:** Anyone
**What you'll learn:** How CoCo can diagnose and fix SQL errors from natural language

### Scenario

A risk analyst wrote a query to pull at-risk loan exposure by branch, but it has a bug. You need to find and fix it quickly.

### Steps

1. Open a new **SQL Worksheet** in Snowsight
2. Set your context:
   ```sql
   USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;
   ```
3. Paste the following broken query (or copy from [`broken_ops_query.sql`](broken_ops_query.sql)):

   ```sql
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
   ```

4. **Run the query** — it will fail with an error like `Object 'LONS' does not exist`
5. Open the **CoCo panel** on the right
6. Type this prompt into CoCo:

   > **Fix this query**

7. CoCo will identify the typo (`LONS` → `LOANS`) and suggest the correction
8. **Accept the fix** and run the corrected query — you should see risk exposure results by branch

### What just happened

Instead of manually scanning for errors or searching through the schema browser, you asked CoCo in plain English and got a fix in seconds. This works for any SQL error — syntax mistakes, wrong column names, missing joins, type mismatches, and more.

### Try it yourself

Intentionally break the query in a new way (wrong column name, missing GROUP BY, etc.) and ask CoCo to fix it again.

---

## 6. Exercise 2: Build a Loan Risk Analysis Notebook

**Time:** ~15-20 minutes
**Skill level:** Intermediate (no data science experience needed — CoCo writes the code)
**What you'll learn:** How to use CoCo to build a multi-cell risk analysis entirely in a notebook

### Scenario

The Chief Risk Officer wants a comprehensive view of loan portfolio health ahead of the next board meeting. Instead of filing a ticket and waiting weeks, you'll build it right now using CoCo.

### Step 1: Create a Notebook

1. In Snowsight, go to **Projects > Notebooks**
2. Click **+ Notebook**
3. Name it `Loan Portfolio Risk Analysis` (or anything you like)
4. Set the database to `CUSTOMERS_BANK_DEMO` and the schema to `BANKING`
5. Select your warehouse
6. Click **Create**

### Step 2: Loan Status Overview (Cell 1)

In the CoCo panel, type this prompt:

> **Query the LOANS table. Show the count and total remaining balance by loan status (Current, Past Due, Watch List, Default). Include the percentage of total portfolio each status represents.**

CoCo will generate a cell that analyzes loan status distribution. **Run the cell.**

### Step 3: Branch Risk Concentration (Cell 2)

Type this prompt into CoCo:

> **Join LOANS with BRANCHES. Show which branches have the highest concentration of past-due and defaulted loans. Include total loan count, at-risk count, at-risk percentage, and total at-risk exposure by branch.**

### Step 4: Customer Risk Profile (Cell 3)

> **Join LOANS with CUSTOMERS. Analyze how credit score and risk rating correlate with loan status. Show average credit score for each loan status, and break down the count of loans by risk_rating and status.**

### Step 5: Days Past Due Distribution (Cell 4)

> **Create a histogram-style breakdown of DAYS_PAST_DUE from the LOANS table. Bucket into: Current (0), 1-30 days, 31-60 days, 61-90 days, 90+ days. Show count and total remaining balance for each bucket.**

### Step 6: Portfolio Summary (Cell 5)

> **Write a summary cell that shows: total portfolio size (sum of all remaining balances), total at-risk exposure (Past Due + Watch List + Default), portfolio risk percentage, average credit score of at-risk borrowers vs current borrowers, and the top 3 branches by at-risk exposure.**

### What just happened

In five prompts, you:
1. Assessed overall loan portfolio health
2. Identified which branches carry the most risk
3. Correlated borrower profiles with delinquency
4. Built a days-past-due aging report
5. Produced an executive summary for the board

No manual SQL writing. No data left Snowflake. The entire analysis was driven by CoCo.

---

## 7. Exercise 3: Create a Dynamic Table for Branch Risk Monitoring

**Time:** ~10 minutes
**Skill level:** Intermediate
**What you'll learn:** How to operationalize an analysis as a live, auto-refreshing pipeline

### Scenario

The risk team loved the notebook analysis but said: "We need this updating automatically as new loans come in and payments are processed."

### Steps

In the CoCo panel (from a SQL Worksheet), type:

> **Create a Dynamic Table called CUSTOMERS_BANK_DEMO.ANALYTICS.BRANCH_RISK_DASHBOARD that keeps a live view of branch-level risk. Join LOANS with BRANCHES. For each branch, show: total_loans, total_exposure (sum of remaining_balance), at_risk_loans (count where status != 'Current'), at_risk_exposure, at_risk_pct, avg_credit_score of borrowers (join CUSTOMERS), and a RISK_FLAG column that is 'HIGH' when at_risk_pct > 15 or at_risk_exposure > 5000000, else 'NORMAL'. Use your warehouse and a target lag of 1 minute. Execute the SQL.**

After CoCo creates it, verify:

> **Show me all rows from the BRANCH_RISK_DASHBOARD dynamic table**

> **Show me the refresh history for the BRANCH_RISK_DASHBOARD dynamic table**

### What just happened

You turned a one-time analysis into a live operational view. When new loans are originated or statuses change, the Dynamic Table updates automatically — no Airflow, no cron jobs, no manual refreshes.

---

## 8. Exercise 4: Deploy a Streamlit Dashboard

**Time:** ~10 minutes
**Skill level:** Anyone
**What you'll learn:** How to go from data to a live, shareable dashboard in one or two CoCo prompts

### Scenario

The executive team wants a visual dashboard they can check before each risk committee meeting.

### Step 1: Ask CoCo to Build the App

In a **SQL Worksheet** (not a notebook), open the CoCo panel and type:

> **Build a Streamlit in Snowflake app called "Branch Risk Monitor" in CUSTOMERS_BANK_DEMO.APPS. The app should: (1) Read from the BRANCH_RISK_DASHBOARD dynamic table in the ANALYTICS schema. (2) Show a header: "Customers Bank — Branch Risk Monitor". (3) Display branch risk cards with color coding — green for NORMAL, red for HIGH risk flag. (4) Show a bar chart comparing total_exposure vs at_risk_exposure by branch. (5) Show a metrics table with all columns. (6) Add a "Risk Summary" section that highlights any branches flagged HIGH with their at-risk percentage and exposure. Use the Snowpark session for data access. Deploy the app.**

### Step 2: Iterate on the Design

Ask CoCo to refine the app:

> **Add a sidebar filter for region and a KPI row at the top showing total portfolio exposure, total at-risk exposure, and overall at-risk percentage.**

Accept the changes and re-run the app.

### What just happened

You went from a data table to a live, interactive, shareable risk dashboard in two prompts. Anyone in your Snowflake account with the right permissions can open this app — no additional infrastructure required.

---

## 9. Bonus Exercises

If you finish the four main exercises and want to keep going, try any of these.

### For Data Engineers

**Build a transaction summary view:**
> "Create a view called DAILY_BRANCH_METRICS in CUSTOMERS_BANK_DEMO.ANALYTICS that aggregates TRANSACTIONS by branch (join through ACCOUNTS and CUSTOMERS), date, and channel. Include total volume, transaction count, and average transaction size."

**Write a multi-table query:**
> "Show the top 10 customers by total relationship size — sum of all account balances plus all loan principals. Include their segment, credit score, and primary branch."

### For Risk Analysts

**Loan concentration analysis:**
> "What percentage of our total loan portfolio is concentrated in Commercial Real Estate? Break it down by branch and show which branches have the highest CRE concentration."

**Past-due trending:**
> "Show a monthly trend of newly past-due loans over the last 6 months. Is the delinquency rate increasing or decreasing?"

**Credit score distribution:**
> "Create a notebook that visualizes the credit score distribution of our borrowers. Overlay the distribution for current vs past-due loans. Are we seeing a pattern?"

### For Business Analysts

**Channel adoption:**
> "What percentage of transactions happen through digital channels (Online Banking + Mobile App) vs traditional (In-Branch + ATM + Phone)? Show the trend over the last 6 months."

**Customer segmentation:**
> "Which customer segment (Premium, Standard, Small Business, Commercial) generates the most transaction volume? Which has the highest average account balance?"

### For Anyone

**Explore the data:**
> "What tables are in the CUSTOMERS_BANK_DEMO.BANKING schema? Describe each one and show me the row count."

**Ask a business question:**
> "Which branch has the highest ratio of at-risk loans to total loans?"

---

## 10. Tips and Troubleshooting

### General CoCo Tips

- **Be specific.** The more detail you give CoCo, the better the output. Include table names, column names, and what you want to see.
- **Iterate.** If the first result isn't perfect, tell CoCo what to change: *"Add a WHERE clause for only Past Due loans"*, *"Use a bar chart instead"*, *"Include the branch region"*.
- **Paste errors.** If anything fails, copy the full error message and paste it into CoCo with *"Fix this"*. It works surprisingly well.
- **Set your context.** Always make sure CoCo knows which database/schema you're working in. Start with `USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;` or tell CoCo: *"Use the CUSTOMERS_BANK_DEMO.BANKING schema"*.
- **Screenshots work too.** In the CoCo panel, you can paste a screenshot of an error or a chart and ask CoCo to help with it.

### Common Issues

| Problem | Solution |
|---------|----------|
| "Object does not exist" | You're in the wrong schema. Run `USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;` |
| CoCo panel isn't visible | Make sure you're in a worksheet or notebook, click the chat icon on the right, or refresh Snowsight |
| Warehouse not set | Run `USE WAREHOUSE <your_warehouse>;` |
| Notebook cell won't run | Check that the cell type matches the code (SQL cell for SQL, Python cell for Python) |
| Streamlit app shows an error | Read the error message in the app. Often it's a missing table or wrong schema. Paste the error into CoCo |
| "Insufficient privileges" | You may need a different role. Try `USE ROLE SYSADMIN;` or ask your admin |

### Useful SQL Quick Reference

```sql
-- Set your context
USE ROLE <your_role>;
USE WAREHOUSE <your_warehouse>;
USE SCHEMA CUSTOMERS_BANK_DEMO.BANKING;

-- Check what tables exist
SHOW TABLES IN SCHEMA CUSTOMERS_BANK_DEMO.BANKING;

-- Check row counts
SELECT COUNT(*) FROM LOANS;

-- Quick risk summary
SELECT
    b.REGION,
    COUNT(l.LOAN_ID) AS total_loans,
    SUM(CASE WHEN l.STATUS != 'Current' THEN 1 ELSE 0 END) AS at_risk,
    SUM(l.REMAINING_BALANCE)::NUMBER(14,2) AS total_exposure
FROM LOANS l
JOIN BRANCHES b ON l.BRANCH_ID = b.BRANCH_ID
GROUP BY b.REGION
ORDER BY total_exposure DESC;
```

---

## You're Done!

You've walked through the full Cortex Code experience:
- **Exercise 1:** Fixed broken SQL with a single natural language prompt
- **Exercise 2:** Built a multi-cell loan risk analysis notebook — five prompts, zero manual SQL
- **Exercise 3:** Operationalized the analysis as an auto-refreshing Dynamic Table
- **Exercise 4:** Deployed a live Streamlit risk dashboard from one prompt

Everything you built lives inside Snowflake — no external tools, no local environments, no package management. Take these patterns back to your own data and start building.

Questions? Reach out to your Snowflake team.
