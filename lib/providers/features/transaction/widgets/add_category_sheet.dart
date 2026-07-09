import 'package:flutter/material.dart';

class AddCategorySheet extends StatefulWidget {
  final String type; // 'income' atau 'expense'

  const AddCategorySheet({super.key, required this.type});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _controller = TextEditingController();
 void _handleSaveCategory() {
  final name = _controller.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama kategori wajib diisi')),
    );
    return;
  }
  Navigator.of(context).pop(name);
 }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Kategori ${widget.type == 'income' ? 'Pemasukan' : 'Pengeluaran'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nama kategori, misal "Laundry"',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:  _handleSaveCategory,
              child:
              const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Simpan Kategori'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}