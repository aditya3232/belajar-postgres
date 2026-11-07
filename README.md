# Panduan Belajar PostgreSQL & Fundamental Basis Data

Repositori ini berisi rangkuman konsep, perbandingan teknologi, catatan sintaks, serta modul latihan praktis SQL menggunakan **PostgreSQL**.

---

## Daftar Isi
1. [Konsep Dasar: SQL vs NoSQL](#1-konsep-dasar-sql-vs-nosql)
   - [Perbedaan Mendasar](#perbedaan-mendasar)
   - [Tabel Perbandingan SQL vs NoSQL](#tabel-perbandingan-sql-vs-nosql)
   - [Kategori Database NoSQL](#kategori-database-nosql)
   - [Kapan Menggunakan SQL vs NoSQL](#kapan-menggunakan-sql-vs-nosql)
2. [Perbandingan RDBMS: PostgreSQL vs MySQL](#2-perbandingan-rdbms-postgresql-vs-mysql)
   - [Ringkasan Perbandingan](#ringkasan-perbandingan-postgresql-vs-mysql)
   - [Analisis Perbedaan Kunci](#analisis-perbedaan-kunci)
   - [Kapan Memilih PostgreSQL vs MySQL](#kapan-memilih-postgresql-vs-mysql)
3. [Fitur Unik & Keunggulan PostgreSQL](#3-fitur-unik--keunggulan-postgresql)
   - [1. Schema (Namespace)](#1-schema-namespace)
   - [2. CHECK Constraint](#2-check-constraint)
   - [3. Auto Number: Identity, Sequence & Serial](#3-auto-number-identity-sequence--serial)
   - [4. Transaksional DDL](#4-transaksional-ddl)
   - [5. Operator Concatenation (`||`)](#5-operator-concatenation-)
   - [6. Klausul DISTINCT ON](#6-klausul-distinct-on)
   - [7. Klausul RETURNING (DML)](#7-klausul-returning-dml)
   - [8. GROUPING SETS, CUBE & ROLLUP](#8-grouping-sets-cube--rollup)
   - [9. Dukungan FULL OUTER JOIN](#9-dukungan-full-outer-join)
   - [10. Placeholder Parameter & Prepared Statement](#10-placeholder-parameter--prepared-statement)
   - [11. Date, Time & Built-in Functions](#11-date-time--built-in-functions)
   - [12. Strictness & Validasi Data](#12-strictness--validasi-data)
4. [Tipe Data Lengkap di PostgreSQL](#4-tipe-data-lengkap-di-postgresql)
   - [Tipe Standar](#tipe-standar)
   - [Tipe Data Unggulan & Khusus PostgreSQL](#tipe-data-unggulan--khusus-postgresql)
5. [Peta Modul Latihan di Repositori](#5-peta-modul-latihan-di-repositori)

---

## 1. Konsep Dasar: SQL vs NoSQL

Dalam arsitektur basis data modern, pemilihan antara model relasional (**SQL**) dan non-relasional (**NoSQL**) ditentukan oleh karakteristik data, kebutuhan konsistensi, dan pola akses aplikasi.

### Perbedaan Mendasar
- **SQL (Relational Database Management System / RDBMS):**
  - Data disimpan dalam bentuk tabel yang terdiri dari baris (*rows/records*) dan kolom (*attributes*).
  - Mengandalkan skema terstruktur (*rigid/fixed schema*) yang harus ditentukan di awal.
  - Menghindari redundansi data melalui teknik **normalisasi** dan menghubungkan data lewat *Foreign Key*.
  - Mengutamakan kepatuhan **ACID** (*Atomicity, Consistency, Isolation, Durability*) untuk menjamin keabsahan transaksi.
- **NoSQL (Not Only SQL / Non-Relational):**
  - Mengadopsi model penyimpanan non-tabular (dokumen, pasangan key-value, graf, atau kolom lebar).
  - Skema bersifat dinamis (*schema-less* atau fleksibel), memungkinkan atribut bervariasi pada setiap entitas.
  - Sering kali memanfaatkan **denormalisasi** (data digabung dalam satu dokumen) untuk meminimalkan *join* dan mempercepat pembacaan data.
  - Biasanya berlandaskan model **BASE** (*Basically Available, Soft-state, Eventual consistency*) dan Teorema CAP, lebih memprioritaskan ketersediaan (*availability*) dan skalabilitas horizontal (*sharding*).

---

### Tabel Perbandingan SQL vs NoSQL

| Aspek | SQL (Relasional) | NoSQL (Non-Relasional) |
| :--- | :--- | :--- |
| **Model Data** | Tabel relasional (baris & kolom) | Dokumen (JSON/BSON), Key-Value, Graph, Wide-Column |
| **Skema** | *Fixed/Strict Schema* (didefinisikan di awal) | *Dynamic/Flexible Schema* (bisa berubah sewaktu-waktu) |
| **Manipulasi Data** | Structured Query Language (SQL standar) | Beragam (API, method-based, JSON query, CQL, Cypher) |
| **Relasi Antar Data** | Didukung secara native (`JOIN`, foreign key) | Jarang mendukung *join* native; data direkatkan di level aplikasi atau didenormalisasi |
| **Integritas Transaksi** | Standar **ACID** (konsistensi kuat) | Umumnya **BASE** (eventual consistency), beberapa mendukung ACID parsial |
| **Strategi Skalabilitas** | **Vertikal** (Scale-up: upgrade CPU, RAM, SSD) | **Horizontal** (Scale-out: distribusi kluster / *sharding*) |
| **Redundansi Data** | Minim (data dinormalisasi) | Cenderung tinggi (data didenormalisasi demi performa) |
| **Penggunaan Ideal** | Transaksi keuangan, sistem ERP/CRM, data dengan relasi erat | Big data streaming, analitik real-time, katalog dinamis, cache, log |

---

### Kategori Database NoSQL

Database NoSQL dibagi ke dalam 4 kategori arsitektur utama:

```
                    ┌─────────────────────────┐
                    │      Database NoSQL     │
                    └────────────┬────────────┘
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌────────┴────────┐     ┌────────┴────────┐     ┌────────┴────────┐     ┌─────────────────┐
│    Document     │     │    Key-Value    │     │   Wide-Column   │     │      Graph      │
│ (MongoDB, Couch)│     │ (Redis, Dynamo) │     │(Cassandra, HBase│     │(Neo4j, Neptune) │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
```

1. **Document Stores (Contoh: MongoDB, CouchDB):**
   - Data disimpan dalam format semi-terstruktur seperti JSON, BSON, atau XML.
   - Setiap dokumen dapat memiliki skema dan struktur field yang berbeda.
   - Sangat cocok untuk CMS, e-commerce product catalog, profil pengguna, dan konten dinamis.
2. **Key-Value Stores (Contoh: Redis, Memcached, Amazon DynamoDB):**
   - Format paling sederhana: setiap item disimpan sebagai pasangan *key* unik dan *value*.
   - Kecepatan baca dan tulis sangat tinggi (latensi sub-milidetik), sering disimpan di *in-memory*.
   - Ideal untuk *caching*, *session management*, *rate limiting*, dan *shopping cart*.
3. **Wide-Column / Column-Family Stores (Contoh: Apache Cassandra, ScyllaDB, Apache HBase):**
   - Data disimpan berdasarkan kolom per baris dinamis, bukan baris tetap.
   - Dirancang untuk menangani data raksasa (petabyte) yang terdistribusi di ribuan node server.
   - Ideal untuk *time-series data*, *IoT sensor logging*, pelacakan riwayat aktivitas, dan data telemetri.
4. **Graph Databases (Contoh: Neo4j, Amazon Neptune, ArangoDB):**
   - Berfokus pada hubungan antar simpul (*nodes/entities*) dan relasi (*edges/relationships*).
   - Melakukan traversi hubungan relasi secara sangat cepat tanpa join SQL berulang kali.
   - Ideal untuk jejaring sosial, sistem rekomendasi kawan/produk, analisis jaringan, dan deteksi *fraud*.

---

### Kapan Menggunakan SQL vs NoSQL

#### Gunakan SQL jika:
- Integritas data dan konsistensi transaksi adalah prioritas mutlak (misal: sistem perbankan, akuntansi, transaksi e-commerce).
- Pola entitas data sudah matang dan memiliki relasi hierarkis antar tabel.
- Butuh query analitik kompleks yang melibatkan filter, agregasi, subquery, dan *multi-table JOIN*.
- Ingin memanfaatkan ekosistem standar industri (SQL ANSI, ORM matang, migrasi terstruktur).

#### Gunakan NoSQL jika:
- Struktur skema data sering berubah atau belum dapat dipastikan sejak awal perancangan.
- Kebutuhan lalu lintas *traffic* data sangat masif (jutaan operasi read/write per detik) yang menuntut skalabilitas kluster horizontal.
- Kasus pemakaian spesifik: penyimpanan cache cepat, message broker, logging terdistribusi, atau pemrosesan relasi jejaring (graf).
- Keterlambatan sinkronisasi data antar node (*eventual consistency*) masih dapat ditoleransi oleh bisnis.

---

## 2. Perbandingan RDBMS: PostgreSQL vs MySQL

Baik **PostgreSQL** maupun **MySQL** merupakan dua sistem basis data relasional open-source paling populer di dunia. Meskipun sama-sama menggunakan sintaks SQL, keduanya memiliki filosofi desain dan fitur yang berbeda.

### Ringkasan Perbandingan PostgreSQL vs MySQL

| Kriteria | PostgreSQL | MySQL (InnoDB) |
| :--- | :--- | :--- |
| **Tipe Database** | **ORDBMS** (*Object-Relational DBMS*) | **RDBMS** murni (*Relational DBMS*) |
| **Filosofi Desain** | Standar ANSI-SQL ketat, ekstensibilitas, integritas data tinggi | Kecepatan baca, kemudahan adopsi, pragmatis, web-first |
| **Kepemilikan / Lisensi** | Open Source sejati (*PostgreSQL License* / MIT-like) | Oracle Corporation (GPL v2 & opsi Lisensi Komersial) |
| **Transaksional DDL** | **Mendukung penuh** (DDL bisa di-`ROLLBACK`) | **Tidak mendukung** (DDL otomatis melakukan *implicit commit*) |
| **Namespace / Skema** | `Database` ➔ `Schema` ➔ `Table` (bisa multi-schema) | `Schema` identik dengan `Database` |
| **Dukungan JSON** | `json` (teks) & **`jsonb`** (biner terindeks GIN, operasi cepat) | `json` native (sejak 5.7), tanpa format biner terpisah setara `jsonb` |
| **Tipe Data Spesial** | Array, Range, Network (inet/cidr), UUID native, Custom Type | Terbatas (tidak ada Array native, Range, atau Network type) |
| **Indeks Tersedia** | B-Tree, Hash, GiST, SP-GiST, **GIN**, **BRIN** | B-Tree, Hash (Memory engine), Full-Text, Spatial (R-Tree) |
| **Auto Increment** | Standar SQL `GENERATED AS IDENTITY`, `SEQUENCE`, `SERIAL` | Atribut kolom `AUTO_INCREMENT` |
| **Mekanisme Concurrency** | MVCC murni (modifikasi tuple/halaman langsung) | MVCC berbasis Undo Log & Buffer Pool InnoDB |
| **Klausul Khusus** | `DISTINCT ON (...)`, `RETURNING`, `GROUPING SETS` | `LIMIT offset, count`, `ON DUPLICATE KEY UPDATE` |
| **Operator Concat** | `\|\|` (standar SQL) atau fungsi `CONCAT()` | Default: fungsi `CONCAT()` (`\|\|` adalah operator logika OR) |
| **Full Outer Join** | Didukung secara native (`FULL OUTER JOIN`) | Tidak didukung langsung (harus emulasi `LEFT JOIN UNION RIGHT JOIN`) |
| **Ekstensibilitas** | Sangat kaya (PostGIS, pgvector, TimescaleDB, Citus) | Cenderung terbatas |

---

### Analisis Perbedaan Kunci

#### 1. Transaksional DDL (Data Definition Language)
- **PostgreSQL:** Pernyataan DDL seperti `CREATE TABLE`, `ALTER TABLE`, atau `DROP TABLE` dapat dibungkus dalam blok transaksi (`BEGIN ... COMMIT / ROLLBACK`). Jika migrasi gagal di tengah jalan, seluruh perubahan struktur tabel dapat dibatalkan secara aman.
  ```sql
  BEGIN;
  CREATE TABLE test (id INT);
  ALTER TABLE test ADD COLUMN email VARCHAR(100);
  -- Jika terjadi error atau berubah pikiran:
  ROLLBACK; -- Tabel 'test' tidak jadi dibuat!
  ```
- **MySQL:** Setiap perintah DDL langsung memicu *implicit commit*. Jika proses migrasi gagal di baris ke-4, perubahan baris 1-3 tetap tersimpan permanen di database.

#### 2. Konsep Database vs Schema
- **PostgreSQL:** Mendukung struktur 3-tingkat: **Cluster ➔ Database ➔ Schema ➔ Table**. Satu database dapat memiliki beberapa *schema* (misalnya schema `public`, `hr`, `sales`, `audit`). Tabel dengan nama sama dapat hidup berdampingan di schema yang berbeda.
- **MySQL:** Menganggap kata kunci `DATABASE` dan `SCHEMA` adalah sinonim (`CREATE DATABASE` = `CREATE SCHEMA`). Tidak ada pembagian namespace di dalam satu database.

#### 3. Penanganan Auto Number (Identity vs Auto Increment)
- **PostgreSQL:**
  - **Identity Column (Standar ANSI SQL - Sangat Disarankan):**
    ```sql
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    -- atau
    id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
    ```
  - **Sequence (Objek Mandiri):** Bisa dibuat terpisah dengan `CREATE SEQUENCE` dan digunakan bersama oleh beberapa tabel.
  - **Serial (Legacy Shortcut):** Sintaks `id SERIAL PRIMARY KEY` yang secara otomatis menciptakan objek sequence di belakang layar.
- **MySQL:**
  - Hanya menggunakan kata kunci `AUTO_INCREMENT` pada kolom integer primary key. Tidak ada objek sequence mandiri.

#### 4. Ekosistem Ekstensibilitas (Plugins & Data Types)
- **PostgreSQL:** Dirancang sejak awal sebagai ORDBMS yang dapat diekstensi (*pluggable*):
  - **PostGIS:** Standar emas GIS spasial di dunia database.
  - **pgvector:** Dukungan penyimpanan dan pencarian similarity vector (AI embedding / LLM memory).
  - **TimescaleDB:** Ekstensi pengolahan *time-series*.
- **MySQL:** Fungsionalitas inti terfokus pada fungsionalitas web standar, ekstensibilitas tipe data dan fungsi komputasi lebih terbatas.

---

### Kapan Memilih PostgreSQL vs MySQL

```
                        Kebutuhan Database Relasional
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                       ▼
        Pilih PostgreSQL jika:                    Pilih MySQL jika:
  • Query analitik & JOIN kompleks         • Aplikasi web standar (CMS / Blog)
  • Butuh integritas data & strictness     • Pola akses dominan Read-heavy
  • Memakai tipe data JSONB / Array / GIS  • Membutuhkan setup cepat & resource ringan
  • Menginginkan migrasi DDL yang aman     • Tim sudah berpengalaman dengan ekosistem
  • AI embedding (pgvector) / Time-series    LAMP / Cloud managed MySQL
```

---

## 3. Fitur Unik & Keunggulan PostgreSQL

Bagian ini merangkum keunikan sintaks dan fitur teknis PostgreSQL yang menjadikannya pilihan kuat bagi developer.

### 1. Schema (Namespace)
PostgreSQL menggunakan *schema* sebagai ruang lingkup (*namespace*) di dalam satu database.
```sql
-- Membuat schema khusus
CREATE SCHEMA hr;

-- Membuat tabel di dalam schema hr
CREATE TABLE hr.employees (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100)
);

-- Mengatur default pencarian schema
SET search_path TO hr, public;
```

### 2. CHECK Constraint
PostgreSQL menerapkan dan mengevaluasi batasan data (*CHECK constraint*) secara ketat dan konsisten pada setiap operasi write:
```sql
CREATE TABLE products (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) CHECK (price > 0),
    discount NUMERIC(5, 2) CHECK (discount >= 0 AND discount <= 100)
);
```

### 3. Auto Number: Identity, Sequence & Serial
Perbandingan ketiga metode auto-number di PostgreSQL:
1. **Identity Column (Direkomendasikan - Standar SQL modern):**
   ```sql
   -- Tidak mengizinkan intervensi nilai manual:
   id INT GENERATED ALWAYS AS IDENTITY
   
   -- Mengizinkan pengisian manual jika diperlukan:
   id INT GENERATED BY DEFAULT AS IDENTITY
   ```
2. **Serial (Praktek lama / shortcut):**
   ```sql
   id SERIAL -- Di balik layar: INT DEFAULT nextval('tablename_id_seq')
   ```
3. **Sequence Object (Objek Independen):**
   ```sql
   CREATE SEQUENCE order_number_seq START 1000 INCREMENT 1;
   SELECT nextval('order_number_seq');
   ```

### 4. Transaksional DDL
Seluruh perintah perubahan skema dapat diamankan dalam satu unit atomik transaksi:
```sql
BEGIN;
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
ALTER TABLE users ADD CONSTRAINT check_phone CHECK (length(phone) >= 10);
COMMIT; -- atau ROLLBACK jika terjadi kesalahan
```

### 5. Operator Concatenation (`||`)
PostgreSQL menggunakan operator standar SQL `||` untuk menggabungkan string:
```sql
SELECT first_name || ' ' || last_name AS full_name FROM employees;
```
*(Catatan: PostgreSQL juga menyediakan fungsi `CONCAT(str1, str2, ...)` yang otomatis menangani nilai NULL).*

### 6. Klausul DISTINCT ON
Fitur unik PostgreSQL untuk mengambil satu baris pertama dari setiap kelompok data berdasarkan urutan tertentu, tanpa perlu menulis window function `ROW_NUMBER()` yang panjang:
```sql
-- Mengambil pesanan terbaru dari masing-masing pelanggan:
SELECT DISTINCT ON (customer_id) customer_id, order_date, total_amount
FROM orders
ORDER BY customer_id, order_date DESC;
```

### 7. Klausul RETURNING (DML)
PostgreSQL memungkinkan perintah DML (`INSERT`, `UPDATE`, `DELETE`) mengembalikan hasil data yang baru saja diproses secara langsung:
```sql
-- Mengambil ID yang baru digenerate saat INSERT:
INSERT INTO customers (name, email)
VALUES ('Adit', 'adit@mail.com')
RETURNING id, created_at;

-- Mengambil data yang berhasil diupdate:
UPDATE products SET price = price * 1.1 WHERE category = 'Elektronik'
RETURNING id, name, price;
```

### 8. GROUPING SETS, CUBE & ROLLUP
Mendukung pelaporan dan agregasi multi-level dalam satu query tunggal:
```sql
SELECT department_id, job_id, SUM(salary)
FROM employees
GROUP BY GROUPING SETS (
    (department_id, job_id),
    (department_id),
    ()
);
```

### 9. Dukungan FULL OUTER JOIN
PostgreSQL mendukung penggabungan baris dari kedua sisi tabel meskipun tidak ada kecocokan data:
```sql
SELECT a.name, b.order_id
FROM customers a
FULL OUTER JOIN orders b ON a.id = b.customer_id;
```

### 10. Placeholder Parameter & Prepared Statement
PostgreSQL menggunakan positional placeholder berbasis angka (`$1`, `$2`, `$n`), bukan sekadar tanda tanya (`?`):
```sql
PREPARE get_employee_by_id (INT) AS
SELECT * FROM employees WHERE id = $1;

EXECUTE get_employee_by_id(101);
DEALLOCATE get_employee_by_id;
```

### 11. Date, Time & Built-in Functions
- Menggunakan standar SQL: `CURRENT_DATE`, `CURRENT_TIMESTAMP`, `LOCALTIMESTAMP`.
- Perhitungan rentang waktu menggunakan tipe data `interval`:
  ```sql
  SELECT CURRENT_TIMESTAMP + INTERVAL '7 days';
  ```

### 12. Strictness & Validasi Data
PostgreSQL sangat mematuhi tipe data secara ketat. Sebagai contoh, jika memasukkan string kosong `""` ke kolom bertipe numerik atau tanggal, PostgreSQL akan melempar *error*, berbeda dengan beberapa DBMS yang otomatis mengonversinya menjadi `0` atau tanggal default.

---

## 4. Tipe Data Lengkap di PostgreSQL

PostgreSQL terkenal memiliki koleksi tipe data bawaan paling komprehensif di antara seluruh RDBMS.

### Tipe Standar

| Kategori | Tipe Data | Keterangan & Contoh |
| :--- | :--- | :--- |
| **Numeric** | `smallint`, `integer`, `bigint` | Bilangan bulat 2, 4, dan 8 byte |
| | `decimal`, `numeric` | Bilangan presisi pasti (sangat cocok untuk uang/finansial) |
| | `real`, `double precision` | Bilangan pecahan mengambang (*floating point*) |
| **Character** | `varchar(n)`, `char(n)`, `text` | `text` di Postgres memiliki performa optimal tanpa batas panjang buatan |
| | `uuid` | Tipe data native untuk UUID 128-bit |
| **Date & Time** | `date`, `time`, `timestamp` | Tanggal dan waktu |
| | `timestamptz` ⭐ | Timestamp dengan informasi zona waktu (disarankan untuk aplikasi global) |
| | `interval` ⭐ | Rentang durasi waktu (contoh: `'3 months 2 days'`) |
| **Boolean** | `boolean` ⭐ | Tipe data boolean sejati (`TRUE`, `FALSE`, `NULL`), bukan integer tipuan |
| **Binary** | `bytea` | Data biner mentah (setara dengan `BLOB` di database lain) |
| **Enum** | `CREATE TYPE ... AS ENUM` | Tipe data enumerasi kustom terdaftar |

---

### Tipe Data Unggulan & Khusus PostgreSQL

Tipe-tipe data berikut menjadi pembeda utama kemampuan PostgreSQL dibandingkan database relasional lainnya:

1. **JSON & JSONB (`json`, `jsonb`) ⭐:**
   - `json`: Menyimpan teks JSON mentah (memerlukan re-parsing tiap dibaca).
   - `jsonb`: Menyimpan JSON dalam format biner yang sudah didekomposisi. Mendukung operasi pencarian cepat, pengindeksan dengan **GIN index**, dan operator seperti `?`, `@>`, `->`, `->>`.
2. **Array Types (`integer[]`, `text[]`, dll.) ⭐:**
   - Kolom dapat menyimpan koleksi data array satu dimensi atau multi dimensi secara langsung.
   - Contoh: `tags text[]` menyimpan `ARRAY['postgres', 'database', 'sql']`.
3. **Range Types (`int4range`, `numrange`, `tsrange`, `daterange`) ⭐:**
   - Menyimpan rentang nilai (misal: periode waktu sewa, batas rentang harga).
   - Mendukung pemeriksaan *overlapping* (tumpang tindih) secara native dengan operator `&&`.
4. **Network Address Types (`inet`, `cidr`, `macaddr`) ⭐:**
   - Menyimpan dan memvalidasi alamat IPv4, IPv6, subnet mask, dan MAC address.
   - Mendukung query pengecekan apakah suatu IP berada dalam subnet tertentu.
5. **Custom Composite Types & Domain ⭐:**
   - **Composite Type:** Membuat tipe data berstruktur objek sendiri:
     ```sql
     CREATE TYPE address_type AS (
         street VARCHAR(100),
         city VARCHAR(50),
         postal_code VARCHAR(10)
     );
     ```
   - **Domain:** Membuat tipe data primitif dengan validasi bawaan:
     ```sql
     CREATE DOMAIN positive_int AS INT CHECK (VALUE > 0);
     ```

---

## 5. Peta Modul Latihan di Repositori

Repositori ini disusun secara sistematis agar dapat dipelajari secara bertahap melalui file SQL dan dokumen konsep berikut:

### 📖 Dokumen Konsep & Teori
- [acid.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid.md) — Penjelasan prinsip **ACID** (*Atomicity, Consistency, Isolation, Durability*) dalam transaksi database.
- [normalisasi.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/normalisasi.md) — Panduan normalisasi basis data dari **1NF, 2NF, hingga 3NF** beserta contoh solusinya.
- [denormalisasi.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/denormalisasi.md) — Strategi denormalisasi data untuk optimasi performa *read-heavy*.

### 💻 Praktik SQL & Latihan
- [migration/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/migration) — Skrip pembuatan skema basis data awal (`v1__schema_hr.sql`).
- [data-definition/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/data-definition) — Pembelajaran DDL (`CREATE DATABASE`, `CREATE USER`, `CREATE INDEX`).
- [data-manipulation/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/data-manipulation) — Operasi DML dasar, `INSERT`, `UPDATE`, `DELETE`, *Prepared Statement*, dan latihan manipulasi data.
- [select/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/select) — Query pengambilan data: operator, fungsi bawaan, klausa `WHERE`, `ORDER BY`, `LIMIT/OFFSET`, agregasi, `JOIN`, `SUBQUERY`, conditional expression (`CASE`), `WITH` query (CTE), hingga latihan query kompleks.
- [transaction-control/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/transaction-control) — Perintah kontrol transaksi TCL (`COMMIT`, `ROLLBACK`, `SAVEPOINT`).
- [acid/](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid) — Simulasi skrip pengujian karakteristik ACID secara langsung di PostgreSQL.
