-- isolation.sql
-- Isolation
--
-- Isolation mengatur bagaimana beberapa transaction yang berjalan
-- secara bersamaan saling melihat dan memengaruhi data.
--
-- Salah satu masalah yang ingin kita hindari adalah race condition
-- ketika beberapa transaction mengakses row yang sama secara bersamaan.
--
-- Latihan ini menggunakan dua PostgreSQL session:
--   Session A
--   Session B
--
-- Buka dua terminal psql dan jalankan bagian sesuai session.


-- ============================================================
-- PERSIAPAN DATA
-- ============================================================

-- Jalankan sekali sebelum latihan.

UPDATE accounts
SET balance = 100000
WHERE id = 'ACC-001';


-- ============================================================
-- LATIHAN 1: CONCURRENT ACCESS TANPA FOR UPDATE
-- ============================================================
--
-- Tujuan:
-- Melihat bagaimana dua transaction dapat membaca data yang sama
-- sebelum salah satunya melakukan perubahan.
--
-- SESSION A
-- ============================================================

BEGIN;

-- A membaca saldo.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- Hasil:
-- balance = 100000
--
-- Jangan COMMIT dulu.


-- SESSION B
-- ============================================================
--
-- Jalankan di terminal/session PostgreSQL yang berbeda.

BEGIN;

-- B juga membaca saldo.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- B juga akan melihat:
-- balance = 100000
--
-- Keduanya sekarang mengetahui saldo yang sama.
--
-- Jangan COMMIT dulu.


-- SESSION A
-- ============================================================

-- A mengurangi saldo sebesar 80000.
UPDATE accounts
SET balance = balance - 80000
WHERE id = 'ACC-001';

COMMIT;


-- SESSION B
-- ============================================================

-- B mencoba mengurangi saldo sebesar 80000.
--
-- Karena row sudah diubah oleh Session A, PostgreSQL akan
-- menangani concurrent UPDATE menggunakan row-level locking
-- internal dan MVCC.
UPDATE accounts
SET balance = balance - 80000
WHERE id = 'ACC-001';

COMMIT;

-- Periksa hasil akhirnya.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';


-- ============================================================
-- LATIHAN 2: MENCEGAH RACE CONDITION DENGAN FOR UPDATE
-- ============================================================
--
-- SELECT ... FOR UPDATE digunakan untuk mengunci row yang
-- akan diproses oleh transaction.
--
-- Transaction lain yang mencoba mendapatkan lock pada row
-- yang sama akan menunggu sampai transaction pertama COMMIT
-- atau ROLLBACK.


-- SESSION A
-- ============================================================

BEGIN;

-- Ambil saldo sekaligus kunci row.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001'
FOR UPDATE;

-- Row sekarang dikunci oleh Session A.
--
-- Jangan COMMIT dulu.


-- SESSION B
-- ============================================================

BEGIN;

-- B mencoba mengunci row yang sama.
SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001'
FOR UPDATE;

-- B akan MENUNGGU karena row sedang dikunci oleh Session A.
--
-- Jangan jalankan query berikut sebelum Session A COMMIT.


-- SESSION A
-- ============================================================

UPDATE accounts
SET balance = balance - 80000
WHERE id = 'ACC-001';

COMMIT;

-- Setelah Session A COMMIT, lock dilepas.
--
-- Session B kemudian dapat melanjutkan.


-- SESSION B
-- ============================================================

-- Setelah mendapatkan lock, B membaca nilai terbaru.
-- Jika saldo tidak cukup, aplikasi seharusnya membatalkan
-- transaction.

SELECT id, name, balance
FROM accounts
WHERE id = 'ACC-001';

-- Contoh pengecekan saldo:
--
-- Jika balance >= 80000:
-- UPDATE accounts
-- SET balance = balance - 80000
-- WHERE id = 'ACC-001';
--
-- Jika balance < 80000:
-- ROLLBACK;


-- ============================================================
-- KESIMPULAN
-- ============================================================
--
-- Tanpa FOR UPDATE:
--   Beberapa transaction dapat membaca row yang sama secara
--   bersamaan. PostgreSQL tetap memiliki mekanisme concurrency
--   control, tetapi logika aplikasi yang melakukan
--   "read -> cek -> update" dapat membutuhkan locking eksplisit.
--
-- Dengan FOR UPDATE:
--   Row dikunci untuk transaction yang sedang memprosesnya.
--   Transaction lain yang meminta lock pada row tersebut
--   harus menunggu sampai transaction pertama selesai.
--
-- Pola yang umum untuk operasi saldo:
--
--   BEGIN;
--   SELECT balance FROM accounts
--   WHERE id = 'ACC-001'
--   FOR UPDATE;
--
--   -- validasi saldo
--   -- update saldo
--
--   COMMIT;
--
-- Isolation membantu mengontrol concurrent transaction,
-- sedangkan SELECT FOR UPDATE dapat digunakan ketika kita
-- membutuhkan row-level locking untuk critical section tertentu.
