import 'package:flutter/material.dart';
import 'package:money_tracker/data/models/transaction_model.dart';
import 'package:money_tracker/core/utils/currency_formatter.dart';

class RecentTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Belum ada transaksi.\nYuk mulai catat keuanganmu!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      // ignore: unnecessary_underscores
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.type == 'income';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: isIncome
                ? Colors.green.withValues(alpha:0.15)
                : Colors.red.withValues(alpha:0.15),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          title: Text(tx.categoryName ?? '-'),
          subtitle: Text(
            tx.note?.isNotEmpty == true ? tx.note! : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}