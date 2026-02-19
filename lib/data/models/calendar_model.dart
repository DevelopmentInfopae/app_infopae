class CalendarModel {
  final int? id;
  final String mes;
  final String semana;
  final String dia; 
  final String nomDia;

  CalendarModel({
    this.id,
    required this.mes,
    required this.semana,
    required this.dia,
    required this.nomDia,
  });

  // Convertir de JSON (API) o Map (SQLite) a Objeto
  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      mes: map['mes'] ?? '',
      semana: map['semana'] ?? '',
      dia: map['dia'], // Puede ser nulo
      nomDia: map['nomDias'] ?? '',
    );
  }

  // Convertir de Objeto a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mes': mes,
      'semana': semana,
      'dia' : dia,
      'nomDia' : nomDia
    };
  }
}


