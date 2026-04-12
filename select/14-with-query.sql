-- simple with query for select statement
-- CTE (common table expression), seperti membuat tabel sementara
-- kalau query sudah kompleks dan panjang, dengan pakai CTE, bikin query jadi lebih rapi, lebih mudah dibaca, & bisa dipakai ulang dalam query yang sama
with get_emp_in_dep_hundred as ( -- ini namanya CTE (common table expression), seperti membuat tabel sementara
    select *
    from employees
    where department_id = 100
)

select
    employee_id,
    first_name,
    salary,
    commission_pct
from get_emp_in_dep_hundred
limit 5;

--recursive query
WITH RECURSIVE t(n) AS (
    VALUES (1)
    UNION ALL
    SELECT n + 1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;
