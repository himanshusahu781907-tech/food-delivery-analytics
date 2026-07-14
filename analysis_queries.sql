 1. Total Orders
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_orders
FROM orders;


-- ------------------------------------------------------------
-- 2. Total Revenue (successfully delivered orders only)
-- ------------------------------------------------------------
SELECT ROUND(SUM(order_amount), 2) AS total_revenue
FROM orders
WHERE order_status <> 'Cancelled';


-- ------------------------------------------------------------
-- 3. Average Order Value (AOV)
-- ------------------------------------------------------------
SELECT ROUND(AVG(order_amount), 2) AS avg_order_value
FROM orders
WHERE order_status <> 'Cancelled';


-- ------------------------------------------------------------
-- 4. Average Delivery Time (minutes)
-- ------------------------------------------------------------
SELECT ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time_minutes
FROM orders
WHERE order_status IN ('Delivered', 'Delayed');


-- ------------------------------------------------------------
-- 5. On-Time Delivery Rate (%)
--    On-time = Delivered AND delivery_time_minutes <= 40
-- ------------------------------------------------------------
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN order_status = 'Delivered' AND delivery_time_minutes <= 40 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS on_time_delivery_rate_pct
FROM orders
WHERE order_status IN ('Delivered', 'Delayed');


-- ------------------------------------------------------------
-- 6. Delayed Delivery Rate (%)
-- ------------------------------------------------------------
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN order_status = 'Delayed' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS delayed_delivery_rate_pct
FROM orders;


-- ------------------------------------------------------------
-- 7. Orders by Hour of Day
-- ------------------------------------------------------------
SELECT
    HOUR(order_date) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY HOUR(order_date)
ORDER BY order_hour;


-- ------------------------------------------------------------
-- 8. Peak Ordering Hour
-- ------------------------------------------------------------
SELECT
    HOUR(order_date) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY HOUR(order_date)
ORDER BY total_orders DESC
LIMIT 1;


-- ------------------------------------------------------------
-- 9. Orders by Day of Week
-- ------------------------------------------------------------
SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY DAYOFWEEK(order_date);


-- ------------------------------------------------------------
-- 10. Revenue by Restaurant
-- ------------------------------------------------------------
SELECT
    r.restaurant_name,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status <> 'Cancelled'
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 11. Revenue by City (customer's city)
-- ------------------------------------------------------------
SELECT
    c.city,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.city
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 12. Top 10 Restaurants by Revenue
-- ------------------------------------------------------------
SELECT
    r.restaurant_name,
    r.cuisine,
    ROUND(SUM(o.order_amount), 2) AS total_revenue,
    COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status <> 'Cancelled'
GROUP BY r.restaurant_name, r.cuisine
ORDER BY total_revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 13. Top Customers by Spending
-- ------------------------------------------------------------
SELECT
    c.customer_name,
    c.city,
    ROUND(SUM(o.order_amount), 2) AS total_spent,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_name, c.city
ORDER BY total_spent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 14. Average Restaurant Rating (overall & by cuisine)
-- ------------------------------------------------------------
SELECT ROUND(AVG(rating), 2) AS avg_rating_overall
FROM restaurants;

SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants
GROUP BY cuisine
ORDER BY avg_rating DESC;


-- ------------------------------------------------------------
-- 15. Delivery Partner Performance
--     (orders handled, avg delivery time, on-time rate)
-- ------------------------------------------------------------
SELECT
    dp.partner_name,
    dp.vehicle_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(
        100.0 * SUM(CASE WHEN o.order_status = 'Delivered' AND o.delivery_time_minutes <= 40 THEN 1 ELSE 0 END)
        / SUM(CASE WHEN o.order_status IN ('Delivered','Delayed') THEN 1 ELSE 0 END), 2
    ) AS on_time_rate_pct
FROM orders o
JOIN delivery_partners dp ON dp.partner_id = o.partner_id
GROUP BY dp.partner_name, dp.vehicle_type
ORDER BY total_orders DESC;


-- ------------------------------------------------------------
-- 16. Average Orders per Delivery Partner
-- ------------------------------------------------------------
SELECT
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT partner_id), 2) AS avg_orders_per_partner
FROM orders;


-- ------------------------------------------------------------
-- 17. Highest Revenue Cuisine
-- ------------------------------------------------------------
SELECT
    r.cuisine,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status <> 'Cancelled'
GROUP BY r.cuisine
ORDER BY total_revenue DESC
LIMIT 1;


-- ------------------------------------------------------------
-- 18. Customer Retention Rate (%)
--     % of customers who placed more than 1 order
-- ------------------------------------------------------------
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS orders_placed
    FROM orders
    GROUP BY customer_id
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN orders_placed > 1 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS customer_retention_rate_pct
FROM order_counts;


-- ------------------------------------------------------------
-- 19. Repeat Order Rate (%)
--     % of all orders that came from repeat customers
-- ------------------------------------------------------------
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS orders_placed
    FROM orders
    GROUP BY customer_id
),
repeat_customers AS (
    SELECT customer_id FROM order_counts WHERE orders_placed > 1
)
SELECT
    ROUND(
        100.0 * (SELECT COUNT(*) FROM orders WHERE customer_id IN (SELECT customer_id FROM repeat_customers))
        / (SELECT COUNT(*) FROM orders), 2
    ) AS repeat_order_rate_pct;


-- ------------------------------------------------------------
-- 20. Cancellation Rate (%)
-- ------------------------------------------------------------
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS cancellation_rate_pct
FROM orders;


-- ------------------------------------------------------------
-- 21. Average Delivery Time by City
-- ------------------------------------------------------------
SELECT
    c.city,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Delivered', 'Delayed')
GROUP BY c.city
ORDER BY avg_delivery_time DESC;


-- ------------------------------------------------------------
-- 22. Average Delivery Time by Cuisine
-- ------------------------------------------------------------
SELECT
    r.cuisine,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.order_status IN ('Delivered', 'Delayed')
GROUP BY r.cuisine
ORDER BY avg_delivery_time DESC;


-- ------------------------------------------------------------
-- 23. Revenue Trend — Daily & Monthly
-- ------------------------------------------------------------
-- Daily
SELECT
    DATE(order_date) AS order_day,
    ROUND(SUM(order_amount), 2) AS daily_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE(order_date)
ORDER BY order_day;

-- Monthly
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(order_amount), 2) AS monthly_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- ------------------------------------------------------------
-- 24. Restaurant Market Share (% of total revenue)
-- ------------------------------------------------------------
WITH restaurant_revenue AS (
    SELECT
        r.restaurant_name,
        SUM(o.order_amount) AS revenue
    FROM orders o
    JOIN restaurants r ON r.restaurant_id = o.restaurant_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY r.restaurant_name
)
SELECT
    restaurant_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS market_share_pct
FROM restaurant_revenue
ORDER BY market_share_pct DESC;


-- ------------------------------------------------------------
-- 25. Customer Lifetime Value (CLV)
--     Total historical spend per customer
-- ------------------------------------------------------------
SELECT
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS lifetime_value,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_name, c.city
ORDER BY lifetime_value DESC;


-- ------------------------------------------------------------
-- BONUS: Customer Order Rank per City (window function)
-- ------------------------------------------------------------
SELECT
    c.city,
    c.customer_name,
    SUM(o.order_amount) AS total_spent,
    RANK() OVER (PARTITION BY c.city ORDER BY SUM(o.order_amount) DESC) AS spend_rank_in_city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.city, c.customer_name
ORDER BY c.city, spend_rank_in_city;
