# Portfolio 1: Database Design and Modelling

**Student:** Ifeoluwa Oluwalana | **Matric No:** 2026/A/MIT/0815 | **Student ID:** 301895229

## Files
- case-study.md: description of the NaijaPay case study
- er-diagram.md: entity relationship diagram
- schema.sql: tables, keys and constraints
- sample-data.sql: test data
- normalisation.md: explanation of 1NF, 2NF and 3NF
- screenshots/: evidence of execution

## How to run
1. Create a database: CREATE DATABASE naijapay;
2. Connect to it, then run schema.sql, then sample-data.sql.
3. Test a constraint: INSERT INTO wallets (customer_id, balance) VALUES (1, -500); this should fail.

## Design choices and challenges
For this project, I chose to normalise the database to Third Normal Form (3NF) to remove data redundancy and keep customer profiles clearly separate from their financial wallets. To protect data integrity, I used foreign keys to enforce the relationship between customers and wallets, and a CHECK constraint to stop wallets from holding negative balances. A key challenge was handling money accurately and avoiding floating-point errors, which I solved by using the NUMERIC data type for all financial values. Finally, writing and testing the SQL scripts, including confirming that an attempt to insert a negative balance was rejected, taught me a lot about data integrity and error handling.
