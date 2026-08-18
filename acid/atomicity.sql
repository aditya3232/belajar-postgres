-- atomicity.sql
-- Atomicity di PostgreSQL diimplementasikan menggunakan transaction.
-- Semua operasi dalam transaction dianggap sebagai satu kesatuan:
-- jika semuanya berhasil -> COMMIT
-- jika terjadi masalah -> ROLLBACK

BEGIN;

-- Kurangi saldo Adit sebesar 100.000
UPDATE accounts
SET balance = balance - 100000
WHERE id = 'ACC-001';

-- Tambah saldo Budi sebesar 100.000
UPDATE accounts
SET balance = balance + 100000
WHERE id = 'ACC-002';

-- Simpan semua perubahan secara permanen.
COMMIT;


-- ============================================================
-- Contoh jika terjadi error:
-- ============================================================

-- BEGIN;

-- UPDATE accounts
-- SET balance = balance - 100000
-- WHERE id = 'ACC-001';

-- Jika operasi berikut gagal, transaction dapat di-ROLLBACK.
-- UPDATE accounts
-- SET balance_salah = balance + 100000
-- WHERE id = 'ACC-002';

-- Batalkan seluruh perubahan dalam transaction.
-- Perubahan pada saldo Adit juga ikut dibatalkan.
-- ROLLBACK;
