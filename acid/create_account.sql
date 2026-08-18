CREATE TABLE accounts (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance BIGINT NOT NULL
);

INSERT INTO accounts (id, name, balance)
VALUES
    ('ACC-001', 'Adit', 1000000),
    ('ACC-002', 'Budi', 500000);