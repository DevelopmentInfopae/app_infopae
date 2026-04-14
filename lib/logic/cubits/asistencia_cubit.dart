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
  final Map<String, bool> diasMarcados;
  final List<dynamic> diasConfirmados;
  final String? errorMessage;
  final List<dynamic> estudiantesSede;
  final bool tienePendientes;

  AsistenciaState({
    this.isLoading = false,
    this.instituciones = const [],
    this.sedes = const [],
    this.grados = const [],
    this.grupos = const [],
    this.complementos = const [],
    this.estudiantes = const [],
    this.dias = const [],
    this.diasMarcados = const {},
    this.diasConfirmados = const [],
    this.errorMessage,
    this.estudiantesSede = const [],
    this.tienePendientes = false,
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
    Map<String, bool>? diasMarcados,
    List<dynamic>? diasConfirmados,
    String? errorMessage,
    List<dynamic>? estudiantesSede,
    bool? tienePendientes,
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
      diasMarcados: diasMarcados ?? this.diasMarcados,
      diasConfirmados: diasConfirmados ?? this.diasConfirmados,
      errorMessage: errorMessage,
      estudiantesSede: estudiantesSede ?? this.estudiantesSede,
      tienePendientes: tienePendientes ?? this.tienePendientes,
    );
  }
}

// asistencia_cubit.dart
class AsistenciaCubit extends Cubit<AsistenciaState> {
  final AsistenciaRepository repository;
  AsistenciaCubit(this.repository) : super(AsistenciaState());

