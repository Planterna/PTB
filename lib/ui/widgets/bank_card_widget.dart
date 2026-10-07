import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class BankCardWidget extends StatefulWidget {
  final String cardName; // Ej: "Cuenta de ahorro", "Tarjeta de Crédito"
  final String cardNumber; // Ej: "0123456789"
  final double balance; // Ej: 1000.0

  const BankCardWidget({
    Key? key,
    required this.cardName,
    required this.cardNumber,
    required this.balance,
  }) : super(key: key);

  @override
  State<BankCardWidget> createState() => _BankCardWidgetState();
}

class _BankCardWidgetState extends State<BankCardWidget> {
  bool _obscureBalance = false;

  @override
  Widget build(BuildContext context) {
    // Formatear el saldo para mostrarlo (podrías usar intl para formato de moneda)
    final displayBalance = widget.balance.toStringAsFixed(2);

    return <Widget>[
      // Parte superior de la tarjeta (Nombre y Número)
      <Widget>[
        <Widget>[
          Text(widget.cardName)
              .textColor(Colors.white)
              .fontSize(14)
              .fontWeight(FontWeight.w500),
          Text(widget.cardNumber)
              .textColor(Colors.white)
              .fontSize(14),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        
        // Icono / Logo del banco o tipo de tarjeta
        const Icon(Icons.account_balance, color: Color(0xFFA5E6D8), size: 24)
            .padding(all: 10)
            .decorated(
              color: const Color(0xFF1E2228),
              borderRadius: BorderRadius.circular(12),
            ),
      ].toRow(),
      
      const SizedBox(height: 30),
      
      // Saldo y botón de ocultar
      const Text('Saldo')
          .textColor(Colors.white)
          .fontSize(14),
      <Widget>[
        Text(_obscureBalance ? '****' : '\$$displayBalance')
            .textColor(Colors.white)
            .fontSize(32)
            .fontWeight(FontWeight.bold)
            .expanded(),
        IconButton(
          icon: Icon(
            _obscureBalance ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscureBalance = !_obscureBalance;
            });
          },
        ),
      ].toRow(),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 20)
        .decorated(
          color: const Color(0xFF0F111A), // Fondo azul muy oscuro
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        );
  }
}
