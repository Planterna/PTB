enum TransactionType { transfer, purchase, subscription, deposit }

class TransactionModel {
  final String id;
  final String name;
  final double value;
  final String? date;
  final TransactionType type;
  final String? category;

  TransactionModel({
    required this.id,
    required this.name,
    required this.value,
    this.date,
    required this.type,
    this.category,
  });

  String get displayCategory {
    if (category != null && category!.trim().isNotEmpty) {
      return category!;
    }
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
}
