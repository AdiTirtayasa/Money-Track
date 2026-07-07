import '../database/db_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DBHelper _dbHelper = DBHelper();

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

  Future<int> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    final map = category.toMap()..remove('id');
    return await db.insert('categories', map);
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
