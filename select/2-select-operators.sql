-- math operator
SELECT
    2 + 2 as tambah,
    2 * 3 as kali,
    10 % 3 as "mod (sisa bagi)",
    2 ^ 3 as pangkat;

SELECT
    first_name,
    salary,
    commission_pct,
    salary * commission_pct as bonus
FROM employees
ORDER BY bonus ASC;

SELECT
    current_date - 2 as "2 hari lalu",
    current_date + 2 as besok,
    current_date + interval '2 hour' as "kurang 2 jam",
    current_timestamp + interval '2 hour' as "kurang 2 jam dari date dan waktu sekarang"
    -- current_date + date '2026-04-09' -- date ditambah date tidak boleh

-- concat operator
SELECT
    employee_id as id,
    first_name,
    last_name,
    last_name || ', ' || first_name as full_name
FROM employees

-- typecast operator (konfersi tipe data)
SELECT
    cast ('100' as int) as string_to_int,
    '100'::int as string_to_int_short,
    cast ('10.3' as double precision) as string_to_double,
    cast ('28-FEB-2022' as date) as string_to_date,
    cast (100 as character varying) as int_to_string,
    'm.aditya' || cast (3232 as character varying) as int_to_string,
    '100'::int + 100 as int_to_string,
    cast (0 as boolean) as int_to_boolean;

-- logical operator
SELECT
    (true AND true)   "AND -> true x true",
    (true AND false)  "AND -> true x false",
    (false AND false) "AND -> false x false",
    (null AND false)  "AND -> null x false",
    (null AND true)   "AND -> null x true",
    (true OR true)    "OR -> true x true",
    (true OR false)   "OR -> true x false",
    (false OR false)  "OR -> false x false",
    (null OR true)    "OR -> null x true",
    (null OR false)   "OR -> null x false",
    NOT(false)        "NOT -> false",
    NOT(null)         "NOT -> null",
    NOT(true)         "NOT -> true";

-- comparison operator
SELECT
    3 > 4 AS compare_less_than,
    'nilai tidak sama' <> 'nilai sama' AS compare_string_no_equal,
    '28-FEB-2022'::DATE = '28-FEB-2021'::DATE AS compare_date_equal,
    2800000 IS NOT NULL AS compare_not_null,
    'off'::boolean IS NOT TRUE AS compare_not_true,
    1 >= 3 and (0 < 1 or 1 = 1) as less_then_eq_same
