-- case when expression
select
    employee_id as kode_karyawan,
    commission_pct as besar_komisi,
    case
        when commission_pct is null
        then 'Tidak memiliki komisi'
    end
from employees;

-- case when else expression
select
    employee_id as kode_karyawan,
    commission_pct as besar_komisi,
    case
        when commission_pct is null then 'Tidak memiliki komisi'
        when commission_pct >= 0.2 then 'Komisi >= 20%'
        when commission_pct < 0.1 then 'Komisi < 10%'
        else 'Komisi antara 10% - 20%'
    end as kategori_komisi
from employees
limit 50;

-- nested case when expression
select
    employee_id as kode_karyawan,
    commission_pct as besar_komisi,
    case
        when commission_pct is not null
        then -- then masuk ke percabangan lain
            case
                when commission_pct <= 0.1 then 'Komisi sebesar 10%'
                when commission_pct <= 0.2 then 'Komisi sebesar 20%'
                when commission_pct <= 0.3 then 'Komisi sebesar 30%'
                else 'Komisi lebih besar dari 30%'
            end
        else 'Tidak memiliki komisi'
    end
from employees
limit 60;

-- using case when expression in WHERE clause
select
    employee_id as kode_karyawan,
    commission_pct as besar_komisi,
    salary as gaji_sebulan
from employees
where case
    when commission_pct is null and salary <= 2200 then true -- tidak punya komisi, gaji <= 2200 ambil data (true)
    when commission_pct is null then false -- semua yg tidak pny komisi,, tapi gaji > 2200 dibuang (false)
    when commission_pct is not null and salary < 8000 then salary in (7500, 7000, 7200) -- punya komisi, gaji < 8000,tapi hanya kalau gajinya salah satu dari (7500,7000,7200) ambil data
    when commission_pct is not null and salary < 12000 then salary = 11000 -- punya komisi, gaji < 12000, tapi harus tepat 11000 ambil data
end;
