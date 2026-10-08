enum TransactionType { transfer, purchase, subscription, deposit }

class TransactionModel {
  final String id;
  final String name;
  final double value;
  final String? date;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.name,
    required this.value,
    this.date,
    required this.type,
  });
}
