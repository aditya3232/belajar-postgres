select
    emp.employee_id, emp.first_name, emp.last_name, emp.job_id, emp.salary, emp.commission_pct
from employees emp
where department_id = 10

-- update salary ke default value nya
update employees
set salary = default
where department_id = 10

-- update using sub-select (sub query) clause
select
    min_salary,
    job_id
from jobs
where job_id in (
    select job_id
    from employees
    where department_id = 10
)

update employees emp
set salary = (select job.min_salary from jobs job where emp.job_id = job.job_id) -- dibagian set tidak boleh pakai alias tabel
where emp.department_id = 10

update employees emp
set salary = emp.salary + 1000 -- tambah 1000 dari data salary sebelumnya
where emp.department_id = 10

-- update using column-list syntax
UPDATE employees emp
SET (salary, commission_pct) = (
    SELECT
        job.max_salary,
        0.2 AS commission_pct
    FROM jobs job
    WHERE emp.job_id = job.job_id
)
WHERE department_id = 10;

-- ini sama seperti yang diatas
-- pakai format tuple (multi-column assignment)
UPDATE employees
SET (salary, commission_pct) = (5000, 0.2)
WHERE department_id = 10;

-- update using with query
-- kalau pakai select, pasti ada valuenya di default_salary
-- tapi kalau pakai insert kita perlu returning
WITH default_salary AS (
    SELECT
        job_id,
        min_salary,
        0.2 AS commission_pct
    FROM jobs
)
UPDATE employees emp
SET (salary, commission_pct) = (
    SELECT
        ds.min_salary,
        ds.commission_pct
    FROM default_salary ds
    WHERE ds.job_id = emp.job_id
)
WHERE department_id = 10;

-- update using from_item clause (khusus postgresql)
UPDATE employees emp
SET
    salary = min_salary, -- min_salary dari tabel job
    commission_pct = 0.1
FROM jobs job
WHERE job.job_id = emp.job_id
  AND department_id = 10;

-- update using returning clause
UPDATE employees emp
SET
    salary = min_salary,
    commission_pct = 0.1
FROM jobs job
WHERE job.job_id = emp.job_id
  AND department_id = 10
 RETURNING *
