# Normalisation Explanation

The design began as one flat table holding, on every row, the customer name, email, phone, wallet number, balance, merchant name, merchant category, transaction reference, amount and date. This caused repetition. A customer's email was stored once per transaction, so a change had to be made in many rows (update anomaly). A merchant could not be recorded until a transaction involved it (insertion anomaly). Deleting a customer's last transaction would erase the only record of their wallet (deletion anomaly).

First normal form (1NF): every value is atomic and there are no repeating groups. Each wallet is its own row, and each value sits in its own column.

Second normal form (2NF): every non-key attribute depends on the whole key. Attributes such as email depended only on the customer, and balance only on the wallet, so they were moved into the customers and wallets tables, each with a single-column primary key.

Third normal form (3NF): no non-key attribute depends on another non-key attribute. Category name depended on the category and not on the merchant, so it moved to merchant_categories. This prevents inconsistent spellings of a category.

Keys and constraints:
- Primary keys identify every row.
- Foreign keys enforce the chain customer to wallet to transaction. ON DELETE RESTRICT stops a customer with wallets from being deleted.
- UNIQUE on email, phone and reference prevents duplicates. The reference also protects against a payment being processed twice.
- CHECK constraints reject negative balances, zero or negative amounts, and invalid status values.
- A table-level CHECK makes sure each transaction type has the right combination of receiver wallet and merchant.
- NOT NULL and default values protect completeness.

The final design is in third normal form.
