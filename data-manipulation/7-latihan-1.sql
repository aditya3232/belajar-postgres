select * from countries;
select * from locations;
select * from employees;

-- soal no 1
insert into countries (country_id, country_name, region_id)
values ('ID', 'Indonesia', 3)

-- soal no 2
prepare create_locations (int, varchar(40), varchar(12), varchar(30), varchar(25), varchar(2))
as
insert into locations (location_id, street_address, postal_code, city, state_province, country_id)
values ($1, $2, $3, $4, $5, $6)
returning location_id, street_address, country_id;

execute create_locations (6232, 'Cinunuk', '40526', 'Kab. Bandung', 'Jawa Barat', 'ID');
execute create_locations (6231, 'Ujung Berung', '40521', 'Kota Bandung', 'Jawa Barat', 'ID');
execute create_locations (6233, 'Margahayu Raya', '40525', 'Kota Bandung', 'Jawa Barat', 'ID');
execute create_locations (6230, 'Blok M', '40620', 'Jakarta Selatan', 'DKI Jakarta', 'ID');
execute create_locations (6220, 'Slipi', '40521', 'Jakarta Utara', 'DKI Jakarta', 'ID');

-- soal no 3
update employees
set commission_pct = 0.10
where job_id = 'IT_PROG'
and employee_id <> 104;

-- soal no 4
insert into employees (
    first_name, last_name, email, phone_number,
    job_id, salary, commission_pct, department_id, manager_id
)
select
    'Dimas',
    'Maryanto',
    upper('Dimas'),
    '081223334444',
    'IT_PROG',
    (j.min_salary + j.max_salary) / 2,
    0.09,
    d.department_id,
    d.manager_id
from jobs j
join departments d on d.department_name = 'IT'
where j.job_id = 'IT_PROG';

-- soal no 5
insert into jobs (job_id, job_title, min_salary, max_salary)
values (
    'IT_MAN',
    'IT Project Manager',
    (select max_salary from jobs where job_id = 'IT_PROG'),
    (select min_salary + 15000 from jobs where job_id = 'IT_PROG')
)

on conflict (job_id)
do update set
    job_title = excluded.job_title,
    min_salary = excluded.min_salary,
    max_salary = excluded.max_salary;
