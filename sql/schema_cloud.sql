-- ============================================================
-- Cloud-compatible schema for Aiven MySQL (or any remote MySQL)
-- ============================================================
-- Aiven provisions a database and admin user for you.
-- You do NOT need CREATE DATABASE or CREATE USER — Aiven
-- handles that. Just run this against the default database.
--
-- Usage (with Aiven connection details):
--   mysql -h <HOST> -P <PORT> -u <USER> -p<PASSWORD> \
--         --ssl-mode=REQUIRED <DATABASE> < sql/schema_cloud.sql
-- ============================================================

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

-- Optional: seed sample warehouse items
INSERT INTO products (product_id, name, category, unit_price, quantity, description) VALUES
('WMS-101', 'Industrial Barcode Scanner', 'Barcode & Scanning', 289.99, 45, 'Wireless 2D handheld imager with charging cradle'),
('WMS-102', 'Heavy Duty Pallet Jack (2500kg)', 'Material Handling', 649.00, 12, 'Hydraulic manual pallet truck with nylon wheels'),
('WMS-103', 'Steel Warehouse Storage Rack (4-Tier)', 'Storage & Racks', 420.50, 8, 'Heavy duty teardrop pallet racking upright frame'),
('WMS-104', 'Stretch Wrap Film Roll (500mm)', 'Packaging Supplies', 18.75, 120, 'High clarity industrial pallet wrapping film roll'),
('WMS-105', 'High-Visibility Safety Vest (Pack of 10)', 'Safety & PPE', 45.00, 30, 'ANSI Class 2 compliant reflective safety apparel'),
('WMS-106', 'Thermal Transfer Label Printer', 'Barcode & Scanning', 510.00, 5, 'Industrial 300 DPI thermal desktop label maker'),
('WMS-107', 'Adjustable Torque Wrench Set', 'Tools & Hardware', 85.50, 0, 'Heavy industrial 1/2-inch mechanical click wrench')
ON DUPLICATE KEY UPDATE name=VALUES(name), category=VALUES(category), unit_price=VALUES(unit_price), description=VALUES(description);
