import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

class NotFoundView extends StatelessWidget {
  final String? attemptedRoute;

  const NotFoundView({
    super.key,
    this.attemptedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF121A27),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.logoSymbol,
                            height: 52,
                            width: 52,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('404')
                          .textColor(AppColors.primary)
                          .fontSize(48)
                          .fontWeight(FontWeight.bold)
                          .alignment(Alignment.center),
                      const SizedBox(height: 8),
                      const Text('Página no encontrada')
                          .textColor(AppColors.textPrimary)
                          .fontSize(24)
                          .fontWeight(FontWeight.bold)
                          .textAlignment(TextAlign.center)
                          .alignment(Alignment.center),
                      const SizedBox(height: 12),
                      const Text(
                        'La ruta a la que intentas acceder no existe o no se encuentra disponible.',
                      )
                          .textColor(AppColors.textMuted)
                          .fontSize(15)
                          .textAlignment(TextAlign.center)
                          .alignment(Alignment.center),
                      if (attemptedRoute != null &&
                          attemptedRoute!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            attemptedRoute!,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          )
                              .textColor(AppColors.secondary)
                              .fontSize(13),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home_outlined, size: 20),
                        label: const Text('Volver al inicio'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
