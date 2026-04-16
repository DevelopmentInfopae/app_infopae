import 'package:app_infopae/data/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // 3. Si todo sale bien entonces limpiamos las tablas y los datos
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_week');
    await db.delete('sedes');
    await db.delete('beneficiarios');
    await db.delete('priorizacion');
    await db.delete('calendar');
    await db.delete('asistencia_det');
  }
}
