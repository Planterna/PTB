class VerifiedAccount {
  final String accountNumber;
  final String ownerName;
  final String identification;
  final String bankName;
  final String accountType;

  const VerifiedAccount({
    required this.accountNumber,
    required this.ownerName,
    required this.identification,
    required this.bankName,
    required this.accountType,
  });

  factory VerifiedAccount.fromJson(Map<String, dynamic> json) {
    final data = json['cuenta'] is Map<String, dynamic>
        ? json['cuenta'] as Map<String, dynamic>
        : json;
    return VerifiedAccount(
      accountNumber: (data['numero_cuenta'] ?? data['accountNumber'] ?? '').toString(),
      ownerName: (data['titular'] ?? data['ownerName'] ?? '').toString(),
      identification: (data['identificacion'] ?? data['identification'] ?? '').toString(),
      bankName: (data['banco'] ?? data['bankName'] ?? 'Prestige Trust Bank').toString(),
      accountType: (data['tipo_cuenta'] ?? data['accountType'] ?? 'Ahorros').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'ownerName': ownerName,
    'identification': identification,
    'bankName': bankName,
    'accountType': accountType,
  };
}
