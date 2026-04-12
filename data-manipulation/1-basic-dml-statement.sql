-- simple insert statement
insert into regions (region_id, region_name)
values (6, 'Africa');

-- simple update statement
update regions
set region_name = 'Oceania'
where region_id = 5

-- simple delete statement
delete from regions
where region_id = 5

-- returning data from modified rows
insert into regions (region_id, region_name)
values (9, 'West Asia')
returning region_id, region_name
