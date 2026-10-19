-- WMS Database Schema
-- Run this script once to set up the database.

CREATE DATABASE IF NOT EXISTS wms_db;
USE wms_db;

-- Create a dedicated application user with least-privilege access.
-- Change the password before use.
CREATE USER IF NOT EXISTS 'wms_user'@'localhost' IDENTIFIED BY 'wms_pass_CHANGE_ME';
GRANT SELECT, INSERT, UPDATE, DELETE ON wms_db.* TO 'wms_user'@'localhost';
FLUSH PRIVILEGES;

-- Products table
CREATE TABLE IF NOT EXISTS products (
    product_id  VARCHAR(20)    NOT NULL,
    name        VARCHAR(100)   NOT NULL,
    category    VARCHAR(50)    NOT NULL,
    unit_price  DECIMAL(10,2)  NOT NULL,
    quantity    INT            NOT NULL DEFAULT 0,
    description TEXT,
    created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
