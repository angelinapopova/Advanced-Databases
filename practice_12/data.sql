INSERT INTO customers (name, email, phone, address) VALUES
('Alice Johnson',   'alice@gmail.com',   '+380501112233', 'Kyiv, Khreshchatyk 1'),
('Bob Smith',       'bob@gmail.com',     '+380502223344', 'Kyiv, Lesi Ukrainky 5'),
('Carol White',     'carol@gmail.com',   '+380503334455', 'Lviv, Rynok Square 3'),
('David Brown',     'david@gmail.com',   '+380504445566', 'Odesa, Derybasivska 10'),
('Eva Green',       'eva@gmail.com',     '+380505556677', 'Kyiv, Antonovycha 12'),
('Frank Black',     'frank@gmail.com',   '+380506667788', 'Kharkiv, Sumska 7'),
('Grace Lee',       'grace@gmail.com',   '+380507778899', 'Kyiv, Baseina 2'),
('Henry Wilson',    'henry@gmail.com',   '+380508889900', 'Dnipro, Hoholya 4'),
('Iryna Kovalenko', 'iryna@gmail.com',   '+380509990011', 'Kyiv, Saksahanskoho 9'),
('John Doe',        'john@gmail.com',    '+380501230099', 'Kyiv, Velyka Vasylkivska 15');

INSERT INTO restaurants (name, address, phone, rating, is_active) VALUES
('Pizza Roma',      'Kyiv, Khreshchatyk 20',     '+380441110001', 4.5, TRUE),
('Sushi House',     'Kyiv, Antonovycha 8',        '+380441110002', 4.8, TRUE),
('Burger King',     'Kyiv, Baseina 3',            '+380441110003', 4.2, TRUE),
('Noodle Bar',      'Lviv, Rynok Square 5',       '+380441110004', 4.6, TRUE),
('Taco Place',      'Odesa, Derybasivska 2',      '+380441110005', 4.0, TRUE),
('Green Bowl',      'Kyiv, Lesi Ukrainky 11',     '+380441110006', 4.7, TRUE),
('Steak House',     'Kharkiv, Sumska 14',         '+380441110007', 4.3, TRUE),
('Wok & Roll',      'Dnipro, Hoholya 6',          '+380441110008', 4.1, TRUE),
('Kebab Palace',    'Kyiv, Saksahanskoho 3',      '+380441110009', 3.9, TRUE),
('Sweet Bakery',    'Kyiv, Velyka Vasylkivska 7', '+380441110010', 4.4, TRUE);


INSERT INTO categories (name) VALUES
('Pizza'),
('Sushi'),
('Burgers'),
('Noodles'),
('Tacos'),
('Salads'),
('Steaks'),
('Wok'),
('Kebab'),
('Desserts');


INSERT INTO menu_items (restaurant_id, category_id, name, description, price, is_available) VALUES
(1, 1,  'Margherita',        'Classic tomato and mozzarella',        180.00, TRUE),
(1, 1,  'Pepperoni',         'Spicy pepperoni pizza',                210.00, TRUE),
(2, 2,  'Philadelphia Roll', 'Salmon and cream cheese',              220.00, TRUE),
(2, 2,  'Dragon Roll',       'Shrimp tempura topped with avocado',   240.00, TRUE),
(3, 3,  'Classic Burger',    'Beef patty with lettuce and tomato',   150.00, TRUE),
(3, 3,  'Cheese Burger',     'Double beef with cheddar',             180.00, TRUE),
(4, 4,  'Pad Thai',          'Stir-fried rice noodles',              170.00, TRUE),
(5, 5,  'Beef Taco',         'Seasoned beef in corn tortilla',       130.00, TRUE),
(6, 6,  'Caesar Salad',      'Romaine, croutons, parmesan',          145.00, TRUE),
(7, 7,  'Ribeye Steak',      '300g ribeye with chimichurri',         450.00, TRUE),
(8, 8,  'Chicken Wok',       'Chicken with vegetables in soy sauce', 165.00, TRUE),
(9, 9,  'Chicken Kebab',     'Grilled chicken with lavash',          155.00, TRUE),
(10, 10,'Chocolate Cake',    'Rich dark chocolate layer cake',        95.00, TRUE),
(1, 1,  'BBQ Chicken Pizza', 'BBQ sauce, chicken, red onion',        220.00, TRUE),
(2, 2,  'California Roll',   'Crab, avocado, cucumber',              200.00, TRUE);


