# Dokumentasi Kode: Database Helper + Models (Money Tracker App)

Dokumen ini menjelaskan fungsi dari setiap bagian kode secara rinci agar mudah dipahami, terutama jika kamu belum familiar dengan Dart/Flutter atau SQLite.

---

## 1. `lib/data/models/category_model.dart`

File ini adalah **model** — representasi struktur data satu baris tabel `categories` dalam bentuk class Dart, supaya data mudah dipakai di seluruh aplikasi (bukan sekadar `Map` mentah).

```dart
class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' atau 'expense'
  final String icon;
  final String color;
  final bool isDefault;
```
- `class CategoryModel` — mendefinisikan blueprint objek kategori.
- `final int? id` — id kategori dari database. Bertanda `?` (nullable) karena saat kategori **baru dibuat** (belum disimpan), id belum ada (auto-increment oleh SQLite).
- `final String name` — nama kategori, misal "Makan".
- `final String type` — menandai kategori ini untuk pemasukan (`income`) atau pengeluaran (`expense`).
- `final String icon` — nama ikon yang dipakai di UI, misal `ti-wallet`.
- `final String color` — kode warna hex untuk ikon/label kategori.
- `final bool isDefault` — penanda apakah kategori ini bawaan aplikasi (tidak bisa dihapus user) atau buatan user sendiri.

```dart
  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });
```
- Ini adalah **constructor** dengan named parameters.
- `required` berarti field wajib diisi saat membuat objek baru.
- `this.id` tidak `required` karena boleh kosong (belum tersimpan).
- `this.isDefault = false` — nilai default jika tidak diisi, dianggap bukan kategori bawaan.

```dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
    };
  }
```
- Fungsi `toMap()` mengubah objek `CategoryModel` menjadi `Map`, format yang dibutuhkan `sqflite` untuk insert/update ke database.
- `isDefault ? 1 : 0` — SQLite tidak punya tipe boolean asli, jadi `true/false` dikonversi ke `1/0`.

```dart
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }
```
- Kebalikan dari `toMap()`: mengubah hasil query database (berupa `Map`) menjadi objek `CategoryModel`.
- `factory` dipakai karena constructor ini tidak selalu membuat instance baru murni — ia memproses data terlebih dahulu (melakukan konversi tipe).
- `(map['is_default'] as int) == 1` — mengembalikan angka `1`/`0` dari database menjadi `true`/`false`.

```dart
  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
```
- `copyWith()` membuat **salinan objek** dengan beberapa field yang bisa diubah, tanpa perlu menulis ulang semua field.
- Operator `??` artinya "gunakan nilai baru jika ada, kalau tidak pakai nilai lama (`this.xxx`)".
- Berguna misalnya saat user mengedit nama kategori saja, field lain tetap sama.

---

## 2. `lib/data/models/transaction_model.dart`

Model untuk satu baris data transaksi (pemasukan/pengeluaran).

```dart
class TransactionModel {
  final int? id;
  final int categoryId;
  final String type; // 'income' atau 'expense'
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String? receiptPhoto;
  final DateTime createdAt;
  final DateTime? updatedAt;
```
- `id` — id transaksi (nullable, sama alasannya seperti di atas).
- `categoryId` — **foreign key** yang menghubungkan transaksi ini ke tabel `categories`.
- `type` — jenis transaksi (income/expense), disimpan terpisah dari kategori supaya query lebih cepat tanpa harus join.
- `amount` — nominal uang, pakai `double` agar mendukung desimal.
- `note` — catatan opsional (nullable, boleh kosong).
- `transactionDate` — tanggal transaksi terjadi (beda dengan waktu input data).
- `receiptPhoto` — path/nama file foto struk, opsional.
- `createdAt` — waktu data ini pertama kali dibuat di sistem.
- `updatedAt` — waktu terakhir diedit, `null` jika belum pernah diedit.

```dart
  // Field tambahan hasil JOIN, tidak disimpan di tabel transactions
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
```
- Tiga field ini **tidak ada di tabel `transactions`** — ini hanya "titipan" data dari tabel `categories` hasil `JOIN` (lihat `getAllTransactions()` di repository), supaya saat menampilkan daftar transaksi di UI, nama & ikon kategori langsung tersedia tanpa query tambahan.

