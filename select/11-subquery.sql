-- subquery on select column list -> subquery ada di select
-- subquery disini menghasilkan satu nilai saja. tidak boleh lebih (result subquery only one row one column)
-- ::date -> cast ketipe date
-- karena subquery tidak ada relasi, maka hasilnya akan sama untuk setiap baris (start join perusahaan)
-- subquery akan dijalankan dulu, baru query yg diluar
select
    j.job_title, -- dijalankan ketiga
    (select min(h.start_date)::date from job_history h) as min_start_join, -- dijalankan pertama
    (select max(h.start_date)::date from job_history h) as max_start_join  -- dijalankan kedua
from jobs j

-- correlated subquery (subquery yang bergantung pada query utama)
-- pakai join lebih cepat kalau kompleks,
-- karena untuk setiap baris employee, subquery dijalankan 2 kali
select
    emp.employee_id,
    emp.first_name,
    (
        select
            man.first_name
        from employees man
        where emp.manager_id = man.employee_id
    ) as manager_name,
    (
        select
            man.job_id
        from employees man
        where emp.manager_id = man.employee_id
    ) as manager_job_id
from employees emp
where emp.manager_id is not null
limit 10;

-- subquery inline view (subquery dibagian FORM yang dianggap seperti tabel sementara)
select
    emp.employee_id,
    emp.first_name,
    emp.salary,
    func.rata2 as average_salary,
    func.maximum as max_salary,
    func.minimum as min_salary
-- karena subquery cuma 1 baris, semua baris employee dapat nilai yang sama (cross join kombinasi data)
from employees emp
cross join (
    select
        round(avg(max_salary), 0) as rata2,
        min(max_salary) as minimum,
        max(max_salary) as maximum
    from jobs
) func -- subquery ini menghasilkan 1 baris berisi agregasi
where emp.salary >= func.rata2;

-- latral subquery
-- LATERAL = subquery di FROM boleh mengakses kolom dari tabel sebelumnya
-- LATERAL = mirip correlated subquery tapi di FROM

-- kita gk boleh pakai ini (error)
select
    emp.employee_id,
    emp.first_name,
    history.job_id,
    history.start_date
from employees emp,
    (select job.job_id, job.start_date::date
    from job_history job
    where emp.employee_id = job.employee_id) as history
order by employee_id, job_id

-- ini yg gk error
select
    emp.employee_id,
    emp.first_name,
    history.job_id,
    history.start_date
from employees emp,
    lateral (select job.job_id, job.start_date::date
    from job_history job
    where emp.employee_id = job.employee_id) as history
order by employee_id, job_id

-- subquery as predicates in where clause
select
    employee_id,
    first_name,
    salary,
    commission_pct
from employees emp
where salary >= (
    select min(max_salary)
    from jobs
    where job_id = 'IT_PROG'
)
limit 10;

select
    employee_id,
    first_name,
    salary,
    commission_pct,
    job_id
from employees emp
where emp.salary >= (
    select avg(min_salary)
    from jobs job
    where emp.job_id = job.job_id
);

-- subquery for single-row comparison
select
    employee_id,
    first_name,
    salary
from employees emp
where emp.salary >= (select avg(max_salary) from jobs)
order by salary;

select
    employee_id,
    first_name,
    salary,
    coalesce(commission_pct, 0),
    job_id
from employees emp
where (emp.salary, emp.salary, emp.job_id) >= (
    select
        round(stddev(max_salary), 0),
        round(max(min_salary)),
        'IT_PROG'
    from jobs
)
order by salary
limit 10;

-- subquery for exists operator
-- Operator EXISTS digunakan untuk mengecek apakah suatu subquery menghasilkan minimal 1 baris data.
-- Kalau subquery ada hasil (>= 1 row) → EXISTS = TRUE
-- Kalau tidak ada hasil (0 row) → EXISTS = FALSE
-- Subquery dicek per baris employee
-- Begitu ketemu 1 saja, langsung dianggap TRUE (tidak lanjut scan)
select
    employee_id,
    first_name,
    job_id,
    salary
from employees out
where exists (
    select 1
    from job_history
    where employee_id = out.employee_id
);

-- subquery with IN predicate to handle multiple value
select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where job_id in (
    select distinct job_id
    from employees inq
    where inq.department_id = 80
)
limit 10;

select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where (job_id, salary) in ( -- tuple comparison (job_id, salary)
    select
        distinct job_id,
        (select max(min_salary) -- ada subquery didalam subquery
         from jobs
         where inq.job_id = job_id)
    from employees inq
)
limit 10;

-- using any & some predicate to handle multiple value
-- some & any implementasinya sama
-- [= ANY] di postgresql sama dengan IN -> = ANY (mirip IN)
-- namun di ANY bisa pakai operator lain [=,<,>,<=,>=]
-- IN → "apakah sama dengan salah satu?"
-- ANY → "apakah memenuhi kondisi dengan salah satu?"
-- ALL → "apakah memenuhi kondisi dengan semua?"
select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where salary = any ( -- artinya ambil employee yang gajinya sama dengan salah satu nilai dari hasil subquery
    select max(salary) as max_salary
    from employees
    group by job_id
    order by max_salary
)
limit 10;


select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where salary > any ( -- artinya salary lebih besar dengan minimal salah satu dari hasil subquery
    select max(salary) as max_salary
    from employees
    group by job_id
    order by max_salary
)
limit 10;

select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where salary <> all ( -- artinya salary tidak sama dengan semua nilai yang dihasilkan subquery. <> all sama dengan not in
    select min(salary) as min_salary
    from employees
    group by job_id
    order by min_salary
);

select
    employee_id,
    first_name,
    salary,
    job_id
from employees out
where salary < all ( -- artinya salary harus lebih kecil dari semua nilai hasil subquery
    select max(salary) as max_salary
    from employees
    group by job_id
    order by max_salary
);
