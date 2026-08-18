## 1. Denormalisasi Data
- normalisasi data digunakan untuk membuat model basis data yang baik
- normalisasi data sebenarnya hanyalah petunjuk saja, dalam keadaan tertentu kadang kita bisa melanggar aturan dari normalisasi data
- pelanggaran normalisasi data tersebut kita sebut denormalisasi data
- alasan kita melakukan denormalisasi data, adalah untuk mendapatkan performa yang lebih baik
- dan denormalisasi data sering kali dilakukan di dunia nyata
- ada banyak sekali cara melakukan denormalisasi data, namun inti dari denormalisasi data adalah meningkatkan performa kecepatan mendapatkan data

## 2. Denormalisasi dengan Menambahkan Derived Attribute
- sebelumnya pada saat melakukan normalisasi data, kita menghapus atribut turunan (derived attribute)
- derived attribute adalah atribut yang nilainya dapat dihitung dari atribut lainnya
- contohnya total_harga dapat dihitung dari harga × jumlah
- contoh lainnya total_berat dapat dihitung dari berat_produk × jumlah
- jika setiap kali mengambil data kita harus menghitung ulang nilai tersebut, prosesnya bisa menjadi lebih lambat, terutama jika datanya banyak
- dalam kondisi tertentu, kita dapat melakukan denormalisasi dengan menyimpan hasil perhitungan tersebut sebagai kolom
- kolom hasil perhitungan tersebut disebut derived attribute

Sebelum denormalisasi:

```bash
order_items
+-------------+-------+--------+
| harga       | jumlah|        |
+-------------+-------+--------+
| 10.000      | 2     |        |
+-------------+-------+--------+

total_harga = harga × jumlah
            = 10.000 × 2
            = 20.000
```

jika ingin menghindari perhitungan berulang, kita bisa menyimpan:

```bash
order_items
+-------------+--------+-------------+
| harga       | jumlah | total_harga |
+-------------+--------+-------------+
| 10.000      | 2      | 20.000      |
+-------------+--------+-------------+
```

## 3. Denormalisasi dengan Menambahkan Atribut Tambahan
- pada 3NF, data yang memiliki transitive dependency dipisahkan ke tabel lain
- akibatnya, untuk mendapatkan data tersebut kita perlu melakukan JOIN
- jika JOIN terlalu sering dan memengaruhi performa, kita dapat melakukan denormalisasi dengan menambahkan atribut dari tabel lain
- konsekuensinya terjadi redundansi data, tetapi pembacaan data dapat menjadi lebih cepat

```bash
Normalisasi (3NF)

tabel Orders

| order_id | customer_id |
| -------- | ----------- |
| O001     | C001        |
| O002     | C001        |

tabel Customers

| customer_id | customer_name |
| ----------- | ------------- |
| C001        | Adit          |

Denormalisasi:

| order_id | customer_id | customer_name |
| -------- | ----------- | ------------- |
| O001     | C001        | Adit          |
| O002     | C001        | Adit          |

```

## 4. Denormalisasi dengan Menambahkan Summary Table
- pada kondisi tertentu, kita membutuhkan data hasil perhitungan atau ringkasan yang sering digunakan
- jika setiap kali mengambil data kita harus melakukan COUNT, SUM, AVG, dan agregasi lainnya, query bisa menjadi lebih berat
- kita dapat membuat summary table yang menyimpan hasil perhitungan tersebut
- summary table merupakan bentuk denormalisasi karena menyimpan data hasil agregasi yang sebenarnya dapat dihitung dari tabel utama
- tujuannya adalah mempercepat proses pembacaan data

