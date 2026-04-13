-- delete with using from_item clause
-- ini adalah delete dengan join, supaya bisa pakai data dari tabel lain untuk kondisi
-- khusus postgresql
DELETE FROM employees emp
USING job_history old
WHERE old.job_id = 'ST_CLERK'
  AND emp.employee_id = old.employee_id;

-- delete using returning
DELETE FROM countries
WHERE country_id IN ('ZM', 'ZW')
RETURNING *;

-- delete using with queries
WITH history_emp_from_dep AS (
    SELECT DISTINCT employee_id
    FROM job_history
    WHERE start_date > '1995-01-01'
)
DELETE
FROM employees emp
USING history_emp_from_dep history
WHERE emp.employee_id = history.employee_id
RETURNING *;
