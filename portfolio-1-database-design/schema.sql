CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(15)  NOT NULL UNIQUE,
    kyc_status   VARCHAR(10)  NOT NULL DEFAULT 'PENDING'
                 CHECK (kyc_status IN ('PENDING','VERIFIED','REJECTED')),
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wallets (
    wallet_id    SERIAL PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    currency     CHAR(3) NOT NULL DEFAULT 'NGN',
    balance      NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    status       VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                 CHECK (status IN ('ACTIVE','FROZEN','CLOSED')),
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE merchant_categories (
    category_id    SERIAL PRIMARY KEY,
    category_name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE merchants (
    merchant_id    SERIAL PRIMARY KEY,
    business_name  VARCHAR(100) NOT NULL,
    category_id    INT NOT NULL REFERENCES merchant_categories(category_id),
    city           VARCHAR(50) NOT NULL
);

CREATE TABLE transactions (
    transaction_id    BIGSERIAL PRIMARY KEY,
    reference         VARCHAR(40) NOT NULL UNIQUE,
    wallet_id         INT NOT NULL REFERENCES wallets(wallet_id),
    receiver_wallet_id INT REFERENCES wallets(wallet_id),
    merchant_id       INT REFERENCES merchants(merchant_id),
    transaction_type  VARCHAR(10) NOT NULL
                      CHECK (transaction_type IN ('FUNDING','TRANSFER','PAYMENT')),
    amount            NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    status            VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                      CHECK (status IN ('PENDING','SUCCESS','FAILED')),
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (wallet_id <> receiver_wallet_id),
    CHECK (
        (transaction_type = 'TRANSFER' AND receiver_wallet_id IS NOT NULL AND merchant_id IS NULL) OR
        (transaction_type = 'PAYMENT'  AND merchant_id IS NOT NULL AND receiver_wallet_id IS NULL) OR
        (transaction_type = 'FUNDING'  AND merchant_id IS NULL AND receiver_wallet_id IS NULL)
    )
);
