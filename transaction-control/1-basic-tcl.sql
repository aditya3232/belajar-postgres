-- default transaction control behavior
/*
Ini menjelaskan konsep ACID dalam transaksi database.
Prinsip dasar supaya data tetap aman dan konsisten.

1. Atomicity (all or nothing)
   - Transaksi harus berhasil semua, atau gagal semua
   - Jika ada beberapa query dalam satu transaksi:
        - semua sukses  -> COMMIT
        - salah satu gagal -> ROLLBACK (dibatalkan semua)

2. Consistency
   - Data harus tetap valid sesuai aturan database
   - Mengikuti constraint (PK, FK, CHECK, dll)
   - Contoh:
        - tidak boleh saldo minus (jika ada constraint)
        - tidak boleh insert data yang melanggar relasi
   - Jadi sebelum dan sesudah transaksi, data tetap dalam kondisi valid

3. Isolation
   - Transaksi tidak saling mengganggu satu sama lain
   - Walaupun berjalan bersamaan, hasilnya seolah-olah dieksekusi satu per satu
   - Contoh:
        - dua user update data yang sama:
            salah satu akan mengunci row, yang lain menunggu
        - dua transaksi membaca/mengubah data yang sama tidak menyebabkan race condition
   - Di PostgreSQL:
        - menggunakan MVCC (Multi-Version Concurrency Control)
        - locking tetap ada, tapi bukan mekanisme utama
        - menggunakan snapshot data untuk konsistensi baca
   - Isolation diatur dengan level:
        - Read Committed (default)
        - Repeatable Read
        - Serializable

4. Durability
   - Data yang sudah di-COMMIT akan tetap tersimpan walaupun terjadi crash
   - PostgreSQL menggunakan WAL (Write-Ahead Logging)
   - Setelah commit, data bisa dipulihkan saat database hidup kembali
*/

-- default behavior
-- sql dibawah ini auto commit
insert into regions(region_id, region_name)
values (10, 'Other');

-- manual behavior by query (memulai transaksi manual)
-- setelah ini, semua query masuk dalam transaksi
-- perubahan belum permanen sebelum commit
begin;

insert into regions(region_id, region_name)
values (11, 'Other 11');

select * from regions where region_id = 11;

--*********************************************************************************************************

-- commit
-- digunakan untuk menyimpan perubahan
-- yang dilakukan oleh perintah data manipulation
-- secara permanan ke database

BEGIN; -- mulai transaksi

INSERT INTO regions (region_id, region_name)
VALUES (7, 'Other 2');

SELECT *
FROM regions
WHERE region_id = 7;

COMMIT; -- menyimpan perubahan secara permanen

--*********************************************************************************************************

-- contoh commit (tidak akan berhasil dijalankan)

-- query pertama berhasil (sementara, belum permanen)
-- query kedua error (duplicate PK)

-- postgres akan:
-- 1. menandai transaksi sebagai FAILED (aborted) kalau select * from regions ada error -> ERROR: current transaction is aborted
-- 2. semua perubahan dalam transaksi dianggap tidak valid
-- 3. COMMIT tidak bisa dilakukan

-- untuk mengembalikan kondisi, harus ROLLBACK, (ganti COMMIT ke ROLLBACK)
-- walaupun di psql ada behavior [COMMIT pada transaksi yang aborted = ROLLBACK]
-- tapi biasakan kalo ada error kita rollback

-- hasil akhirnya:
-- data region_id = 9 tidak jadi masuk (atomic: all or nothing)

BEGIN;

INSERT INTO regions (region_id, region_name)
VALUES (9, 'Test A');

-- ini akan gagal (duplicate PK)
INSERT INTO regions (region_id, region_name)
VALUES (9, 'Test B');

-- COMMIT; tidak akan bisa dijalankan
-- ERROR sudah terjadi sebelumnya

ROLLBACK; -- WAJIB untuk mengakhiri transaksi yang gagal

--*********************************************************************************************************

-- rollback
-- digunakan untuk membatalkan transaksi yang sedang aktif
-- untuk mengembalikan ke last state commit pada database
-- misal eksekusi 3 query, jika dirollback, maka semua kembali kesemula (commit terakhir)

BEGIN;

UPDATE regions
SET region_name = 'Other 3'
WHERE region_id = 7;

SELECT *
FROM regions
WHERE region_id = 7;

ROLLBACK; -- membatalkan perubahan, jadi data kembali seperti semula

--*********************************************************************************************************

-- savepoint
-- adalah titik checkpoint di dalam transaksi
-- jadi bisa rollback ke titik tertentu tanpa membatalkan semuanya

BEGIN;

INSERT INTO regions VALUES (20, 'A');

-- cek setelah insert pertama
SELECT * FROM regions WHERE region_id IN (20, 21);

SAVEPOINT sp1;

INSERT INTO regions VALUES (21, 'B');

-- cek setelah insert kedua
SELECT * FROM regions WHERE region_id IN (20, 21);

SAVEPOINT sp2;

-- ini akan error
INSERT INTO regions VALUES (21, 'C');

-- transaksi sekarang aborted → SELECT akan error
-- SELECT * FROM regions WHERE region_id IN (20, 21);

-- rollback ke sebelum error
ROLLBACK TO sp2;

-- cek setelah rollback
SELECT * FROM regions WHERE region_id IN (20, 21);

COMMIT;
