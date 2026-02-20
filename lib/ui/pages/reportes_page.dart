import 'package:app_infopae/logic/cubits/reportes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<ReportesCubit, ReportesState>(
        builder: (context, state) {
          final sedes = state.sedes;

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0XFF18a34c),
                strokeWidth: 3,
              ),
            );
          }

          if (sedes.isEmpty) {
            return const Center(child: Text("No hay sedes disponibles"));
          }

          return ListView.builder(
            itemCount: sedes.length,
            itemBuilder: (_, index) {
              final sede = sedes[index];
              final grupos = sede['grupos'] as List<dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sede['sede'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...grupos.map((grupo) {
                        final dias = grupo['dias'] as List<dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                grupo['grupo'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Lista de días
                              ...dias.map((d) {
                                final confirmado = d['confirmado'] == true;

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      d['dia'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Icon(
                                      confirmado
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: confirmado
                                          ? Colors.green
                                          : Colors.red,
                                      size: 26,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

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
                    text: ' - Reportes',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
