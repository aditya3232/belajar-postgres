## 1. Bentuk Normal Basis Data ke 1 (1NF)
- tidak ada nama kolom yang duplikat / ganda
- tidak ada baris yang duplikat / ganda
- tidak ada atribut turunan misal: produk total, total harga, total berat, total belanja adalah atribut turunan

## 2. Bentuk Normal Basis Data ke 2 (2NF)
- harus sudah dalam bentuk normal basis data ke 1
- buat tabel terpisah untuk nilai-nilai yang keluar berulang kali pada beberapa baris
- tambahkan primary key pada tiap tabel
- hubungkan menggunakan foreign key

## 3. Bentuk Normal Basis Data ke 3 (3NF)
- harus sudah dalam bentuk normal basis data ke 2
- atribut non-key harus bergantung langsung pada primary key (transitive dependency)

Contohnya:

| order_id | customer_id | customer_name | customer_email                        |
| -------- | ----------- | ------------- | ------------------------------------- |
| 1        | C001        | Adit          | adit@mail.com                         |
| 2        | C002        | Budi          | budi@mail.com                         |
| 3        | C001        | Adit          | adit@mail.com                         |

Primary key: order_id

Masalahnya:

customer_name dan customer_email tidak bergantung langsung kepada order_id. Ini disebut transitive dependency, dan melanggar 3NF. SOlusi dipisahkan.

tabel orders:

| order_id | customer_id |
| -------- | ----------- |
| 1        | C001        |
| 2        | C002        |
| 3        | C001        |

Tabel customers:

| customer_id | customer_name | customer_email                        |
| ----------- | ------------- | ------------------------------------- |
| C001        | Adit          | adit@mail.com                         |
| C002        | Budi          | budi@mail.com                         |


