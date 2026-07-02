-- soal no 1
select
    concat(emp.first_name, ' ', emp.last_name) as nama_lengkap,
    dep.department_name,
    to_char(salary, 'FM999,999,999') as gaji_sebulan,
    case
        when emp.commission_pct is null then 'Tidak punya komisi'
        else to_char(emp.commission_pct * emp.salary, 'FM999,999,999')
    end as komisi,
    to_char(emp.salary + (emp.salary * coalesce(emp.commission_pct, 0)), 'FM999,999,999') as gaji_terima
from employees emp
inner join departments dep on (emp.department_id = dep.department_id)

-- soal no 2
select
    concat(emp.last_name, ', ', emp.first_name) as nama_karyawan,
    dep.department_name as nama_bagian,
    case
        when man.employee_id is null then 'Tidak punya manager' -- pakai employee_id, karena manager pasti punya employee_id
        else concat(man.first_name, ' ', man.last_name)
    end as manager_name,
    job.job_title as nama_jabatan
from employees emp
join departments dep on (emp.department_id = dep.department_id)
left join employees man on (emp.manager_id = man.employee_id) -- self join
join jobs job on (emp.job_id = job.job_id)
order by manager_name, nama_karyawan asc

-- soal no 3
select
    dep.department_name,
    sum(emp.salary) as total_gaji
from employees emp
join departments dep on (emp.department_id = dep.department_id)
group by dep.department_name -- semua kolom non-agregat di SELECT harus ada di GROUP BY
order by total_gaji desc

-- soal no 4
select
    case
        when (emp.salary * 12) > 200000 then 'Tinggi'
        when (emp.salary * 12) between 100000 and 200000 then 'Sedang'
        else 'Rendah'
    end as kategori_gaji,
    count(*) as jumlah_karyawan
from employees emp
where emp.commission_pct is not null
group by kategori_gaji
order by max(emp.salary * 12) desc;

-- soal no 5
select *
from employees emp
where emp.salary >= (
    select max(e.salary)
    from employees e
    where e.job_id = 'IT_PROG'
);


-- soal no 6
with employees_in_us as (
    select e.*, dep.department_name, loc.city
    from departments dep
             join locations loc on dep.location_id = loc.location_id
             left join employees e on dep.manager_id = e.employee_id
    where loc.country_id = 'US'
      and dep.manager_id is not null)
select employee_id                as emp_id,
       upper(first_name)          as emp_name,
       to_char(salary, '999,999') as emp_salary,
       department_name               dep_name,
       city                          dep_city
from employees_in_us
order by salary desc;
