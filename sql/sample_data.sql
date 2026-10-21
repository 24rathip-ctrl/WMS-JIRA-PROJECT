-- Sample electronics warehouse items for demonstration
USE wms_db;

INSERT INTO products (product_id, name, category, unit_price, quantity, description) VALUES
('WMS-101', 'ProBook 15 G10 Laptop (16GB RAM, 512GB SSD)', 'Laptops & Computers', 64999.00, 35, '15.6-inch FHD anti-glare display with Intel Core i7 processor'),
('WMS-102', 'Ultra 5G Smartphone (128GB Storage, 8GB RAM)', 'Mobile & Tablets', 24999.00, 50, 'AMOLED display mobile smartphone with 50MP triple camera system'),
('WMS-103', 'BoomBlast Wireless Bluetooth Party Speaker (40W)', 'Audio & Speakers', 4999.00, 8, 'Portable waterproof IPX7 bluetooth speaker with deep bass radiator'),
('WMS-104', 'Studio USB Condenser Microphone with Pop Filter', 'Microphones & Recording', 3499.00, 18, 'Cardioid studio recording microphone for podcasts and streaming'),
('WMS-105', '55-Inch 4K Ultra HD Smart OLED Television', 'Televisions & Displays', 54999.00, 5, 'Dolby Vision HDR smart television display with Google TV OS'),
('WMS-106', 'Wireless Active Noise-Cancelling (ANC) Headset', 'Headsets & Wearables', 7999.00, 24, 'Over-ear wireless bluetooth headset with 40-hour battery life'),
('WMS-107', 'Fast Charging GaN Desktop Power Hub (65W)', 'Electronics Accessories', 1999.00, 0, 'Multi-port USB-C fast charging adapter for laptops and mobiles')
ON DUPLICATE KEY UPDATE name=VALUES(name), category=VALUES(category), unit_price=VALUES(unit_price), quantity=VALUES(quantity), description=VALUES(description);
