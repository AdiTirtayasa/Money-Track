import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/data/models/transaction_model.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'package:money_tracker/providers/features/transaction/screens/transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  HistoryFilter _filter = const HistoryFilter();

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    var result = all;

    if (_filter.type == TransactionTypeFilter.income) {
      result = result.where((t) => t.type == 'income').toList();
    } else if (_filter.type == TransactionTypeFilter.expense) {
      result = result.where((t) => t.type == 'expense').toList();
    }

    final now = DateTime.now();
    if (_filter.period == PeriodFilter.thisMonth) {
      result = result
          .where((t) =>
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month)
          .toList();
    } else if (_filter.period == PeriodFilter.lastMonth) {
      final lastMonth = DateTime(now.year, now.month - 1);
      result = result
          .where((t) =>
              t.transactionDate.year == lastMonth.year &&
              t.transactionDate.month == lastMonth.month)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return (t.categoryName ?? '').toLowerCase().contains(q) ||
            (t.note ?? '').toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final key =
          '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<HistoryFilter>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FilterBottomSheet(currentFilter: _filter),
    );
    if (result != null) setState(() => _filter = result);
  }

  bool get _isFilterActive =>
      _filter.type != TransactionTypeFilter.all ||
      _filter.period != PeriodFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final filtered = _applyFilters(provider.transactions);
    final grouped = _groupByDate(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _isFilterActive,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari kategori atau catatan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada transaksi ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              ...entry.value.map((tx) => TransactionListItem(
                                    transaction: tx,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TransactionDetailScreen(transaction: tx),
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}