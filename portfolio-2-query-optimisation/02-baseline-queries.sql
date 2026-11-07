-- Q1: transaction history of one wallet, newest first
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM transactions
WHERE wallet_id = 1234 AND created_at >= '2025-06-01'
ORDER BY created_at DESC;

-- Q2: total successful payment value per merchant category
EXPLAIN (ANALYZE, BUFFERS)
SELECT mc.category_name, count(*) AS payments, sum(t.amount) AS total_value
FROM transactions t
JOIN merchants m ON m.merchant_id = t.merchant_id
JOIN merchant_categories mc ON mc.category_id = m.category_id
WHERE t.transaction_type = 'PAYMENT' AND t.status = 'SUCCESS'
GROUP BY mc.category_name
ORDER BY total_value DESC;

-- Q3: top 10 senders by transfer value since August 2026
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.customer_id, c.first_name, c.last_name, sum(t.amount) AS sent
FROM transactions t
JOIN wallets w   ON w.wallet_id = t.wallet_id
JOIN customers c ON c.customer_id = w.customer_id
WHERE t.transaction_type = 'TRANSFER' AND t.created_at >= '2026-08-01'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY sent DESC
LIMIT 10;

-- Q4: customer lookup by case insensitive email
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM customers WHERE LOWER(email) = 'user15000@example.com';