```dart
  TransactionModel({
    this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.transactionDate,
    this.receiptPhoto,
    DateTime? createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  }) : createdAt = createdAt ?? DateTime.now();
```
- Constructor dengan named parameters, mirip `CategoryModel`.
- Bagian penting: `: createdAt = createdAt ?? DateTime.now()` — ini disebut **initializer list**. Artinya: jika `createdAt` tidak diberikan saat membuat objek, otomatis diisi waktu sekarang (`DateTime.now()`). Ini memastikan `createdAt` (yang bertipe non-nullable `DateTime`) selalu punya nilai.

```dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note,
      'transaction_date':
          '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
      'receipt_photo': receiptPhoto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
```
- Sama seperti sebelumnya, mengubah objek menjadi `Map` untuk disimpan ke SQLite.
- Baris `transaction_date` melakukan **format manual** tanggal menjadi `YYYY-MM-DD`:
  - `.toString().padLeft(2, '0')` — menambahkan angka 0 di depan jika bulan/tanggal hanya 1 digit (misal `5` menjadi `05`), agar format tanggal konsisten dan bisa diurutkan/di-query dengan benar oleh SQLite.
- `createdAt.toIso8601String()` — menyimpan waktu lengkap (jam, menit, detik) dalam format standar ISO 8601, contoh: `2026-07-01T10:30:00.000`.
- `updatedAt?.toIso8601String()` — tanda `?` berarti hanya dipanggil jika `updatedAt` tidak `null`; kalau `null`, hasilnya otomatis `null` juga (tidak error).

```dart
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      receiptPhoto: map['receipt_photo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['icon'] as String?,
      categoryColor: map['color'] as String?,
    );
  }
}
```
- Mengubah hasil query (`Map`) menjadi objek `TransactionModel`.
- `(map['amount'] as num).toDouble()` — nilai dari SQLite bisa terbaca sebagai `int` atau `double`, jadi di-cast ke `num` dulu (tipe umum angka) baru dipastikan jadi `double`.
- `DateTime.parse(...)` — mengubah string tanggal/waktu (hasil `toMap()` sebelumnya) kembali menjadi objek `DateTime`.
- `updatedAt: map['updated_at'] != null ? DateTime.parse(...) : null` — ini adalah **conditional (ternary) operator**: cek dulu apakah datanya `null`, baru diparse; kalau tidak dicek langsung, `DateTime.parse(null)` akan error.
- `categoryName`, `categoryIcon` (dari kolom `icon`), `categoryColor` (dari kolom `color`) — diisi dari hasil `JOIN` di query, lihat penjelasan `getAllTransactions()` di bawah.

---

## 3. `lib/data/database/db_helper.dart`

File ini mengatur **koneksi dan struktur database SQLite** — dibuat sekali dan dipakai bersama (shared) di seluruh aplikasi.

```dart
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
```
- Ini adalah pola desain **Singleton** — memastikan hanya ada **satu** instance `DBHelper` di seluruh aplikasi (tidak membuka banyak koneksi database secara bersamaan yang bisa menyebabkan bug/konflik).
- `static final DBHelper _instance = DBHelper._internal()` — membuat satu instance tunggal yang disimpan secara statis (dimiliki oleh class, bukan per objek).
- `factory DBHelper() => _instance` — setiap kali kode memanggil `DBHelper()`, yang dikembalikan selalu instance yang sama itu-itu saja, bukan instance baru.
- `DBHelper._internal()` — constructor privat (ditandai `_`), hanya bisa dipanggil dari dalam class ini sendiri, mencegah orang lain membuat instance baru secara langsung.
- `static Database? _database` — menyimpan objek koneksi database, nullable karena awalnya belum dibuka (`null`).

```dart
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
```
- Ini adalah **getter** bernama `database` yang bisa dipanggil seperti properti biasa (`dbHelper.database`), tapi sebenarnya menjalankan logika async di baliknya.
- Cek dulu: kalau `_database` sudah pernah dibuka (`!= null`), langsung kembalikan itu (tanda `!` artinya "saya yakin ini tidak null" / non-null assertion).
- Kalau belum ada, panggil `_initDB()` untuk membuka koneksi baru, simpan hasilnya, lalu kembalikan.
- Pola ini disebut **lazy initialization** — database baru benar-benar dibuka saat pertama kali dibutuhkan, bukan langsung saat aplikasi start.

