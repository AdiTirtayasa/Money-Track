import 'package:flutter/material.dart';
import '../widgets/transaction_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionForm(type: 'expense');
  }
}