class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'No es posible conectarse al servidor en estos momentos'])
      : super(statusCode: 0);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Sesión expirada o credenciales inválidas'])
      : super(statusCode: 401);
}
