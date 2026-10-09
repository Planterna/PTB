import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../data/models/account_model.dart';

class AccountCardWidget extends StatefulWidget {
  final AccountModel account;

  const AccountCardWidget({
    super.key,
    required this.account,
  });

  @override
  State<AccountCardWidget> createState() => _AccountCardWidgetState();
}

class _AccountCardWidgetState extends State<AccountCardWidget> {
  bool _obscureBalance = false;

  @override
  Widget build(BuildContext context) {
    final displayBalance = widget.account.saldoCuenta.toStringAsFixed(2);
    final isAhorro = widget.account.tipoCuenta == 'ahorro';
    final accountTypeLabel = isAhorro ? 'Cuenta de Ahorros' : 'Cuenta Corriente';

    // Degradados dinámicos
    final List<Color> cardGradient = isAhorro
        ? [AppColors.secondary, const Color(0xFF98C1E5)] // Degradado celeste
        : [AppColors.softAccent, AppColors.accent]; // Degradado verdoso

    final textColor = AppColors.textDark;
    final mutedColor = AppColors.textDark.withOpacity(0.6);

    return <Widget>[
      <Widget>[
        <Widget>[
          Text(accountTypeLabel)
              .textColor(textColor)
              .fontSize(16)
              .fontWeight(FontWeight.bold),
          Text(widget.account.numeroCuenta)
              .textColor(mutedColor)
              .fontSize(14),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        
        SvgPicture.asset(
          AppAssets.logoSmall,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        )
            .padding(all: 8)
            .decorated(
              color: AppColors.background.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
      ].toRow(),
      
      const SizedBox(height: 32),
      
      const Text('Saldo Disponible')
          .textColor(mutedColor)
          .fontSize(14),
      <Widget>[
        _obscureBalance
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Text('\$$displayBalance')
                    .textColor(textColor)
                    .fontSize(24)
                    .fontWeight(FontWeight.bold),
              ).expanded()
            : Text('\$$displayBalance')
                .textColor(textColor)
                .fontSize(24)
                .fontWeight(FontWeight.bold)
                .expanded(),
                
        IconButton(
          icon: Icon(
            _obscureBalance ? Icons.visibility_off : Icons.visibility,
            color: mutedColor,
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
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withOpacity(0.26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        );
  }
}
