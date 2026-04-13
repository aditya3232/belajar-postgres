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
