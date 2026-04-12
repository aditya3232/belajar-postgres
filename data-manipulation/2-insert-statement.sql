-- insert with specific column and data type
insert into employees (email, first_name, last_name, job_id, salary)
values ('DIMAS', initcap('dimas'), initcap('maryanto'), upper('it_prog'), 15000);

-- start_date tipe datanya adalah timestamp without timezone
-- tapi postgresql akan melakukan akuto konversi jika memungkinkan
-- dari values date ke timestamp witohout timezone
insert into job_history (employee_id, start_date, job_id)
values (2, '2016-07-15', 'IT_PROG');

-- perintah alter tabel
alter table employees
alter column salary set default 0;

-- insert with default value
-- kita tidak memasukkan data salary
-- nanti datanya akan otomatis berisi default valuenya
insert into employees (email, first_name, last_name, job_id)
values ('DIMAS', initcap('dimas'), initcap('maryanto'), upper('it_prog'));

-- insert single and multiple rows
INSERT INTO countries (country_id, country_name, region_id)
VALUES
    ('ID', 'Indonesia', 3),
    ('SI', 'Singapore', 3),
    ('TH', 'Thailand', 3);
COMMIT;

-- insert to many rows, bisa kita bagi2 biar server gk lag [metode batch input]
-- dengan pakai commit, maka kalau ada error saat insert, kita gk harus ngulang proses dari awal
INSERT INTO countries (country_id, country_name, region_id)
VALUES
    ('ID', 'Indonesia', 3),
    ('SI', 'Singapore', 3),
    ('TH', 'Thailand', 3);
COMMIT;


INSERT INTO countries (country_id, country_name, region_id)
VALUES
    ('ID', 'Indonesia', 3),
    ('SI', 'Singapore', 3),
    ('TH', 'Thailand', 3);
COMMIT;


INSERT INTO countries (country_id, country_name, region_id)
VALUES
    ('ID', 'Indonesia', 3),
    ('SI', 'Singapore', 3),
    ('TH', 'Thailand', 3);
COMMIT;

-- insert with on conflict do nothing
-- harusnya ada error conflict primary key
-- tapi karena ada on conflict do nothing,
-- errornya tidak muncul
-- namun 0 rows affected (tidak terjadi apa-apa)
INSERT INTO countries (country_id, country_name, region_id)
VALUES ('ID', 'Republic Indonesia', 3)
on conflict (country_id) do nothing;

-- on conflict do update
-- jika ada conflict waktu insert
-- akan melakukan update data
INSERT INTO countries (country_id, country_name, region_id)
VALUES ('ID', 'Republic Indonesia', 3)
on conflict (country_id) do update
set country_name  = excluded.country_name,
    region_id = excluded.region_id

-- using nested insert statement (with query)
with insert_emp as (
    insert into employees (email, first_name, last_name, job_id, salary, department_id)
    values ('DIMAS89', initcap('dimas'), initcap('maryanto'), upper('it_prog'), 15000, 10)
    returning employee_id, job_id, department_id
)
insert into job_history (employee_id, start_date, job_id, department_id)
select
    employee_id,
    now(),
    job_id,
    department_id
from insert_emp;
