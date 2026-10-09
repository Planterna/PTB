class ApiConstants {
  // Dominio base de nuestro backend
  // Si corres el emulador de Android usa 'http://10.0.2.2:3000/api'
  // Si corres la app web o en Linux local usa 'http://127.0.0.1:3000/api'
  static const String baseUrl = 'https://ptbbackend.vercel.app/api';

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String accounts = '/cuentas';
  static const String cards = '/tarjetas';
  static const String transactions = '/movimientos';

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