```dart
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }
```
- `getDatabasesPath()` — fungsi dari package `sqflite` untuk mendapatkan folder default penyimpanan database di device (Android/iOS).
- `join(dbPath, 'money_tracker.db')` — menggabungkan path folder dengan nama file database menjadi satu path lengkap (fungsi dari package `path`, aman untuk perbedaan format path Android/iOS).
- `openDatabase(...)` — membuka (atau membuat jika belum ada) file database SQLite di path tersebut.
  - `version: 1` — versi skema database, dipakai nanti kalau butuh migrasi (upgrade struktur tabel).
  - `onCreate: _onCreate` — fungsi yang dipanggil **hanya sekali**, saat file database dibuat pertama kali (belum ada tabel sama sekali).
  - `onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON')` — perintah SQL khusus untuk **mengaktifkan foreign key constraint**. Secara default SQLite mematikan pengecekan foreign key, jadi harus diaktifkan manual di setiap sesi koneksi.

```dart
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        icon TEXT,
        color TEXT,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
```
- Membuat tabel `categories` lewat SQL mentah.
- `id INTEGER PRIMARY KEY AUTOINCREMENT` — id otomatis bertambah tiap ada data baru, jadi primary key unik.
- `name TEXT NOT NULL` — nama wajib diisi, tidak boleh kosong.
- `type TEXT NOT NULL CHECK (type IN ('income', 'expense'))` — kolom `type` wajib diisi, dan **dibatasi hanya boleh** salah satu dari dua nilai itu (validasi di level database, bukan cuma di Dart).
- `icon TEXT`, `color TEXT` — boleh kosong (tidak ada `NOT NULL`).
- `is_default INTEGER NOT NULL DEFAULT 0` — default-nya `0` (bukan kategori bawaan) kalau tidak diisi saat insert.

```dart
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        amount REAL NOT NULL CHECK (amount > 0),
        note TEXT,
        transaction_date TEXT NOT NULL,
        receipt_photo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');
```
- Membuat tabel `transactions`.
- `amount REAL NOT NULL CHECK (amount > 0)` — nominal wajib diisi dan **harus lebih besar dari 0** (validasi langsung di database, mencegah data nominal 0 atau minus masuk).
- `FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT` — ini yang membuat `category_id` benar-benar terhubung ke tabel `categories`.
  - `ON DELETE RESTRICT` — jika ada yang mencoba menghapus kategori yang **masih dipakai** oleh transaksi manapun, SQLite akan **menolak penghapusan** tersebut (mencegah data transaksi jadi "yatim piatu" tanpa kategori).

```dart
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions (transaction_date)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions (category_id)');

    await _seedDefaultCategories(db);
  }
```
- Membuat **index** pada kolom `transaction_date` dan `category_id`. Index mempercepat proses query (misalnya saat filter transaksi per bulan atau per kategori), terutama saat data sudah banyak.
- Terakhir, memanggil `_seedDefaultCategories(db)` untuk mengisi data kategori bawaan begitu tabel selesai dibuat.

```dart
  Future<void> _seedDefaultCategories(Database db) async {
    final incomeCategories = [
      {'name': 'Uang Saku', 'icon': 'ti-wallet', 'color': '#1D9E75'},
      ...
    ];

    final expenseCategories = [
      {'name': 'Makan', 'icon': 'ti-tools-kitchen-2', 'color': '#D85A30'},
      ...
    ];
```
- Dua `List<Map>` berisi data kategori default: kategori pemasukan (hijau `#1D9E75`) dan kategori pengeluaran (oranye `#D85A30`).

```dart
    for (final cat in incomeCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'income',
        'icon': cat['icon'],
        'color': cat['color'],
        'is_default': 1,
      });
    }

    for (final cat in expenseCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'expense',
        'icon': cat['icon'],
        'color': cat['color'],
        'is_default': 1,
      });
    }
  }
}
```
- Loop `for` untuk memasukkan (insert) setiap data kategori satu per satu ke tabel `categories`, sekaligus menandai `is_default: 1` supaya nanti bisa dibedakan dari kategori buatan user (yang defaultnya `false`/`0` sesuai `CategoryModel`).
- Fungsi ini hanya berjalan sekali seumur hidup aplikasi (saat `onCreate`), jadi user akan langsung punya kategori siap pakai begitu install aplikasi.

---

## 4. `lib/data/repositories/category_repository.dart`

