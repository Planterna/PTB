import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

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
              .textColor(AppColors.textPrimary)
              .fontSize(16)
              .fontWeight(FontWeight.bold),
          Text(widget.cardNumber)
              .textColor(AppColors.textMuted)
              .fontSize(14),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        
        SvgPicture.asset(
          AppAssets.logoSmall,
          width: 24,
          height: 24,
        )
            .padding(all: 8)
            .decorated(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
      ].toRow(),
      
      const SizedBox(height: 32),
      
      const Text('Saldo')
          .textColor(AppColors.textMuted)
          .fontSize(14),
      <Widget>[
        _obscureBalance
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Text('\$$displayBalance')
                    .textColor(AppColors.textPrimary)
                    .fontSize(24)
                    .fontWeight(FontWeight.bold),
              ).expanded()
            : Text('\$$displayBalance')
                .textColor(AppColors.textPrimary)
                .fontSize(24)
                .fontWeight(FontWeight.bold)
                .expanded(),
                
        IconButton(
          icon: Icon(
            _obscureBalance ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
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
          color: AppColors.surface,
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
