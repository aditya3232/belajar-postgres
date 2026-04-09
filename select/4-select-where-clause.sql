-- relational predicate
SELECT *
FROM employees
WHERE employee_id = 101;

SELECT employee_id, first_name, salary
FROM employees
WHERE salary >= 15000;

-- like pedicate
SELECT *
FROM employees
where first_name like 'S%' -- % = bebas (0 atau lebih karakter) setelah 'S'

SELECT *
FROM employees
where first_name like '__a%' -- _ = tepat 1 karakter (jadi '__a%' = huruf ke-3 harus 'a')

SELECT *
FROM employees
where first_name ilike 's%' -- ILIKE = case-insensitive LIKE (tidak peduli huruf besar/kecil)

-- between predicate
SELECT *
FROM employees
where salary between 15000 and 25000 -- ambil data dengan salary di rentang 15000–25000 (inklusif)

SELECT *
FROM employees
WHERE substring(email from 1 for 1) between 'A' and 'J' -- ambil email yang huruf pertama antara A–J

SELECT *
FROM job_history
WHERE start_date between '1993-01-01' and '1993-12-31'

-- null predicate
SELECT *
from employees
where manager_id is null -- menampilkan yang null

SELECT *
from employees
where manager_id is not null

-- logical predicate
SELECT *
FROM employees
WHERE manager_id = 100 and department_id = 90 -- dua kondisi harus terpenuhi

SELECT *
FROM employees
WHERE manager_id = 100 or department_id = 90 -- cukup 1 kondisi terpenuhi

SELECT *
from employees
WHERE job_id not like  '%_MAN' -- bebas (0 atau lebih karakter) sebelum _MAN

SELECT *
FROM employees
WHERE manager_id = 100 -- department_id harus 100
and (department_id = 90 or salary >= 10000) -- dan salah satu kondisi disini terpenuhi
and commission_pct is not null -- commission_pct tidak boleh null

-- regular expression (regex) predicate
-- SIMILAR TO -> adalah regex versi sql standar (tapi jarang dipakai karena kurang fleksibel)
-- lebih baik pakai POSIX
/*
1. | -> artinya or (pilihan). cocok salah satu dari beberapa opsi. 'A|B' -- A atau B
2. * -> artinya 0 atau lebih kali. bisa tidak ada atau berulang banyak. 'A*' -- A, AA, AAA
3. + -> artinya minimal 1 kali (1 atau lebih). harus ada minimal 1. 'A+' -- A, AA, AAA (tidak bisa kosong)
4. ? -> artinya opsional (0 atau 1 kali). bisa ada ata tidak. 'A?' -- '' atau A
5. {m} -> artinya harus tepat m kali. 'A{3}' -- AAA (harus 3 kali)
6. {m,} -> artinya minimal m kali (m atau lebih). 'A{2,}' -- AA, AAA, AAAA, ...
7. {m,n} -> artinya m sampai n kali. 'A{2,4}' -- AA, AAA, AAAA
8. () -> artinya grouping (pengelompokan). supaya dianggap satu kesatuan. '(AB)+' -- AB, ABAB, ABABAB
9. [...] -> artinya set karakter (pilih salah satu karakter). '[ABC]' -- A atau B atau C
*/

select *
from employees
where first_name similar to 'Ste(ph|v)en' -- Steven or Stephen

select *
from employees
where first_name ~ '^S.*(a|v|ph)' -- POSIX

-- in
select
    employee_id,
    first_name,
    phone_number,
    job_id
from employees
where job_id in ('IT_PROG', 'SA_MAN', 'MK_MAN') -- cukup salah satu kondisi terpenuhi, mirip or

select
    employee_id,
    first_name,
    phone_number,
    job_id
from employees
where job_id not in ('IT_PROG', 'SA_MAN', 'MK_MAN')

-- some & any
/*
WHERE job_id = 'IT_PROG'
   OR job_id = 'SA_MAN'
   OR job_id = 'MK_MAN'
*/
select
    employee_id,
    first_name,
    phone_number,
    job_id
from employees
where job_id = any (array['IT_PROG', 'SA_MAN', 'MK_MAN']) -- (= any) tujuannya sama seperti in, cukup salah satu kondisi terpenuhi

/*
WHERE salary > 3100
   OR salary > 7700
   OR salary > 4800
   OR salary > 6000
*/
select *
from employees
where salary > any (array[3100, 7700, 4800, 6000]) -- (> any) disini tujuannya adalah salary lebih besar dari salah satu nilai di array
