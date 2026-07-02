-- TRUNCATE
-- Perintah untuk menghapus semua data dalam tabel tanpa WHERE clause (berbeda dengan DELETE).
-- Lebih cepat karena tidak melakukan row-by-row scan (langsung deallocasi data).
-- Membutuhkan akses eksklusif (ACCESS EXCLUSIVE LOCK), sehingga akan memblok operasi lain.
-- Opsi RESTART IDENTITY akan mereset sequence (misalnya primary key auto increment).
-- Tidak bisa dijalankan jika tabel memiliki foreign key, kecuali menggunakan CASCADE.
-- CASCADE akan menghapus data pada tabel lain yang memiliki dependensi (FK).

-- ==================================================================================================

-- CHECK 1: Tabel tanpa dependensi
-- Tidak memiliki foreign key dan tidak menggunakan identity
SELECT * FROM job_history;

-- Bisa langsung di-truncate
TRUNCATE TABLE job_history;

-- ==================================================================================================

-- CHECK 2: Tabel dengan dependensi
-- Memiliki relasi ke tabel lain (foreign key)
SELECT * FROM departments;

-- Memiliki sequence (identity)
SELECT nextval('departments_department_id_seq');

-- Akan error jika tanpa CASCADE:
-- ERROR: cannot truncate a table referenced in a foreign key constraint
TRUNCATE TABLE departments;

-- Solusi: gunakan CASCADE
-- Akan menghapus data pada tabel yang berelasi juga
TRUNCATE TABLE departments RESTART IDENTITY CASCADE;

-- Bukti: tabel employees ikut kosong karena dependensi
SELECT * FROM employees;

-- ==================================================================================================

-- vacuum
/*
vacuum berfungsi untuk:
- menghapus dead tuples (data lama hasil update/delete)
- membebaskan ruang agar dipakai ulang
- mencegah tabel bloat (membengkaknya ukuran tabel)
- menjaga performa query tetap optimal
- Di PostgreSQL, UPDATE/DELETE tidak langsung menghapus data lama, tapi ditandai sebagai “mati” → di sinilah VACUUM berperan.
*/

/*
kapan perlu vacuum:
- setelah banyak update/delete
- performa query mulai menurun
- tabel terasa membengkak
*/

-- Membersihkan data sampah di tabel employees, sambil menampilkan prosesnya, dan sekaligus mengupdate statistik query planner.
vacuum (verbose, analyze) employees

-- cek dead tuples -> adalah data lama yang sudah tidak berlaku lagi, tapi masih tersimpan secara fisik di tabel.
-- n_dead_tup > 10.000 mulai vacuum
-- dead_percentage > 20% mulai vacuum
SELECT
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    ROUND(n_dead_tup * 100.0 / (n_live_tup + 1), 2) AS dead_percentage
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- cek kapan terakhir di vacuum
SELECT
    relname,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables;

-- cek ukuran tabel (bloat indikasi kasar)
SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
