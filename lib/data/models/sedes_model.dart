
class SedesModel {
  final int? id;
  final String cod_inst;
  final String nom_inst;
  final String cod_sede; 
  final String nom_sede;

  SedesModel({
    this.id,
    required this.cod_inst,
    required this.nom_inst,
    required this.cod_sede,
    required this.nom_sede,
  });

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory SedesModel.fromMap(Map<String, dynamic> map) {
    return SedesModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      nom_inst: map['nom_inst'] ?? '',
      cod_inst: map['cod_inst'] ?? '',
      cod_sede: map['cod_sede'], // Puede ser nulo
      nom_sede: map['nom_sede'] ?? '',
    );
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_inst': nom_inst,
      'cod_inst': cod_inst,
      'cod_sede' : cod_sede,
      'nom_sede' : nom_sede,
    };
  }
}
