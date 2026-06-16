# PostgreSQL Performance Analysis and Optimization Report

**Assignment:** Practical 02 — PostgreSQL Performance Analysis and Optimization  
**Database:** `student_perf_lab`  
**Environment:** PostgreSQL 16, local instance  
 
---
 
## Table of Contents
 
1. [Overview](#1-overview)
2. [Database Schema](#2-database-schema)
3. [Identified Performance Issues](#3-identified-performance-issues)
4. [Diagnostic Tools and Methods](#4-diagnostic-tools-and-methods)
5. [Query and Execution Plan Analysis](#5-query-and-execution-plan-analysis)
6. [Optimizations Implemented](#6-optimizations-implemented)
7. [Before and After Comparison](#7-before-and-after-comparison)
8. [Bonus: Concurrency and Deadlock Analysis](#8-bonus-concurrency-and-deadlock-analysis)
9. [Conclusions](#9-conclusions)
---
 
## 1. Overview
 
This report documents the analysis of a synthetic CRM/e-commerce PostgreSQL database under simulated concurrent load. A Python load generator (`load_assignment_generator.py`) was used to populate the database with test data and run multiple concurrent worker threads, each reproducing a specific class of performance problem. The objective was to independently identify bottlenecks, validate findings with PostgreSQL diagnostic tools, apply targeted optimizations, and measure the resulting improvement.
 
**Dataset scale:**
 
| Table | Row Count |
|---|---|
| customers | 20,000 |
| products | 2,000 |
| orders | 120,000 |
| order_items | ~360,000 |
| customer_events_wide | 200,000 |
 
---
 
## 2. Database Schema
 
The schema consists of five tables. Four tables represent a standard CRM/e-commerce model (`customers`, `products`, `orders`, `order_items`). The fifth table, `customer_events_wide`, is intentionally denormalized with 25 columns, including ten generic `attr_01` through `attr_10` text columns, representing a wide-table anti-pattern.
 
The following indexes were present by default before any optimization:
 
```sql
idx_orders_customer_id         ON orders(customer_id)
idx_order_items_order_id       ON order_items(order_id)
idx_order_items_product_id     ON order_items(product_id)
idx_events_customer_id         ON customer_events_wide(customer_id)
```
 
No indexes existed on `email`, `delivery_city`, `status`, or `event_time` columns.
 
---
 
## 3. Identified Performance Issues
 
Six categories of performance issues were identified during the load test:
 
### 3.1 Sequential Scans on Unindexed Text Columns
 
Queries filtering on `email` and `delivery_city` using `LIKE` patterns performed full sequential scans, reading all rows in the table regardless of selectivity.
 
### 3.2 High-Cost Aggregation on a Wide Table
 
The `customer_events_wide` table is 25 columns wide. Aggregation queries that only require `customer_id`, `event_type`, and `event_time` still force PostgreSQL to read the full row width for all 200,000 records, resulting in excessive I/O.
 
### 3.3 Cartesian-Style JOIN Pressure
 
A three-way JOIN between `customers`, `orders`, and `customer_events_wide` on the same `customer_id` key produces a large intermediate result set. Without filtering on a selective indexed column, PostgreSQL must hash-join very large intermediate sets, consuming significant memory and CPU.
 
### 3.4 Row-Level Lock Contention on Hot Rows
 
The load generator uses a small set of "hot" customer IDs (1–5) that are repeatedly updated by multiple concurrent workers. One worker holds a row lock for 8–15 seconds before committing, while other workers queue behind it. This creates sustained lock wait chains visible in `pg_stat_activity`.
 
### 3.5 Table-Level Lock Blocking Writes
 
A dedicated worker acquires `LOCK TABLE orders IN SHARE ROW EXCLUSIVE MODE` and holds it for 8–12 seconds. Any concurrent `UPDATE` on the `orders` table must wait for this lock to be released, blocking all write traffic to that table.
 
### 3.6 Intentional Deadlocks
 
Two pairs of worker threads acquire row locks on the `customers` table in opposite order, producing repeated deadlock cycles. PostgreSQL detects and resolves these automatically by rolling back one transaction, but the rollbacks generate overhead and degrade throughput.
 
---
 
## 4. Diagnostic Tools and Methods
 
### 4.1 pg_stat_statements
 
Used to identify the most time-consuming queries across all sessions during the load test:
 
```sql
SELECT
    query,
    calls,
    round(total_exec_time::numeric, 2) AS total_ms,
    round(mean_exec_time::numeric, 2)  AS mean_ms,
    rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```
 
**Top findings from pg_stat_statements:**
 
| Query (abbreviated) | Calls | Total (ms) | Mean (ms) |
|---|---|---|---|
| UPDATE customers SET city = city | 3,360 | 34,185,153 | 10,174 |
| UPDATE customers SET phone = ... | 3,929 | 10,329,857 | 2,629 |
| UPDATE customers SET country = country | 2,132 | 3,953,490 | 1,854 |
| UPDATE customers SET status = ... | 773 | 1,594,483 | 2,062 |
| SELECT ... FROM customer_events_wide GROUP BY ... | 7,100 | 1,317,966 | 185 |
| SELECT p.category, COUNT(*) FROM order_items JOIN products | 6,872 | 1,176,415 | 171 |
| SELECT COUNT(*) FROM customers JOIN orders JOIN events | 6,934 | 1,139,387 | 164 |
| SELECT * FROM orders WHERE delivery_city LIKE ... | 6,846 | 304,236 | 44 |
| SELECT * FROM customers WHERE email LIKE ... | 7,014 | 33,991 | 4 |
 
The dominant cost is in `UPDATE customers` queries, driven entirely by lock wait time rather than query execution time. The events aggregation and Cartesian join are the most expensive pure read operations.
 
### 4.2 pg_stat_activity — Blocked Sessions
 
```sql
SELECT
    blocked.pid        AS blocked_pid,
    blocked.query      AS blocked_query,
    blocking.pid       AS blocking_pid,
    blocking.query     AS blocking_query,
    blocked.wait_event_type,
    blocked.wait_event
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
ORDER BY blocked.pid;
```
 
**Observed result:** Nine concurrent blocked sessions were captured in a single snapshot. Multiple `UPDATE customers` sessions were blocked by other `UPDATE customers` sessions on the same rows (`wait_event = tuple`). One session was waiting on a `relation` lock, confirming the table-level lock on `orders` was actively blocking writers.
 
### 4.3 pg_stat_activity — Long-Running Transactions
 
```sql
SELECT pid, usename, state, now() - xact_start AS transaction_duration, query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start;
```
 
**Observed result:** A session in `idle in transaction` state was observed holding an open transaction for nearly 20 seconds. This corresponds directly to the `row_lock_holder_worker`, which acquires a row lock and then sleeps before committing. `idle in transaction` sessions are particularly dangerous because they hold locks without making progress.
 
### 4.4 pg_stat_activity — Sessions Waiting on Locks
 
```sql
SELECT pid, usename, wait_event_type, wait_event, now() - query_start AS running_for, query
FROM pg_stat_activity
WHERE wait_event_type = 'Lock';
```
 
**Observed result:** Five sessions simultaneously waiting on locks. Lock types observed: `relation` (table-level), `transactionid` (waiting for a transaction to commit or roll back), and `tuple` (waiting for a row-level lock held by another session).
 
### 4.5 EXPLAIN ANALYZE
 
Used to inspect execution plans and confirm sequential scan behavior before and after index creation. Results are detailed in Section 5.
 
---
 
## 5. Query and Execution Plan Analysis
 
### 5.1 Email Search — Sequential Scan
 
```sql
EXPLAIN ANALYZE
SELECT * FROM customers WHERE email LIKE '%gmail%';
```
 
**Before optimization:**
```
Seq Scan on customers  (cost=0.00..593.00 rows=2 width=97)
                       (actual time=4.079..4.079 rows=0.00 loops=1)
  Filter: (email ~~ '%gmail%'::text)
  Rows Removed by Filter: 20000
Execution Time: 4.104 ms
```
 
The planner performs a full sequential scan of all 20,000 rows. A standard B-tree index cannot be used for `LIKE '%...'` patterns where the wildcard appears at the beginning of the string, because B-tree indexes rely on prefix ordering.
 
### 5.2 Orders by City and Status — Sequential Scan
 
```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE delivery_city LIKE '%a%' AND status = 'paid';
```
 
**Before optimization:**
```
Seq Scan on orders  (cost=0.00..3056.12 rows=16306 width=49)
                    (actual time=0.037..43.654 rows=19512.00 loops=1)
  Filter: ((delivery_city ~~ '%a%'::text) AND (status = 'paid'::text))
  Rows Removed by Filter: 100488
Execution Time: 45.113 ms
```
 
The query scans 120,000 rows and discards 100,488 at the filter stage. The `delivery_city LIKE '%a%'` predicate is highly non-selective and forces a full scan.
 
### 5.3 Events Aggregation — Sequential Scan on Wide Table
 
```sql
EXPLAIN ANALYZE
SELECT customer_id, event_type, COUNT(*) AS events_count, MAX(event_time) AS last_event_time
FROM customer_events_wide
WHERE event_time >= NOW() - INTERVAL '180 days'
GROUP BY customer_id, event_type
ORDER BY events_count DESC
LIMIT 200;
```
 
**Before optimization:**
```
Seq Scan on customer_events_wide  (cost=0.00..12933.61 rows=97484 width=19)
                                  (actual time=0.077..119.779 rows=98120.00 loops=1)
  Filter: (event_time >= (now() - '180 days'::interval))
  Rows Removed by Filter: 101880
Buffers: shared hit=9431
Execution Time: 242.730 ms
```
 
PostgreSQL reads the full width of 200,000 rows (25 columns each) to extract only three fields. The `event_time` column has no index, so date-range filtering happens after reading all rows.
 
### 5.4 Cartesian JOIN Pressure
 
```sql
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN customer_events_wide e ON e.customer_id = c.customer_id
WHERE c.status IN ('active', 'inactive')
  AND e.event_time >= NOW() - INTERVAL '90 days';
```
 
**Before optimization:**
```
Parallel Seq Scan on customer_events_wide e
  Filter: (event_time >= (now() - '90 days'::interval))
  Rows Removed by Filter: 75518
Parallel Seq Scan on orders o  rows=60000.00 per worker
Execution Time: 261.714 ms
```
 
All three tables are joined via sequential scans. PostgreSQL launches a parallel worker to compensate, but the fundamental issue is that `customer_events_wide` must be fully scanned to apply the `event_time` filter, and the join produces a very large intermediate result before aggregation.
 
---
 
## 6. Optimizations Implemented
 
### 6.1 Trigram Indexes for LIKE Search
 
The `pg_trgm` extension enables GIN indexes that support arbitrary `LIKE '%...%'` patterns by decomposing strings into trigrams (three-character sequences) and indexing them.
 
```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
 
CREATE INDEX idx_customers_email_trgm
    ON customers USING GIN (email gin_trgm_ops);
 
CREATE INDEX idx_orders_delivery_city_trgm
    ON orders USING GIN (delivery_city gin_trgm_ops);
```
 
### 6.2 Partial Index on orders.status
 
A partial index covers only rows where `status = 'paid'`, reducing index size and improving selectivity for the most common filter value.
 
```sql
CREATE INDEX idx_orders_status_paid
    ON orders (status) WHERE status = 'paid';
```
 
### 6.3 Composite Index on customer_events_wide
 
An index on `(event_time, customer_id)` allows the planner to use an index scan for date-range filters on the events table, reducing the number of heap blocks read.
 
```sql
CREATE INDEX idx_events_time_customer
    ON customer_events_wide (event_time, customer_id);
```
 
### 6.4 Table Normalization — Splitting customer_events_wide
 
The `customer_events_wide` table was decomposed into two tables:
 
- `customer_events` — contains the frequently queried core fields (9 columns)
- `customer_event_attributes` — contains rarely queried fields (utm parameters, IP address, page URL, generic `attr_*` columns)
```sql
CREATE TABLE customer_events (
    event_id      INT PRIMARY KEY,
    customer_id   INT,
    event_type    TEXT,
    event_time    TIMESTAMP,
    source        TEXT,
    campaign      TEXT,
    device        TEXT,
    browser       TEXT,
    os            TEXT
);
 
CREATE TABLE customer_event_attributes (
    event_id     INT,
    ip_address   TEXT,
    page_url     TEXT,
    referrer     TEXT,
    utm_source   TEXT,
    utm_medium   TEXT,
    utm_campaign TEXT,
    attr_01 TEXT, attr_02 TEXT, attr_03 TEXT, attr_04 TEXT, attr_05 TEXT,
    attr_06 TEXT, attr_07 TEXT, attr_08 TEXT, attr_09 TEXT, attr_10 TEXT
);
 
INSERT INTO customer_events
SELECT event_id, customer_id, event_type, event_time, source, campaign, device, browser, os
FROM customer_events_wide;
 
INSERT INTO customer_event_attributes
SELECT event_id, ip_address, page_url, referrer, utm_source, utm_medium, utm_campaign,
       attr_01, attr_02, attr_03, attr_04, attr_05, attr_06, attr_07, attr_08, attr_09, attr_10
FROM customer_events_wide;
 
CREATE INDEX idx_ce_event_time   ON customer_events (event_time);
CREATE INDEX idx_ce_customer_id  ON customer_events (customer_id);
```
 
---
 
## 7. Before and After Comparison
 
### 7.1 Email LIKE Search
 
| Metric | Before | After |
|---|---|---|
| Scan type | Seq Scan | Bitmap Index Scan (GIN trgm) |
| Rows read | 20,000 | 0 (index only) |
| Buffer reads | 343 | 8 |
| Execution time | 4.104 ms | 0.130 ms |
| Improvement | — | **31x faster** |
 
### 7.2 Orders by City and Status
 
| Metric | Before | After |
|---|---|---|
| Scan type | Seq Scan | Bitmap Index Scan (partial index on status) |
| Rows discarded by filter | 100,488 | 9,249 |
| Execution time | 45.113 ms | 11.189 ms |
| Improvement | — | **4x faster** |
 
### 7.3 Events Aggregation (Normalized Table)
 
| Metric | Before (customer_events_wide) | After (customer_events) |
|---|---|---|
| Scan type | Seq Scan | Bitmap Index Scan (idx_ce_event_time) |
| Buffer reads | 9,431 | 2,566 |
| Columns read per row | 25 | 9 |
| Execution time | 242.730 ms | 205.897 ms |
| Improvement | — | **15% faster, 3.7x fewer buffer reads** |
 
The execution time improvement for the aggregation query is modest because the bottleneck is the aggregation of ~98,000 qualifying rows, which is inherent to the query's nature. However, the I/O reduction is significant: buffer reads dropped from 9,431 to 2,566, indicating that the narrower table structure substantially reduces the amount of data read from disk per row.
 
### 7.4 Cartesian JOIN
 
| Metric | Before | After |
|---|---|---|
| Scan type on events | Parallel Seq Scan | Parallel Seq Scan |
| Execution time | 261.714 ms | 198.332 ms |
| Improvement | — | **~24% faster** |
 
The composite index on `(event_time, customer_id)` provided a moderate improvement. The planner continued to prefer a parallel sequential scan because the date range filter matches approximately 49% of the table — a selectivity level at which a sequential scan remains competitive. Further improvement would require query rewriting (pre-aggregating events before joining) or partitioning `customer_events` by `event_time`.
 
---
 
## 8. Bonus: Concurrency and Deadlock Analysis
 
### 8.1 Root Cause
 
The load generator intentionally creates deadlocks using two pairs of threads that acquire row locks in opposite order:
 
- `deadlock_a`: locks `customer_id=1`, then `customer_id=2`
- `deadlock_b`: locks `customer_id=2`, then `customer_id=1`
When both threads reach their second `UPDATE` simultaneously, each holds a lock that the other requires, and neither can proceed. PostgreSQL detects the cycle after `deadlock_timeout` (set to 500ms in the script) and rolls back one of the transactions.
 
### 8.2 Evidence
 
The terminal output from the load generator captured repeated deadlock events:
 
```
deadlock_a: locked first customer_id=1
deadlock_b: locked first customer_id=2
deadlock_d failed: LockNotAvailable: ПОМИЛКА: виконання оператора скасовано через тайм-аут блокування
```
 
The `pg_stat_statements` data confirmed the impact: `UPDATE customers SET city = city` accumulated over 34 billion milliseconds of total execution time across 3,360 calls, with a mean execution time of 10,174 ms per call — almost entirely attributable to lock wait time rather than actual query processing.
 
The blocked session query confirmed the lock chain in real time, showing multiple `UPDATE customers` sessions with `wait_event = transactionid` and `wait_event = tuple`, indicating both transaction-level and row-level contention.
 
### 8.3 Solution
 
The standard approach to eliminating this class of deadlock is to enforce a consistent lock acquisition order across all transactions that modify the same set of rows. When all concurrent transactions update rows in the same sequence (e.g., always ascending by `customer_id`), no circular dependency can form.
 
```sql
-- Instead of: lock customer_id=2 then customer_id=1
-- Enforce:    always lock in ascending order
 
BEGIN;
-- Sort target IDs before locking
UPDATE customers SET city = city WHERE customer_id = 1;
UPDATE customers SET country = country WHERE customer_id = 2;
COMMIT;
```
 
An alternative mitigation is to reduce the duration for which locks are held by keeping transactions as short as possible, eliminating the `time.sleep()` between the two updates, and using `SELECT ... FOR UPDATE NOWAIT` or `SKIP LOCKED` where appropriate to avoid blocking queues on hot rows.
 
Additionally, moving the hot-row updates to a queue-based pattern (e.g., using `pg_notify` or an application-level queue) would eliminate direct contention on the `customers` table entirely.
 
### 8.4 Validation
 
After enforcing consistent lock ordering, the deadlock cycle is broken by construction: no two transactions can hold locks that the other requires simultaneously. The `deadlock` error count in `pg_stat_statements` and the PostgreSQL server log would decrease to zero for that specific access pattern.
 
---
 
## 9. Conclusions
 
The following table summarizes all identified issues, their root causes, the tools used to detect them, and the solutions applied.
 
| Issue | Detection Tool | Root Cause | Solution Applied |
|---|---|---|---|
| Seq scan on `email LIKE '%...'` | EXPLAIN ANALYZE | No trigram index; B-tree unusable for leading wildcard | GIN index with `pg_trgm` |
| Seq scan on `delivery_city LIKE '%...'` | EXPLAIN ANALYZE | No index on text column | GIN trigram index + partial index on `status` |
| High I/O on events aggregation | EXPLAIN ANALYZE, pg_stat_statements | 25-column wide table read for 3-field query | Table normalization; index on `event_time` |
| Cartesian JOIN pressure | EXPLAIN ANALYZE | No index on `event_time` for range filter | Composite index `(event_time, customer_id)` |
| Row lock contention | pg_stat_activity, pg_locks | Long-running transactions on hot rows | Identified; mitigation: shorter transactions, lock ordering |
| Table lock on `orders` | pg_stat_activity | Explicit `LOCK TABLE` held 8–12 seconds | Identified; mitigation: avoid explicit table locks |
| Deadlocks on `customers` | Terminal output, pg_stat_statements | Inconsistent lock acquisition order | Enforce consistent ordering; reduce hold duration |
 
The most impactful single change was the addition of GIN trigram indexes, which reduced the email search execution time by a factor of 31. Normalization of `customer_events_wide` produced a 3.7x reduction in buffer reads for aggregation queries. Lock contention and deadlock scenarios, while not eliminable without modifying the load generator's application logic, were fully characterized and solutions were described and justified.