```bash
data utama:

tabel orders

| order_id | customer_id |   total |
| -------- | ----------- | ------: |
| O001     | C001        | 100.000 |
| O002     | C001        | 150.000 |
| O003     | C002        | 200.000 |

tabel customer_order_summary

| customer_id | total_order | total_belanja |
| ----------- | ----------: | ------------: |
| C001        |           2 |       250.000 |
| C002        |           1 |       200.000 |

daripada setiap kali melakukan:

SELECT
    customer_id,
    COUNT(*) AS total_order,
    SUM(total) AS total_belanja
FROM orders
GROUP BY customer_id;

kita cukup membaca: customer_order_summary

```

## 5. Denormalisasi dengan Menambahkan Atribut Pencarian
- pada kondisi tertentu, kita sering melakukan pencarian berdasarkan atribut tertentu
- jika atribut tersebut berada di tabel lain, kita harus melakukan JOIN terlebih dahulu
- untuk mengurangi kebutuhan JOIN, kita dapat menambahkan atribut tersebut ke tabel yang sering digunakan untuk pencarian
- atribut tambahan tersebut digunakan sebagai searching attribute
- konsekuensinya terjadi redundansi data, tetapi proses pencarian dapat menjadi lebih sederhana dan cepat

```bash
normalisasi:

tabel orders

| order_id | customer_id |
| -------- | ----------- |
| O001     | C001        |
| O002     | C002        |

tabel customers

| customer_id | customer_name |
| ----------- | ------------- |
| C001        | Adit          |
| C002        | Budi          |

misalnya kita sering mencari order berdasarkan customer_name

tabel orders

| order_id | customer_id | customer_name |
| -------- | ----------- | ------------- |
| O001     | C001        | Adit          |
| O002     | C002        | Budi          |

Sekarang pencarian dapat dilakukan langsung pada tabel orders berdasarkan customer_name, tanpa perlu JOIN ke tabel customers.

```

## 6. Immutable dan Mutable Table

### Immutable Table

- immutable table adalah tabel yang datanya tidak atau hampir tidak pernah diubah setelah dibuat
- data biasanya hanya ditambahkan (insert) dan jarang dilakukan UPDATE atau DELETE
- cocok untuk menyimpan data historis atau data yang sudah final
- karena datanya tidak banyak berubah, data tambahan hasil denormalisasi relatif aman untuk disimpan

```bash
contoh: tabel order_history

| order_id | customer_id | customer_name |   total |
| -------- | ----------- | ------------- | ------: |
| O001     | C001        | Adit          | 100.000 |
| O002     | C002        | Budi          | 200.000 |

setelah order selesai, datanya dianggap sebagai snapshot/historis dan tidak banyak berubah.
```

### Mutable Table
- mutable table adalah tabel yang datanya sering mengalami perubahan
- data dapat mengalami UPDATE atau DELETE
- jika melakukan denormalisasi pada tabel mutable, data redundant harus selalu diperbarui
- semakin banyak data redundant, semakin besar kemungkinan terjadi data tidak konsisten

```bash
contoh: table customers

| customer_id | customer_name | email                                 |
| ----------- | ------------- | ------------------------------------- |
| C001        | Adit          | adit@mail.com                         |
| C002        | Budi          | budi@mail.com                         |

misalnya customer_name berubah: Adit -> Aditya
Jika customer_name juga disimpan di beberapa tabel lain, semua data tersebut harus ikut diperbarui.

``` 

### Perbandingan

```bash
|                      | Immutable           | Mutable                      |
| -------------------- | ------------------- | ---------------------------- |
| Data berubah         | Jarang/tidak        | Sering                       |
| Operasi utama        | `INSERT`            | `INSERT`, `UPDATE`, `DELETE` |
| Contoh               | History, log, event | Customer, product            |
| Denormalisasi        | Relatif lebih aman  | Lebih berisiko               |
| Risiko inkonsistensi | Rendah              | Lebih tinggi                 |

Intinya: denormalisasi lebih mudah diterapkan pada immutable table karena datanya jarang berubah. Pada mutable table, denormalisasi harus mempertimbangkan biaya menjaga data tetap konsisten.

```
