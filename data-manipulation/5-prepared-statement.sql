-- prepared statement for insert
-- akan di compile dan direncanakan sekali saja oleh PostgreSQL, tapi kalau session habis harus prepare ulang
-- lebih aman dari sql injection, karena parameter di treat sebagai data, bukan bagian dari SQl
-- selain itu akan mengurangi error karena missmatch data karena parameter sudah ditentukan
prepare create_employee (varchar(25), varchar(20), varchar(25), varchar(10), int, numeric(8,2), numeric(2,2))
as
insert into employees (email, first_name, last_name, job_id, department_id, salary, commission_pct)
values ($1, $2, $3, $4, $5, $6, $7)
returning employee_id, first_name, last_name;

-- execute create_employee
execute create_employee ('ICSAN', 'Ichsan', 'Ashiddiqi', 'AD_VP', 90, 1500, 0.1);
execute create_employee ('HERLIEN', 'Herlien', 'Novawati', 'AD_PRES', 10, 25000, 0.1);

-- check
select * from employees where employee_id IN (7,8)

-- check all prepared statements available in the session
-- kalau session baru, di session itu beda lagi datanya
select * from pg_prepared_statements;

-- remove prepared statement
-- tanpa harus hapus session nya
deallocate prepare create_employee;

--***************************************************************************************************************************
