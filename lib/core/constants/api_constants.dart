import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // URLs del backend
  static const String localUrl = 'http://127.0.0.1:3000/api';
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000/api';
  static const String vercelUrl = 'https://ptbbackend.vercel.app/api';

  // Alterna entre el backend local (localhost:3000) o Vercel
  static const bool useLocalBackend = false;

  static String get baseUrl {
    const customUrl = String.fromEnvironment('BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;

    if (!useLocalBackend) {
      return vercelUrl;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return androidEmulatorUrl;
    }
    return localUrl;
  }

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String accounts = '/cuentas';
  static const String currentAccount = '/cuentas/corriente';
  static const String currentAccountRequests = '/cuentas/solicitudes-corriente';
  static const String validateAccount = '/cuentas/validar';
  static const String validateInterbankAccount =
      '/cuentas/validar-interbancaria';
  static const String transfer = '/cuentas/transferir';
  static const String transferInterbank = '/cuentas/transferir-interbancaria';
  static const String banks = '/cuentas/bancos';
  static const String cards = '/tarjetas';
  static const String transactions = '/movimientos';
  static const String profile = '/usuario/perfil';

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
