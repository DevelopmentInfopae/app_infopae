import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/download_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// --- 1. DEFINICIÓN DE ESTADOS ---
abstract class DownloadState {}

class DownloadInitial extends DownloadState {}

class DownloadSinConexion extends DownloadState {}

class DownloadInProgress extends DownloadState {
  final double progress;
  DownloadInProgress(this.progress);
}

class DownloadSuccess extends DownloadState {}

class DownloadFailure extends DownloadState {
  final String error;
  DownloadFailure(this.error);
}

// --- 2. EL CUBIT ---
class DownloadCubit extends Cubit<DownloadState> {
  final DownloadRepository repository;

  DownloadCubit(this.repository) : super(DownloadInitial());

  Future<bool> _tieneConexion() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> verificarConexion() async {
    final conectado = await _tieneConexion();
    if (!conectado) {
      emit(DownloadSinConexion());
    }
  }

  // Ejemplo de cómo usarías la lógica más adelante:
  Future<void> iniciarDescarga() async {
    final conectado = await _tieneConexion();
    if (!conectado) {
      emit(DownloadSinConexion());
      return;
    }

    try {
      // Limpiar las tablas
      await repository.cleanData();

      // 1. Inicio: 0%
      emit(DownloadInProgress(0.0));

      await Future.delayed(const Duration(seconds: 2)); // Simulación instituciones
      emit(DownloadInProgress(0.20)); 
      // --- ETAPA 1: Instituciones y Sedes ---
      // Aquí llamarías a: await repository.descargarSedes();
      await repository.descargarSedes();
      //await Future.delayed(const Duration(seconds: 1)); // Simulación
      emit(DownloadInProgress(.40)); 

      // --- ETAPA 2: Listado de Estudiantes ---
      // Aquí llamarías a: await repository.descargarEstudiantes();
      // await Future.delayed(const Duration(seconds: 2)); // Simulación (pesa más)
      await repository.descargarBeneficiarios();
      emit(DownloadInProgress(0.60));

      // --- ETAPA 3: Cupos de raciones ---
      // Aquí llamarías a: await repository.descargarCupos();
      await repository.descargarPriorizacion();
      emit(DownloadInProgress(0.80));

      await repository.descargarCalendario();
      // 2. Éxito Final: 100%
      emit(DownloadSuccess());
      
    } catch (e) {
      emit(DownloadFailure("Error en la descarga: ${e.toString()}"));
    }
  }

}