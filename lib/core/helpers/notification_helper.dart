import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import '../constants/app_colors.dart';

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
        backgroundColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.alert:
        backgroundColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationType.danger:
        backgroundColor = AppColors.danger;
        icon = Icons.error_outline;
        break;
    }

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: <Widget>[
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(message)
            .textColor(Colors.black87)
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
