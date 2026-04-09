-- limit data
select
    employee_id,
    first_name,
    salary,
    commission_pct
from employees
order by employee_id
limit 10

-- offset data
-- digunakan untuk skip data
-- misal offset 3, berarti dia melewati 3 baris pertama. (1,2,3,4,5) offset 2 (3,4,5)
select
    *
from departments
order by department_id
offset 20

-- limit & offset together
-- dia akan skip menggunakan offset dulu, baru dia menghitung dari limit datanya
select
    *
from employees
order by employee_id desc
limit 5  -- 2. baru kita limit data yg ditampilkan
offset 10 -- 1. kita offset terlebih dahulu. skip 10 data. dari data pertama atau terakhir bergantung order nya asc / desc

-- menampilkan 10 halaman pertama (implementasi paination)
select *
from employees
order by employee_id
limit 10
offset 10

-- menampilkan 10 halaman kedua (implementasi pagination)
select *
from employees
order by employee_id
limit 10
offset 20
