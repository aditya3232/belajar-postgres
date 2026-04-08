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
