INSERT INTO customers (first_name, last_name, email, phone, kyc_status) VALUES
('Ada','Okafor','ifeoluwa@gmail.com','08031112222','VERIFIED'),
('Tunde','Bakare','ifeoluwa@gmail.com','08054443333','VERIFIED'),
('Ngozi','Eze','ifeoluwa@gmail.com','07066667777','PENDING');

INSERT INTO wallets (customer_id, balance) VALUES (1, 50000.00), (2, 12000.00), (3, 0.00);

INSERT INTO merchant_categories (category_name) VALUES ('Groceries'), ('Transport'), ('Utilities');

INSERT INTO merchants (business_name, category_id, city) VALUES
('Shoprite Port Harcourt', 1, 'Port Harcourt'),
('Rivers Bus Services', 2, 'Port Harcourt');

INSERT INTO transactions (reference, wallet_id, receiver_wallet_id, merchant_id, transaction_type, amount, status) VALUES
('NP0001', 1, NULL, NULL, 'FUNDING',  50000.00, 'SUCCESS'),
('NP0002', 1, 2,    NULL, 'TRANSFER',  5000.00, 'SUCCESS'),
('NP0003', 2, NULL, 1,    'PAYMENT',   3500.00, 'SUCCESS');
