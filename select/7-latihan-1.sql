/*
Pertanyaan untuk tugas ini:
1. Buatlah query untuk menampilkan seluruh data karyawan dari table employees yang diurutkan berdasarkan email paling terakhir.
2. Buatlah query untuk menampilkan data karyawan yang gajinya lebih besar 3200.00 sampai dengan 12000.00
3. Buatlah query untuk menampilkan data karyawan yang memiliki huruf A diawal nama depannya.
4. Buatlah query untuk menampilkan data karyawan yang memiliki kode karyawan diantaranya 103, 115, 196, 187, 102 dan 100
5. Buatlah query untuk menampilkan data karyawan yang nama belakangnya memiliki huruf kedua u.
6. Buatlah query untuk menampilkan kode department apa saja yang ada di tabel employees secara unique
7. Buatlah query untuk menampilkan nama lengkap karyawan, kode jabatan, gaji setahun dari table employees yang kode manager sama dengan 100.
8. Buatlah query untuk menampilkan nama belakang, gaji perbulan, kode jabatan dari table employees yang tidak memiliki komisi
9. Buatlah query untuk menampilkan data karyawan yang bukan dari jabatan IT_PROG dan SH_CLERK.
*/

-- 1
select
    *
from employees
order by email desc

--2
select
    first_name,
    last_name,
    salary
from employees
where salary between 3200.00 and 12000.00

--3
select
    employee_id,
    first_name
from employees
where first_name like 'A%'

--4
select
    employee_id,
    first_name,
    last_name
from employees
where employee_id in (103, 115, 196, 187, 102, 100)

--5
select
    employee_id,
    last_name
from employees
where last_name like '_u%'

--6
select distinct on (department_id)
    employee_id,
    first_name,
    last_name,
    department_id
from employees

--7
select
    first_name || E'\t' || last_name as nama_lengkap,
    job_id as kode_jabatan,
    salary * 12 as gaji_setahun,
    manager_id
from employees
where manager_id = 100

--8
select
    last_name as nama_belakang,
    salary as gaji_perbulan,
    job_id as kode_jabatan,
    commission_pct as komisi
from employees
where commission_pct is null

--9
select *
from employees
where job_id not in ('IT_PROG','SH_CLERK')
