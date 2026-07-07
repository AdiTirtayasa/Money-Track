import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> addTransaction(TransactionModel tx) async {
    final db = await _dbHelper.database;
    final map = tx.toMap()..remove('id');
    return await db.insert('transactions', map);
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

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
  
  Future<List<Map<String, dynamic>>> getDailyTrend(DateTime month) async {
  final db = await _dbHelper.database;
  final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';
  return await db.rawQuery('''
    SELECT
      CAST(strftime('%d', transaction_date) AS INTEGER) as day,
      type,
      SUM(amount) as total
    FROM transactions
    WHERE strftime('%Y-%m', transaction_date) = ?
    GROUP BY day, type
    ORDER BY day ASC
  ''', [monthStr]);
}
}
