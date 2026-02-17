import 'package:app_infopae/data/models/sedes_model.dart';

import '../database_helper.dart';
import '../models/beneficiario_model.dart';
import '../providers/api_provider.dart';

class DownloadRepository {
  final ApiProvider apiProvider;
  final DatabaseHelper dbHelper;

  DownloadRepository({required this.apiProvider, required this.dbHelper});

  Future<void> descargarBeneficiarios() async {
    final List<BeneficiarioModel> remoteBeneficiarios = await apiProvider.getBeneficiariosFromApi();

    for (var beneficiario in remoteBeneficiarios) {
      await dbHelper.insertOrUpdateBeneficiario(beneficiario);
    }

    await dbHelper.allBeneficiarios();
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