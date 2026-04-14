import 'package:app_infopae/logic/cubits/asistencia_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/build_list_beneficiarios.dart';

class AsistenciaPage extends StatefulWidget {
  const AsistenciaPage({super.key});

  @override
  State<AsistenciaPage> createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  final _formKey = GlobalKey<FormState>();
  int _expansionKeyInt = 0;
  // Variables para capturar los valores
  String? instId, sedeId, gradoId, grupoId, complementoId;

  @override
  void initState() {
    super.initState();
    context.read<AsistenciaCubit>().cargarInstituciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: BlocConsumer <AsistenciaCubit, AsistenciaState>(
                listener: (context, state) {
                  // 👇 Aquí sí podemos llamar setState y callbacks sin problema
                    _checkAutoSelect(state);
                  },
                    builder: (context, state) {
                  // Forzamos que isLoading sea tratado como bool siempre
                  final bool cargando = state.isLoading == true;

                  return Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key('expansion_tile_$_expansionKeyInt'),
                      title: const Text("Filtros de búsqueda"),
                      // Si usas inicialmenteExpanded, asegúrate de no pasar null
                      initiallyExpanded: false,
                      iconColor: const Color(0XFF18a34c),
                      textColor: const Color(0XFF18a34c),
                      children: [
                        const SizedBox(height: 15),
                        // 1. INSTITUCIONES
                        _buildDropdown(
                            "Institución", state.instituciones, instId, (val) {
                          if (instId != null && instId == val) {
                            return;
                          }
                          setState(() {
                            instId = val; // Este será el cod_inst
                            sedeId =
                                null; // Reset de sede al cambiar de institución
                            gradoId = null;
                            grupoId = null;
                            complementoId = null;
                          });
                          if (val != null) {
                            context.read<AsistenciaCubit>().cargarSedes(val);
                          }
                        }),

                        // Dropdown de Sedes
                        _buildDropdown("Sede", state.sedes, sedeId, (val) {
                          if (sedeId != null && sedeId == val) {
                            return;
                          }
                          setState(() {
                            sedeId = val;
                            gradoId = null;
                            grupoId = null;
                            complementoId = null;
                          }); // Este será el cod_sede
                          if (val != null) {
                            context.read<AsistenciaCubit>().cargarGrados(val);
                          }
                        }),

                        // 3. GRADOS
                        _buildDropdown("Grado", state.grados, gradoId, (val) {
                          if (gradoId != null && gradoId == val) {
                            return;
                          }
                          setState(() {
                            gradoId = val;
                            grupoId = null;
                            complementoId = null;
                          });
                          if (val != null && sedeId != null) {
                            context
                                .read<AsistenciaCubit>()
                                .cargarGrupos(sedeId!, val);
                          }
                        }),

                        // 3. GRUPO
                        _buildDropdown("Grupo", state.grupos, grupoId, (val) {
                          if (grupoId != null && grupoId == val) {
                            return;
                          }
                          setState(() {
                            grupoId = val;
                            complementoId = null;
                          });
                          if (val != null &&
                              sedeId != null &&
                              gradoId != null) {
                            context
                                .read<AsistenciaCubit>()
                                .cargarComplementos(sedeId!, gradoId!, val);
                          }
                        }),

                        // 3. GRUPO
                        _buildDropdown(
                            "Complemento", state.complementos, complementoId,
                            (val) {
                          if (complementoId != null && complementoId == val) {
                            return;
                          }
                          setState(() {
                            complementoId = val;
                          });
                        }),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: cargando ? null : _ejecutarFiltro,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF18a34c),
                              foregroundColor: Colors.white),
                          child: cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text("FILTRAR ESTUDIANTES"),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AsistenciaCubit, AsistenciaState>(
              builder: (context, state) {
                // Usa comparación explícita == true para evitar el error de Null
                if (state.isLoading == true && state.estudiantes.isEmpty) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0XFF18a34c)));
                }

                if (state.errorMessage != null && state.estudiantes.isEmpty) {
                  return Center(child: Text("Error: ${state.errorMessage}"));
                }

                if (state.estudiantes.isNotEmpty && state.dias.isNotEmpty) {
                  return ListaEstudiantesWidget(
                    estudiantes: state.estudiantes,
                    dias: state.dias,
                    onCheckTapped: (estudiante, dia) async {
                      if (estudiante == "CONFIRMAR_DIA") {
                        // 2. AQUÍ usas la función del Cubit
                        context.read<AsistenciaCubit>().confirmarDia(dia);
                      }else if(estudiante == "DESCONFIRMAR_DIA"){
                        context.read<AsistenciaCubit>().desConfirmarDia(dia);
                      }
                      
                      else {
                        // Aquí llamas a tu Cubit para guardar la asistencia
                        final cubit = context.read<AsistenciaCubit>();
                        await context
                            .read<AsistenciaCubit>()
                            .toggleAsistencia(estudiante, dia);

                        if (estudiante == 'MARCAR_TODOS' ||
                            estudiante == 'DESMARCAR_TODOS') {
                          if (instId != null &&
                              sedeId != null &&
                              complementoId != null) {
                            cubit.reloadConsumos(
                                institucion: instId!,
                                sede: sedeId!,
                                complemento: complementoId!);
                          }
                        }
                      }
                    },
                  );
                }

