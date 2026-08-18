-- consistency.sql
-- Consistency memastikan database selalu berpindah dari satu
-- kondisi valid ke kondisi valid lainnya.
--
-- PostgreSQL dapat membantu menjaga consistency menggunakan
-- constraint, misalnya CHECK, NOT NULL, PRIMARY KEY, dan FOREIGN KEY.
--
-- Pada latihan accounts, kita dapat memastikan saldo tidak boleh negatif.

-- Tambahkan constraint agar balance tidak boleh kurang dari 0.
ALTER TABLE accounts
ADD CONSTRAINT accounts_balance_non_negative
CHECK (balance >= 0);


-- ============================================================
-- Contoh data valid
-- ============================================================

-- Saldo 1.000.000 memenuhi constraint balance >= 0.
UPDATE accounts
SET balance = 1000000
WHERE id = 'ACC-001';


-- ============================================================
-- Contoh data tidak valid
-- ============================================================

-- Query berikut akan gagal karena saldo menjadi negatif.
-- PostgreSQL akan menolak perubahan tersebut.
UPDATE accounts
SET balance = -100000
WHERE id = 'ACC-001';


-- ============================================================
-- Contoh consistency pada transfer
-- ============================================================

-- Selama saldo Adit mencukupi, kedua perubahan menjaga
-- kondisi database tetap valid.

BEGIN;

-- Kurangi saldo Adit.
UPDATE accounts
SET balance = balance - 100000
WHERE id = 'ACC-001'
  AND balance >= 100000;

-- Tambah saldo Budi.
UPDATE accounts
SET balance = balance + 100000
WHERE id = 'ACC-002';

COMMIT;


-- Intinya:
-- Sebelum transaction:
--   Adit  = 1.000.000
--   Budi  =   500.000
--
-- Setelah transfer:
--   Adit  =   900.000
--   Budi  =   600.000
--
-- Database tetap memenuhi aturan:
--   balance >= 0
