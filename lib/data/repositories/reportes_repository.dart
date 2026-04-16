import '../database_helper.dart';
import '../providers/api_provider.dart';

class ReportesRepository {
  final ApiProvider apiProvider;
  final DatabaseHelper dbHelper;

  ReportesRepository({required this.apiProvider, required this.dbHelper});
  Future<List<Map<String, dynamic>>> getSedesConAsistenciaInicial() async {
    final db = await dbHelper.database;

    // 1️⃣ OBTENER SEDES
    final sedes = await db.rawQuery("""
    SELECT DISTINCT cod_sede, cod_inst, nom_sede
    FROM beneficiarios
    ORDER BY cod_sede
  """);

    if (sedes.isEmpty) return [];

    // 2️⃣ OBTENER DÍAS DEL CALENDARIO
    final dias = await db.rawQuery("""
    SELECT dia, nomDia, mes, semana
    FROM calendar
    ORDER BY id
  """);

    List<Map<String, dynamic>> resultado = [];

    for (var sede in sedes) {
      final codSede = sede["cod_sede"];
      final nomSede = sede['nom_sede'];
      final codInst = sede["cod_inst"];

      // 3️⃣ OBTENER GRADOS/GRUPOS DE ESA SEDE
      final grupos = await db.rawQuery("""
      SELECT DISTINCT cod_grado, nom_grupo, nom_sede, tipo_complemento
      FROM beneficiarios
      WHERE cod_sede = ? AND cod_inst = ?
      ORDER BY CAST(cod_grado AS INTEGER) ASC, CAST(nom_grupo AS INTEGER) ASC
    """, [codSede, codInst]);

      List<Map<String, dynamic>> gruposProcesados = [];

      for (var g in grupos) {
        final grado = g["cod_grado"];
        final grupo = g["nom_grupo"];
        final complemento = g["tipo_complemento"];

        // 4️⃣ CONTAR ESTUDIANTES DEL GRUPO (para determinar si hay confirmación total)
        //   final totalEstudiantesRow = await db.rawQuery("""
        //   SELECT COUNT(*) AS total
        //   FROM beneficiarios
        //   WHERE cod_sede = ? AND cod_inst = ?
        //     AND cod_grado = ? AND nom_grupo = ?
        // """, [codSede, codInst, grado, grupo]);

        // 5️⃣ PROCESAR DÍAS
        List<Map<String, dynamic>> diasProcesados = [];

        for (var d in dias) {
          final dia = d["dia"];
          final semana = d["semana"];
          final mes = d["mes"];

          // Número de estudiantes confirmados
          final confirmadosRow = await db.rawQuery("""
          SELECT COUNT(*) AS confirmados
          FROM asistencia_det ad
          JOIN beneficiarios b
               ON b.num_doc = ad.num_doc
          WHERE ad.dia = ?
            AND ad.semana = ?
            AND ad.mes = ?
            AND b.cod_sede = ?
            AND b.cod_inst = ?
            AND b.cod_grado = ?
            AND b.nom_grupo = ?
            AND b.tipo_complemento = ?
            AND ad.confirmed = 1
        """, [dia, semana, mes, codSede, codInst, grado, grupo, complemento]);

          final confirmados = confirmadosRow.first["confirmados"] as int;

          final textDia = d["nomDia"] as String? ?? "";
          String textDiaProcesdo =
              textDia[0].toUpperCase() + textDia.substring(1);
          diasProcesados.add({
            "dia": textDiaProcesdo,
            "confirmado": confirmados > 0, // puede ser "todos" si quieres
          });
        }

        gruposProcesados.add({
          "grupo": " ${nombresGrados[grado]} - $grupo ($complemento)",
          "dias": diasProcesados,
        });
      }

      resultado.add({
        "sede": "$nomSede",
        "grupos": gruposProcesados,
      });
    }

    return resultado;
  }

  final Map<String, String> nombresGrados = {
    "-2": "Prejardin",
    "-1": "Jardin 1 o A o Kinder",
    "0": "Jardin 2 o B o Transcicsion o Grado 0",
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
    "12": "Doce - Normal Superior",
    "13": "Trece - Normal Superior",
    "99": "Aceleracion del Aprendizaje"
  };
}
