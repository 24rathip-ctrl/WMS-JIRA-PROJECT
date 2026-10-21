-- Sample electronics warehouse items for demonstration
USE wms_db;

INSERT INTO products (product_id, name, category, unit_price, quantity, description) VALUES
('WMS-101', 'Apple MacBook Pro 16" (M3 Max, 36GB RAM, 1TB SSD)', 'Laptops & Computers', 249900.00, 15, 'Liquid Retina XDR display with Apple M3 Max 14-core CPU and 30-core GPU'),
('WMS-102', 'Apple iPhone 16 Pro Max (256GB, Desert Titanium)', 'Mobile & Tablets', 144900.00, 42, 'Super Retina XDR 6.9-inch OLED with A18 Pro chip and 48MP Fusion camera'),
('WMS-103', 'JBL PartyBox Stage 320 Bluetooth Speaker (240W)', 'Audio & Speakers', 39999.00, 8, 'High-power portable wireless party speaker with AI sound boost and lightshow'),
('WMS-104', 'Shure SM7B Cardioid Dynamic Studio Microphone', 'Microphones & Recording', 34500.00, 18, 'Legendary broadcast vocal microphone with flat wide-range frequency response'),
('WMS-105', 'Sony Bravia XR 65" 4K OLED Smart Google TV', 'Televisions & Displays', 189900.00, 4, 'Cognitive Processor XR OLED panel with Acoustic Surface Audio+ and Dolby Vision'),
('WMS-106', 'Sony WH-1000XM5 Wireless Noise Cancelling Headset', 'Headsets & Wearables', 29990.00, 25, 'Premium over-ear wireless headphones with Auto NC Optimizer and 30hr battery'),
('WMS-107', 'Apple 140W USB-C Power Adapter + MagSafe 3 Cable', 'Electronics Accessories', 9500.00, 0, 'Fast charging GaN power adapter with 2-meter braided USB-C to MagSafe 3 cable')
ON DUPLICATE KEY UPDATE name=VALUES(name), category=VALUES(category), unit_price=VALUES(unit_price), quantity=VALUES(quantity), description=VALUES(description);
