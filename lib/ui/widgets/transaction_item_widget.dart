import 'package:flutter/material.dart';
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

  String _resolveCategory() {
    if (category != null && category!.trim().isNotEmpty) return category!;
    final lower = name.toLowerCase();
    if (lower.contains('burger') ||
        lower.contains('restaurante') ||
        lower.contains('comida') ||
        lower.contains('caf') ||
        lower.contains('pizza') ||
        lower.contains('almuerzo')) {
      return 'Comida';
    }
    if (lower.contains('farmacia') ||
        lower.contains('salud') ||
        lower.contains('med') ||
        lower.contains('hospital') ||
        lower.contains('doctor')) {
      return 'Salud';
    }
    if (lower.contains('cine') ||
        lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('ocio') ||
        lower.contains('juego') ||
        lower.contains('steam')) {
      return 'Ocio';
    }
    switch (type) {
      case TransactionType.purchase:
        return 'Compras';
      case TransactionType.deposit:
        return 'Depósito';
      case TransactionType.subscription:
        return 'Suscripción';
      case TransactionType.transfer:
        return 'Transferencia';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final formattedValue = '\$${value.abs().toStringAsFixed(2)}';
    final displayAmount = isPositive ? '+$formattedValue' : '-$formattedValue';
    final amountColor = isPositive ? AppColors.accent : AppColors.textPrimary;
    final resolvedCategory = _resolveCategory();

    Widget transactionCard = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _getIconForCategory(resolvedCategory),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    resolvedCategory,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            displayAmount,
            style: AppTheme.amountStyle(
              fontSize: 16,
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (date != null && date!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
            child: Text(
              date!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          transactionCard,
        ],
      );
    }

    return transactionCard;
  }
}
