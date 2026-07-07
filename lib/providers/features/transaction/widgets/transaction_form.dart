import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/data/models/category_model.dart';
import 'package:money_tracker/data/models/transaction_model.dart';
import 'package:money_tracker/providers/category_provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'amount_input_field.dart';
import 'category_picker.dart';
import 'add_category_sheet.dart';

class TransactionForm extends StatefulWidget {
  final String type;
  final TransactionModel? existingTransaction; // null = tambah baru

  const TransactionForm({
    super.key,
    required this.type,
    this.existingTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get isIncome => widget.type == 'income';
  Color get accentColor => isIncome ? Colors.green : Colors.red;

  @override
void initState() {
  super.initState();

  final existing = widget.existingTransaction;
  if (existing != null) {
    _amountController.text = existing.amount.toStringAsFixed(0);
    _noteController.text = existing.note ?? '';
    _selectedDate = existing.transactionDate;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final categoryProvider = context.read<CategoryProvider>();
    await categoryProvider.loadCategories();

    if (existing != null && mounted) {
      final list = isIncome
          ? categoryProvider.incomeCategories
          : categoryProvider.expenseCategories;
      setState(() {
        _selectedCategory =
            list.where((c) => c.id == existing.categoryId).firstOrNull;
      });
    }
  });
}

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _openAddCategorySheet() async {
    final newCategoryName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddCategorySheet(type: widget.type),
    );

    if (newCategoryName != null && mounted) {
      final categoryProvider = context.read<CategoryProvider>();
      await categoryProvider.addCategory(
        CategoryModel(
          name: newCategoryName,
          type: widget.type,
          icon: 'ti-dots',
          color: isIncome ? '#1D9E75' : '#D85A30',
        ),
      );
      // Auto-select kategori yang baru dibuat
      final updated = isIncome
          ? categoryProvider.incomeCategories
          : categoryProvider.expenseCategories;
      setState(() {
        _selectedCategory = updated.firstWhere(
          (c) => c.name == newCategoryName,
          orElse: () => updated.last,
        );
      });
    }
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
    );
    return;
  }

  setState(() => _isSaving = true);

  final cleanedAmount = _amountController.text.replaceAll('.', '');
  final amount = double.parse(cleanedAmount);
  final isEditing = widget.existingTransaction != null;

  final tx = TransactionModel(
    id: isEditing ? widget.existingTransaction!.id : null,
    categoryId: _selectedCategory!.id!,
    type: widget.type,
    amount: amount,
    note: _noteController.text.trim(),
    transactionDate: _selectedDate,
    createdAt: isEditing ? widget.existingTransaction!.createdAt : DateTime.now(),
    updatedAt: isEditing ? DateTime.now() : null,
  );

  final txProvider = context.read<TransactionProvider>();
  if (isEditing) {
    await txProvider.updateTransaction(tx);
  } else {
    await txProvider.addTransaction(tx);
  }

  if (mounted) {
    setState(() => _isSaving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing
            ? 'Transaksi berhasil diperbarui'
            : (isIncome ? 'Pemasukan berhasil dicatat' : 'Pengeluaran berhasil dicatat')),
        backgroundColor: accentColor,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = isIncome
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    return Scaffold(
      appBar: AppBar(
  title: Text(widget.existingTransaction != null
      ? 'Edit Transaksi'
      : (isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran')),
),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Input jumlah
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: AmountInputField(
                controller: _amountController,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : CategoryPicker(
                    categories: categories,
                    selected: _selectedCategory,
                    accentColor: accentColor,
                    onSelect: (cat) => setState(() => _selectedCategory = cat),
                    onAddCategory: _openAddCategorySheet,
                  ),
            const SizedBox(height: 24),

            const Text(
              'Tanggal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Catatan (opsional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Misal: Makan siang di kantin',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}