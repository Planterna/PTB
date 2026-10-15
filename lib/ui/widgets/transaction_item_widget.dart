import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';

class TransactionItemWidget extends StatelessWidget {
  final String name;
  final double value;
  final String? date;
  final TransactionType type;
  final String? category;

  const TransactionItemWidget({
    super.key,
    required this.name,
    required this.value,
    this.date,
    required this.type,
    this.category,
  });

  Widget _getIconForCategory(String categoryName) {
    final cat = categoryName.toLowerCase();
    if (cat.contains('comida') || cat.contains('restaurante')) {
      return const Icon(Icons.restaurant, color: AppColors.primary, size: 22);
    }
    if (cat.contains('salud') || cat.contains('farmacia')) {
      return const Icon(Icons.medical_services_outlined, color: AppColors.accent, size: 22);
    }
    if (cat.contains('ocio') || cat.contains('cine') || cat.contains('entretenimiento')) {
      return const Icon(Icons.local_movies_outlined, color: AppColors.warning, size: 22);
    }

    switch (type) {
      case TransactionType.transfer:
        return const Icon(Icons.swap_horiz, color: AppColors.primary, size: 22);
      case TransactionType.purchase:
        return const Icon(Icons.shopping_bag_outlined, color: AppColors.secondary, size: 22);
      case TransactionType.subscription:
        return const Icon(Icons.autorenew, color: AppColors.softAccent, size: 22);
      case TransactionType.deposit:
        return const Icon(Icons.arrow_downward, color: AppColors.accent, size: 22);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final formattedValue = '\$${value.abs().toStringAsFixed(2)}';
    final displayAmount = isPositive ? '+$formattedValue' : '-$formattedValue';
    final amountColor = isPositive ? AppColors.accent : AppColors.textPrimary;
    final resolvedCategory = category ?? 'General';

    final transactionCard = <Widget>[
      _getIconForCategory(resolvedCategory)
          .padding(all: 10)
          .decorated(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
      const SizedBox(width: 14),
      <Widget>[
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            .textColor(AppColors.textPrimary)
            .fontSize(15)
            .fontWeight(FontWeight.w500),
        const SizedBox(height: 4),
        Text(resolvedCategory)
            .textColor(AppColors.textMuted)
            .fontSize(11)
            .fontWeight(FontWeight.w500)
            .padding(horizontal: 6, vertical: 2)
            .decorated(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
      const SizedBox(width: 12),
      Text(
        displayAmount,
        style: AppTheme.amountStyle(
          fontSize: 16,
          color: amountColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]
        .toRow()
        .padding(horizontal: 16, vertical: 14)
        .decorated(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        )
        .padding(bottom: 12);

    if (date != null && date!.isNotEmpty) {
      return <Widget>[
        Text(date!)
            .textColor(AppColors.textMuted)
            .fontSize(13)
            .fontWeight(FontWeight.bold)
            .padding(bottom: 8, top: 4),
        transactionCard,
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
    }

    return transactionCard;
  }
}
