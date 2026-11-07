# Portfolio 2: Results and Analysis

**Student:** Ifeoluwa Oluwalana | **Matric No:** 2026/A/MIT/0815 | **Student ID:** 301895229

## Data volume
20,003 customers, 20,003 wallets, 202 merchants and 500,003 transactions in PostgreSQL 18.

## Results

| Query | Plan before | Time before (ms) | Plan after | Time after (ms) | Improvement |
|---|---|---|---|---|---|
| Q1 wallet history | Parallel Seq Scan | 167.076 | Index Scan | 0.258 | about 650 times |
| Q2 category totals | Seq Scan | 118.742 | Index Only Scan | 62.180 | about 1.9 times |
| Q3 top senders | Seq Scan | 86.206 | Index Only Scan | 25.181 | about 3.4 times |
| Q4 email lookup | Seq Scan | 11.211 | Index Scan | 0.184 | about 61 times |

## Index sizes

| Index | Size |
|---|---|
| idx_txn_wallet_created | 15 MB |
| idx_txn_transfer_created | about 6.6 MB |
| idx_txn_success_payments | about 3.1 MB |
| idx_customers_lower_email | 808 kB |

## Analysis

Before indexing, the planner used sequential scans on the transactions and customers tables. For Q1 it read 6,095 buffers and removed 166,661 rows per worker to return only 20 rows, which took 167 ms. After a composite index on (wallet_id, created_at DESC), the same query used an Index Scan, touched 4 buffers and took 0.258 ms. The index handled both the filter and the ordering, so the Sort step disappeared.

Q2 improved least (118.7 ms to 62.2 ms). It sums about 100,000 successful payments, which is a large share of the table, so even an Index Only Scan with zero heap fetches still has to read many entries. Indexes help most when a query is selective and help little when most rows are needed.

Q4 shows why the form of a query matters. The existing unique index on email could not be used because the query wraps the column in LOWER(). An expression index on LOWER(email) fixed this, and the time fell from 11.2 ms to 0.184 ms.

The trade-off is cost. The four new indexes add about 25 MB of disk space and must be updated on every insert and update. For a payments system with heavy writes, each index slows writing, so only indexes that support frequent queries should be kept.

## My own observation
(write 2 to 3 sentences here in your own words, for example which result surprised you and why)
