-- durability.sql
-- Durability
--
-- Durability memastikan perubahan data yang sudah di-COMMIT
-- tetap tersimpan di database dan tidak hilang setelah
-- transaction selesai.
--
-- PostgreSQL menggunakan WAL (Write-Ahead Logging) untuk
-- membantu memastikan perubahan yang sudah di-COMMIT dapat
-- dipulihkan jika terjadi crash atau restart.


-- ============================================================
-- LATIHAN 1: COMMIT
-- ============================================================
--
-- Perubahan yang sudah di-COMMIT dianggap permanen.

BEGIN;

-- Tambahkan saldo ke akun Adit.
UPDATE accounts
SET balance = balance + 100000
WHERE id = 'ACC-001';

-- COMMIT membuat perubahan menjadi permanen.
COMMIT;


-- ============================================================
-- VERIFIKASI
-- ============================================================

-- Periksa saldo setelah COMMIT.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- Catat hasilnya.
--
-- Contoh:
-- Sebelum:
--   balance = 100000
--
-- Setelah COMMIT:
--   balance = 200000


-- ============================================================
-- LATIHAN 2: RECONNECT
-- ============================================================
--
-- Tutup session/connection PostgreSQL setelah COMMIT.
--
-- Contoh:
--
--   \q
--
-- Kemudian connect kembali ke database:
--
--   psql -U postgres -d nama_database
--
-- Jalankan kembali query berikut.

SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- Data yang sudah di-COMMIT tetap ada meskipun connection
-- sebelumnya sudah ditutup.
--
-- Inilah contoh sederhana dari Durability.


-- ============================================================
-- PERBANDINGAN COMMIT DAN ROLLBACK
-- ============================================================

-- Perubahan berikut TIDAK menjadi permanen karena ROLLBACK.

BEGIN;

UPDATE accounts
SET balance = balance + 50000
WHERE id = 'ACC-001';

-- Batalkan perubahan.
ROLLBACK;


-- Verifikasi.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- Penambahan 50000 tidak tersimpan karena transaction
-- diakhiri dengan ROLLBACK.


-- ============================================================
-- KESIMPULAN
-- ============================================================
--
-- COMMIT:
--   Perubahan transaction disimpan secara permanen.
--
-- ROLLBACK:
--   Perubahan transaction dibatalkan.
--
-- Durability:
--   Setelah COMMIT berhasil, perubahan tetap tersimpan
--   walaupun connection ditutup atau database mengalami
--   restart/crash dan kemudian melakukan recovery.
--
-- PostgreSQL menggunakan WAL (Write-Ahead Logging) sebagai
-- salah satu mekanisme penting untuk durability dan recovery.