                return const Center(child: Text("Seleccione los filtros"));
              },
            ),
          )
        ],
      ),
    );
  }

  // Tu AppBar actual (limpiado para legibilidad)
  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: AppBar(
        backgroundColor: const Color(0xFF1a242e),
        toolbarHeight: 80,
        title: Container(
          height: 80,
          alignment: Alignment.centerLeft,
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: '@Info',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26)),
                TextSpan(
                    text: 'PAE',
                    style: TextStyle(
                        color: Color(0XFF18a34c),
                        fontWeight: FontWeight.bold,
                        fontSize: 21)),
                TextSpan(
                    text: ' - Toma Asistencia',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> data,
      String? currentValue, Function(String?) onChanged) {
    final bool existe = data.any((item) {
      final id = item['tipo_complemento'] ??
          item['nom_grupo'] ??
          item['cod_sede']?.toString() ??
          item['cod_inst']?.toString() ??
          item['cod_grado']?.toString();
      return id == currentValue;
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: existe ? currentValue : null,
        isExpanded: true,
        alignment: AlignmentDirectional.centerStart,
        decoration: InputDecoration(
          labelText: label,
          // floatingLabelBehavior: FloatingLabelBehavior.always, // Opcional: si quieres que siempre esté arriba
          alignLabelWithHint: true,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          floatingLabelStyle: const TextStyle(
            color: Color(0XFF18a34c),
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),

          // Aumentamos el padding interno vertical para bajar el texto seleccionado
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 18),

          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0XFF18a34c), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: data.map<DropdownMenuItem<String>>((item) {
          // Determinamos qué columna usar según si es Institución o Sede
          final String id = item['tipo_complemento'] ??
              item['nom_grupo'] ??
              item['cod_grado'] ??
              item['cod_sede']?.toString() ??
              item['cod_inst']?.toString() ??
              '';
          final String nombre = item['tipo_complemento'] ??
              item['nom_grupo'] ??
              item['nom_grado'] ??
              item['nom_sede']?.toString() ??
              item['nom_inst']?.toString() ??
              '';

          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        // Icono verde para abrir el dropdown
        icon: const Icon(Icons.arrow_drop_down_circle_outlined,
            color: Color(0XFF18a34c)),

        // Evita que el menú se pegue a los bordes
        menuMaxHeight: 300,
      ),
    );
  }

  void _checkAutoSelect(AsistenciaState state) {
  // Auto-select Institución
  if (state.instituciones.length == 1 && instId == null) {
    final id = _extractId(state.instituciones.first);
    if (id.isNotEmpty) {
      setState(() => instId = id);
      context.read<AsistenciaCubit>().cargarSedes(id);
    }
  }

  // Auto-select Sede
  if (state.sedes.length == 1 && sedeId == null) {
    final id = _extractId(state.sedes.first);
    if (id.isNotEmpty) {
      setState(() => sedeId = id);
      context.read<AsistenciaCubit>().cargarGrados(id);
    }
  }

  // Auto-select Grado
  if (state.grados.length == 1 && gradoId == null) {
    final id = _extractId(state.grados.first);
    if (id.isNotEmpty) {
      setState(() => gradoId = id);
      context.read<AsistenciaCubit>().cargarGrupos(sedeId!, id);
    }
  }

  // Auto-select Grupo
  if (state.grupos.length == 1 && grupoId == null) {
    final id = _extractId(state.grupos.first);
    if (id.isNotEmpty) {
      setState(() => grupoId = id);
      context.read<AsistenciaCubit>().cargarComplementos(sedeId!, gradoId!, id);
    }
  }

  // Auto-select Complemento
  if (state.complementos.length == 1 && complementoId == null) {
    final id = _extractId(state.complementos.first);
    if (id.isNotEmpty) {
      setState(() => complementoId = id);
    }
  }
}

// Helper para extraer el id de un item
String _extractId(Map<String, dynamic> item) {
  return item['tipo_complemento'] ??
      item['nom_grupo'] ??
      item['cod_grado'] ??
      item['cod_sede']?.toString() ??
      item['cod_inst']?.toString() ??
      '';
}

  void _ejecutarFiltro() {
    if (_formKey.currentState!.validate()) {
      if (instId != null &&
          sedeId != null &&
          gradoId != null &&
          grupoId != null &&
          complementoId != null) {
        setState(() {
          _expansionKeyInt++;
        });
        context.read<AsistenciaCubit>().filtrarEstudiantes(
              institucion: instId!,
              sede: sedeId!,
              grado: gradoId!,
              grupo: grupoId!,
              complemento: complementoId!,
            );
      }
    }
  }
}