  // 1. Cargar instituciones al entrar a la página
  Future<void> cargarInstituciones() async {
    emit(state.copyWith(estudiantes: [], isLoading: true));
    try {
      final inst = await repository.getInstituciones();
      emit(state.copyWith(instituciones: inst, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  // 2. Cargar sedes cuando se seleccione una institución
  Future<void> cargarSedes(String instId) async {
    emit(state.copyWith(estudiantes: [], sedes: []));
    try {
      final sedes = await repository.getSedes(instId);
      emit(state.copyWith(sedes: sedes));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> cargarGrados(String codSede) async {
    emit(state
        .copyWith(estudiantes: [], grados: [])); // Limpiamos grados anteriores
    try {
      final listaGrados = await repository.getGradosPorSede(codSede);
      emit(state.copyWith(grados: listaGrados));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> cargarGrupos(String codSede, String codGrado) async {
    emit(state
        .copyWith(estudiantes: [], grupos: [])); // Limpiamos grados anteriores
    try {
      final listaGrupos =
          await repository.getGruposPorSedeGrado(codSede, codGrado);
      emit(state.copyWith(grupos: listaGrupos));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // 1. Cargar instituciones al entrar a la página
  Future<void> cargarComplementos(
      String codSede, String codGrado, String codGrupo) async {
    emit(state.copyWith(estudiantes: [], complementos: []));
    try {
      final listaComplementos =
          await repository.getComplementos(codSede, codGrado, codGrupo);
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
          inst: institucion,
          sede: sede,
          grado: grado,
          grupo: grupo,
          comp: complemento,
          dias: diasDb);

      final listaSede = await repository.getEstudiantesConAsistenciaSede(
          inst: institucion, sede: sede, comp: complemento, dias: diasDb);

      emit(state.copyWith(
          estudiantes: lista,
          estudiantesSede: listaSede,
          dias: diasDb,
          isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> reloadConsumos({
    required String institucion,
    required String sede,
    required String complemento,
  }) async {
    emit(state.copyWith(estudiantesSede: [], isLoading: true));
    try {
      final diasDb = await repository.getDias();

      final listaSede = await repository.getEstudiantesConAsistenciaSede(
          inst: institucion, sede: sede, comp: complemento, dias: diasDb);

      emit(state.copyWith(estudiantesSede: listaSede, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> toggleAsistencia(e, dia) async {
    final String diaKey = dia['dia'].toString();

    /// ─────────────────────────────────────────
    /// 🚀 SI ES "TODOS" MARCAMOS TODOS LOS ESTUDIANTES
    /// ─────────────────────────────────────────
    if (e == "MARCAR_TODOS") {
      final nuevosEstudiantes = state.estudiantes.map((est) {
        final actualizado = Map<String, dynamic>.from(est);
        actualizado[diaKey] = 1; // marcar todo
        return actualizado;
      }).toList();

      emit(state.copyWith(estudiantes: nuevosEstudiantes));

      // Guardar en DB uno por uno
      for (var est in state.estudiantes) {
        await repository.updateAsistenciaLocal(est['tipo_doc'], est['num_doc'],
            est['tipo_complemento'], dia['mes'], dia['semana'], dia['dia'], 1);
      }
      return;
    }

    // DESMARCAR TODOS
    if (e == "DESMARCAR_TODOS") {
      final nuevosEstudiantes = state.estudiantes.map((est) {
        final actualizado = Map<String, dynamic>.from(est);
        actualizado[diaKey] = 0; // marcar todo
        return actualizado;
      }).toList();

      emit(state.copyWith(estudiantes: nuevosEstudiantes));

      // Guardar en DB uno por uno
      for (var est in state.estudiantes) {
        await repository.updateAsistenciaLocal(est['tipo_doc'], est['num_doc'],
            est['tipo_complemento'], dia['mes'], dia['semana'], dia['dia'], 0);
      }
      return;
    }

    /// ─────────────────────────────────────────
    /// 🧍‍♂️ CASO NORMAL: UN SOLO ESTUDIANTE
    /// ─────────────────────────────────────────
    int asistio;
    if (e[dia['dia']] == 0) {
      asistio = 1;
    } else {
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
      return estudiante;
    }).toList();

    final nuevosEstudiantesSede = state.estudiantesSede.map((estudiante) {
      if (estudiante['num_doc'] == e['num_doc']) {
        final actualizado = Map<String, dynamic>.from(estudiante);
        if (asistio == 1) {
          actualizado['consumio'] += 1;
        } else {
          actualizado['consumio'] -= 1;
        }
        return actualizado;
      }
      return estudiante;
    }).toList();

    emit(state.copyWith(
        estudiantes: nuevosEstudiantes,
        estudiantesSede: nuevosEstudiantesSede));

    await repository.updateAsistenciaLocal(e['tipo_doc'], e['num_doc'],
        e['tipo_complemento'], dia['mes'], dia['semana'], dia['dia'], asistio);
  }

  void marcarTodos(String dia) {
    final nuevosDias = Map<String, bool>.from(state.diasMarcados);
    nuevosDias[dia] = true;
    emit(state.copyWith(
      diasMarcados: nuevosDias,
    ));
  }

  void desmarcarTodos(String dia) {
    final nuevosDias = Map<String, bool>.from(state.diasMarcados);
    nuevosDias[dia] = false;
    emit(state.copyWith(
      diasMarcados: nuevosDias,
    ));
  }

  bool todosMarcados(String dia) {
    if (state.estudiantes.isEmpty) return false;

    for (final b in state.estudiantes) {
      final valor = b[dia] ?? 0;
      if (valor == 0) {
        return false;
      } // si uno no está marcado → NO están todos marcados
    }

    return true;
  }

  void confirmarDia(dynamic dia) async {
    // Guardar en DB uno por uno
    for (var est in state.estudiantes) {
      await repository.updateAsistenciaLocalConfirmed(
          est['tipo_doc'],
          est['num_doc'],
          est['tipo_complemento'],
          dia['mes'],
          dia['semana'],
          dia['dia']);
    }

    final String keyConfirmacion = "confirmed_${dia['dia']}";
    final nuevaLista = state.estudiantes.map((estudiante) {
      return {
        ...estudiante,
        keyConfirmacion: 1,
      };
    }).toList();
    emit(state.copyWith(estudiantes: nuevaLista));
  }

  void desConfirmarDia(dia) async {
    for (var est in state.estudiantes) {
      await repository.updateAsistenciaLocalDesConfirmed(
          est['tipo_doc'],
          est['num_doc'],
          est['tipo_complemento'],
          dia['mes'],
          dia['semana'],
          dia['dia']);
      }

      final String keyConfirmacion = "confirmed_${dia['dia']}";
      final nuevaLista = state.estudiantes.map((estudiante) {
      return {
        ...estudiante,
        keyConfirmacion: 0,
      };
    }).toList();
    emit(state.copyWith(estudiantes: nuevaLista));
  }

  Future<void> verificarPendientes() async {
    final pendientes = await repository.tienePendientesPorConfirmar();
    emit(state.copyWith(tienePendientes: pendientes));
  }
}
