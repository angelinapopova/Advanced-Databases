SELECT
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    blocked.wait_event_type,
    blocked.wait_event
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
ORDER BY blocked.pid;


SELECT pid, usename, state, now() - xact_start AS transaction_duration, query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start;

SELECT pid, usename, wait_event_type, wait_event, now() - query_start AS running_for, query
FROM pg_stat_activity
WHERE wait_event_type = 'Lock';


CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT
    query,
    calls,
    round(total_exec_time::numeric, 2) AS total_ms,
    round(mean_exec_time::numeric, 2) AS mean_ms,
    rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE email LIKE '%gmail%';

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE delivery_city LIKE '%a%'
AND status = 'paid';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN customer_events_wide e ON e.customer_id = c.customer_id
WHERE c.status IN ('active', 'inactive')
AND e.event_time >= NOW() - INTERVAL '90 days';


-- Оптимізація
-- 1. pg_trgm для LIKE пошуку
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_customers_email_trgm
ON customers USING GIN (email gin_trgm_ops);

CREATE INDEX idx_orders_delivery_city_trgm
ON orders USING GIN (delivery_city gin_trgm_ops);

-- 2. Partial index для status (часто фільтрують)
CREATE INDEX idx_orders_status_paid
ON orders (status) WHERE status = 'paid';

-- 3. Composite index для events_wide
CREATE INDEX idx_events_time_customer
ON customer_events_wide (event_time, customer_id);

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE email LIKE '%gmail%';

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE delivery_city LIKE '%a%'
AND status = 'paid';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN customer_events_wide e ON e.customer_id = c.customer_id
WHERE c.status IN ('active', 'inactive')
AND e.event_time >= NOW() - INTERVAL '90 days';

-- до оптимізації нормаліація широкої таблиці
EXPLAIN ANALYZE
SELECT
    customer_id,
    event_type,
    COUNT(*) AS events_count,
    MAX(event_time) AS last_event_time
FROM customer_events_wide
WHERE event_time >= NOW() - INTERVAL '180 days'
GROUP BY customer_id, event_type
ORDER BY events_count DESC
LIMIT 200;

-- нормалізація широкої таблиці
-- Нова вузька таблиця подій
CREATE TABLE customer_events (
    event_id INT PRIMARY KEY,
    customer_id INT,
    event_type TEXT,
    event_time TIMESTAMP,
    source TEXT,
    campaign TEXT,
    device TEXT,
    browser TEXT,
    os TEXT
);

-- Таблиця для рідко використовуваних атрибутів
CREATE TABLE customer_event_attributes (
    event_id INT,
    ip_address TEXT,
    page_url TEXT,
    referrer TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    attr_01 TEXT,
    attr_02 TEXT,
    attr_03 TEXT,
    attr_04 TEXT,
    attr_05 TEXT,
    attr_06 TEXT,
    attr_07 TEXT,
    attr_08 TEXT,
    attr_09 TEXT,
    attr_10 TEXT
);

-- Мігруємо дані
INSERT INTO customer_events
SELECT event_id, customer_id, event_type, event_time, source, campaign, device, browser, os
FROM customer_events_wide;

INSERT INTO customer_event_attributes
SELECT event_id, ip_address, page_url, referrer, utm_source, utm_medium, utm_campaign,
       attr_01, attr_02, attr_03, attr_04, attr_05, attr_06, attr_07, attr_08, attr_09, attr_10
FROM customer_events_wide;

-- Індекси на новій таблиці
CREATE INDEX idx_ce_event_time ON customer_events (event_time);
CREATE INDEX idx_ce_customer_id ON customer_events (customer_id);

-- після оптимізації нормаліація широкої таблиці
EXPLAIN ANALYZE
SELECT
    customer_id,
    event_type,
    COUNT(*) AS events_count,
    MAX(event_time) AS last_event_time
FROM customer_events
WHERE event_time >= NOW() - INTERVAL '180 days'
GROUP BY customer_id, event_type
ORDER BY events_count DESC
LIMIT 200;
