import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/download_repository.dart';

// --- 1. DEFINICIÓN DE ESTADOS ---
// Puedes ponerlos aquí mismo o en un archivo aparte llamado download_state.dart
abstract class DownloadState {}

class DownloadInitial extends DownloadState {}

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

  // Ejemplo de cómo usarías la lógica más adelante:
  Future<void> iniciarDescarga() async {

    try {
      // 1. Inicio: 0%
      emit(DownloadInProgress(0.0));

      // --- ETAPA 1: Instituciones y Sedes ---
      // Aquí llamarías a: await repository.descargarSedes();
      await repository.descargarSedes();
      //await Future.delayed(const Duration(seconds: 1)); // Simulación
      emit(DownloadInProgress(0.33)); 

      // --- ETAPA 2: Listado de Estudiantes ---
      // Aquí llamarías a: await repository.descargarEstudiantes();
      await Future.delayed(const Duration(seconds: 2)); // Simulación (pesa más)
      emit(DownloadInProgress(0.66));

      // --- ETAPA 3: Cupos de raciones ---
      // Aquí llamarías a: await repository.descargarCupos();
      await Future.delayed(const Duration(seconds: 1)); // Simulación
      
      // 2. Éxito Final: 100%
      emit(DownloadSuccess());
      
    } catch (e, stack) {
      print("💥 ERROR REAL: $e");
  print(stack);
      emit(DownloadFailure("Error en la descarga: ${e.toString()}"));
    }
  }
}