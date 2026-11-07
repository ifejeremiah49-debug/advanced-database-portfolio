-- A. Successful transfer of 5000 from wallet 1 to wallet 2: COMMIT
BEGIN;
UPDATE wallets SET balance = balance - 5000 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 5000 WHERE wallet_id = 2;
INSERT INTO transactions (reference, wallet_id, receiver_wallet_id, transaction_type, amount, status)
VALUES ('DEMO-001', 1, 2, 'TRANSFER', 5000, 'SUCCESS');
COMMIT;

SELECT wallet_id, balance FROM wallets WHERE wallet_id IN (1,2) ORDER BY wallet_id;
-- Result: wallet 1 = 45000.00, wallet 2 = 17000.00

-- B. Failed transfer: wallet 2 cannot send 70000, so the CHECK constraint fires
BEGIN;
UPDATE wallets SET balance = balance - 70000 WHERE wallet_id = 2;
-- ERROR: new row for relation "wallets" violates check constraint "wallets_balance_check"
ROLLBACK;
-- After an error, PostgreSQL marks the transaction as aborted:
-- "current transaction is aborted, commands ignored until end of transaction block"
-- ROLLBACK is required to clear it.

SELECT wallet_id, balance FROM wallets WHERE wallet_id = 2;
-- Result: still 17000.00, so the failed transfer changed nothing

-- C. Deliberate rollback of a valid change (shows atomicity)
BEGIN;
UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 1;
SELECT balance FROM wallets WHERE wallet_id = 1;
ROLLBACK;
SELECT balance FROM wallets WHERE wallet_id = 1;
-- Result: 45000.00, the 1000 subtraction was undone
