import 'dart:ffi';

import '../database_helper.dart';
import '../providers/api_provider.dart';

class AsistenciaRepository {
  final ApiProvider apiProvider;
  final DatabaseHelper dbHelper;

  AsistenciaRepository({required this.apiProvider, required this.dbHelper});

  Future<List<Map<String, dynamic>>> getEstudiantesLocal(
      {required String inst,
      required String sede,
      required String grado,
      required String grupo,
      required String comp}) async {
    final db = await dbHelper.database;
    // Consulta SQL con filtros
    return await db.query(
      'beneficiarios',
      orderBy: 'ape1, ape2, nom1, nom2',
      where:
          'cod_inst = ? AND cod_sede = ? AND cod_grado = ? AND nom_grupo = ? AND tipo_complemento = ?',
      whereArgs: [inst, sede, grado, grupo, comp],
    );
  }

  /// Funcion para obtener los datos con los días de asistencia
  Future<List<Map<String, dynamic>>> getEstudiantesConAsistencia(
      {required String inst,
      required String sede,
      required String grado,
      required String grupo,
      required String comp,
      required List<dynamic> dias}) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> beneficiarios = await db.query(
      'beneficiarios',
      orderBy: 'ape1, ape2, nom1, nom2',
      where:
          'cod_inst = ? AND cod_sede = ? AND cod_grado = ? AND nom_grupo = ? AND tipo_complemento = ?',
      whereArgs: [inst, sede, grado, grupo, comp],
    );

    if (beneficiarios.isEmpty) return [];

    final List<String> diasTexto =
        dias.map((d) => d['dia'].toString()).toList();
    final String placeholders = diasTexto.map((_) => '?').join(',');

    final List<Map<String, dynamic>> asistenciasRaw = await db.query(
      'asistencia_det',
      where: 'dia IN ($placeholders)',
      whereArgs: diasTexto,
    );

    return beneficiarios.map((b) {
      final Map<String, dynamic> estudianteMap = Map<String, dynamic>.from(b);
      for (var d in dias) {
        String diaKey = d['dia'].toString(); // Ejemplo: "16"

        final registro = asistenciasRaw.firstWhere(
          (a) => a['num_doc'] == b['num_doc'] && a['dia'].toString() == diaKey,
          orElse: () => {},
        );
        estudianteMap[diaKey] =
            registro.isNotEmpty ? registro['asistencia'] : 0;

        estudianteMap['confirmed_$diaKey'] =
            registro.isNotEmpty ? registro['confirmed'] : 0;
      }

      return estudianteMap;
    }).toList();
  }

  /// Funcion para obtener los datos con los días de asistencia
  Future<List<Map<String, dynamic>>> getEstudiantesConAsistenciaSede({
    required String inst,
    required String sede,
    required String comp,
    required List<dynamic> dias,
  }) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> beneficiarios = await db.query(
      'beneficiarios',
      orderBy: 'ape1, ape2, nom1, nom2',
      where: 'cod_inst = ? AND cod_sede = ? AND tipo_complemento = ?',
      whereArgs: [inst, sede, comp],
    );

    if (beneficiarios.isEmpty) return [];

    final List<String> diasTexto =
        dias.map((d) => d['dia'].toString()).toList();
    final String placeholders = diasTexto.map((_) => '?').join(',');

    final List<Map<String, dynamic>> asistenciasRaw = await db.query(
      'asistencia_det',
      where: 'dia IN ($placeholders)',
      whereArgs: diasTexto,
    );

    return beneficiarios.map((b) {
      final Map<String, dynamic> estudianteMap = Map<String, dynamic>.from(b);
      estudianteMap['consumio'] = 0;
      for (var d in dias) {
        String diaKey = d['dia'].toString(); // Ejemplo: "16"

        final registro = asistenciasRaw.firstWhere(
          (a) => a['num_doc'] == b['num_doc'] && a['dia'].toString() == diaKey,
          orElse: () => {},
        );
        estudianteMap[diaKey] =
            registro.isNotEmpty ? registro['asistencia'] : 0;

        estudianteMap['consumio'] += registro['consumio'];
      }

      return estudianteMap;
    }).toList();
  }

  // Trae solo una fila por cada institución
  Future<List<Map<String, dynamic>>> getInstituciones() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT DISTINCT cod_inst, nom_inst 
      FROM sedes 
      ORDER BY nom_inst ASC
    ''');
  }

  // Trae las sedes de esa institución específica
  Future<List<Map<String, dynamic>>> getSedes(String codInst) async {
    final db = await dbHelper.database;
    return await db.query('sedes',
        where: 'cod_inst = ?', whereArgs: [codInst], orderBy: 'nom_sede ASC');
  }

  // Trae las sedes de esa institución específica
  Future<List<Map<String, dynamic>>> getGradosPorSede(String codSede) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT DISTINCT cod_grado, cod_grado
      FROM beneficiarios 
      WHERE cod_sede = ? 
      ORDER BY CAST(cod_grado AS INTEGER) ASC
    ''', [codSede]);

    return res.map((item) {
      String codigo = item['cod_grado'].toString();
      return {
        'cod_grado': codigo,
        'nom_grado': nombresGrados[codigo] ??
            "Grado $codigo", // Si no existe en el mapa, muestra el número
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getGruposPorSedeGrado(
      String codSede, String codGrado) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT DISTINCT nom_grupo, nom_grupo
      FROM beneficiarios 
      WHERE cod_sede = ? 
      AND cod_grado = ?
      ORDER BY CAST(nom_grupo AS INTEGER) ASC
    ''', [codSede, codGrado]);
  }

  // Diccionario de grados
  final Map<String, String> nombresGrados = {
    "0": "Preescolar",
    "1": "Primero",
    "2": "Segundo",
    "3": "Tercero",
    "4": "Cuarto",
    "5": "Quinto",
    "6": "Sexto",
    "7": "Séptimo",
    "8": "Octavo",
    "9": "Noveno",
    "10": "Décimo",
    "11": "Once",
  };

  Future<List<Map<String, dynamic>>> getComplementos(
      String codSede, String codGrado, String codGrupo) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT DISTINCT tipo_complemento, tipo_complemento
      FROM beneficiarios 
      WHERE cod_sede = ? 
      AND cod_grado = ?
      AND nom_grupo = ?
      ORDER BY tipo_complemento ASC
    ''', [codSede, codGrado, codGrupo]);
  }

  Future<List<Map<String, dynamic>>> getDias() async {
    final db = await dbHelper.database;
    return await db.query(
      'calendar',
    );
  }

  Future<void> updateAsistenciaLocal(
      String tipoDoc,
      String numDoc,
      String tipoComplemento,
      String mes,
      String semana,
      String dia,
      int valor) async {
    final db = await dbHelper.database;

    await db.update(
      'asistencia_det',
      {'asistencia': valor, 'consumio': valor},
      where:
          'tipo_doc = ? AND num_doc = ? AND complemento = ? AND mes = ? AND semana = ? AND dia = ?',
      whereArgs: [tipoDoc, numDoc, tipoComplemento, mes, semana, dia],
    );
  }

  Future<void> updateAsistenciaLocalConfirmed(
    String tipoDoc,
    String numDoc,
    String tipoComplemento,
    String mes,
    String semana,
    String dia,
  ) async {
    final db = await dbHelper.database;

    await db.update(
      'asistencia_det',
      {
        'confirmed': 1,
      },
      where:
          'tipo_doc = ? AND num_doc = ? AND complemento = ? AND mes = ? AND semana = ? AND dia = ?',
      whereArgs: [tipoDoc, numDoc, tipoComplemento, mes, semana, dia],
    );
  }
}
