# Lost Update Demonstration

Two sessions (Session A and Session B) each open their own transaction on wallet 1, which starts with a balance of 50000.00. Session A wants to spend 10000 and Session B wants to spend 5000.

| Step | Session A (spend 10000) | Session B (spend 5000) |
|---|---|---|
| 1 | BEGIN; | |
| 2 | SELECT balance FROM wallets WHERE wallet_id = 1; (returns 50000) | |
| 3 | | BEGIN; |
| 4 | | SELECT balance FROM wallets WHERE wallet_id = 1; (returns 50000) |
| 5 | UPDATE wallets SET balance = 40000 WHERE wallet_id = 1; | |
| 6 | COMMIT; | |
| 7 | | UPDATE wallets SET balance = 45000 WHERE wallet_id = 1; |
| 8 | | COMMIT; |

## Result

The final balance was 45000.00. A total of 15000 was spent, so the correct balance is 35000.00. Session A's update was lost, because Session B calculated its new value from the old balance it had read earlier and then overwrote Session A's change.

## Why it happened

The application read the balance, calculated the new value itself, and wrote it back. Between the read and the write, another transaction changed the row, and the second write did not take that change into account.

## How it can be prevented

1. Pessimistic locking: SELECT balance FROM wallets WHERE wallet_id = 1 FOR UPDATE; makes the second session wait until the first one commits, so it reads the new balance.
2. A stricter isolation level such as REPEATABLE READ, where PostgreSQL rejects the second write with a serialisation error and the application retries the transaction.
3. Writing the change as one statement, such as SET balance = balance - 5000, so the database applies it to the latest committed value.
