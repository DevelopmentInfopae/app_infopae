import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubits/asistencia_cubit.dart';

class ListaEstudiantesWidget extends StatelessWidget {
  final List<dynamic> estudiantes;
  final List<dynamic> dias;
  final Function(dynamic estudiante, dynamic dia) onCheckTapped;

  const ListaEstudiantesWidget({
    super.key,
    required this.estudiantes,
    required this.dias,
    required this.onCheckTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AsistenciaCubit, AsistenciaState>(
          buildWhen: (previous, current) =>
              previous.estudiantesSede !=
              current
                  .estudiantesSede, // Solo reconstruye si cambia la data global
          builder: (context, state) {
            final listaCompleta = state.estudiantesSede ?? [];
            // 1. Sumamos el campo 'consumio' de TODA la sede/complemento en el state
            final int totalConsumido = listaCompleta.fold(0, (sum, e) {
              final valor = e['consumio'] ?? 0;
              return sum +
                  (valor is int ? valor : int.tryParse(valor.toString()) ?? 0);
            });

            // 2. Obtenemos el total de beneficiarios de esa sede
            final int totalBeneficiarios = listaCompleta.length;

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0XFF18a34c),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "$totalConsumido de $totalBeneficiarios", // <--- Valores dinámicos
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "APELLIDOS Y NOMBRES",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Espacio alineado con el trailing del ListTile
              SizedBox(
                width: dias.length * 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: dias.map((dia) {
                    // Tomamos la inicial del día
                    final String nomDia = dia['nomDia'][0].toUpperCase();
                    final marked = context
                        .read<AsistenciaCubit>()
                        .todosMarcados(dia['dia']);
                    return GestureDetector(
                      onTap: () {
                        final marcadoAhora = context
                            .read<AsistenciaCubit>()
                            .todosMarcados(dia['dia']);

                        if (marcadoAhora) {
                          onCheckTapped("DESMARCAR_TODOS", dia);
                          context
                              .read<AsistenciaCubit>()
                              .desmarcarTodos(dia['dia']);
                        } else {
                          onCheckTapped("MARCAR_TODOS", dia);
                          context
                              .read<AsistenciaCubit>()
                              .marcarTodos(dia['dia']);
                        }
                        // onCheckTapped(action, dia);
                      },
                      child: Container(
                        width: 24,
                        margin: const EdgeInsets.only(left: 6),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            nomDia,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF18a34c),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            margin: const EdgeInsets.only(left: 1),
                            width:
                                24, // Lo hacemos un poco más grande para que sea fácil de tocar
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: marked
                                    ? const Color(0XFF18a34c)
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              color: marked
                                  ? const Color(0XFF18a34c).withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: marked
                                  ? const Color(0XFF18a34c)
                                  : Colors.transparent,
                            ),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: estudiantes.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 20, // Ajustado para que la línea sea más larga
              endIndent: 20,
              color: Color(0xFFEEEEEE),
            ),
            itemBuilder: (context, i) {
              final e = estudiantes[i];

              final String apellidos =
                  "${e['ape1'] ?? ''} ${e['ape2'] ?? ''}".trim();
              final String nombres =
                  "${e['nom1'] ?? ''} ${e['nom2'] ?? ''}".trim();

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  apellidos,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize:
                        14, // Un poco más pequeño para dar espacio a los días
                    color: Color(0xFF1a242e),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  nombres,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
                // --- AQUÍ PINTAMOS LOS DÍAS ---
                trailing: SizedBox(
                  width: dias.length *
                      30.0, // Ajusta el ancho según la cantidad de días
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: dias.map((dia) {
                      // Aquí la lógica de si está marcado debe venir del objeto estudiante 'e'
                      // Por ahora usaremos una lógica de ejemplo:
                      bool asistio = false;
                      if (e[dia['dia']] != null && e[dia['dia']] == 1) {
                        asistio = true;
                      }

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            onCheckTapped(e, dia), // Notificamos el click
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          width:
                              24, // Lo hacemos un poco más grande para que sea fácil de tocar
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: asistio
                                  ? const Color(0XFF18a34c)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            color: asistio
                                ? const Color(0XFF18a34c).withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: asistio
                                ? const Color(0XFF18a34c)
                                : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                onTap: () {
                  // Lógica para marcar asistencia al tocar la fila
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey
                .shade50, // Un color ligeramente distinto para diferenciarlo
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "CONFIRMACIÓN DÍA",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a242e),
                  ),
                ),
              ),
              SizedBox(
                width: dias.length * 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: dias.map((dia) {
                    final String keyConfirmacion = "confirmed_${dia['dia']}";

                    // VALIDACIÓN: Verificamos si CADA estudiante tiene ese día confirmado
                    // .every devuelve true solo si todos cumplen la condición
                    final bool isConfirmed = estudiantes.every((e) {
                      return e[keyConfirmacion] != null &&
                          (e[keyConfirmacion] == 1 ||
                              e[keyConfirmacion] == "1");
                    });

                    // Consultamos al Cubit si el día ya está confirmado
                    // Asumiendo que tienes un método 'esDiaConfirmado' en tu Cubit

                    return GestureDetector(
                      onTap: () {
                        onCheckTapped("CONFIRMAR_DIA", dia);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape
                              .rectangle, // Cuadrado para diferenciar de la asistencia
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isConfirmed
                                ? const Color(0XFF18a34c)
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: isConfirmed
                              ? const Color(0XFF18a34c)
                              : Colors.white,
                        ),
                        child: Icon(
                          Icons.done_all, // Icono diferente para "Confirmación"
                          size: 16,
                          color:
                              isConfirmed ? Colors.white : Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
