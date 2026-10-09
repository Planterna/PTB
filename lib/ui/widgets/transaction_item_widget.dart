import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import 'package:styled_widget/styled_widget.dart';
import '../../data/models/transaction_model.dart';

class TransactionItemWidget extends StatelessWidget {
  final String name; 
  final double value; 
  final String? date; 
  final TransactionType type; 

  const TransactionItemWidget({
    super.key,
    required this.name,
    required this.value,
    this.date,
    required this.type,
  });

  Widget _getIconForType() {
    switch (type) {
      case TransactionType.transfer:
        return const Icon(Icons.person, color: AppColors.primary, size: 24);
      case TransactionType.purchase:
        return const Icon(Icons.shopping_bag, color: AppColors.primary, size: 24);
      case TransactionType.subscription:
        return const Icon(Icons.autorenew, color: AppColors.textMuted, size: 24);
      case TransactionType.deposit:
        return const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final formattedValue = '\$${value.abs().toStringAsFixed(2)}';
    final displayAmount = isPositive ? '+$formattedValue' : '-$formattedValue';

    final amountColor = isPositive ? AppColors.accent : AppColors.textPrimary;

    Widget transactionCard =
        <Widget>[
              _getIconForType()
                  .padding(all: 8)
                  .decorated(
                    color: AppColors.background, 
                    borderRadius: BorderRadius.circular(14)
                  ),
              const SizedBox(width: 16),
              Text(name)
                  .textColor(AppColors.textPrimary)
                  .fontSize(16)
                  .fontWeight(FontWeight.w500)
                  .expanded(),
              Text(displayAmount)
                  .textColor(amountColor)
                  .fontSize(16)
                  .fontWeight(FontWeight.bold),
            ]
            .toRow()
            .padding(all: 16)
            .decorated(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.background.withOpacity(0.12),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            )
            .padding(bottom: 16);

    if (date != null && date!.isNotEmpty) {
      return <Widget>[
        Text(date!)
            .textColor(AppColors.textMuted)
            .fontSize(14)
            .fontWeight(FontWeight.bold)
            .padding(bottom: 8, top: 8),
        transactionCard,
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
    }

    return transactionCard;
  }
}
