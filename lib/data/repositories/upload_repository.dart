import 'package:app_infopae/data/providers/api_provider.dart';

import '../database_helper.dart';

class UploadRepository {
  final ApiProvider apiProvider;
  final DatabaseHelper dbHelper;

  UploadRepository({required this.apiProvider, required this.dbHelper});

  Future<void> enviarAsistencia() async {
    final db = await dbHelper.database;

    // 1. Obtenemos solo los registros que no han sido confirmados o toda la tabla
    // Si tienes una columna 'confirmed', podrías filtrar: WHERE confirmed = 0
    final List<Map<String, dynamic>> asistenciaLocal =
        await db.query('asistencia_det');

    if (asistenciaLocal.isEmpty) return;

    // 2. Enviamos a la API
    await apiProvider.postAsistencia(asistenciaLocal);

    // 3. Opcional: Marcar como confirmados localmente para no reenviar
    // await db.update('asistencia_det', {'confirmed': 1});
  }
}
