import 'package:flutter/material.dart';
import '../data/repositories/transaction_repository.dart';
import 'features/chart/widgets/pie_chart_category.dart';
import 'features/chart/widgets/bar_chart_trend.dart';

class ChartProvider extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  DateTime selectedMonth = DateTime.now();
  List<CategoryExpenseData> categoryData = [];
  List<DailyTrendData> trendData = [];
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = false;

  Future<void> loadChartData() async {
    isLoading = true;
    notifyListeners();

    // Pie chart: pengeluaran per kategori
    final categoryRows = await _repo.getExpenseByCategory(selectedMonth);
    categoryData = categoryRows.map((row) {
      return CategoryExpenseData(
        name: row['name'] as String,
        color: row['color'] as String? ?? '#D85A30',
        total: (row['total'] as num).toDouble(),
      );
    }).toList();

    // Bar chart: tren harian
    final trendRows = await _repo.getDailyTrend(selectedMonth);
    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    final Map<int, double> incomeByDay = {};
    final Map<int, double> expenseByDay = {};
    for (final row in trendRows) {
      final day = row['day'] as int;
      final total = (row['total'] as num).toDouble();
      if (row['type'] == 'income') {
        incomeByDay[day] = total;
      } else {
        expenseByDay[day] = total;
      }
    }

    trendData = List.generate(daysInMonth, (i) {
      final day = i + 1;
      return DailyTrendData(
        day: day,
        income: incomeByDay[day] ?? 0,
        expense: expenseByDay[day] ?? 0,
      );
    });

    // Summary total
    final summary = await _repo.getMonthlySummary(selectedMonth);
    totalIncome = summary['income'] ?? 0;
    totalExpense = summary['expense'] ?? 0;

    isLoading = false;
    notifyListeners();
  }

  void changeMonth(int offset) {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset);
    loadChartData();
  }
}