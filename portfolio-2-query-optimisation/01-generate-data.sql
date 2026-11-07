INSERT INTO customers (first_name, last_name, email, phone, kyc_status)
SELECT 'First' || g, 'Last' || g, 'user' || g || '@example.com',
       '080' || lpad(g::text, 8, '0'),
       (ARRAY['PENDING','VERIFIED','REJECTED'])[1 + floor(random()*3)::int]
FROM generate_series(1, 20000) g;

INSERT INTO wallets (customer_id, balance)
SELECT customer_id, round((random()*200000)::numeric, 2)
FROM customers WHERE customer_id > 3;

INSERT INTO merchants (business_name, category_id, city)
SELECT 'Merchant ' || g, 1 + floor(random()*3)::int,
       (ARRAY['Port Harcourt','Lagos','Abuja','Kano','Enugu'])[1 + floor(random()*5)::int]
FROM generate_series(1, 200) g;

WITH cnt AS (
    SELECT (SELECT count(*) FROM wallets)::int AS wc,
           (SELECT count(*) FROM merchants)::int AS mc
),
wn AS (
    SELECT row_number() OVER (ORDER BY wallet_id)::int AS rn, wallet_id FROM wallets
),
mn AS (
    SELECT row_number() OVER (ORDER BY merchant_id)::int AS rn, merchant_id FROM merchants
),
gen AS MATERIALIZED (
    SELECT g,
           cnt.wc,
           1 + floor(random()*cnt.wc)::int AS wi,
           1 + floor(random()*cnt.mc)::int AS mi,
           (ARRAY['FUNDING','TRANSFER','PAYMENT'])[1 + floor(random()*3)::int] AS t,
           round((100 + random()*50000)::numeric, 2) AS amount,
           (ARRAY['SUCCESS','SUCCESS','SUCCESS','FAILED','PENDING'])[1 + floor(random()*5)::int] AS status,
           TIMESTAMP '2025-01-01' + random() * INTERVAL '600 days' AS ts
    FROM generate_series(1, 500000) g, cnt
)
INSERT INTO transactions
    (reference, wallet_id, receiver_wallet_id, merchant_id, transaction_type, amount, status, created_at)
SELECT 'GEN' || gen.g,
       w1.wallet_id,
       CASE WHEN gen.t = 'TRANSFER' THEN w2.wallet_id END,
       CASE WHEN gen.t = 'PAYMENT'  THEN m.merchant_id END,
       gen.t, gen.amount, gen.status, gen.ts
FROM gen
JOIN wn w1 ON w1.rn = gen.wi
JOIN wn w2 ON w2.rn = (gen.wi % gen.wc) + 1
JOIN mn m  ON m.rn = gen.mi;

ANALYZE;
