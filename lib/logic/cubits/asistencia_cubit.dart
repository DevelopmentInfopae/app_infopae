// asistencia_state.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/asistencia_repository.dart';

class AsistenciaState {
  final bool isLoading;
  final List<Map<String, dynamic>> instituciones;
  final List<Map<String, dynamic>> sedes;
  final List<Map<String, dynamic>> grados;
  final List<Map<String, dynamic>> grupos;
  final List<Map<String, dynamic>> complementos;
  final List<dynamic> estudiantes;
  final List<dynamic> dias;
  final String? errorMessage;

  AsistenciaState({
    this.isLoading = false,
    this.instituciones = const [],
    this.sedes = const [],
    this.grados = const[],
    this.grupos = const[],
    this.complementos = const[],
    this.estudiantes = const [],
    this.dias = const [],

    this.errorMessage,
  });

  // Método copyWith para actualizar solo lo que necesitemos
  AsistenciaState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? instituciones,
    List<Map<String, dynamic>>? sedes,
    List<Map<String, dynamic>>? grados,
    List<Map<String, dynamic>>? grupos,
    List<Map<String, dynamic>>? complementos,
    List<dynamic>? estudiantes,
    List<dynamic>? dias,
    String? errorMessage,
  }) {
    return AsistenciaState(
      isLoading: isLoading ?? this.isLoading,
      instituciones: instituciones ?? this.instituciones,
      sedes: sedes ?? this.sedes,
      grados: grados ?? this.grados,
      grupos: grupos ?? this.grupos,
      complementos: complementos ?? this.complementos,
      estudiantes: estudiantes ?? this.estudiantes,
      dias: dias ?? this.dias,
      errorMessage: errorMessage,
    );
  }
}

// asistencia_cubit.dart
class AsistenciaCubit extends Cubit<AsistenciaState> {
  final AsistenciaRepository repository;
  AsistenciaCubit(this.repository) : super(AsistenciaState());

  // 1. Cargar instituciones al entrar a la página
  Future<void> cargarInstituciones() async {
    emit(state.copyWith(isLoading: true));
    try {
      final inst = await repository.getInstituciones();
      emit(state.copyWith(instituciones: inst, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  // 2. Cargar sedes cuando se seleccione una institución
  Future<void> cargarSedes(String instId) async {
    emit(state.copyWith(sedes: []));
    try {
      final sedes = await repository.getSedes(instId);
      emit(state.copyWith(sedes: sedes));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> cargarGrados(String codSede) async {
    emit(state.copyWith(grados: [])); // Limpiamos grados anteriores
    try {
      final listaGrados = await repository.getGradosPorSede(codSede);
      emit(state.copyWith(grados: listaGrados));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> cargarGrupos(String codSede, String codGrado) async {
    emit(state.copyWith(grupos: [])); // Limpiamos grados anteriores
    try {
      final listaGrupos = await repository.getGruposPorSedeGrado(codSede, codGrado);
      emit(state.copyWith(grupos: listaGrupos));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // 1. Cargar instituciones al entrar a la página
  Future<void> cargarComplementos(String codSede, String codGrado, String codGrupo) async {
    emit(state.copyWith(complementos: []));
    try {
      final listaComplementos = await repository.getComplementos(codSede, codGrado, codGrupo);
      emit(state.copyWith(complementos: listaComplementos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  // Cargar los días
  Future<void> cargarDias() async {
    emit(state.copyWith(dias: []));
    try {
      final listDias = await repository.getDias();
      emit(state.copyWith(dias: listDias, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  // 3. Tu función de filtrar
  Future<void> filtrarEstudiantes({
    required String institucion,
    required String sede,
    required String grado,
    required String grupo,
    required String complemento,
  }) async {
    emit(state.copyWith(isLoading: true, estudiantes: []));
    try {
      final diasDb = await repository.getDias();
      final lista = await repository.getEstudiantesConAsistencia(
        inst: institucion, sede: sede, grado: grado, grupo: grupo, comp: complemento, dias : diasDb
      );
      emit(state.copyWith(estudiantes: lista, dias: diasDb, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> toggleAsistencia( e, dia ) async {
    int asistio;
    if (e[dia['dia']] == 0) {
      asistio = 1;
    }else{
      asistio = 0;
    }
    final nuevosEstudiantes = state.estudiantes.map((estudiante) {
      if (estudiante['num_doc'] == e['num_doc']) {
        final actualizado = Map<String, dynamic>.from(estudiante);
        final key = dia['dia'].toString();
        final valorActual = actualizado[key] ?? 0;
        actualizado[key] = valorActual == 1 ? 0 : 1;
        return actualizado;
      }
      // print("object $estudiante");
      return estudiante;
    }).toList();
    emit(state.copyWith(estudiantes: nuevosEstudiantes));


    await repository.updateAsistenciaLocal(e['tipo_doc'], e['num_doc'], e['tipo_complemento'], dia['mes'], dia['semana'], dia['dia'], asistio);  
  }
}