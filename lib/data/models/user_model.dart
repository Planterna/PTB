class UserModel {
  final String id;
  final String cedula;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.cedula,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      cedula: json['cedula'] ?? '',
      name: json['name'],
      email: json['email'],
    );
  }
}
