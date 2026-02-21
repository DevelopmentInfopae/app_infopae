import 'package:app_infopae/data/repositories/upload_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- 1. DEFINICIÓN DE ESTADOS ---
abstract class UploadState {}

class UploadInitial extends UploadState {}

class UploadInProgress extends UploadState {
  final double progress;
  UploadInProgress(this.progress);
}

class UploadSuccess extends UploadState {}

class UploadFailure extends UploadState {
  final String error;
  UploadFailure(this.error);
}

// --- 2. EL CUBIT ---
class UploadCubit extends Cubit<UploadState> {
  final UploadRepository repository;

  UploadCubit(this.repository) : super(UploadInitial());

  // Ejemplo de cómo usarías la lógica más adelante:
  Future<void> iniciarCarga() async {
    try {
      emit(UploadInProgress(0.1));

      // Simulamos o ejecutamos el progreso
      // Si la API no soporta progreso por partes, lo hacemos manual:
      emit(UploadInProgress(0.5));

      await repository.enviarAsistencia();

      emit(UploadInProgress(1.0));
      emit(UploadSuccess());
    } catch (e) {
      emit(UploadFailure("Error al subir asistencia: ${e.toString()}"));
    }
  }
}
