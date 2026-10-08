import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

enum NotificationType { success, alert, danger }

class NotificationHelper {
  static void show(
    BuildContext context, {
    required String message,
    required NotificationType type,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = const Color(0xFF2E7D32); // Verde oscuro
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.alert:
        backgroundColor = const Color(0xFFF57C00); // Naranja
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationType.danger:
        backgroundColor = const Color(0xFFD32F2F); // Rojo
        icon = Icons.error_outline;
        break;
    }

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent, // Transparente para usar el diseño del contenedor interno
      elevation: 0,
      content: <Widget>[
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(message)
            .textColor(Colors.white)
            .fontSize(14)
            .fontWeight(FontWeight.w500)
            .expanded(),
      ]
          .toRow()
          .padding(all: 16)
          .decorated(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      duration: const Duration(seconds: 3),
    );

    // Muestra el SnackBar ocultando el anterior si existe
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
