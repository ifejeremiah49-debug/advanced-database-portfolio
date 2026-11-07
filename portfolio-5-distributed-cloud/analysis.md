# Portfolio 5: Analysis

**Student:** Ifeoluwa Oluwalana | **Matric No:** 2026/A/MIT/0815 | **Student ID:** 301895229

## What I built

I split NaijaPay transaction data into four hash partitions on wallet_id (txn_shard_0 to txn_shard_3) and loaded 100,000 rows. PostgreSQL partitioning on one machine follows the same routing logic as sharding across several nodes, so it shows how a shard key behaves.

## Results

1. Distribution: the rows spread almost evenly, with 24,326, 25,650, 25,454 and 24,570 rows in the four shards. Hashing the wallet_id gave a balanced split.
2. Query with the shard key (wallet_id = 42): the plan searched only txn_shard_2, using its primary key index. The other three shards were not touched. This is partition pruning, the single machine version of a router sending a query to one shard.
3. Query without the shard key (reference = 'SH500'): the plan searched all four shards with a sequential scan on each. Without the shard key the database cannot know where the row is, so the work is repeated on every shard.

## Replication versus sharding

Replication keeps copies of the same data on several nodes to improve availability and read capacity. Sharding divides the data across nodes to improve write capacity and storage. Large systems normally use both: each shard is replicated.

## Choosing the shard key

wallet_id suits NaijaPay because it spreads writes evenly and keeps one wallet's history together, so the most common query (a wallet's transactions) touches one shard. Sharding by created_at would send all new writes to the newest shard and create a hotspot. Sharding by merchant would be uneven, because a few merchants handle most payments.

## Costs and limitations

The primary key had to include wallet_id, because uniqueness is enforced per partition. A globally unique reference across shards cannot be enforced cheaply, so it needs the shard key, a lookup table, or reference values that include the shard. A transfer between wallets on different shards would need a distributed transaction or a saga, which is slower and more complex than the single node transaction in Portfolio 3. Queries without the shard key are multiplied across all shards.

## Consistency and availability

Sharding alone does not give availability, because losing a shard loses its data unless it is replicated. A replicated design must choose between consistency and availability during a failure. Synchronous replication protects the latest commits but can block writes when a replica is down. Asynchronous replication stays available and fast, but a failover can lose the most recent commits. For money movement I would prefer synchronous replication to a second node, and asynchronous read replicas for reports.

## Recommendation for NaijaPay

Start with one PostgreSQL primary and replicas. Shard by wallet_id only when a single node can no longer handle the write volume, because cross shard transfers add real cost.

## Limits of my demo

It ran on one machine, so there was no network between shards and no real failover. I did not demonstrate replication, failover or a cloud deployment.

## My own observation
(write 2 to 3 sentences here in your own words)
