import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubits/download_cubit.dart';

class AsistenciaPage extends StatelessWidget {
  const AsistenciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sincronización")),
      body: BlocConsumer<DownloadCubit, DownloadState>(
        listener: (context, state) {
          if (state is DownloadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("¡Datos actualizados!"), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_download_rounded, size: 80, color: Color(0XFF18a34c)),
                const SizedBox(height: 20),
                const Text(
                  "Descargando Información",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Espere mientras actualizamos el listado de beneficiarios y cupos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                // BARRA DE CARGA
                if (state is DownloadInProgress) ...[
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0XFF18a34c),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 10),
                  Text("${(state.progress * 100).toInt()}%"),
                ],

                if (state is DownloadInitial || state is DownloadFailure)
                  ElevatedButton.icon(
                    onPressed: () => context.read<DownloadCubit>().iniciarDescarga(),
                    icon: const Icon(Icons.sync),
                    label: const Text("Iniciar Descarga"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFF18a34c)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}