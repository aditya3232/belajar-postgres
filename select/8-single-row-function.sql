-- single row function
-- fungsi SQL yang bekerja pada setiap baris secara individu dan menghasilkan 1 output untuk setiap baris.

select
    employee_id,
    concat(first_name, ' ', last_name) as nama_lengkap,
    to_char(salary, '$999,999,999') as salary,
    coalesce(commission_pct, 0) as commission
from employees
where coalesce(commission_pct, 0) > 0 -- single row function di klausa where
limit 10
