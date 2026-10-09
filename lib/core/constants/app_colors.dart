import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal
  static const Color background = Color(0xFF000000);
  static const Color primary = Color(0xFFA4BCFC);
  static const Color secondary = Color(0xFFCDE7FC);
  static const Color accent = Color(0xFFA7DBCB);
  static const Color softAccent = Color(0xFFC4DED6);

  // Superficies (para contraste sobre el fondo negro)
  static const Color surface = Color(0xFF14171D); // Mantener un gris oscuro para tarjetas base
  static const Color surfaceLight = Color(0xFF1C2028); 

  // Textos
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA8AEB8);
  static const Color textDark = Color(0xFF000000); // Texto sobre colores claros (primary, secondary)

  // Transacciones y Estados
  static const Color transfer = primary;
  static const Color purchase = secondary;
  static const Color subscription = softAccent;
  static const Color deposit = accent;

  static const Color success = accent;
  static const Color danger = Color(0xFFFF8A8A); // Rojo para errores
  static const Color warning = Color(0xFFFFD166);
}
