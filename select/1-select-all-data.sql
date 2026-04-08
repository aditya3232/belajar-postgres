SELECT *
FROM departments;

-- kalau pakai kutip 2 case sensitive
SELECT *
FROM "departments";

-- ambil spesifik kolom
SELECT
    department_id,
    department_name,
    manager_id,
    location_id
FROM departments;

-- alias kolom
SELECT
    department_id as kode_divisi,
    department_name as nama_departemen,
    manager_id as "Kode Manager"
FROM departments;

-- spescial characters / escape characters
SELECT
    E'*',
    E'()',
    E'saya\thobi\tmenggambar,\ndan\ttraveling', -- \t memberikan tab, \n memberikan baris baru
    E'[]'; -- menampilkan array

SELECT
    department_name || E'\t' || department_id as info -- ||untuk menggabungkan string
FROM departments;

-- eliminasi duplikat data
SELECT DISTINCT
    job_id
FROM employees;

/*
1. data dikelompokkan berdasarkan department_id
2. didalam tiap kelompok:
    - diurutkan berdasarkan salary DESC
3. PostgreSQL ambil:
    - baris pertama dari tiap kelompok
4. arti query ini:
    - ambil 1 karyawan dengan gaji tertinggi disetiap departemen
*/
SELECT DISTINCT ON (department_id)  -- ambil 1 baris pertama untuk setiap department_id
    department_id,                  -- kolom yang ditampilkan
    job_id,                         -- kolom yang ditampilkan
    salary                          -- kolom yang ditampilkan
FROM employees                      -- sumber data dari tabel employees
ORDER BY
    department_id,                  -- WAJIB: harus sesuai dengan DISTINCT ON (ini penentu grup). disini urutkan dulu berdasarkan department_id (ASC default), baru salary DESC
    salary DESC;                    -- dalam tiap grup, urutkan dari salary tertinggi → jadi yang dipilih adalah gaji tertinggi
