class CurrentAccountRequestModel {
  final bool tieneResidenciaUsa;
  final bool declaraImpuestosOtroPais;
  final String modeloChequera;
  final int numeroCheques;
  final String tipoChequera;
  final String nombreEnDocumentos;
  final String agenciaRetiro;
  final String metodoPago; // 'DEBITO_AHORROS' | 'PAGO_VENTANILLA'
  final String? idCuentaOrigen;
  final String? numeroCuentaOrigen;

  CurrentAccountRequestModel({
    required this.tieneResidenciaUsa,
    required this.declaraImpuestosOtroPais,
    required this.modeloChequera,
    required this.numeroCheques,
    required this.tipoChequera,
    required this.nombreEnDocumentos,
    required this.agenciaRetiro,
    required this.metodoPago,
    this.idCuentaOrigen,
    this.numeroCuentaOrigen,
  });

  Map<String, dynamic> toJson() => {
        'tiene_residencia_usa': tieneResidenciaUsa,
        'declara_impuestos_otro_pais': declaraImpuestosOtroPais,
        'modelo_chequera': modeloChequera,
        'numero_cheques': numeroCheques,
        'tipo_chequera': tipoChequera,
        'nombre_en_documentos': nombreEnDocumentos,
        'agencia_retiro': agenciaRetiro,
        'metodo_pago': metodoPago,
        if (idCuentaOrigen != null) 'id_cuenta_origen': idCuentaOrigen,
        if (numeroCuentaOrigen != null)
          'numero_cuenta_origen': numeroCuentaOrigen,
      };
}

class CurrentAccountResponseModel {
  final bool exito;
  final String metodoPago;
  final String estado;
  final String mensaje;
  final Map<String, dynamic>? cuenta;
  final Map<String, dynamic>? solicitud;

  CurrentAccountResponseModel({
    required this.exito,
    required this.metodoPago,
    required this.estado,
    required this.mensaje,
    this.cuenta,
    this.solicitud,
  });

  factory CurrentAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return CurrentAccountResponseModel(
      exito: json['exito'] == true,
      metodoPago: json['metodo_pago']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      cuenta: json['cuenta'] is Map<String, dynamic>
          ? json['cuenta'] as Map<String, dynamic>
          : null,
      solicitud: json['solicitud'] is Map<String, dynamic>
          ? json['solicitud'] as Map<String, dynamic>
          : null,
    );
  }
}
