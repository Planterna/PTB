class CardModel {
  final String id;
  final String idCuenta;
  final String cardName;
  final String cardNumber;
  final String tipoTarjeta;

  CardModel({
    required this.id,
    required this.idCuenta,
    required this.cardName,
    required this.cardNumber,
    required this.tipoTarjeta,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id_tarjeta'] ?? '',
      idCuenta: json['id_cuenta'] ?? '',
      cardName: json['nombre_tarjeta'] ?? '',
      cardNumber: json['numero_tarjeta'] ?? '',
      tipoTarjeta: json['tipo_tarjeta'] ?? 'debito',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tarjeta': id,
      'id_cuenta': idCuenta,
      'nombre_tarjeta': cardName,
      'numero_tarjeta': cardNumber,
      'tipo_tarjeta': tipoTarjeta,
    };
  }
}
