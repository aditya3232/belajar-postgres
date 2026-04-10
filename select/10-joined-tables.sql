-- simple natural join
-- postgresql akan otomatis mencari kolom yang namanya sama di kedua tabel
-- join otomatis berdasarkan nama kolom yang sama [poin pentingnya ini]
-- tidak perlu menulis kondisi ON
select *
from employees
natural join jobs

-- multiple natural join
-- hindari pakai ini, karena kalau ada nama kolom yg sama data gk bisa diprediksi di natural join
-- selain itu sulit dibaca karena gk ada ON
select *
from employees
natural join jobs
natural join departments
natural join locations

-- using specify column in natural join
select
    emp.employee_id,
    concat(emp.first_name, ' ', emp.last_name) as fullname,
    emp.job_id,
    job.job_title,
    emp.department_id,
    dep.department_name
from employees emp
natural join jobs job
natural join departments dep

-- cross join (cartesian product)
-- tidak pakai kondisi ON
-- semua kombinasi akan muncul tanpa filter (on/using/where) [poin pentingnya ini]
-- jumlah baris = jumlah baris A x jumlah baris B
-- di contoh query ini artinya setiap department akan dipasangkan dengan semua job
-- misal tabel A: [1,2]
-- tabel B: [A,B]
-- hasil cross join [1A,1B,2A,2B]; ada 4 data dari 2 * 2
-- biasanya dipakai untuk:
-- mencari semua kombinasi memungkinkan
select
    dep.department_id,
    dep.department_name,
    job.job_id,
    job.job_title
from departments dep
cross join jobs job

-- jenis-jenis qualified join (berdasarkan kondisi):

-- inner join:
-- hanya menampilkan data yang memiliki pasangan (match) di kedua tabel

-- left outer join:
-- menampilkan semua data dari tabel kiri
-- + data dari tabel kanan jika ada yang match
-- + jika tidak match → kolom kanan bernilai NULL

-- right outer join:
-- menampilkan semua data dari tabel kanan
-- + data dari tabel kiri jika ada yang match
-- + jika tidak match → kolom kiri bernilai NULL

-- full outer join:
-- menampilkan semua data dari kedua tabel
-- + yang match digabung
-- + yang tidak match tetap muncul dengan NULL di sisi yang tidak punya pasangan

-- inner join
select
    emp.employee_id,
    emp.first_name,
    job.job_title,
    job.max_salary,
    dep.department_name
from employees emp
inner join jobs job on (emp.job_id = job.job_id) -- boleh gk pake inner
inner join departments dep on (emp.department_id = dep.department_id)

-- left outer join
select
    emp.employee_id,
    emp.first_name,
    dep.department_id,
    dep.department_name
from employees emp
left outer join departments dep on (emp.department_id = dep.department_id) -- boleh tanpa outer

-- right outer join
select
    emp.employee_id,
    emp.first_name,
    dep.department_id,
    dep.department_name
from employees emp
right outer join departments dep on (emp.department_id = dep.department_id)

-- full outer join
select
    emp.employee_id,
    emp.first_name,
    dep.department_id,
    dep.department_name
from employees emp
full outer join departments dep on (emp.department_id = dep.department_id)

-- self join: join tabel dengan dirinya sendiri (employees dipakai 2 kali)
-- di tabel employee:
-- manager_id mereferensikan employee_id lain di tabel yang sama;
-- Semua orang (karyawan & manager) ada di satu tabel;
-- Manager itu juga karyawan, cuma punya bawahan;
-- self join biasanya dipakai untuk mengambil informasi yang saling berelasi dalam satu tabel
-- misal, relasi atasan bawahan, data hirarki yg semua disimpan dalam tabel yg sama
select
    emp.employee_id as "employee id",   -- ambil id karyawan
    emp.last_name as "employee name",   -- ambil nama karyawan
    man.employee_id as "manager id",    -- ambil id manager (dari tabel yang sama)
    man.last_name as "manager name"     -- ambil nama manager
from employees emp                      -- tabel employees sebagai "emp" (role: karyawan)
left outer join employees man           -- tabel employees lagi sebagai "man" (role: manager)
    on emp.manager_id = man.employee_id -- hubungkan: manager_id karyawan = employee_id manager
limit 10;                               -- batasi output 10 baris

-- [using] clause
-- sama kaya on, syaratnya kolom harus sama
select
    emp.employee_id,
    emp.last_name,
    job.job_id,
    job.job_title
from  employees emp
join jobs job using(job_id) -- sama dengan join jobs job on (emp.job_id = job.job_id)
limit 10;

-- using where clause
select
    emp.employee_id,
    emp.last_name,
    job.job_id,
    job.job_title
from  employees emp, jobs job
where emp.job_id = job.job_id
limit 10
