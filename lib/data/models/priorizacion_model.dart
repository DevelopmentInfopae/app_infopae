class PriorizacionModel {
  final int? id;
  final String cod_sede;
  final String aps;
  final String cajmps; 
  final String cajmri;
  final String cajtps;
  final String cajtri;

  PriorizacionModel({
    this.id,
    required this.cod_sede,
    required this.aps,
    required this.cajmps,
    required this.cajmri,
    required this.cajtps,
    required this.cajtri,
  });

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory PriorizacionModel.fromMap(Map<String, dynamic> map) {
    return PriorizacionModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      cod_sede: map['cod_sede'] ?? '',
      aps: map['APS'] ?? '',
      cajmps: map['CAJMPS'] ?? '', 
      cajmri: map['CAJMRI'] ?? '',
      cajtps : map['CAJTPS'] ?? '',
      cajtri : map['CAJTRI'] ?? '',
    );
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cod_sede': cod_sede,
      'aps': aps,
      'cajmps' : cajmps,
      'cajmri' : cajmri,
      'cajtps' : cajtps,
      'cajtri' : cajtri
    };
  }
}


