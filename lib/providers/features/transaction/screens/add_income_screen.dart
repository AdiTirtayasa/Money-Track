import 'package:flutter/material.dart';
import '../widgets/transaction_form.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionForm(type: 'income');
  }
}