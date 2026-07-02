-- union queries
-- artinya menggabungkan kedua hasil
-- union distinct, atau default union, akan menghapus data yang duplikat
-- syarat union jumlah kolom, posisi kolom, dan tipenya harus sama
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (2, 'myusuf', 'Muhamad Yusuf', true),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data1
union
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (4, 'abdul', 'Abdul Rahman', false)
) as data2;

-- union all
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (2, 'myusuf', 'Muhamad Yusuf', true),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data1
union all
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (4, 'abdul', 'Abdul Rahman', false)
) as data2;

-- intersect
-- default intersect distinct adalah intersect
-- tujuannya adalah mengambil data yang ada di kedua query
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (2, 'myusuf', 'Muhamad Yusuf', true),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data1
intersect distinct
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (4, 'abdul', 'Abdul Rahman', false),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data2;

-- except
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (2, 'myusuf', 'Muhamad Yusuf', true),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data1
except
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (4, 'abdul', 'Abdul Rahman', false),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data2;

-- using combination (union, intersect, except)
-- prioritas dari kiri kekanan
-- dari query ini berarti (query1 union query2) except query3
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (2, 'myusuf', 'Muhamad Yusuf', true),
    (3, 'mpurwadi', 'Muhamad Purwadi', false)
) as data1
union
select *
from (values
    (1, 'dimasm93', 'Dimas Maryanto', true),
    (4, 'abdul', 'Abdul Rahman', false)
) as data2
except
select *
from (values
    (2, 'myusuf', 'Muhamad Yusuf', true)
) as data3;
