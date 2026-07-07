import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_tracker/core/utils/currency_formatter.dart';

class CategoryExpenseData {
  final String name;
  final String color;
  final double total;

  CategoryExpenseData({
    required this.name,
    required this.color,
    required this.total,
  });
}

class PieChartCategory extends StatefulWidget {
  final List<CategoryExpenseData> data;

  const PieChartCategory({super.key, required this.data});

  @override
  State<PieChartCategory> createState() => _PieChartCategoryState();
}

class _PieChartCategoryState extends State<PieChartCategory> {
  int _touchedIndex = -1;

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Belum ada pengeluaran bulan ini',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final total = widget.data.fold<double>(0, (sum, d) => sum + d.total);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(widget.data.length, (index) {
                final item = widget.data[index];
                final isTouched = index == _touchedIndex;
                final percentage = (item.total / total * 100);

                return PieChartSectionData(
                  color: _parseColor(item.color),
                  value: item.total,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: isTouched ? 65 : 55,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _parseColor(item.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.name} (${CurrencyFormatter.format(item.total)})',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}