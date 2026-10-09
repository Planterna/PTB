class AccountModel {
  final String idCuenta;
  final String idUsuario;
  final String tipoCuenta; // 'ahorro' or 'corriente'
  final String numeroCuenta;
  final double saldoCuenta;

  AccountModel({
    required this.idCuenta,
    required this.idUsuario,
    required this.tipoCuenta,
    required this.numeroCuenta,
    required this.saldoCuenta,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      idCuenta: json['id_cuenta'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      tipoCuenta: json['tipo_cuenta'] ?? 'ahorro',
      numeroCuenta: json['numero_cuenta'] ?? '',
      saldoCuenta: (json['saldo_cuenta'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cuenta': idCuenta,
      'id_usuario': idUsuario,
      'tipo_cuenta': tipoCuenta,
      'numero_cuenta': numeroCuenta,
      'saldo_cuenta': saldoCuenta,
    };
  }
}
