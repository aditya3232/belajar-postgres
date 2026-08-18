# Database ACID
- ACID merupakan compliance (kepatuhan) untuk sistem basis data yang memiliki karakter Atomicity, Consistency, Isolation, Durability
- ACID adalah sekumpulan properti transaksi basis data yang dimaksudkan untuk menjamin validitas data meskipun ada kesalahan, kegagalan daya, dan kecelakaan lainnya

## 1. Atomicity
- setiap statement dalam transaksi (baik itu membaca, menulis, mengubah, atau menghapus) diperlakukan sebagai satu kesatuan
- jika transaksi berhasil, maka seluruh statement harus berhasil
- jika transaksi gagal, maka seluruh statement harus tidak boleh ada yang berhasil, atau digagalkan 
- properti ini mencegah terjadinya kehilangan atau kerusakan data, misal jika ditengah transaksi terjadi kegagalan aplikasi

## 2. Consistency
- memastikan bahwa transaksi hanya bisa mengubah data dari satu kondisi konsisten ke kondisi konsisten lainnya
- setiap data yang ditulis ke database harus valid sesuai dengan semua aturan yang sudah ditetapkan
- hal ini mencegah data menjadi tidak konsisten, dan menjamin integritas relasi antar data

## 3. Isolation
- transaksi sering dieksekusi secara bersamaan (misal, beberapa transaksi membaca dan menulis ke tabel pada waktu yang sama)
- isolation memastikan bahwa eksekusi transaksi secara bersamaan meninggalkan database dalam keadaan sama, yang akan diperoleh jika transaksi dieksekusi secara berurutan
- isolation adalah tujuan utama kontrol konkurensi, tergantung pada tingkat isolasi yang digunakan, efek dari transaksi yang tidak lengkap mungkin tidak terlihat oleh transaksi lain

## 4. Durability
- durability menjamin bahwa sekali transaksi telah disimpan, itu akan tetap disimpan bahkan dalam kasus kegagalan sistem (misalnya, pemadaman listrik atau crash)