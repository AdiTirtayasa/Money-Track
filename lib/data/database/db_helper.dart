import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

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

    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions (transaction_date)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions (category_id)');

    await _seedDefaultCategories(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final incomeCategories = [
      {'name': 'Uang Saku', 'icon': 'ti-wallet', 'color': '#1D9E75'},
      {'name': 'Beasiswa', 'icon': 'ti-school', 'color': '#1D9E75'},
      {'name': 'Freelance', 'icon': 'ti-briefcase', 'color': '#1D9E75'},
      {'name': 'Hadiah', 'icon': 'ti-gift', 'color': '#1D9E75'},
      {'name': 'Lainnya', 'icon': 'ti-dots', 'color': '#1D9E75'},
    ];

    final expenseCategories = [
      {'name': 'Makan', 'icon': 'ti-tools-kitchen-2', 'color': '#D85A30'},
      {'name': 'Transportasi', 'icon': 'ti-bus', 'color': '#D85A30'},
      {'name': 'Kos/Sewa', 'icon': 'ti-home', 'color': '#D85A30'},
      {'name': 'Kuota', 'icon': 'ti-wifi', 'color': '#D85A30'},
      {'name': 'Pendidikan', 'icon': 'ti-book', 'color': '#D85A30'},
      {'name': 'Hiburan', 'icon': 'ti-device-gamepad-2', 'color': '#D85A30'},
      {'name': 'Lainnya', 'icon': 'ti-dots', 'color': '#D85A30'},
    ];

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