import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  List<TransactionModel> transactions = [];
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = false;

  double get balance => totalIncome - totalExpense;

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    transactions = await _repo.getAllTransactions();
    final summary = await _repo.getMonthlySummary(DateTime.now());
    totalIncome = summary['income'] ?? 0;
    totalExpense = summary['expense'] ?? 0;

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _repo.addTransaction(tx);
    await loadDashboardData();
  }
  Future<void> deleteTransaction(int id) async {
    await _repo.deleteTransaction(id);
    await loadDashboardData();
  }
  Future<void> updateTransaction(TransactionModel tx) async {
  await _repo.updateTransaction(tx);
  await loadDashboardData();
}
}