# Portfolio 3: Analysis

**Student:** Ifeoluwa Oluwalana | **Matric No:** 2026/A/MIT/0815 | **Student ID:** 301895229

## ACID in the NaijaPay examples

Atomicity: a transfer of 5000 from wallet 1 to wallet 2 is one unit made of two balance updates and one transaction record. When I tried to take 70000 from wallet 2, the CHECK constraint rejected the update and wallet 2 stayed at 17000.00, so nothing was left half done. A deliberate ROLLBACK of a 1000 debit also returned wallet 1 to 45000.00.

Consistency: the CHECK constraint on balance stops wallets going negative, and the total money across the two wallets stayed the same after the committed transfer.

Isolation: two sessions read the same balance of 50000 and each wrote back a value calculated from it. The final balance was 45000.00 instead of 35000.00, so one update was lost. This shows what happens when concurrent transactions are not properly isolated.

Durability: once COMMIT returned, the new balances were stored. PostgreSQL writes to its write ahead log before confirming a commit, so committed data survives a crash.

## The aborted transaction state

After the failed update, PostgreSQL refused every later command with the message "current transaction is aborted, commands ignored until end of transaction block". A ROLLBACK was needed to clear it. This protects consistency, because the database will not let a session continue on top of a failed step.

## Preventing the lost update

The lost update happened because the application read the balance, calculated the new value, and wrote it back. Locking the row with SELECT FOR UPDATE makes the second session wait and then read the new balance. A stricter isolation level such as REPEATABLE READ rejects the second write with a serialisation error, and the application must retry. Writing the change as a single statement, SET balance = balance - 5000, also avoids it, because the database applies it to the latest committed value.

## Recommendation for NaijaPay

I would use the default READ COMMITTED level together with explicit row locks for every balance change, and keep transactions short. For sensitive reporting or reconciliation I would use REPEATABLE READ or SERIALIZABLE with retry logic. Wallets should always be locked in a fixed order, for example by wallet_id, to avoid deadlocks when two customers pay each other at the same time.

## My own observation
What surprised me most was how simply rewriting my SQL into a single statement (SET balance = balance - 5000) completely eliminated the lost update issue without needing complex application-level locking. Conversely, the strictness of the aborted transaction state was a harsh but excellent lesson, showing me that the database is designed to halt entirely rather than ever allow a half-completed transfer.
