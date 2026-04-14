import 'package:app_infopae/data/models/sedes_model.dart';

import '../database_helper.dart';
import '../models/beneficiario_model.dart';
import '../models/priorizacion_model.dart';
import '../models/calendar_model.dart';
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
  }

  Future<void> descargarSedes() async {
    final List<SedesModel> remoteSedes = await apiProvider.getSedesFromApi();
    for (var sede in remoteSedes) {
      await dbHelper.insertOrUpdateSede(sede);
    }
  }

  Future<void> descargarPriorizacion() async {
    final List<PriorizacionModel> remotePriorizaciones = await apiProvider.getPriorizacionFromApi();
    for (var priorizacion in remotePriorizaciones) {
      await dbHelper.insertOrUpdatePriorizacion(priorizacion);
    }
  }

  Future<void> descargarCalendario() async {
    final List<CalendarModel> remoteCalendar = await apiProvider.getCalendarFromApi();
    for (var calendar in remoteCalendar) {
      // aca en cadía día hacer la inserción en asistencia det
      await dbHelper.insertOrUpdateCalendar(calendar);
      await dbHelper.insertOrUpdateAsistenciaDet(calendar);
    }
  }

  Future<void> cleanData() async{
    await dbHelper.cleanData();
  }
}