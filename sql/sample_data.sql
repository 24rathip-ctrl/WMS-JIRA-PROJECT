-- Sample warehouse items for practical demonstration
USE wms_db;

INSERT INTO products (product_id, name, category, unit_price, quantity, description) VALUES
('WMS-101', 'Industrial Barcode Scanner', 'Barcode & Scanning', 289.99, 45, 'Wireless 2D handheld imager with charging cradle'),
('WMS-102', 'Heavy Duty Pallet Jack (2500kg)', 'Material Handling', 649.00, 12, 'Hydraulic manual pallet truck with nylon wheels'),
('WMS-103', 'Steel Warehouse Storage Rack (4-Tier)', 'Storage & Racks', 420.50, 8, 'Heavy duty teardrop pallet racking upright frame'),
('WMS-104', 'Stretch Wrap Film Roll (500mm)', 'Packaging Supplies', 18.75, 120, 'High clarity industrial pallet wrapping film roll'),
('WMS-105', 'High-Visibility Safety Vest (Pack of 10)', 'Safety & PPE', 45.00, 30, 'ANSI Class 2 compliant reflective safety apparel'),
('WMS-106', 'Thermal Transfer Label Printer', 'Barcode & Scanning', 510.00, 5, 'Industrial 300 DPI thermal desktop label maker'),
('WMS-107', 'Adjustable Torque Wrench Set', 'Tools & Hardware', 85.50, 0, 'Heavy industrial 1/2-inch mechanical click wrench')
ON DUPLICATE KEY UPDATE name=VALUES(name), category=VALUES(category), unit_price=VALUES(unit_price), description=VALUES(description);
