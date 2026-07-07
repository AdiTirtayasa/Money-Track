import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<CategoryModel> incomeCategories = [];
  List<CategoryModel> expenseCategories = [];
  bool isLoading = false;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    incomeCategories = await _repo.getCategoriesByType('income');
    expenseCategories = await _repo.getCategoriesByType('expense');

    isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repo.addCategory(category);
    await loadCategories();
  }
}