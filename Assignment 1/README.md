# 🏦 Banking Fraud Monitoring System

Advanced PostgreSQL project that simulates a production-like fraud detection environment used in modern banking systems.

## 📋 Overview

The system stores customers, accounts, cards and transactions, automatically detects suspicious activity, tracks status changes, maintains audit logs and provides analytical reporting.

## 🗂️ Project Structure

```
├── step1_tables.sql          — DDL: tables, constraints, indexes + seed data
├── step2_functions.sql       — Reusable PostgreSQL functions
├── step3_procedures.sql      — Stored procedures for business logic
├── step4_triggers.sql        — Triggers for automation
├── step5_views.sql           — Views and materialized views
└── step6_scheduled_refresh.sql — Bonus: scheduled refresh via pg_cron
```

## 🗄️ Database Schema

### Tables

| Table | Description |
|---|---|
| `customers` | Bank customers with personal info |
| `accounts` | Bank accounts (UAH / USD / EUR) |
| `cards` | Debit and credit cards (PAN stored as SHA-256 hash) |
| `transactions` | All financial transactions |
| `transaction_status_history` | Full audit trail of status changes |
| `fraud_rules` | Configurable fraud detection rules |
| `fraud_alerts` | Alerts generated for suspicious transactions |
| `audit_log` | INSERT / UPDATE / DELETE log across key tables |

### ER Diagram

```
customers
  └── accounts
        └── cards
        └── transactions
              └── transaction_status_history
              └── fraud_alerts
                    └── fraud_rules
audit_log
```

## ⚙️ Key Constraints

- **Primary Keys** on all tables
- **Foreign Keys** enforcing all relationships
- **Unique**: `customers.email`, `accounts.account_number`, `cards.card_number_hash`
- **Check**: `amount > 0`, `balance >= 0`, `currency IN ('UAH','USD','EUR')`, `status IN ('PENDING','APPROVED','DECLINED','FLAGGED')`

## 🔧 Functions

| Function | Returns | Description |
|---|---|---|
| `get_customer_age(customer_id)` | `INT` | Customer age in years |
| `mask_card_number(card_number)` | `TEXT` | Masks PAN → `**** **** **** 1001` |
| `is_high_risk_country(country_code)` | `BOOLEAN` | FATF blacklist + sanctioned countries check |
| `calculate_customer_daily_volume(customer_id, date)` | `NUMERIC` | Daily transaction volume in UAH equivalent |
| `calculate_transaction_risk_score(transaction_id)` | `INT` | Risk score 0–100 based on 5 rules |
| `get_customer_risk_profile(customer_id)` | `TABLE` | Aggregated risk summary for a customer |
| `get_account_velocity(account_id, minutes)` | `INT` | Transaction count in last N minutes |

### Risk Score Rules

| Rule | Points |
|---|---|
| Large amount (> 50 000 UAH equivalent) | +25 |
| High-risk country (FATF / sanctions) | +30 |
| Suspicious merchant (GAMBLING, CASINO, CRYPTO, WIRE_TRANSFER) | +20 |
| Night transaction (00:00 – 05:00) | +10 |
| High daily volume (> 100 000 UAH) | +15 |
| **Maximum** | **100** |

## 📦 Stored Procedures

| Procedure | Description |
|---|---|
| `process_transaction(transaction_id)` | Calculates risk, sets status, updates balance, creates alert |
| `create_fraud_alert(transaction_id, reason, risk_score)` | Creates fraud alert with matching rule |
| `freeze_account(account_id)` | Freezes account + blocks all active cards + writes to audit log |
| `approve_pending_transactions(minutes)` | Batch-processes all PENDING transactions older than N minutes |
| `refresh_fraud_dashboard()` | Refreshes `mv_daily_fraud_summary` and logs the event |

### Transaction Processing Flow

```
INSERT transaction (PENDING)
        ↓
  BEFORE trigger: calculate risk score
        ↓
   score >= 70 → DECLINED
   score >= 40 → FLAGGED
   score < 40  → stays PENDING
        ↓
  AFTER trigger: create fraud alert if FLAGGED / DECLINED
```

## ⚡ Triggers

| Trigger | Event | Description |
|---|---|---|
| `trg_transaction_risk_evaluation` | `BEFORE INSERT` on transactions | Auto-calculates risk score and sets status |
| `trg_fraud_alert_on_insert` | `AFTER INSERT` on transactions | Creates fraud alert if FLAGGED or DECLINED |

## 👁️ Views

| View | Description |
|---|---|
| `vw_customer_accounts` | Customers with their accounts and card counts |
| `vw_recent_transactions` | Last 30 days of transactions with risk level label |
| `vw_flagged_transactions` | All suspicious transactions with alert and rule details |
| `vw_customer_risk_profile` | Aggregated risk profile per customer (LOW / MEDIUM / HIGH / CRITICAL) |

## 📊 Materialized View

### `mv_daily_fraud_summary`

Daily fraud statistics snapshot. Stored on disk and refreshed on schedule — not recalculated on every query.

| Column | Description |
|---|---|
| `transaction_date` | Date |
| `total_transactions` | Total transaction count |
| `total_amount` | Total transaction amount |
| `flagged_count` | Number of FLAGGED + DECLINED transactions |
| `suspicious_amount` | Total amount of suspicious transactions |
| `avg_risk_score` | Average risk score for the day |
| `top_risky_customers` | Top 3 customer IDs by max risk score |
| `total_fraud_alerts` | Total fraud alerts created |

## ⏰ Scheduled Refresh (Bonus)

Automatic refresh configured via `pg_cron`:

```sql
-- Every day at 03:00
SELECT cron.schedule('refresh_fraud_dashboard_daily',
    '0 3 * * *',
    'CALL refresh_fraud_dashboard()');

-- Every 15 minutes on weekdays 09:00–18:00
SELECT cron.schedule('refresh_fraud_dashboard_realtime',
    '*/15 9-18 * * 1-5',
    'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_fraud_summary');
```

> **Note:** `pg_cron` requires installation at the OS level and `shared_preload_libraries = 'pg_cron'` in `postgresql.conf`. As an alternative, the same result can be achieved via system cron calling `psql`.

## 🚀 Getting Started

### Requirements

- PostgreSQL 14+
- Extension: `pgcrypto` (built-in, just needs enabling)
- Extension: `pg_cron` (optional, for scheduled refresh)

### Setup

```sql
-- 1. Create database
CREATE DATABASE fraud_db;

-- 2. Connect and run scripts in order
\c fraud_db

\i step1_tables.sql
\i step2_functions.sql
\i step3_procedures.sql
\i step4_triggers.sql
\i step5_views.sql
\i step6_scheduled_refresh.sql   -- optional
```

### Quick Test

```sql
-- Check row counts
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'fraud_alerts',  COUNT(*) FROM fraud_alerts;

-- Check risk profiles
SELECT * FROM vw_customer_risk_profile;

-- Check daily fraud summary
SELECT * FROM mv_daily_fraud_summary;

-- Process all pending transactions
CALL approve_pending_transactions();
```

## 🛠️ Tech Stack

- **PostgreSQL 14+**
- **PL/pgSQL** — stored procedures, functions, triggers
- **pgcrypto** — SHA-256 card number hashing
- **pg_cron** — scheduled materialized view refresh
- **JSONB** — flexible audit log storage
