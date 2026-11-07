# Panduan Transaksi Basis Data: ACID Compliance di PostgreSQL

Dokumen ini membahas secara mendalam prinsip **ACID** (*Atomicity, Consistency, Isolation, Durability*) dalam sistem manajemen basis data relasional, mekanisme internal PostgreSQL dalam menjamin integritas data, serta panduan praktis implementasinya.

---

## Daftar Isi
1. [Pengantar Transaksi & Filosofi ACID](#1-pengantar-transaksi--filosofi-acid)
2. [Pilar 1: Atomicity (Semua atau Tidak Sama Sekali)](#2-pilar-1-atomicity-semua-atau-tidak-sama-sekali)
   - [Konsep & Skenario Masalah](#konsep--skenario-masalah-atomicity)
   - [Implementasi di PostgreSQL: Transaksi & Savepoint](#implementasi-di-postgresql-transaksi--savepoint)
3. [Pilar 2: Consistency (Integritas Kondisi Data)](#3-pilar-2-consistency-integritas-kondisi-data)
   - [Konsep State Invariant](#konsep-state-invariant)
   - [Penegakan Konsistensi: Database vs Aplikasi](#penegakan-konsistensi-database-vs-aplikasi)
   - [Fitur Penjaga Konsistensi di PostgreSQL](#fitur-penjaga-konsistensi-di-postgresql)
4. [Pilar 3: Isolation (Isolasi Eksekusi Konkuren)](#4-pilar-3-isolation-isolasi-eksekusi-konkuren)
   - [Anomali Pembacaan Data Konkuren](#anomali-pembacaan-data-konkuren)
   - [Tingkat Isolasi Transaksi (Isolation Levels)](#tingkat-isolasi-transaksi-isolation-levels)
   - [MVCC vs Explicit Locking (`FOR UPDATE`)](#mvcc-vs-explicit-locking-for-update)
5. [Pilar 4: Durability (Ketahanan & Permanensi Data)](#5-pilar-4-durability-ketahanan--permanensi-data)
   - [Konsep Crash Recovery](#konsep-crash-recovery)
   - [Mekanisme Internal: Write-Ahead Logging (WAL)](#mekanisme-internal-write-ahead-logging-wal)
   - [Trade-off Performa vs Durabilitas](#trade-off-performa-vs-durabilitas)
6. [Tabel Rangkuman ACID di PostgreSQL](#6-tabel-rangkuman-acid-di-postgresql)
7. [Panduan Praktik Modul `acid/`](#7-panduan-praktik-modul-acid)

---

## 1. Pengantar Transaksi & Filosofi ACID

Dalam basis data, **Transaksi** adalah satu kesatuan logis dari pekerjaan (*logical unit of work*) yang terdiri dari satu atau lebih operasi (baca, tulis, ubah, hapus).

```
                      Status Data Konsisten (A)
                                │
                        [ BEGIN TRANSACTION ]
                                │
                    ├── Operasi SQL 1 (UPDATE)
                    ├── Operasi SQL 2 (INSERT)
                    └── Operasi SQL 3 (UPDATE)
                                │
                 ┌──────────────┴──────────────┐
                 ▼                             ▼
       [ COMMIT TRANSACTION ]        [ ROLLBACK TRANSACTION ]
                 │                             │
       Status Baru Konsisten (B)      Kembali ke Status Awal (A)
```

Jika tidak ada mekanisme perlindungan transaksi, kegagalan di tengah proses (seperti listrik padam, jaringan terputus, atau aplikasi crash) dapat menyebabkan data tersimpan sebagian (*partial state*), merusak integritas seluruh sistem.

Standar **ACID** hadir untuk menjamin keabsahan data:
- **Atomicity:** Memastikan semua operasi berhasil tereksekusi seluruhnya, atau dibatalkan tanpa jejak sama sekali.
- **Consistency:** Menjamin database hanya berpindah dari satu status valid ke status valid lainnya sesuai seluruh aturan constraint.
- **Isolation:** Menjaga transaksi-transaksi yang berjalan bersamaan agar tidak saling mengganggu atau membaca status data yang belum final.
- **Durability:** Menjamin bahwa data dari transaksi yang telah di-*commit* tersimpan permanen dan tidak akan hilang meskipun sistem mendadak mati.

---

## 2. Pilar 1: Atomicity (Semua atau Tidak Sama Sekali)

### Konsep & Skenario Masalah (Atomicity)
Prinsip dasar Atomicity adalah *All or Nothing*. Tidak boleh ada sebagian operasi yang berhasil disimpan sementara operasi lainnya gagal.

**Skenario Dunia Nyata: Transfer Dana Antar Rekening**
Misalkan nasabah Adit mentransfer uang Rp100.000 ke rekening Budi. Proses ini membutuhkan 2 operasi update:
1. Kurangi saldo Adit sebesar Rp100.000.
2. Tambahkan saldo Budi sebesar Rp100.000.

> [!CAUTION]
> Jika sistem mengalami crash **setelah** langkah 1 selesai dan **sebelum** langkah 2 dieksekusi, saldo Adit berkurang namun saldo Budi tidak bertambah. Uang Rp100.000 lenyap dari peredaran.

### Implementasi di PostgreSQL: Transaksi & Savepoint

PostgreSQL mengimplementasikan Atomicity menggunakan blok transaksi:

```sql
BEGIN;

-- Langkah 1: Kurangi saldo pengirim
UPDATE accounts
SET balance = balance - 100000
WHERE id = 'ACC-001';

-- Langkah 2: Tambah saldo penerima
UPDATE accounts
SET balance = balance + 100000
WHERE id = 'ACC-002';

-- Jika kedua langkah berhasil tanpa kendala:
COMMIT;
```

Jika salah satu statement SQL mengalami kegagalan sintaks, melanggar constraint, atau aplikasi memanggil `ROLLBACK`, PostgreSQL membatalkan seluruh operasi dalam blok tersebut kembali ke titik sebelum `BEGIN`.

#### Fitur Lanjutan: Savepoints (Pembatalan Bertahap)
PostgreSQL mendukung *nested error handling* melalui `SAVEPOINT`. Anda dapat membatalkan bagian tertentu dari transaksi tanpa membatalkan seluruh transaksi:

```sql
BEGIN;

UPDATE accounts SET balance = balance - 50000 WHERE id = 'ACC-001';

SAVEPOINT sp_bonus;

-- Operasi opsional (misal pemberian cashback)
UPDATE accounts SET balance = balance + 5000 WHERE id = 'ACC-002';

-- Jika terjadi kondisi yang membatalkan bonus saja:
ROLLBACK TO SAVEPOINT sp_bonus;

-- Transaksi utama pengurangan saldo ACC-001 tetap dapat di-COMMIT
COMMIT;
```

> **Praktik SQL:** Skrip uji coba atomicity dapat dilihat di [acid/atomicity.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/atomicity.sql).

---

## 3. Pilar 2: Consistency (Integritas Kondisi Data)

### Konsep State Invariant
**Consistency** memastikan transaksi tidak melanggar aturan integritas bisnis (*invariants*) yang telah ditetapkan dalam database. Status database sebelum transaksi harus konsisten, dan setelah transaksi selesai (baik commit maupun rollback), database harus tetap konsisten.

Pada contoh transfer uang:
$$\text{Total Saldo Akun A} + \text{Total Saldo Akun B} = \text{Konstan sebelum \& sesudah transaksi}$$
Selain itu, saldo tidak boleh bernilai negatif jika aturan bisnis melarang cerukan (*overdraft*).

### Penegakan Konsistensi: Database vs Aplikasi
Meskipun validasi logika bisnis sering dilakukan di level aplikasi (backend), validasi di level database merupakan pertahanan terakhir (*last line of defense*) paling aman dari bug aplikasi atau *concurrency race condition*.

### Fitur Penjaga Konsistensi di PostgreSQL
PostgreSQL menyediakan berbagai mekanisme deklaratif untuk menjamin konsistensi:

1. **CHECK Constraint:** Memvalidasi ekspresi logika data kolom.
   ```sql
   ALTER TABLE accounts
   ADD CONSTRAINT accounts_balance_non_negative
   CHECK (balance >= 0);
   ```
2. **PRIMARY KEY & UNIQUE:** Mencegah duplikasi entitas atau ID akun.
3. **NOT NULL:** Menjamin kelengkapan data mandatory.
4. **FOREIGN KEY:** Menjaga integritas referensial antar tabel relasi (`ON DELETE RESTRICT / CASCADE`).
5. **Deferred Constraints:** Memungkinkan pengecekan constraint ditunda hingga akhir transaksi (`COMMIT`), berguna untuk *circular dependency* antar tabel:
   ```sql
   SET CONSTRAINTS ALL DEFERRED;
   ```

> **Praktik SQL:** Skrip uji coba penegakan aturan konsistensi dapat dilihat di [acid/consistency.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/consistency.sql).

---

## 4. Pilar 3: Isolation (Isolasi Eksekusi Konkuren)

### Anomali Pembacaan Data Konkuren
Ketika puluhan atau ribuan transaksi berjalan serentak, transaksi yang belum selesai dapat saling melihat perubahan yang sedang terjadi. Standar SQL mendefinisikan beberapa fenomena anomali data:

1. **Dirty Read:** Transaksi A membaca perubahan data dari Transaksi B yang **belum di-commit**. Jika Transaksi B kemudian melakukan `ROLLBACK`, data yang dibaca Transaksi A adalah data fiktif (*dirty*).
2. **Non-Repeatable Read (Fuzzy Read):** Transaksi A membaca sebuah baris data. Transaksi B kemudian mengubah baris tersebut dan melakukan `COMMIT`. Ketika Transaksi A membaca kembali baris yang sama, nilainya sudah berbeda.
3. **Phantom Read:** Transaksi A membaca sekumpulan baris dengan filter tertentu (misal `balance > 500000`). Transaksi B menambahkan baris baru yang memenuhi filter tersebut dan melakukan `COMMIT`. Ketika Transaksi A mengulang query yang sama, muncul baris baru ("hantu").
4. **Serialization Anomaly:** Hasil eksekusi transaksi yang berjalan bersamaan menghasilkan kondisi data yang mustahil terjadi jika transaksi dieksekusi berurutan satu per satu.

---

### Tingkat Isolasi Transaksi (Isolation Levels)

Standar SQL mendefinisikan 4 level isolasi. Menariknya, PostgreSQL **tidak pernah mengizinkan Dirty Read**, sehingga level `READ UNCOMMITTED` di PostgreSQL otomatis diperlakukan sama dengan `READ COMMITTED`.

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | Serialization Anomaly |
| :--- | :---: | :---: | :---: | :---: |
| **Read Uncommitted** *(di Postgres = Read Committed)* | ❌ Dicegah | ⚠️ Mungkin Terjadi | ⚠️ Mungkin Terjadi | ⚠️ Mungkin Terjadi |
| **Read Committed** *(Default PostgreSQL)* | ❌ Dicegah | ⚠️ Mungkin Terjadi | ⚠️ Mungkin Terjadi | ⚠️ Mungkin Terjadi |
| **Repeatable Read** | ❌ Dicegah | ❌ Dicegah | ❌ Dicegah di Postgres | ⚠️ Mungkin Terjadi |
| **Serializable** | ❌ Dicegah | ❌ Dicegah | ❌ Dicegah | ❌ Dicegah |

Cara menyetel level isolasi pada sebuah transaksi:
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- atau
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

### MVCC vs Explicit Locking (`FOR UPDATE`)

PostgreSQL menggunakan model arsitektur **MVCC (Multi-Version Concurrency Control)**.
- Prinsip MVCC: *"Readers never block writers, and writers never block readers."*
- Saat transaksi membaca data, PostgreSQL memberikan snapshot versi data yang valid saat query dimulai (atau saat transaksi dimulai pada level *Repeatable Read*).

#### Kapan Perlu Explicit Locking?
Dalam skenario transaksi keuangan atau reservasi tiket (misal pola: *Baca Saldo ➔ Cek Kecukupan Saldo di Aplikasi ➔ Update Saldo*), dua proses dapat membaca saldo yang sama pada waktu bersamaan, lalu keduanya melakukan pengurangan saldo. Ini dikenal sebagai **Lost Update / Race Condition**.

Untuk mencegahnya, gunakan kunci baris eksplisit:
```sql
BEGIN;

-- Kunci baris target sehingga sesi lain harus menunggu (queue)
SELECT id, balance
FROM accounts
WHERE id = 'ACC-001'
FOR UPDATE;

-- Update saldo setelah dipastikan aman
UPDATE accounts
SET balance = balance - 80000
WHERE id = 'ACC-001';

COMMIT;
```

> **Praktik SQL:** Simulasi simulasi interaktif dua sesi (Session A & Session B) dapat dilihat di [acid/isolation.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/isolation.sql).

---

## 5. Pilar 4: Durability (Ketahanan & Permanensi Data)

### Konsep Crash Recovery
**Durability** memastikan bahwa begitu sebuah transaksi dinyatakan berhasil (`COMMIT`), data tersebut dijamin tersimpan secara permanen pada media penyimpanan sekunder (SSD/HDD). Jika server mendadak kehilangan daya satu milidetik setelah pesan `COMMIT` dikembalikan ke klien, data tersebut **tidak boleh hilang**.

### Mekanisme Internal: Write-Ahead Logging (WAL)
Menulis seluruh data tabel yang dimodifikasi langsung ke file database di disk (*data pages*) pada setiap commit membutuhkan operasi I/O acak (*random I/O*) yang sangat lambat.

Untuk mengatasi ini, PostgreSQL menggunakan teknik **Write-Ahead Logging (WAL)**:

```
[ Transaksi COMMIT ]
         │
         ▼
 1. Tulis perubahan secara sekuensial ke WAL Buffer & flush ke WAL File di Disk (fsync)
         │
         ▼
 2. Ubah data di RAM (Shared Memory Buffers) ➔ Kirim konfirmasi COMMIT ke Client
         │
         ▼ (Background async)
 3. Checkpointer menulis data kotor (dirty pages) ke Tabel Utama di Disk
```

- **Aturan Emas WAL:** Tidak ada data page yang boleh ditulis ke disk sebelum entri WAL yang mendeskripsikan perubahan tersebut selesai ditulis dan di-*flush* ke disk.
- **Proses Crash Recovery:** Jika server mati mendadak, saat PostgreSQL dihidupkan kembali, proses recovery akan membaca berkas WAL terakhir dan melakukan operasi *REDO* untuk memulihkan seluruh data transaksi yang telah di-commit ke keadaan yang semestinya.

### Trade-off Performa vs Durabilitas
PostgreSQL menyediakan parameter konfigurasi untuk menyeimbangkan durabilitas maksimum dan kecepatan throughput penulisan:

- `synchronous_commit = on` (Default): `COMMIT` baru merespon klien setelah catatan WAL benar-benar tertulis di disk via panggilan sistem `fsync`. Durabilitas terjamin 100%.
- `synchronous_commit = off`: Transaksi langsung merespon tanpa menunggu WAL di-flush ke disk. Menghasilkan peningkatan performa tulis yang masif, namun ada potensi kehilangan data beberapa ratus milidetik terakhir jika server listrik padam mendadak (meskipun database tetap terhindar dari *data corruption*).

> **Praktik SQL:** Skrip uji coba durabilitas dan pembuktian status commit/rollback dapat dilihat di [acid/durability.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/durability.sql).

---

## 6. Tabel Rangkuman ACID di PostgreSQL

| Pilar | Definisi Singkat | Mekanisme di PostgreSQL | Perintah Terkait |
| :--- | :--- | :--- | :--- |
| **Atomicity** | *All-or-Nothing*: transaksi tereksekusi utuh atau batal total | Log transaksi, rollback engine, savepoint | `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT` |
| **Consistency** | Data selalu valid dan mematuhi seluruh invariant skema | Validasi constraint tabel, foreign keys, triggers | `CHECK`, `NOT NULL`, `UNIQUE`, `FOREIGN KEY` |
| **Isolation** | Transaksi paralel tidak menghasilkan anomali data | MVCC (Multi-Version Concurrency Control) & Row-level Lock | `ISOLATION LEVEL`, `SELECT ... FOR UPDATE` |
| **Durability** | Data yang di-commit tidak akan hilang saat crash | Write-Ahead Logging (WAL), Checkpoint, `fsync` | File WAL (`pg_wal`), `CHECKPOINT`, `synchronous_commit` |

---

## 7. Panduan Praktik Modul `acid/`

Untuk mempraktikkan konsep di atas secara langsung di server PostgreSQL, ikuti urutan skrip latihan berikut:

1. **Inisialisasi Tabel & Data Awal:**
   - Jalankan [create_account.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/create_account.sql) untuk membuat tabel `accounts` dan saldo awal.
2. **Uji Coba Atomicity:**
   - Jalankan [atomicity.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/atomicity.sql) untuk melihat bagaimana `ROLLBACK` membatalkan semua pernyataan ketika terjadi kegagalan.
3. **Uji Coba Consistency:**
   - Jalankan [consistency.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/consistency.sql) untuk menguji penolakan data ketika constraint saldo negatif dilanggar.
4. **Uji Coba Isolation (Multi-Session):**
   - Buka 2 terminal terpisah (`Session A` dan `Session B`), lalu ikuti skenario interaktif di [isolation.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/isolation.sql) untuk mengamati efek `FOR UPDATE`.
5. **Uji Coba Durability:**
   - Jalankan [durability.sql](file:///home/xylo/Documents/adit/devbox/belajar-postgres/acid/durability.sql) untuk memverifikasi keabadian data setelah pemutusan koneksi (*reconnect*).
