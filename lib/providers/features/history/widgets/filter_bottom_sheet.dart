import 'package:flutter/material.dart';

enum TransactionTypeFilter { all, income, expense }
enum PeriodFilter { all, thisMonth, lastMonth }

class HistoryFilter {
  final TransactionTypeFilter type;
  final PeriodFilter period;

  const HistoryFilter({
    this.type = TransactionTypeFilter.all,
    this.period = PeriodFilter.all,
  });

  HistoryFilter copyWith({
    TransactionTypeFilter? type,
    PeriodFilter? period,
  }) {
    return HistoryFilter(
      type: type ?? this.type,
      period: period ?? this.period,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final HistoryFilter currentFilter;

  const FilterBottomSheet({super.key, required this.currentFilter});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late HistoryFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          const Text('Jenis', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: _filter.type == TransactionTypeFilter.all,
                onSelected: (_) => setState(
                    () => _filter = _filter.copyWith(type: TransactionTypeFilter.all)),
              ),
              ChoiceChip(
                label: const Text('Pemasukan'),
                selected: _filter.type == TransactionTypeFilter.income,
                onSelected: (_) => setState(() =>
                    _filter = _filter.copyWith(type: TransactionTypeFilter.income)),
              ),
              ChoiceChip(
                label: const Text('Pengeluaran'),
                selected: _filter.type == TransactionTypeFilter.expense,
                onSelected: (_) => setState(() =>
                    _filter = _filter.copyWith(type: TransactionTypeFilter.expense)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Periode', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: _filter.period == PeriodFilter.all,
                onSelected: (_) =>
                    setState(() => _filter = _filter.copyWith(period: PeriodFilter.all)),
              ),
              ChoiceChip(
                label: const Text('Bulan Ini'),
                selected: _filter.period == PeriodFilter.thisMonth,
                onSelected: (_) => setState(
                    () => _filter = _filter.copyWith(period: PeriodFilter.thisMonth)),
              ),
              ChoiceChip(
                label: const Text('Bulan Lalu'),
                selected: _filter.period == PeriodFilter.lastMonth,
                onSelected: (_) => setState(
                    () => _filter = _filter.copyWith(period: PeriodFilter.lastMonth)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _filter),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Terapkan Filter'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}