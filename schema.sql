-- ============================================
-- Food Delivery Analytics — Database Schema
-- Compatible with MySQL 8.0+ / PostgreSQL (minor tweaks noted)
-- ============================================

CREATE DATABASE IF NOT EXISTS food_delivery_db;
USE food_delivery_db;

-- ---------- Customers ----------
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city          VARCHAR(50),
    signup_date   DATE
);

-- ---------- Restaurants ----------
CREATE TABLE restaurants (
    restaurant_id   INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    cuisine         VARCHAR(50),
    city            VARCHAR(50),
    rating          DECIMAL(3,2)
);

-- ---------- Delivery Partners ----------
CREATE TABLE delivery_partners (
    partner_id   INT PRIMARY KEY,
    partner_name VARCHAR(100),
    vehicle_type VARCHAR(30)
);

-- ---------- Orders ----------
CREATE TABLE orders (
    order_id              INT PRIMARY KEY,
    customer_id           INT,
    restaurant_id         INT,
    partner_id            INT,
    order_date             TIMESTAMP,
    delivery_time_minutes INT,
    order_amount           DECIMAL(10,2),
    order_status           VARCHAR(20),
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (partner_id)    REFERENCES delivery_partners(partner_id)
);

-- Helpful indexes for analytics queries
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_partner    ON orders(partner_id);
CREATE INDEX idx_orders_status     ON orders(order_status);
CREATE INDEX idx_orders_date       ON orders(order_date);
