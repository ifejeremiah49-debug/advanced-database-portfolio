-- Hash partitioning of NaijaPay transactions by wallet_id (4 shards)
CREATE TABLE transactions_sharded (
    transaction_id BIGSERIAL,
    reference      VARCHAR(40) NOT NULL,
    wallet_id      INT NOT NULL,
    amount         NUMERIC(14,2) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wallet_id, transaction_id)
) PARTITION BY HASH (wallet_id);

CREATE TABLE txn_shard_0 PARTITION OF transactions_sharded FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE txn_shard_1 PARTITION OF transactions_sharded FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE txn_shard_2 PARTITION OF transactions_sharded FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE txn_shard_3 PARTITION OF transactions_sharded FOR VALUES WITH (MODULUS 4, REMAINDER 3);

INSERT INTO transactions_sharded (reference, wallet_id, amount)
SELECT 'SH' || g, 1 + (random()*4999)::int, round((100 + random()*50000)::numeric, 2)
FROM generate_series(1, 100000) g;

ANALYZE transactions_sharded;

-- 1. How evenly the rows were spread
-- Result: 24326, 25650, 25454 and 24570 rows
SELECT tableoid::regclass AS shard, count(*) FROM transactions_sharded GROUP BY 1 ORDER BY 1;

-- 2. Query WITH the shard key: only one shard is searched (txn_shard_2)
EXPLAIN SELECT * FROM transactions_sharded WHERE wallet_id = 42;

-- 3. Query WITHOUT the shard key: all four shards are searched
EXPLAIN SELECT * FROM transactions_sharded WHERE reference = 'SH500';
