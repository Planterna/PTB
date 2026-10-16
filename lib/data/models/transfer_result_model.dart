class TransferResult {
  final String referencia;
  final String mensaje;
  final String cuentaOrigen;
  final String cuentaDestino;
  final String titularOrigen;
  final String titularDestino;
  final double monto;
  final double comision;
  final double? totalDebitado;
  final String? bancoDestino;
  final String? descripcion;
  final double? saldoRestanteOrigen;
  final DateTime? fecha;

  const TransferResult({
    required this.referencia,
    required this.mensaje,
    required this.cuentaOrigen,
    required this.cuentaDestino,
    required this.titularOrigen,
    required this.titularDestino,
    required this.monto,
    this.comision = 0.0,
    this.totalDebitado,
    this.bancoDestino,
    this.descripcion,
    this.saldoRestanteOrigen,
    this.fecha,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    final t = json['transferencia'] as Map<String, dynamic>? ?? {};
    final monto = (t['monto'] as num?)?.toDouble() ?? 0.0;
    final comision = (t['comision'] as num?)?.toDouble() ?? 0.0;
    final totalDebitado = (t['total_debitado'] as num?)?.toDouble() ?? (monto + comision);

    return TransferResult(
      referencia: json['referencia']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? 'Transferencia realizada exitosamente',
      cuentaOrigen: (t['cuenta_origen'] ?? '').toString(),
      cuentaDestino: (t['cuenta_destino'] ?? '').toString(),
      titularOrigen: (t['titular_origen'] ?? '').toString(),
      titularDestino: (t['titular_destino'] ?? '').toString(),
      monto: monto,
      comision: comision,
      totalDebitado: totalDebitado,
      bancoDestino: t['banco_destino']?.toString(),
      descripcion: t['descripcion']?.toString(),
      saldoRestanteOrigen: (t['saldo_restante_origen'] as num?)?.toDouble(),
      fecha: t['fecha'] != null ? DateTime.tryParse(t['fecha'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'referencia': referencia,
    'mensaje': mensaje,
    'transferencia': {
      'cuenta_origen': cuentaOrigen,
      'cuenta_destino': cuentaDestino,
      'titular_origen': titularOrigen,
      'titular_destino': titularDestino,
      'monto': monto,
      'comision': comision,
      'total_debitado': totalDebitado,
      'banco_destino': bancoDestino,
      'descripcion': descripcion,
      'saldo_restante_origen': saldoRestanteOrigen,
      'fecha': fecha?.toIso8601String(),
    },
  };
}
