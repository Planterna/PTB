import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/bank_card_widget.dart';
import '../viewmodels/home_viewmodel.dart';

class PaymentsView extends StatelessWidget {
  final HomeViewModel viewModel;

  const PaymentsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: <Widget>[
        const SizedBox(height: 20),
        const Text('Realizar Pagos')
            .textColor(AppColors.textPrimary)
            .fontSize(24)
            .fontWeight(FontWeight.bold)
            .alignment(Alignment.centerLeft)
            .padding(horizontal: 24),
        const SizedBox(height: 8),
        const Text('Tus tarjetas asociadas listas para comprar')
            .textColor(AppColors.textMuted)
            .fontSize(14)
            .alignment(Alignment.centerLeft)
            .padding(horizontal: 24),
        const SizedBox(height: 24),

        ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final creditCardsCount = viewModel.cards
                .where((c) => c.tipoTarjeta == 'credito')
                .length;

            double requiredBalance = double.infinity;
            if (creditCardsCount == 0)
              requiredBalance = 1000;
            else if (creditCardsCount == 1)
              requiredBalance = 5000;
            else if (creditCardsCount == 2)
              requiredBalance = 10000;
            else if (creditCardsCount == 3)
              requiredBalance = 20000;
            else if (creditCardsCount == 4)
              requiredBalance = 50000;

            final savingsAccounts = viewModel.accounts
                .where((acc) => acc.tipoCuenta == 'ahorro')
                .toList();
            final eligibleAccounts = savingsAccounts
                .where((acc) => acc.saldoCuenta >= requiredBalance)
                .toList();
            final hasEligibleAccount =
                eligibleAccounts.isNotEmpty && creditCardsCount < 5;

            return SingleChildScrollView(
              child: <Widget>[
                if (hasEligibleAccount)
                  <Widget>[
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(height: 8),
                        const Text(
                              '¡Eres elegible para una Tarjeta de Crédito!',
                            )
                            .textColor(AppColors.textPrimary)
                            .fontSize(16)
                            .fontWeight(FontWeight.bold),
                        const SizedBox(height: 8),
                        Text(
                              'Por tener un saldo mayor a \$${requiredBalance.toInt()} en tu cuenta de ahorro, puedes solicitar tu tarjeta #${creditCardsCount + 1}.',
                            )
                            .textColor(AppColors.textMuted)
                            .fontSize(12)
                            .textAlignment(TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () async {
                            // Usar la primera cuenta elegible
                            final error = await viewModel.requestCreditCard(
                              eligibleAccounts.first.idCuenta,
                            );
                            if (context.mounted) {
                              if (error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '¡Tarjeta solicitada con éxito!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Solicitar Tarjeta de Crédito',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                      .toColumn()
                      .padding(all: 20)
                      .decorated(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                        ),
                      )
                      .padding(horizontal: 24, bottom: 24),

                if (viewModel.cards.isEmpty)
                  const Center(
                    child: Text(
                      'No tienes tarjetas asociadas.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                else
                  ...viewModel.cards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24.0,
                        left: 24,
                        right: 24,
                      ),
                      child: SizedBox(
                        height: 200, // Hacer la tarjeta más grande
                        child: BankCardWidget(
                          cardName: card.cardName,
                          cardNumber: card.cardNumber,
                          tipoTarjeta: card.tipoTarjeta,
                        ),
                      ),
                    );
                  }),
              ].toColumn(),
            );
          },
        ).expanded(),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    );
  }
}
