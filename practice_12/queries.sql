-- Top 5 customers by revenue
SELECT
    c.customer_id,
    c.name,
    SUM(orders.total_amount) AS revenue
FROM orders
JOIN customers c on c.customer_id = orders.customer_id
GROUP BY c.customer_id, c.name
ORDER BY revenue DESC
LIMIT 5;

-- Orders created this month
SELECT
    mi.restaurant_id,
    o.customer_id,
    c.name AS customer_name,
    mi.name AS item_name,
    o.created_at
FROM orders o
JOIN menu_items mi on o.restaurant_id = mi.restaurant_id
JOIN customers c on c.customer_id = o.customer_id
WHERE o.created_at >= NOW() - INTERVAL '30 days'
ORDER BY o.created_at;

-- Most popular product
SELECT
    mi.restaurant_id,
    mi.name AS item_name,
    oi.quantity
FROM menu_items mi
JOIN order_items oi on mi.item_id = oi.item_id
ORDER BY oi.quantity DESC;

-- Number of active users
SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM orders
WHERE created_at >= NOW() - INTERVAL '30 days';

-- Revenue by category
SELECT
    cat.name AS category,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
JOIN categories cat ON cat.category_id = mi.category_id
GROUP BY cat.name
ORDER BY revenue DESC;

-- Products never ordered
SELECT
    mi.item_id,
    mi.name
FROM menu_items mi
LEFT JOIN order_items oi ON oi.item_id = mi.item_id
WHERE oi.item_id IS NULL;

-- Customers without transactions
SELECT
    c.customer_id,
    c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Average order value
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders;

-- Monthly sales trend
SELECT
    EXTRACT(MONTH FROM created_at) AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY EXTRACT(MONTH FROM created_at)) AS revenue_change
FROM orders
GROUP BY month
ORDER BY month;

-- Top selling category
SELECT
    cat.name AS category,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
JOIN categories cat ON cat.category_id = mi.category_id
GROUP BY cat.name
ORDER BY total_sold DESC
LIMIT 1;
