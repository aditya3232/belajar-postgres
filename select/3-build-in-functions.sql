-- build-in string function
SELECT
    substring('Dimas Maryanto' FROM 1 FOR 3) AS "substring from", -- ambil 3 karakter dari posisi 1
    substr('Dimas Maryanto', 1, 5) AS "substr", -- ambil 5 karakter dari posisi 1
    lower('Ini Adalah Text BESAR dan Kecil') AS "lower", -- ubah ke huruf kecil semua
    upper('Ini Adalah Text BESAR dan Kecil') AS "upper", -- ubah ke huruf besar semua
    initcap('Ini Adalah Text BESAR dan Kecil') AS "initcap", -- kapital huruf awal tiap kata
    trim(both ' ' FROM ' ini text ada spacenya ') AS "trim both", -- hapus spasi depan & belakang
    trim(trailing ' ' FROM ' ini text ada spacenya ') AS "trim trailing", -- hapus spasi belakang saja
    reverse('dimas') AS "reverse", -- membalik string
    length('dimas maryanto') AS "length", -- hitung jumlah karakter
    concat('dimasm93', ' : ', 'Dimas Maryanto') AS "concat", -- gabungkan string
    ascii('D') AS "ascii"; -- ambil kode ASCII karakter

-- build-in math function
SELECT
    abs(-10) "absolut",              -- nilai absolut (hilangkan tanda negatif)
    div(10, 3) "division",           -- pembagian integer (hasil tanpa desimal)
    mod(5, 2) "mod",                 -- sisa hasil bagi (modulus)
    power(2, 3) "power",             -- pangkat (2^3 = 8)
    round(5.451234, 2) "round scale2", -- pembulatan 2 angka di belakang koma
    round(5.43) "round",             -- pembulatan ke bilangan bulat terdekat
    round(5.6) "roundup",            -- pembulatan ke atas (karena > .5)
    floor(5.45234) "floor",          -- dibulatkan ke bawah
    floor(5.6) "floor2";             -- tetap ke bawah (jadi 5)

-- build-in date/time function
SELECT
    current_date tgl_sekarang,                    -- tanggal hari ini (tanpa waktu)
    now() datetime_sekarang_func,                 -- tanggal + waktu saat ini
    current_timestamp AS datetime_tz,             -- timestamp sekarang (dengan timezone)
    age(timestamp '1996-07-28') AS years_old,     -- selisih waktu dari tanggal tsb ke sekarang {"years":29,"months":8,"days":11} hasil json
    age(current_timestamp, '1996-07-28') AS years_old_2, -- hasil json
    extract(year FROM current_timestamp) get_current_year,  -- ambil tahun saat ini
    extract(month FROM current_date) get_current_month;     -- ambil bulan saat ini

-- build-in null function
SELECT
    COALESCE(null, 'data1', 'data2') return_data1, -- ambil nilai pertama yang tidak NULL (hasil: 'data1')
    COALESCE(null, null, 'data2') return_data2,   -- skip NULL sampai ketemu nilai (hasil: 'data2')
    COALESCE(null, null, null) return_null,       -- semua NULL → hasil NULL
    NULLIF(null, 'data1') return_null1,           -- bandingkan, jika sama → NULL (null vs 'data1' → tetap NULL)
    NULLIF('data1', 'data1') return_null2,        -- sama → hasil NULL
    NULLIF('data1', 'data2') return_data1;        -- tidak sama → kembalikan nilai pertama

SELECT
    product_name,
    COALESCE(discount, 0) AS discount -- kalau NULL jadi 0
FROM products;

SELECT
    employee_id,
    commission_pct,
    coalesce(commission_pct, 0),
    salary * coalesce(commission_pct, 0)SELECT
        employee_id,
FROM employees

-- build-in data type formatting function
SELECT
    to_char(current_date, 'DD/MON/YYYY') date_indonesia, -- format tanggal (contoh: 08/APR/2026)
    to_char(current_timestamp, 'DD/MM/YYYY HH24:MI') datetime_indonesia, -- format tanggal + jam (24 jam)
    to_char(1000000, 'Rp 999,999,999.00') sejuta_rupiah, -- format angka jadi rupiah dengan padding & desimal
    to_date('02/03/22', 'DD/MM/YY') format_ke_date, -- ubah string ke tipe DATE
    to_number('10,132,456.53', '999,999,999') format_ke_number, -- ubah string ke angka
    to_char(1000000, 'FM999,999,999.00'),
    to_char(1996, 'FM RN') romawi

SELECT
    employee_id,
    to_char(coalesce(commission_pct, 0) * 100, 'FM999%') as komisi
FROM employees
