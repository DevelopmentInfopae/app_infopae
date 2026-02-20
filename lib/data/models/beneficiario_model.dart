class BeneficiarioModel {
  final int? id;
  final String tipo_doc;
  final String num_doc;
  final String nom1;
  final String nom2;
  final String ape1;
  final String ape2;
  final String cod_inst;
  final String cod_sede;
  final String nom_sede;
  final String cod_grado;
  final String nom_grupo;
  final String tipo_complemento;

  BeneficiarioModel(
      {this.id,
      required this.tipo_doc,
      required this.num_doc,
      required this.nom1,
      required this.nom2,
      required this.ape1,
      required this.ape2,
      required this.cod_inst,
      required this.cod_sede,
      required this.nom_sede,
      required this.cod_grado,
      required this.nom_grupo,
      required this.tipo_complemento});

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory BeneficiarioModel.fromMap(Map<String, dynamic> map) {
    return BeneficiarioModel(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
        tipo_doc: map['tipo_doc'] ?? '',
        num_doc: map['num_doc'] ?? '',
        nom1: map['nom1'] ?? '',
        nom2: map['nom2'] ?? '',
        ape1: map['ape1'], // Puede ser nulo
        ape2: map['ape2'] ?? '',
        cod_sede: map['cod_sede'] ?? '',
        nom_sede: map['nom_sede'] ?? '',
        cod_inst: map['cod_inst'] ?? '',
        cod_grado: map['cod_grado'] ?? '',
        nom_grupo: map['nom_grupo'] ?? '',
        tipo_complemento: map['Tipo_complemento']);
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo_doc': tipo_doc,
      'num_doc': num_doc,
      'nom1': nom1,
      'nom2': nom2,
      'ape1': ape1,
      'ape2': ape2,
      'cod_sede': cod_sede,
      'nom_sede': nom_sede,
      'cod_inst': cod_inst,
      'cod_grado': cod_grado,
      'nom_grupo': nom_grupo,
      'tipo_complemento': tipo_complemento,
    };
  }
}
