class UserModel {
  final int? id;
  final String username;
  final String email;

  UserModel({this.id, required this.username, required this.email});

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
    );
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }

  static fromJson(user) {}
}