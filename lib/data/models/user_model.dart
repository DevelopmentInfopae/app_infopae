class UserModel {
  final int? id;
  final String nombre;
  final String clave;
  final String? foto;
  final String email;

  UserModel({
    this.id,
    required this.nombre,
    required this.clave,
    this.foto,
    required this.email,
  });

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      nombre: map['nombre'] ?? '',
      clave: map['clave'] ?? '',
      foto: map['foto'], // Puede ser nulo
      email: map['email'] ?? '',
    );
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'clave': clave,
      'foto' : foto,
      'email' : email,
    };
  }
 

}