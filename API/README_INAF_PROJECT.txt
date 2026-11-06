INAF PROJECT - ADD-ON

Pemasangan:
1. Upload seluruh isi ZIP ke folder bot yang sama (backup folder lama terlebih dahulu).
2. Pastikan Node.js 20+ dan dependency pada package.json terpasang.
3. Jalankan bot seperti cara menjalankan script sebelumnya.
4. Buka chat pribadi bot lalu /start.
5. Buka Developer Panel untuk mengatur QRIS, banner, harga role, link grup, developer ID, dan komisi.
6. Gunakan menu Hubungkan Akun untuk memasangkan username database dengan Telegram ID. Setelah terhubung, role reseller ke atas dapat membuka menu Setoran dan Jual Role.
7. Atur QRIS dan link grup untuk setiap role sebelum menerima transaksi.

Alur:
- Pembeli memilih role / lapak, mengisi username|password, lalu mengirim foto bukti pembayaran.
- Developer menerima foto bukti transaksi dengan tombol SETUJUI / TOLAK.
- Jika disetujui, akun role dibuat di database.json dan link grup role dikirim jika sudah dikonfigurasi.
- Setoran reseller juga dikirim dengan foto bukti untuk persetujuan Developer. Saldo bertambah setelah disetujui.
- Banner hanya satu file global; QRIS juga satu file global.
- /start di grup hanya menampilkan menu informasi grup. /mytitle menampilkan title di chat pribadi setelah Telegram ID terhubung.

PENTING KEAMANAN:
- Token Telegram di script sumber sudah tertanam dan harus segera di-rotate melalui BotFather karena file sumber pernah dibagikan. Setelah rotate, perbarui konstanta TOKEN di index.js dengan token baru.
- File ZIP sumber berisi database dan kredensial sesi WhatsApp. Jangan membagikan ZIP ini ke orang lain; batasi akses panel dan lakukan backup terenkripsi.
- Password akun lama pada database.json tersimpan dalam format lama/plaintext. Batasi akses file dan rencanakan migrasi hashing password.

Catatan:
- Fitur lama tidak dihapus oleh add-on ini.
- Fitur penjualan hanya untuk pengelolaan role/akun dan transaksi manual yang aman.
