import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isExpense = transaction.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.arrow_outward : Icons.call_received,
              color: isExpense ? AppColors.error : AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  transaction.category,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? "-" : "+"} ${currencyFormat.format(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isExpense ? AppColors.error : AppColors.success,
                ),
              ),
              Text(
                DateFormat('dd MMM').format(transaction.date),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