INSERT INTO couriers (name, phone, vehicle_type, is_active) VALUES
('Ivan Petrenko',   '+380671234501', 'scooter', TRUE),
('Mykola Bondar',   '+380671234502', 'bike',    TRUE),
('Olena Tkach',     '+380671234503', 'car',     TRUE),
('Serhii Moroz',    '+380671234504', 'scooter', TRUE),
('Daryna Koval',    '+380671234505', 'foot',    TRUE),
('Andriy Shevchuk', '+380671234506', 'bike',    TRUE),
('Yulia Savchenko', '+380671234507', 'car',     TRUE),
('Dmytro Lysenko',  '+380671234508', 'scooter', TRUE),
('Natalia Hrytsak', '+380671234509', 'bike',    FALSE),
('Viktor Pavlenko', '+380671234510', 'car',     TRUE);


INSERT INTO orders (customer_id, restaurant_id, status, total_amount, created_at) VALUES
(1,  1, 'delivered',   390.00, NOW() - INTERVAL '10 days'),
(2,  2, 'delivered',   460.00, NOW() - INTERVAL '9 days'),
(3,  3, 'delivered',   330.00, NOW() - INTERVAL '8 days'),
(4,  4, 'delivered',   170.00, NOW() - INTERVAL '7 days'),
(5,  5, 'delivered',   260.00, NOW() - INTERVAL '6 days'),
(6,  6, 'delivered',   145.00, NOW() - INTERVAL '5 days'),
(7,  7, 'delivered',   450.00, NOW() - INTERVAL '4 days'),
(8,  8, 'in_delivery', 165.00, NOW() - INTERVAL '1 hour'),
(9,  9, 'preparing',   310.00, NOW() - INTERVAL '30 minutes'),
(10, 10,'pending',      95.00, NOW() - INTERVAL '5 minutes');
INSERT INTO orders (customer_id, restaurant_id, status, total_amount, created_at) VALUES
(1, 1, 'delivered', 350.00, NOW() - INTERVAL '2 months'),
(2, 2, 'delivered', 480.00, NOW() - INTERVAL '2 months'),
(3, 3, 'delivered', 200.00, NOW() - INTERVAL '1 month');


INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(1,  1,  1, 180.00),
(1,  2,  1, 210.00),
(2,  3,  1, 220.00),
(2,  4,  1, 240.00),
(3,  5,  1, 150.00),
(3,  6,  1, 180.00),
(4,  7,  1, 170.00),
(5,  8,  2, 130.00),
(6,  9,  1, 145.00),
(7,  10, 1, 450.00),
(8,  11, 1, 165.00),
(9,  12, 2, 155.00),
(10, 13, 1,  95.00),
(1,  14, 1, 220.00),
(2,  15, 1, 200.00);


INSERT INTO deliveries (order_id, courier_id, assigned_at, delivered_at, status) VALUES
(1, 1, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days' + INTERVAL '40 minutes', 'delivered'),
(2, 2, NOW() - INTERVAL '9 days',  NOW() - INTERVAL '9 days'  + INTERVAL '35 minutes', 'delivered'),
(3, 3, NOW() - INTERVAL '8 days',  NOW() - INTERVAL '8 days'  + INTERVAL '50 minutes', 'delivered'),
(4, 4, NOW() - INTERVAL '7 days',  NOW() - INTERVAL '7 days'  + INTERVAL '30 minutes', 'delivered'),
(5, 5, NOW() - INTERVAL '6 days',  NOW() - INTERVAL '6 days'  + INTERVAL '45 minutes', 'delivered'),
(6, 6, NOW() - INTERVAL '5 days',  NOW() - INTERVAL '5 days'  + INTERVAL '25 minutes', 'delivered'),
(7, 7, NOW() - INTERVAL '4 days',  NOW() - INTERVAL '4 days'  + INTERVAL '55 minutes', 'delivered'),
(8, 8, NOW() - INTERVAL '1 hour',  NULL,                                                'picked_up'),
(9, 10,NOW() - INTERVAL '25 minutes', NULL,                                               'assigned');