**Repository** adalah lapisan yang menjembatani antara UI/Provider dengan `DBHelper` — tempat semua query terkait kategori dikumpulkan, supaya kode di UI tidak perlu tahu detail SQL.

```dart
class CategoryRepository {
  final DBHelper _dbHelper = DBHelper();
```
- Mengambil instance `DBHelper` (ingat, ini singleton — jadi selalu instance yang sama).

```dart
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'is_default DESC, name ASC',
    );
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }
```
- Mengambil daftar kategori berdasarkan tipenya (`income` atau `expense`).
- `where: 'type = ?'` dan `whereArgs: [type]` — ini teknik **parameterized query**, mencegah SQL Injection (lebih aman daripada menggabungkan string SQL secara manual).
- `orderBy: 'is_default DESC, name ASC'` — urutkan kategori bawaan (`is_default = 1`) muncul lebih dulu, lalu diurutkan berdasarkan nama A-Z.
- `result.map((e) => CategoryModel.fromMap(e)).toList()` — hasil query berupa `List<Map>`, di-*mapping* satu per satu jadi `List<CategoryModel>` memakai `fromMap()` yang sudah dibuat di model.

```dart
  Future<int> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    final map = category.toMap()..remove('id');
    return await db.insert('categories', map);
  }
```
- Menambah kategori baru.
- `category.toMap()..remove('id')` — memakai **cascade operator** (`..`) untuk memanggil `remove('id')` pada hasil `toMap()` lalu tetap mengembalikan map itu sendiri. Alasannya: id belum ada (kategori belum tersimpan) dan biar SQLite yang meng-generate id secara otomatis (`AUTOINCREMENT`), bukan dikirim manual dari Dart.
- `db.insert(...)` mengembalikan `id` baru yang berhasil dibuat (return type `int`).

```dart
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
```
- Menghapus kategori berdasarkan id.
- Jika kategori tersebut masih dipakai transaksi, ingat aturan `ON DELETE RESTRICT` di database — perintah ini akan **melempar error/exception**, bukan diam-diam gagal. Perlu ditangani (try-catch) di layer atasnya (Provider/UI) untuk kasih pesan ke user.

---

## 5. `lib/data/repositories/transaction_repository.dart`

Sama seperti di atas, tapi khusus untuk semua operasi terkait tabel `transactions`.

```dart
class TransactionRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> addTransaction(TransactionModel tx) async {
    final db = await _dbHelper.database;
    final map = tx.toMap()..remove('id');
    return await db.insert('transactions', map);
  }
```
- Sama polanya dengan `addCategory` — hapus `id` dulu sebelum insert karena id auto-generate.

```dart
  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }
```
- Mengupdate transaksi yang sudah ada, dicari berdasarkan `id`-nya (`tx.id`, kali ini **tidak** dihapus dari map karena tidak masalah kalau id ikut terkirim saat update — id tetap sama, tidak diubah).

```dart
  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
```
- Menghapus satu transaksi berdasarkan id. Tidak ada batasan foreign key di sini (transaksi bebas dihapus kapan saja, tidak seperti kategori).

```dart
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT t.*, c.name as category_name, c.icon, c.color
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      ORDER BY t.transaction_date DESC, t.created_at DESC
    ''');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }
```
- Ini fungsi paling penting untuk menampilkan **daftar riwayat transaksi**.
- `rawQuery` dipakai (bukan `db.query` biasa) karena butuh **JOIN** antar dua tabel, yang tidak bisa dilakukan dengan method bawaan `query()`.
- `SELECT t.*, c.name as category_name, c.icon, c.color` — ambil semua kolom dari tabel `transactions` (alias `t`), ditambah kolom `name` dari tabel `categories` (alias `c`) yang diberi nama ulang jadi `category_name` (supaya tidak bentrok dengan kolom lain), plus `icon` dan `color`-nya.
- `JOIN categories c ON t.category_id = c.id` — menggabungkan baris transaksi dengan baris kategori yang cocok (`category_id` di transaksi = `id` di kategori). Inilah alasan `TransactionModel` punya field tambahan `categoryName`, `categoryIcon`, `categoryColor` yang dijelaskan sebelumnya — hasil JOIN ini langsung dibaca lewat `fromMap()`.
- `ORDER BY t.transaction_date DESC, t.created_at DESC` — urutkan dari transaksi terbaru ke terlama; jika ada beberapa transaksi di tanggal yang sama, urutkan berdasarkan waktu input terbaru.

