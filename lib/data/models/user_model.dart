class UserModel {
  final String id;
  final String cedula;
  final String name;
  final String email;
  final String? username;

  UserModel({
    required this.id,
    required this.cedula,
    required this.name,
    required this.email,
    this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['id_usuario'] ?? '',
      cedula: json['cedula'] ?? json['cedula_usuario'] ?? '',
      name: json['name'] ?? json['nombres'] ?? json['nombres_usuario'] ?? '',
      email: json['email'] ?? json['email_usuario'] ?? '',
      username: json['usuario'] ?? json['username'],
    );
  }
}
