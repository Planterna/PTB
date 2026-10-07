import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class TransactionItemWidget extends StatelessWidget {
  final String name; // Nombre o empresa
  final double value; // Valor de la transacción
  final String? date; // Fecha (opcional, si se manda, aparece como cabecera)
  final Widget companyLogo; // Logo de la empresa o ícono

  const TransactionItemWidget({
    Key? key,
    required this.name,
    required this.value,
    this.date,
    required this.companyLogo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir si es ingreso o egreso para formatear el texto
    final isPositive = value >= 0;
    final formattedValue = '\$${value.abs().toStringAsFixed(2)}';
    final displayAmount = isPositive ? '+$formattedValue' : '-$formattedValue';

    // Tarjeta del movimiento
    Widget transactionCard = <Widget>[
      companyLogo.padding(all: 8).decorated(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      const SizedBox(width: 16),
      Text(name)
          .textColor(const Color(0xFFA5E6D8))
          .fontSize(14)
          .fontWeight(FontWeight.w500)
          .expanded(),
      Text(displayAmount)
          .textColor(const Color(0xFFA5E6D8)) // Podríamos cambiar el color según isPositive si se desea
          .fontSize(14)
          .fontWeight(FontWeight.bold),
    ]
        .toRow()
        .padding(all: 16)
        .decorated(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
        )
        .padding(bottom: 16);

    // Si pasamos una fecha, agregamos la cabecera arriba de la tarjeta
    if (date != null && date!.isNotEmpty) {
      return <Widget>[
        Text(date!)
            .textColor(const Color(0xFFA5E6D8))
            .fontSize(14)
            .fontWeight(FontWeight.bold)
            .padding(bottom: 8, top: 8),
        transactionCard,
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
    }

    return transactionCard;
  }
}
