import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

enum TransactionType { transfer, purchase, subscription, deposit }

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
        return const Icon(Icons.person, color: Color(0xFFA4BCFC), size: 24);
      case TransactionType.purchase:
        return const Icon(Icons.shopping_bag, color: Color(0xFFCFEAFF), size: 24);
      case TransactionType.subscription:
        return const Icon(Icons.autorenew, color: Color(0xFFA8AEB8), size: 24);
      case TransactionType.deposit:
        return const Icon(Icons.account_balance_wallet, color: Color(0xFFA7DBCB), size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final formattedValue = '\$${value.abs().toStringAsFixed(2)}';
    final displayAmount = isPositive ? '+$formattedValue' : '-$formattedValue';

    final amountColor = isPositive ? const Color(0xFFA7DBCB) : const Color(0xFFFFFFFF);

    Widget transactionCard =
        <Widget>[
              _getIconForType()
                  .padding(all: 8)
                  .decorated(
                    color: const Color(0xFF000000), 
                    borderRadius: BorderRadius.circular(14)
                  ),
              const SizedBox(width: 16),
              Text(name)
                  .textColor(const Color(0xFFFFFFFF))
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
              color: const Color(0xFF14171D),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            )
            .padding(bottom: 16);

    if (date != null && date!.isNotEmpty) {
      return <Widget>[
        Text(date!)
            .textColor(const Color(0xFFA8AEB8))
            .fontSize(14)
            .fontWeight(FontWeight.bold)
            .padding(bottom: 8, top: 8),
        transactionCard,
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
    }

    return transactionCard;
  }
}