```dart
  Future<Map<String, double>> getMonthlySummary(DateTime month) async {
    final db = await _dbHelper.database;
    final monthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE strftime('%Y-%m', transaction_date) = ?
      GROUP BY type
    ''', [monthStr]);
```
- Fungsi ini menghitung **total pemasukan dan pengeluaran dalam satu bulan** — cocok untuk ditampilkan di dashboard/ringkasan bulanan.
- `monthStr` — mengubah objek `DateTime` menjadi string format `YYYY-MM`, misal `2026-07`, untuk dicocokkan dengan data di database.
- `strftime('%Y-%m', transaction_date)` — fungsi SQLite untuk mengekstrak bagian tahun-bulan saja dari kolom `transaction_date`, lalu dibandingkan dengan `monthStr` (parameter `?` diisi lewat list `[monthStr]`, tetap aman dari SQL Injection).
- `SUM(amount) as total` + `GROUP BY type` — menjumlahkan semua `amount`, dikelompokkan berdasarkan `type` (jadi hasilnya maksimal 2 baris: total income dan total expense).

```dart
    double income = 0;
    double expense = 0;
    for (final row in result) {
      if (row['type'] == 'income') income = (row['total'] as num).toDouble();
      if (row['type'] == 'expense') {
        expense = (row['total'] as num).toDouble();
      }
    }
    return {'income': income, 'expense': expense};
  }
```
- Karena hasil query bisa berupa 0, 1, atau 2 baris (tergantung ada tidaknya transaksi income/expense di bulan itu), kode ini **inisialisasi default 0** dulu, lalu loop hasil query untuk mengisi nilai yang sesuai.
- Ini mencegah error jika ternyata di bulan tersebut belum ada transaksi income sama sekali (`result` tidak akan punya baris `type: income`, tapi variabel `income` tetap `0`, bukan `null`/error).
- Hasil akhirnya dikembalikan sebagai `Map` sederhana `{'income': ..., 'expense': ...}` supaya mudah dipakai di UI (misal `summary['income']`).

```dart
  Future<List<Map<String, dynamic>>> getExpenseByCategory(
      DateTime month) async {
    final db = await _dbHelper.database;
    final monthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = 'expense'
        AND strftime('%Y-%m', t.transaction_date) = ?
      GROUP BY c.id
      ORDER BY total DESC
    ''', [monthStr]);
  }
}
```
- Fungsi ini untuk kebutuhan **grafik/pie chart pengeluaran per kategori** dalam satu bulan (misalnya untuk menampilkan "Makan 40%, Transportasi 25%", dst).
- Mirip `getMonthlySummary`, tapi kali ini di-`JOIN` dengan `categories` supaya dapat nama & warna kategori langsung, difilter `WHERE t.type = 'expense'` (hanya pengeluaran, income tidak relevan untuk breakdown kategori pengeluaran).
- `GROUP BY c.id` — jumlahkan total per kategori (bukan per tipe transaksi seperti sebelumnya).
- `ORDER BY total DESC` — kategori dengan pengeluaran terbesar muncul paling atas, cocok untuk urutan di chart/list.
- Return type-nya `List<Map<String, dynamic>>`, bukan `List<TransactionModel>`, karena hasilnya bukan representasi satu transaksi utuh, cuma ringkasan (nama, warna, total) — jadi tidak dipetakan ke model manapun, cukup dipakai langsung sebagai `Map` di UI/chart widget.

---

## Ringkasan Alur Data

```
UI / Provider
     ↓  (panggil fungsi)
Repository (CategoryRepository / TransactionRepository)
     ↓  (query lewat db.insert/query/update/delete/rawQuery)
DBHelper (buka koneksi, kelola singleton)
     ↓
SQLite Database (file money_tracker.db di device)
```

- **Model** → bentuk data di sisi Dart (objek).
- **DBHelper** → satu-satunya pintu masuk ke database fisik, memastikan tidak ada koneksi ganda.
- **Repository** → "penerjemah" antara objek Dart dan bahasa SQL, sekaligus tempat semua logika query dikumpulkan supaya rapi dan mudah dites terpisah dari UI.

Kalau mau, langkah selanjutnya (Provider atau UI Dashboard) juga bisa didokumentasikan dengan gaya yang sama.
