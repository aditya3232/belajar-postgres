-- group atau aggregate function
select
    count(*) as row_count
from employees

select
    max(salary) as max_salary,
    min(salary) as min_salary
from employees
where department_id = 90

select avg(salary)
from employees
where job_id = 'IT_PROG'

-- group by clause
-- perintah yang digunakan untuk mengelompokkan dari sebuah data berdasarkan nilai yang identikal
-- biasanya digunakan bersamaan dengan group function

select
    job_id
from employees
group by job_id -- perilaku di query ini akan group job_id. jadi seperti distinct

select
    job_id,
    count(*) as count_employees_by_job, -- group function
    sum(salary) as salary_group_by_job, -- group function
    max(salary) as max_salary_employees_by_job
from employees
group by job_id

-- group by bisa juga dipakai untuk multiple column
select
    department_id,
    job_id,
    count(*) as employee_by_dep_and_job
from employees
group by department_id, job_id
order by job_id

-- having
-- filter data for group function
-- adalah suatu perintah yg digunakan untuk memfilter data,
-- tujuannya mengeliminiasi hasil dari group function
-- simpelnya, where: filter data sebelum di group. having: filter data setelah di group, dan yg difilter adalah group/aggregate function
select
    job_id,
    count(*) as count_employees_by_job,
    sum(salary) as salary_group_by_job,
    max(salary) as max_salary_employees_by_job
from employees
group by job_id
having count(*) >= 5 and max(salary) >= 10000-- filter data setelah di group, yg difilter aggregate func

select
    job_id,
    sum(salary) as salary_group_by_job
from employees
where job_id in ('FI_ACCOUNT','SA_MAN','IT_PROG','HR_REP','MK_MAN') -- filter single row
group by job_id
having sum(salary) >= 20000 -- filter aggregate function

-- grouping set (di mysql gk ada)
-- artinya kita bikin beberapa group by, lalu digabung jadi satu
-- biasanya dipakai untuk laporan multi level
select
    manager_id,
    department_id,
    count(*),
    sum(salary)
from employees
group by grouping sets ((manager_id), (department_id)) -- dalam kurung ada 2 karena group by untuk 2 ya

-- grouping set diatas itu sama seperti menjalankan 2 query ini, dan hasilnya digabung jadi satu
select
    manager_id,
    count(*),
    sum(salary)
from employees
group by manager_id

select
    department_id,
    count(*),
    sum(salary)
from employees
group by department_id
