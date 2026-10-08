import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BankCardWidget extends StatefulWidget {
  final String cardName;
  final String cardNumber;
  final double balance;

  const BankCardWidget({
    super.key,
    required this.cardName,
    required this.cardNumber,
    required this.balance,
  });

  @override
  State<BankCardWidget> createState() => _BankCardWidgetState();
}

class _BankCardWidgetState extends State<BankCardWidget> {
  bool _obscureBalance = false;

  @override
  Widget build(BuildContext context) {
    final displayBalance = widget.balance.toStringAsFixed(2);

    return <Widget>[
      <Widget>[
        <Widget>[
          Text(widget.cardName)
              .textColor(const Color(0xFFFFFFFF))
              .fontSize(16)
              .fontWeight(FontWeight.bold),
          Text(widget.cardNumber)
              .textColor(const Color(0xFFA8AEB8))
              .fontSize(14),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        
        SvgPicture.asset(
          'assets/logos/logo-prestige-trust-bank-small-icon.svg',
          width: 24,
          height: 24,
        )
            .padding(all: 8)
            .decorated(
              color: const Color(0xFF000000), // Contraste oscuro dentro de la tarjeta
              borderRadius: BorderRadius.circular(14),
            ),
      ].toRow(),
      
      const SizedBox(height: 32),
      
      const Text('Saldo')
          .textColor(const Color(0xFFA8AEB8))
          .fontSize(14),
      <Widget>[
        _obscureBalance
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Text('\$$displayBalance')
                    .textColor(const Color(0xFFFFFFFF))
                    .fontSize(24)
                    .fontWeight(FontWeight.bold),
              ).expanded()
            : Text('\$$displayBalance')
                .textColor(const Color(0xFFFFFFFF))
                .fontSize(24)
                .fontWeight(FontWeight.bold)
                .expanded(),
                
        IconButton(
          icon: Icon(
            _obscureBalance ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFA8AEB8),
            size: 24,
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
        .padding(all: 24)
        .decorated(
          color: const Color(0xFF14171D), // Nuevo fondo de superficie
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        );
  }
}
