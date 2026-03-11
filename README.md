# Customers Bank x Cortex Code — CoCo Enablement Demo

**Date:** March 11, 2026 (Zoom)
**Duration:** 60 minutes (30 min demo + 30 min hands-on)

---

## Quick Start

### 1. Run the Setup Script
Open a Snowsight worksheet and paste the contents of [`setup.sql`](setup.sql). Run all statements. This creates the `CUSTOMERS_BANK_DEMO` database with 5 tables of realistic banking data (5K customers, 3K loans, 8K accounts, 200K+ transactions across 15 branches).

### 2. Verify CoCo is Enabled
In Snowsight, open any **SQL Worksheet** or **Notebook** and look for the **Cortex Code panel** on the right side of the screen. It should appear automatically — just click the chat icon if the panel is collapsed.

### 3. Start Building
Open the [Quickstart Guide](quickstart_guide.md) and follow the step-by-step exercises.

---

## Repo Contents

| File | Description |
|------|-------------|
| [`setup.sql`](setup.sql) | Master setup script — creates database, schemas, and all demo tables |
| [`broken_ops_query.sql`](broken_ops_query.sql) | Pre-loaded broken SQL for the "Fix It" demo |
| [`quickstart_guide.md`](quickstart_guide.md) | A-Z Quickstart Guide — self-paced walkthrough of all exercises |

---

## Demo Data

All data lives in `CUSTOMERS_BANK_DEMO.BANKING`:

| Table | Rows | Description |
|-------|------|-------------|
| `BRANCHES` | 15 | Branch locations across Northeast and Mid-Atlantic — Flagship, Full-Service, Commercial, Community |
| `CUSTOMERS` | 5,000 | Individual and business customers with credit scores, income, risk ratings, and segments |
| `ACCOUNTS` | 8,000 | Checking, Savings, Money Market, CD, and Business accounts with balances and interest rates |
| `LOANS` | 3,000 | Mortgage, CRE, Business LOC, Auto, Personal, SBA, Construction — with status and days past due |
| `TRANSACTIONS` | ~200K+ | 6 months of deposits, withdrawals, transfers, ACH, wires, checks, and fees across channels |

---

## Session Structure

| Time | Segment | What Happens |
|------|---------|--------------|
| 0:00–2:00 | Opener | CoCo intro, frame the session |
| 2:00–7:00 | Demo A: "Fix It" | Run broken SQL, ask CoCo to fix it |
| 7:00–17:00 | Demo B: "Analyze It" | Build a loan risk analysis notebook with CoCo prompts |
| 17:00–22:00 | Demo C: "Operationalize It" | Create a Dynamic Table for live branch risk monitoring |
| 22:00–28:00 | Demo D: "Ship It" | Deploy a Streamlit risk dashboard from one prompt |
| 28:00–30:00 | Transition | Share Quickstart Guide, hand off to attendees |
| 30:00–60:00 | "Go Build" | Attendees build with CoCo, we troubleshoot in chat |
