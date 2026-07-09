import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding:   const EdgeInsets.symmetric(horizontal: 8.0), 
    child: Row(
      children: [
        Text(
          'Rp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor, width: 0.5),
              ),
            ),
            validator: (value) {
        final cleaned = (value ?? '').replaceAll('.', '');
        if (cleaned.isEmpty) return 'Jumlah wajib diisi';
        final amount = int.tryParse(cleaned) ?? 0;
        if (amount <= 0) return 'Jumlah harus lebih dari 0';
        return null;
      },
          ),
        ),
      ],
    )
    );
  }
}


// Formatter otomatis menambahkan titik ribuan saat mengetik, misal 15000 -> 15.000
class _ThousandsFormatter extends TextInputFormatter {
  final _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digitsOnly = newValue.text.replaceAll('.', '');
    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}