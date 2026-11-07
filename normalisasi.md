# Panduan Normalisasi Basis Data Relasional

Dokumen ini membahas prinsip dan metodologi **Normalisasi Basis Data**, anomali data yang ingin dihindari, jenis-jenis ketergantungan fungsional (*functional dependency*), serta tahapan normalisasi dari **UNF hingga 3NF/BCNF** lengkap dengan studi kasus dan skema DDL di **PostgreSQL**.

---

## Daftar Isi
1. [Pengantar & Tujuan Normalisasi](#1-pengantar--tujuan-normalisasi)
2. [Anomali Data: Mengapa Normalisasi Dibutuhkan?](#2-anomali-data-mengapa-normalisasi-dibutuhkan)
   - [Insert Anomaly (Anomali Penyisipan)](#insert-anomaly-anomali-penyisipan)
   - [Update Anomaly (Anomali Pembaruan)](#update-anomaly-anomali-pembaruan)
   - [Delete Anomaly (Anomali Penghapusan)](#delete-anomaly-anomali-penghapusan)
3. [Konsep Ketergantungan Fungsional (Functional Dependency)](#3-konsep-ketergantungan-fungsional-functional-dependency)
   - [Full Functional Dependency](#1-full-functional-dependency-ketergantungan-penuh)
   - [Partial Dependency](#2-partial-dependency-ketergantungan-sebagian)
   - [Transitive Dependency](#3-transitive-dependency-ketergantungan-transitif)
4. [Tahapan Bentuk Normal (Normal Forms)](#4-tahapan-bentuk-normal-normal-forms)
   - [1NF (First Normal Form)](#1nf-first-normal-form)
   - [2NF (Second Normal Form)](#2nf-second-normal-form)
   - [3NF (Third Normal Form)](#3nf-third-normal-form)
   - [BCNF (Boyce-Codd Normal Form)](#bcnf-boyce-codd-normal-form)
5. [Studi Kasus Lengkap: Normalisasi Data Transaksi Penjualan](#5-studi-kasus-lengkap-normalisasi-data-transaksi-penjualan)
   - [Tahap 0: Unnormalized Form (UNF)](#tahap-0-unnormalized-form-unf)
   - [Tahap 1: Transformasi ke 1NF](#tahap-1-transformasi-ke-1nf)
   - [Tahap 2: Transformasi ke 2NF](#tahap-2-transformasi-ke-2nf)
   - [Tahap 3: Transformasi ke 3NF](#tahap-3-transformasi-ke-3nf)
   - [Implementasi DDL PostgreSQL Hasil Normalisasi](#implementasi-ddl-postgresql-hasil-normalisasi)
6. [Kapan Harus Berhenti Normalisasi?](#6-kapan-harus-berhenti-normalisasi)
7. [Hubungan Normalisasi dengan Denormalisasi](#7-hubungan-normalisasi-dengan-denormalisasi)

---

## 1. Pengantar & Tujuan Normalisasi

**Normalisasi Basis Data** adalah proses pengorganisasian data ke dalam tabel-tabel terstruktur guna:
1. **Mengurangi redundansi (duplikasi) data:** Mencegah informasi yang sama disimpan berulang kali di banyak baris.
2. **Mencegah anomali data:** Menghindari inkonsistensi saat operasi penambahan (*insert*), pengubahan (*update*), atau penghapusan (*delete*).
3. **Menjaga integritas data:** Memastikan ketergantungan antar kolom logis dan diproteksi oleh *Foreign Key*.

Proses normalisasi dilakukan secara bertahap melalui serangkaian aturan yang disebut **Bentuk Normal (*Normal Forms*)**.

---

## 2. Anomali Data: Mengapa Normalisasi Dibutuhkan?

Jika basis data dirancang secara asal (misalnya semua data faktur, pelanggan, dan barang ditumpuk dalam satu tabel raksasa), sistem akan mengalami 3 jenis anomali data:

```
+---------------------------------------------------------------------------------------------------+
| order_id | customer_id | customer_name | customer_city | product_id | product_name | price | qty  |
+---------------------------------------------------------------------------------------------------+
| O-101    | C-001       | Adit          | Jakarta       | P-01       | Laptop       | 10jt  | 1    |
| O-101    | C-001       | Adit          | Jakarta       | P-02       | Mouse        | 200rb | 2    |
| O-102    | C-002       | Budi          | Bandung       | P-01       | Laptop       | 10jt  | 1    |
+---------------------------------------------------------------------------------------------------+
```

### Insert Anomaly (Anomali Penyisipan)
Kondisi di mana kita **tidak bisa memasukkan data entitas tertentu** sebelum entitas lain ada.
- *Contoh:* Toko memiliki produk baru (misal `P-03: Keyboard`), tetapi belum ada pesanan sama sekali. Karena `order_id` adalah bagian dari Primary Key, kita tidak bisa menyimpan produk tersebut tanpa mengisi kolom order dengan nilai dummy atau NULL.

### Update Anomaly (Anomali Pembaruan)
Kondisi di mana perubahan pada satu nilai **harus dilakukan pada banyak baris sekaligus**.
- *Contoh:* Jika pelanggan Adit (`C-001`) pindah alamat dari `Jakarta` ke `Surabaya`, kita harus memperbarui seluruh baris transaksi milik Adit. Jika ada satu baris terlewat karena kegagalan jaringan atau aplikasi, data kota pelanggan menjadi tidak konsisten.

### Delete Anomaly (Anomali Penghapusan)
Kondisi di mana penghapusan satu fakta **tanpa sengaja ikut menghapus fakta penting lainnya**.
- *Contoh:* Jika pelanggan Budi (`C-002`) membatalkan pesanan `O-102` dan baris tersebut dihapus, informasi bahwa ada pelanggan bernama Budi yang bertempat tinggal di Bandung ikut lenyap dari sistem.

---

## 3. Konsep Ketergantungan Fungsional (Functional Dependency)

Ketergantungan fungsional dinotasikan dengan simbol panah:
$$X \rightarrow Y$$
Artinya: **Nilai atribut $X$ menentukan secara tunggal nilai atribut $Y$** ($Y$ secara fungsional bergantung pada $X$).

### 1. Full Functional Dependency (Ketergantungan Penuh)
Atribut non-key $Y$ bergantung sepenuhnya pada seluruh atribut kunci penentu ($X$), bukan hanya pada sebagian atribut pembentuk kunci.
- Misal Primary Key gabungan (*Composite Key*) adalah `(order_id, product_id)`.
- Kolom `quantity` bergantung penuh pada `(order_id, product_id)` karena jumlah barang hanya spesifik untuk produk tersebut di dalam pesanan tersebut.

### 2. Partial Dependency (Ketergantungan Sebagian)
Atribut non-key bergantung hanya pada **sebagian** dari Primary Key komposit.
- Primary Key: `(order_id, product_id)`.
- Kolom `product_name` hanya bergantung pada `product_id`, tidak bergantung pada `order_id`.
- Keberadaan *Partial Dependency* melanggar syarat **2NF**.

### 3. Transitive Dependency (Ketergantungan Transitif)
Atribut non-key $Z$ bergantung pada atribut non-key $Y$, di mana $Y$ bergantung pada Primary Key $X$:
$$X \rightarrow Y \quad \text{dan} \quad Y \rightarrow Z \implies X \rightarrow Z$$
- Primary Key: `order_id`.
- `order_id` $\rightarrow$ `customer_id`.
- `customer_id` $\rightarrow$ `customer_city`.
- `customer_city` secara transitif bergantung pada `order_id` melalui `customer_id`.
- Keberadaan *Transitive Dependency* melanggar syarat **3NF**.

---

## 4. Tahapan Bentuk Normal (Normal Forms)

```
[ Data Mentah / UNF ]
         │
         ▼ (Hilangkan multi-value, grup berulang & atribut turunan; tentukan PK)
      [ 1NF ]
         │
         ▼ (Hilangkan Partial Dependency pada composite key)
      [ 2NF ]
         │
         ▼ (Hilangkan Transitive Dependency antar atribut non-key)
      [ 3NF ]
         │
         ▼ (Pastikan setiap determinan adalah Candidate Key)
      [ BCNF ]
```

### 1NF (First Normal Form)
Sebuah tabel memenuhi 1NF jika:
1. **Nilai setiap sel bersifat atomik** (tidak ada *multi-value attribute* seperti menyimpan daftar hobi `'membaca, berenang'` atau daftar barang dalam satu baris).
2. **Tidak ada grup berulang (*repeating groups*)**, misalnya kolom `item1`, `item2`, `item3`.
3. **Setiap kolom memiliki nama unik** dan setiap baris memiliki identitas unik (*Primary Key*).
4. **Tidak menyimpan atribut turunan (*derived attributes*)** yang bisa dihitung dari kolom lain (misalnya kolom `total_harga = harga * qty`).

### 2NF (Second Normal Form)
Sebuah tabel memenuhi 2NF jika:
1. Sudah memenuhi **1NF**.
2. **Tidak ada Partial Dependency**: Seluruh atribut non-key harus bergantung secara penuh pada seluruh Primary Key.
   > [!NOTE]
   > Jika tabel hanya memiliki **single-column Primary Key** (bukan composite key) dan sudah memenuhi 1NF, maka tabel tersebut otomatis sudah memenuhi 2NF.

### 3NF (Third Normal Form)
Sebuah tabel memenuhi 3NF jika:
1. Sudah memenuhi **2NF**.
2. **Tidak ada Transitive Dependency**: Atribut non-key tidak boleh bergantung pada atribut non-key lainnya. Semua atribut non-key harus bergantung **langsung dan hanya** pada Primary Key.

### BCNF (Boyce-Codd Normal Form)
Bentuk penguatan dari 3NF. Sebuah relasi memenuhi BCNF jika untuk setiap ketergantungan fungsional $X \rightarrow Y$, maka $X$ adalah **Super Key / Candidate Key**. Kasus pelanggaran BCNF biasanya terjadi jika sebuah tabel memiliki beberapa *overlapping candidate keys*.

---

## 5. Studi Kasus Lengkap: Normalisasi Data Transaksi Penjualan

Mari kita lakukan proses normalisasi dari format dokumen struk/faktur transaksi penjualan hingga menjadi skema basis data relasional.

### Tahap 0: Unnormalized Form (UNF)
Pada format mentah, data pesanan dan barang disimpan dalam satu baris dengan nilai berulang:

| order_id | order_date | customer_id | customer_name | customer_city | items (nama, harga, qty) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| O-001 | 2026-03-01 | C-01 | Adit | Jakarta | [Laptop, 10.000.000, 1], [Mouse, 200.000, 2] |
| O-002 | 2026-03-02 | C-02 | Budi | Bandung | [Laptop, 10.000.000, 1] |

---

### Tahap 1: Transformasi ke 1NF
Langkah:
- Pisahkan nilai kolom `items` yang majemuk menjadi baris-baris individual (atomik).
- Buat Primary Key komposit: `(order_id, product_id)`.
- Hapus atribut turunan seperti `subtotal`.

**Tabel Penjualan (1NF):**

| order_id (PK) | product_id (PK) | order_date | customer_id | customer_name | customer_city | product_name | price | qty |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| O-001 | P-01 | 2026-03-01 | C-01 | Adit | Jakarta | Laptop | 10.000.000 | 1 |
| O-001 | P-02 | 2026-03-01 | C-01 | Adit | Jakarta | Mouse | 200.000 | 2 |
| O-002 | P-01 | 2026-03-02 | C-02 | Budi | Bandung | Laptop | 10.000.000 | 1 |

*Evaluasi 1NF:*
- `product_name` dan `price` hanya bergantung pada `product_id` (sebagian dari PK).
- `order_date`, `customer_id`, `customer_name`, `customer_city` hanya bergantung pada `order_id` (sebagian dari PK).
- Terdapat **Partial Dependency**! Harus dipecah ke 2NF.

---

### Tahap 2: Transformasi ke 2NF
Langkah:
- Pisahkan entitas yang bergantung pada sebagian kunci ke tabel terpisah:
  1. `orders`: Bergantung penuh pada `order_id`.
  2. `products`: Bergantung penuh pada `product_id`.
  3. `order_items`: Bergantung penuh pada gabungan `(order_id, product_id)`.

**Tabel `order_items` (2NF):**
*Primary Key: `(order_id, product_id)`*

| order_id | product_id | qty |
| :--- | :--- | :--- |
| O-001 | P-01 | 1 |
| O-001 | P-02 | 2 |
| O-002 | P-01 | 1 |

**Tabel `products` (2NF):**
*Primary Key: `product_id`*

| product_id | product_name | price |
| :--- | :--- | :--- |
| P-01 | Laptop | 10.000.000 |
| P-02 | Mouse | 200.000 |

**Tabel `orders` (2NF):**
*Primary Key: `order_id`*

| order_id | order_date | customer_id | customer_name | customer_city |
| :--- | :--- | :--- | :--- | :--- |
| O-001 | 2026-03-01 | C-01 | Adit | Jakarta |
| O-002 | 2026-03-02 | C-02 | Budi | Bandung |

*Evaluasi 2NF:*
- Tabel `order_items` dan `products` sudah bersih dari ketergantungan parsial dan transitif.
- Namun, pada tabel `orders`, terdapat:
  `order_id` $\rightarrow$ `customer_id` $\rightarrow$ (`customer_name`, `customer_city`).
- Kolom `customer_name` dan `customer_city` bukan atribut asli dari transaksi order, melainkan atribut dari customer. Ini adalah **Transitive Dependency**!

---

### Tahap 3: Transformasi ke 3NF
Langkah:
- Pisahkan data pelanggan ke tabel `customers` tersendiri.
- Tabel `orders` cukup menyimpan `customer_id` sebagai **Foreign Key**.

**Tabel `customers` (3NF):**
*Primary Key: `customer_id`*

| customer_id | customer_name | customer_city |
| :--- | :--- | :--- |
| C-01 | Adit | Jakarta |
| C-02 | Budi | Bandung |

**Tabel `orders` (3NF):**
*Primary Key: `order_id`, Foreign Key: `customer_id`*

| order_id | order_date | customer_id |
| :--- | :--- | :--- |
| O-001 | 2026-03-01 | C-01 |
| O-002 | 2026-03-02 | C-02 |

**Tabel `products` (3NF):**
*Primary Key: `product_id`*

| product_id | product_name | price |
| :--- | :--- | :--- |
| P-01 | Laptop | 10.000.000 |
| P-02 | Mouse | 200.000 |

**Tabel `order_items` (3NF):**
*Primary Key: `(order_id, product_id)`, Foreign Key: `order_id`, `product_id`*

| order_id | product_id | qty |
| :--- | :--- | :--- |
| O-001 | P-01 | 1 |
| O-001 | P-02 | 2 |
| O-002 | P-01 | 1 |

---

### Implementasi DDL PostgreSQL Hasil Normalisasi

Berikut adalah skrip SQL standar PostgreSQL untuk merepresentasikan hasil normalisasi 3NF di atas:

```sql
-- 1. Tabel Pelanggan
CREATE TABLE customers (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- 2. Tabel Produk
CREATE TABLE products (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0)
);

-- 3. Tabel Pesanan (Orders)
CREATE TABLE orders (
    id VARCHAR(50) PRIMARY KEY,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_id VARCHAR(50) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 4. Tabel Detail Pesanan (Order Items)
CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products (id)
        ON DELETE RESTRICT
);
```

---

## 6. Kapan Harus Berhenti Normalisasi?

Dalam industri rekayasa perangkat lunak dan arsitektur database:
- **Tingkat 3NF / BCNF adalah standar industri umum** untuk sebagian besar sistem OLTP (*Online Transaction Processing*).
- Normalisasi ke tingkat yang lebih tinggi (4NF dan 5NF) jarang dibutuhkan dalam aplikasi web/bisnis praktis karena skenarionya spesifik (*multi-valued dependency* dan *join dependency*) dan dapat membuat arsitektur query terlalu kompleks.

---

## 7. Hubungan Normalisasi dengan Denormalisasi

Normalisasi berfokus pada **integritas data dan efisiensi penyimpanan (*Write-Optimized*)**, sedangkan Denormalisasi sengaja melanggar beberapa kaidah normalisasi demi **kecepatan pembacaan query (*Read-Optimized*)**.

| Kriteria | Normalisasi (3NF) | Denormalisasi |
| :--- | :--- | :--- |
| **Tujuan Utama** | Mencegah anomali & redundansi | Mempercepat pembacaan data (minimalkan `JOIN`) |
| **Operasi `INSERT` / `UPDATE`** | Cepat (cukup update di 1 tempat) | Lebih lambat (harus update di banyak baris/tabel) |
| **Operasi `SELECT`** | Butuh `JOIN` antar tabel | Sederhana & sangat cepat |
| **Penyimpanan (Storage)** | Hemat ruang disk | Menggunakan lebih banyak ruang disk |
| **Cocok Untuk** | Sistem OLTP, perbankan, CRM, ERP | Sistem OLAP, laporan analitik, Read-heavy dashboard |

Untuk panduan lengkap mengenai teknik dan strategi melakukan denormalisasi secara aman, pelajari dokumen [denormalisasi.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/denormalisasi.md).
