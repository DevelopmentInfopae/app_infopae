// asistencia_state.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/reportes_repository.dart';

class ReportesState {
  final bool isLoading;
  final List<Map<String, dynamic>> sedes;

  ReportesState({
    this.isLoading = false,
    this.sedes = const [],
  });

  // Método copyWith para actualizar solo lo que necesitemos
  ReportesState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? sedes,
  }) {
    return ReportesState(
      isLoading: isLoading ?? this.isLoading,
      sedes: sedes ?? this.sedes,
    );
  }
}

// asistencia_cubit.dart
class ReportesCubit extends Cubit<ReportesState> {
  final ReportesRepository repository;
  ReportesCubit(this.repository) : super(ReportesState()) {
    cargarResumenAsistencia();
  }

  Future<void> cargarResumenAsistencia() async {
    emit(state.copyWith(isLoading: true));

    try {
      final data = await repository.getSedesConAsistenciaInicial();

      emit(state.copyWith(
        isLoading: false,
        sedes: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }
}
