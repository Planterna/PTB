import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class BankCardWidget extends StatelessWidget {
  final String cardName;
  final String cardNumber;
  final String tipoTarjeta;

  const BankCardWidget({
    super.key,
    required this.cardName,
    required this.cardNumber,
    required this.tipoTarjeta,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar gradiente basado en el tipo de tarjeta (Débito vs Crédito)
    final bool isCredit = tipoTarjeta == 'credito';
    
    // Débito: Gradiente azul oscuro clásico
    // Crédito: Gradiente dorado o oscuro premium
    final List<Color> cardGradient = isCredit
        ? [const Color(0xFFD4AF37), const Color(0xFFAA8222)] // Dorado premium
        : [const Color(0xFF2C3E50), const Color(0xFF141E30)]; // Azul oscuro profundo

    final textColor = isCredit ? AppColors.background : AppColors.textPrimary;
    final mutedTextColor = textColor.withOpacity(0.70);

    return <Widget>[
      // Fila Superior: Nombre del banco / Chip
      <Widget>[
        <Widget>[
          Text(cardName)
              .textColor(textColor)
              .fontSize(18)
              .fontWeight(FontWeight.bold),
          const Text('Prestige Trust Bank')
              .textColor(mutedTextColor)
              .fontSize(12),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        
        SvgPicture.asset(
          AppAssets.logoSmall,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        )
            .padding(all: 8)
            .decorated(
              color: textColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
      ].toRow(),
      
      const Spacer(),

      // Fila Inferior: Número de Tarjeta y Marca
      <Widget>[
        Text(cardNumber.length == 16 
              ? '**** **** **** ${cardNumber.substring(12)}' 
              : cardNumber)
            .textColor(textColor)
            .fontSize(20)
            .letterSpacing(2)
            .fontWeight(FontWeight.w500)
            .expanded(),
            
        Icon(Icons.credit_card, color: textColor, size: 32),
      ].toRow(),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 24)
        .decorated(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withOpacity(0.45),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        );
  }
}
