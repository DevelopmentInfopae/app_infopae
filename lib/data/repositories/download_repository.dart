import 'package:app_infopae/data/models/sedes_model.dart';

import '../database_helper.dart';
import '../providers/api_provider.dart';

class DownloadRepository {
  final ApiProvider apiProvider;
  final DatabaseHelper dbHelper;

  DownloadRepository({required this.apiProvider, required this.dbHelper});

  Future<void> descargarBeneficiarios() async {
    // Tu lógica de conexión a la API y guardado en DB
  }

  Future<void> descargarSedes() async {
    final List<SedesModel> remoteSedes = await apiProvider.getSedesFromApi();
    // Guardamos cada usuario en SQLite (upsert)
    for (var sede in remoteSedes) {
      await dbHelper.insertOrUpdateSede(sede);
    }

    //  await dbHelper.allSedes();
    
  }
}