select *
from departments
order by department_id -- default asc

select *
from departments
order by department_id desc

select *
from departments
order by department_name

-- sort expression
select
    employee_id,
    first_name,
    salary,
    coalesce(commission_pct, 0) as commission_digit,
    salary * coalesce(commission_pct, 0) as commission_currency
from employees
order by salary * coalesce(commission_pct, 0) desc -- ini boleh, karena pakai nama kolom asli, bukan alias


select
    employee_id,
    first_name,
    salary,
    coalesce(commission_pct, 0) as commission_digit,
    salary * coalesce(commission_pct, 0) as commission_currency
from employees
order by commission_currency desc -- seperti ini lebih rapi juga boleh

select
    employee_id,
    first_name,
    salary,
    coalesce(commission_pct, 0) as commission_digit,
    salary * coalesce(commission_pct, 0) as commission_currency
from employees
order by 2 asc -- (2) disini artinya order by kolom ke 2

-- multiple column sort
-- semakin tinggi urutannya, maka semakin tinggi juga priority sort nya
-- order by x, y desc -> artinya order by x asc, y desc. jadi masing2 ya yang diorder, yang paling atas yang prioritas

select
    location_id,
    department_id,
    department_name
from departments
order by location_id asc, department_id desc -- urutkan dulu location_id, baru department_id

-- choose null value show position (di mysql gk ada)
select
    employee_id,
    salary,
    commission_pct
from employees
order by
    commission_pct desc  -- urutkan dari komisi terbesar ke kecil
    nulls last;          -- nilai NULL ditaruh di PALING BAWAH

select
    employee_id,
    salary,
    manager_id,
    commission_pct
from employees
order by
    manager_id nulls first,   -- NULL (tidak punya manager) ditaruh di ATAS
    commission_pct nulls last;-- lalu urutkan komisi, NULL di BAWAH
