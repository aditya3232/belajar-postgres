# Panduan Denormalisasi Basis Data Relasional

Dokumen ini membahas strategi dan metodologi **Denormalisasi Basis Data**, motivasi di balik trade-off performa pembacaan data (*Read-Optimized*) versus penulisan (*Write-Optimized*), teknik-teknik implementasi di **PostgreSQL**, pengelolaan tabel *Immutable* vs *Mutable*, serta cara menjaga konsistensi data redundan.

---

## Daftar Isi
1. [Pengantar & Filosofi Denormalisasi](#1-pengantar--filosofi-denormalisasi)
   - [Definisi Denormalisasi](#definisi-denormalisasi)
   - [Trade-off: Read vs Write](#trade-off-read-vs-write)
   - [Risiko yang Harus Dimitigasi](#risiko-yang-harus-dimitigasi)
2. [Pola & Teknik Strategis Denormalisasi](#2-pola--teknik-strategis-denormalisasi)
   - [Teknik 1: Menyimpan Atribut Turunan (Derived Columns)](#teknik-1-menyimpan-atribut-turunan-derived-columns)
   - [Teknik 2: Duplikasi Atribut untuk Menghilangkan JOIN (Pre-joined Columns)](#teknik-2-duplikasi-atribut-untuk-menghilangkan-join-pre-joined-columns)
   - [Teknik 3: Tabel Agregasi & Materialized Views](#teknik-3-tabel-agregasi--materialized-views)
   - [Teknik 4: Atribut Pencarian / Filter Khusus](#teknik-4-atribut-pencarian--filter-khusus)
   - [Teknik 5: Kolom Semi-Terstruktur (JSONB) sebagai Alternatif EAV](#teknik-5-kolom-semi-terstruktur-jsonb-sebagai-alternatif-eav)
   - [Teknik 6: Partisi Tabel Vertikal & Horizontal](#teknik-6-partisi-tabel-vertikal--horizontal)
3. [Klasifikasi Tabel: Immutable vs Mutable](#3-klasifikasi-tabel-immutable-vs-mutable)
   - [Tabel Immutable (Append-Only)](#tabel-immutable-append-only)
   - [Tabel Mutable (Dinamis & Sering Diubah)](#tabel-mutable-dinamis--sering-diubah)
   - [Tabel Perbandingan](#tabel-perbandingan-immutable-vs-mutable)
4. [Strategi Menjaga Konsistensi Data Redundan](#4-strategi-menjaga-konsistensi-data-redundan)
   - [1. Database Trigger](#1-database-trigger-di-postgresql)
   - [2. Event-Driven / Application Layer (CQRS)](#2-arsitektur-event-driven--cqrs-di-level-aplikasi)
   - [3. Batch / Scheduled Synchronization](#3-sinkronisasi-periodik-scheduled-batch)
5. [Matriks Pengambilan Keputusan (Kapan Harus Denormalisasi?)](#5-matriks-pengambilan-keputusan-kapan-harus-denormalisasi)
6. [Hubungan dengan Dokumen Lain](#6-hubungan-dengan-dokumen-lain)

---

## 1. Pengantar & Filosofi Denormalisasi

### Definisi Denormalisasi
**Denormalisasi** adalah proses optimasi basis data di mana kita **sengaja memasukkan redundansi data atau melanggar kaidah normalisasi (seperti 2NF atau 3NF)** ke dalam skema fisik basis data demi meningkatkan performa pembacaan query (*read performance*).

Normalisasi adalah langkah awal wajib untuk merancang model data yang benar, sedangkan denormalisasi adalah langkah optimasi lanjutan berdasarkan profil beban kerja aplikasi (*workload pattern*).

```
[ Model Konseptual ] ──➔ [ Normalisasi (3NF / BCNF) ] ──➔ [ Analisis Bottleneck ] ──➔ [ Denormalisasi Selektif ]
                          (Menjamin integritas data)       (Beban query tinggi)         (Optimasi performa read)
```

---

### Trade-off: Read vs Write
Setiap keputusan denormalisasi merupakan kompromi teknik:

| Aspek | Normalisasi Penuh (3NF) | Denormalisasi |
| :--- | :--- | :--- |
| **Kecepatan Baca (`SELECT`)** | Lebih lambat karena membutuhkan banyak operasi `JOIN` | **Sangat cepat**, data siap saji dalam satu baris/tabel |
| **Kecepatan Tulis (`INSERT`/`UPDATE`)** | **Cepat & Efisien**, perubahan hanya di satu baris | Lebih lambat, harus memperbarui salinan data di banyak tempat |
| **Konsistensi Data** | Terjamin oleh integritas relasional & constraint | Memerlukan mekanisme ekstra agar data salinan tidak basi/inkonsisten |
| **Ukuran Disk (Storage)** | Minimal (tidak ada duplikasi informasi) | Membutuhkan kapasitas penyimpanan lebih besar |

---

### Risiko yang Harus Dimitigasi
1. **Inkonsistensi Data:** Salinan data di tabel A diperbarui, namun salinan di tabel B tertinggal.
2. **Write Overhead:** Satu aksi pengguna di aplikasi memicu serangkaian update pada tabel redundan dan indeks terkait.
3. **Kompleksitas Kode:** Logika aplikasi atau skrip trigger menjadi lebih rumit untuk menjaga sinkronisasi data.

---

## 2. Pola & Teknik Strategis Denormalisasi

### Teknik 1: Menyimpan Atribut Turunan (Derived Columns)
Atribut turunan adalah data yang nilainya dapat dihitung dari atribut lain (misalnya: `subtotal = price * quantity` atau `total_bayar = subtotal - diskon + ongkir`).

#### Masalah pada Normalisasi:
Setiap kali data diambil, sistem harus menghitung ulang ekspresi matematika tersebut untuk ribuan baris:
```sql
SELECT id, price * quantity AS subtotal FROM order_items;
```

#### Solusi Denormalisasi:
Simpan hasil komputasi langsung sebagai kolom di tabel.

**Pendekatan Modern di PostgreSQL: Generated Columns**
Sejak PostgreSQL 12, kita dapat menggunakan fitur native `GENERATED ALWAYS AS (...) STORED`:
```sql
CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    -- Kolom turunan yang dihitung dan disimpan otomatis oleh PostgreSQL:
    subtotal NUMERIC(12, 2) GENERATED ALWAYS AS (price * quantity) STORED,
    PRIMARY KEY (order_id, product_id)
);
```
> [!TIP]
> Dengan *stored generated column*, PostgreSQL secara otomatis mengupdate nilai `subtotal` setiap kali `price` atau `quantity` berubah, sehingga bebas dari risiko inkonsistensi!

---

### Teknik 2: Duplikasi Atribut untuk Menghilangkan JOIN (Pre-joined Columns)
Dalam sistem e-commerce, daftar pesanan pelanggan sangat sering diakses. Menampilkan nama pelanggan pada setiap baris order membutuhkan operasi `JOIN` ke tabel pelanggan.

#### Skema Normalisasi (3NF):
- Tabel `orders`: `(order_id, customer_id, order_date)`
- Tabel `customers`: `(customer_id, customer_name, customer_email)`

Untuk menampilkan daftar riwayat order:
```sql
SELECT o.order_id, o.order_date, c.customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

#### Solusi Denormalisasi:
Salin kolom `customer_name` langsung ke tabel `orders`:

**Tabel `orders` (Didenormalisasi):**

| order_id | order_date | customer_id | customer_name |
| :--- | :--- | :--- | :--- |
| O-001 | 2026-03-01 | C-01 | Adit |
| O-002 | 2026-03-02 | C-01 | Adit |

Query pembacaan menjadi tanpa `JOIN`:
```sql
SELECT order_id, order_date, customer_name FROM orders;
```

---

### Teknik 3: Tabel Agregasi & Materialized Views
Menghitung agregasi data besar secara real-time (`COUNT`, `SUM`, `AVG`) pada tabel transaksi jutaan baris dapat melumpuhkan kinerja database.

#### Contoh Masalah:
Dashboard admin membutuhkan statistik penjualan bulanan per toko:
```sql
-- Query berat: Membaca jutaan baris setiap reload halaman
SELECT customer_id, COUNT(*) AS total_order, SUM(total_amount) AS total_belanja
FROM orders
GROUP BY customer_id;
```

#### Solusi Denormalisasi 1: Summary Table Manual
Membuat tabel ringkasan `customer_order_summary` yang diperbarui setiap kali terjadi transaksi baru.

#### Solusi Denormalisasi 2 (PostgreSQL Native): Materialized View
PostgreSQL menyediakan fitur **Materialized View** yang menyimpan hasil query kompleks secara fisik di disk dan dapat di-*refresh* secara terjadwal:

```sql
-- Membuat Materialized View
CREATE MATERIALIZED VIEW mv_customer_summary AS
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spending
FROM orders
GROUP BY customer_id;

-- Membuat index unik untuk mendukung refresh tanpa mengunci pembacaan
CREATE UNIQUE INDEX idx_mv_customer_summary ON mv_customer_summary (customer_id);

-- Refresh data secara berkala (tanpa memblokir query SELECT yang sedang berjalan)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_customer_summary;
```

---

### Teknik 4: Atribut Pencarian / Filter Khusus
Jika kita sering melakukan filter pencarian berdasarkan nama kategori produk atau nama pelanggan di tabel pesanan:
```sql
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE c.customer_name ILIKE '%Adit%';
```
Dengan menduplikasi kolom `customer_name` ke tabel `orders` dan membuat indeks di kolom tersebut (`CREATE INDEX idx_orders_customer_name ON orders(customer_name);`), pencarian teks dapat dilakukan langsung pada tabel utama dengan latensi minimal.

---

### Teknik 5: Kolom Semi-Terstruktur (JSONB) sebagai Alternatif EAV
Dalam model relasional tradisional, jika suatu entitas produk memiliki ratusan atribut variatif (misal: pakaian memiliki *ukuran/warna*, laptop memiliki *RAM/prosesor/GPU*), normalisasi murni sering kali menggunakan pola **EAV (Entity-Attribute-Value)**:
- `products` (id, name)
- `attributes` (id, attribute_name)
- `product_attribute_values` (product_id, attribute_id, value)

> [!WARNING]
> Pola EAV membutuhkan belasan operasi `JOIN` hanya untuk menampilkan spesifikasi satu buah produk.

#### Solusi Denormalisasi di PostgreSQL: Kolom `JSONB`
Simpan seluruh atribut dinamis langsung dalam satu kolom berformat binary JSON:

```sql
CREATE TABLE products (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    specifications JSONB -- Menyimpan spesifikasi dinamis
);

-- Contoh Insert Data:
INSERT INTO products (id, name, price, specifications)
VALUES (
    'P-01',
    'Laptop Gaming',
    15000000,
    '{"ram": "16GB", "storage": "512GB SSD", "gpu": "RTX 4060"}'::jsonb
);

-- Query pencarian sangat cepat dengan GIN Index:
CREATE INDEX idx_products_specs ON products USING GIN (specifications);

SELECT * FROM products WHERE specifications @> '{"ram": "16GB"}';
```

---

### Teknik 6: Partisi Tabel Vertikal & Horizontal

#### 1. Pemisahan Vertikal (Vertical Partitioning)
Memecah satu tabel menjadi dua berdasarkan frekuensi akses kolom:
- **Tabel Inti (Sering Diakses):** `users (id, username, email, password_hash)`
- **Tabel Profil (Jarang Diakses):** `user_profiles (user_id, bio, avatar_blob, full_address, preferences)`
Hal ini membuat *cache memory* (shared buffers) PostgreSQL dapat menampung lebih banyak baris data inti.

#### 2. Pemisahan Horizontal (Partitioning by Range/List)
Membagi baris tabel besar ke beberapa sub-tabel fisik berdasarkan kriteria waktu (misal partisi per tahun):
```sql
CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    action VARCHAR(50),
    created_at TIMESTAMP NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE audit_logs_2025 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE audit_logs_2026 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
```

---

## 3. Klasifikasi Tabel: Immutable vs Mutable

Risiko denormalisasi sangat bergantung pada sifat data dalam tabel:

```
                            Karakteristik Data
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                       ▼
       Tabel Immutable (Aman)                  Tabel Mutable (Berisiko)
  • Append-Only (Hanya INSERT)           • Data dinamis (INSERT, UPDATE, DELETE)
  • Data snapshot historis               • Menyimpan master entitas saat ini
  • Denormalisasi sangat disarankan      • Perlu sinkronisasi & proteksi ketat
```

### Tabel Immutable (Append-Only)
- **Karakteristik:** Begitu data ditulis, data tidak akan pernah diubah atau dihapus (misalnya: transaksi penjualan yang sudah selesai, log audit, riwayat pembayaran).
- **Denormalisasi:** **Sangat aman dan sangat disarankan**.
- **Alasan Bisnis:** Ketika pelanggan Adit melakukan pemesanan pada 1 Maret 2026, kita justru **wajib membekukan snapshot nama, alamat kirim, dan harga produk** pada saat transaksi tersebut terjadi. Jika 6 bulan kemudian harga produk naik atau nama pelanggan berubah, struk transaksi masa lalu tidak boleh ikut berubah.

### Tabel Mutable (Dinamis & Sering Diubah)
- **Karakteristik:** Data aktif yang terus diperbarui (misalnya: saldo rekening, stok barang gudang, status akun pengguna).
- **Denormalisasi:** **Berisiko tinggi terhadap inkonsistensi**.
- Jika `user_status` diduplikasi di 5 tabel berbeda, setiap pembaruan status harus menjamin kelima tabel tersebut ikut terupdate secara atomik.

### Tabel Perbandingan Immutable vs Mutable

| Parameter | Tabel Immutable | Tabel Mutable |
| :--- | :--- | :--- |
| **Operasi Dominan** | `INSERT`, `SELECT` (Write-once, Read-many) | `SELECT`, `UPDATE`, `DELETE` |
| **Contoh Entitas** | `order_history`, `audit_logs`, `invoices` | `customers`, `products`, `accounts` |
| **Tingkat Keamanan Denormalisasi** | Sangat Aman & Direkomendasikan | Berisiko Tinggi |
| **Biaya Menjaga Konsistensi** | Nol (tidak ada update ke data lama) | Tinggi (butuh locking / trigger / transaksi) |

---

## 4. Strategi Menjaga Konsistensi Data Redundan

Jika Anda memutuskan menduplikasi data pada tabel *mutable*, gunakan salah satu strategi berikut untuk menjaga keabsahan data:

### 1. Database Trigger di PostgreSQL
Gunakan trigger untuk memperbarui data salinan secara otomatis di dalam satu transaksi database:

```sql
CREATE OR REPLACE FUNCTION sync_customer_name()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET customer_name = NEW.name
    WHERE customer_id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_customer_name
AFTER UPDATE OF name ON customers
FOR EACH ROW
EXECUTE FUNCTION sync_customer_name();
```

### 2. Arsitektur Event-Driven / CQRS di Level Aplikasi
Pada arsitektur microservices modern:
1. Layanan *Write* memproses perintah dan menerbitkan pesan event (misal: `CustomerNameUpdated`).
2. Layanan *Read* mengonsumsi event dan memperbarui model baca (*read model / query store*) yang telah didenormalisasi secara asinkron.

### 3. Sinkronisasi Periodik (Scheduled Batch)
Untuk data agregasi statistik atau laporan yang tidak membutuhkan ketelitian detik (misal ringkasan mingguan):
- Buat cron job atau scheduler PostgreSQL (`pg_cron`) untuk me-refresh data secara berkala:
  ```sql
  SELECT cron.schedule('0 2 * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_customer_summary');
  ```

---

## 5. Matriks Pengambilan Keputusan (Kapan Harus Denormalisasi?)

Gunakan checklist berikut sebelum memutuskan melakukan denormalisasi:

- [ ] **Apakah sudah mengukur performa?** Jangan lakukan *premature optimization*. Pastikan query lambat memang disebabkan oleh overhead `JOIN`, bukan karena ketiadaan indeks atau query yang tidak efisien.
- [ ] **Berapa rasio Read vs Write?** Denormalisasi ideal untuk sistem dengan rasio baca jauh lebih tinggi daripada tulis (misalnya 95% Read : 5% Write).
- [ ] **Apakah datanya Immutable?** Jika data bersifat historis/snapshot transaksi, lakukan denormalisasi tanpa ragu.
- [ ] **Apakah bisnis menoleransi inkonsistensi sesaat?** Jika data ringkasan analitik boleh tertinggal beberapa menit (*eventual consistency*), denormalisasi dengan *Materialized View* adalah pilihan tepat.
- [ ] **Apakah sistem sanggup menanggung biaya pembaruan?** Pastikan overhead transaksi tulis ekstra tidak menurunkan performa aplikasi secara keseluruhan.

---

## 6. Hubungan dengan Dokumen Lain

- [normalisasi.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/normalisasi.md) — Pelajari tahapan normalisasi 1NF, 2NF, hingga 3NF/BCNF sebagai landasan perancangan skema relasional yang benar.
- [acid.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid.md) — Pahami bagaimana kepatuhan ACID (terutama *Consistency* dan *Isolation*) melindungi transaksi dari anomali data.
- [README.md](file:///home/xylo/Documents/adit/devbox/belajar-postgres/README.md) — Panduan lengkap fitur PostgreSQL, tipe data JSONB, dan direktori modul latihan SQL.
