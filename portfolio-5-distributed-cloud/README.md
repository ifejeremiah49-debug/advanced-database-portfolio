# Portfolio 5: Distributed and Cloud Database Exercise

**Student:** Ifeoluwa Oluwalana | **Matric No:** 2026/A/MIT/0815 | **Student ID:** 301895229

## Case study link
NaijaPay transactions are partitioned by wallet_id to show how data would be sharded across nodes as volume grows.

## Files
- shard-demo.sql: hash partitioning demonstration
- analysis.md: written analysis of sharding, replication, availability and consistency
- screenshots/: evidence

## How to run
1. Complete Portfolio 1 first.
2. Run shard-demo.sql in pgAdmin on the naijapay database.
3. Compare the plan for a query with the shard key and a query without it.
