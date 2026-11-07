-- Q1: equality on wallet_id plus range and ordering on created_at
CREATE INDEX idx_txn_wallet_created ON transactions (wallet_id, created_at DESC);

-- Q2: partial index covering only successful payments, with amount included
CREATE INDEX idx_txn_success_payments
  ON transactions (merchant_id) INCLUDE (amount)
  WHERE transaction_type = 'PAYMENT' AND status = 'SUCCESS';

-- Q3: narrow date range on transfers
CREATE INDEX idx_txn_transfer_created
  ON transactions (created_at) INCLUDE (wallet_id, amount)
  WHERE transaction_type = 'TRANSFER';

-- Q4: expression index, because LOWER(email) cannot use the plain email index
CREATE INDEX idx_customers_lower_email ON customers (LOWER(email));

ANALYZE;
