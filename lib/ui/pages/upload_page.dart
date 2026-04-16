import 'package:app_infopae/logic/cubits/upload_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<UploadCubit>().verificarConexion();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        final isLoading = state is UploadInProgress;
        return PopScope(
          canPop: !isLoading,
          child: Scaffold(
            appBar: _buildAppBar(),
            body: BlocListener<UploadCubit, UploadState>(
              listener: (context, state) {
                if (state is UploadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('¡Asistencia enviada con éxito!'),
                        backgroundColor: Color(0XFF18a34c)),
                  );
                  Navigator.pushReplacementNamed(context, '/home');
                }
                if (state is UploadFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: BlocBuilder<UploadCubit, UploadState>(
                builder: (context, state) {
                  double globalProgress = 0.0;
                  if (state is UploadInProgress)
                    globalProgress = state.progress;
                  if (state is UploadSuccess) globalProgress = 1.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildMainActionCard(context, state, globalProgress),
                        const SizedBox(height: 20),
                        _buildDetailsCard(state),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: AppBar(
        backgroundColor: const Color(0xFF1a242e),
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    text: ' - Cargar asistencia',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMainActionCard(
    BuildContext context, UploadState state, double progress) {
  bool isLoading = state is UploadInProgress;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_rounded, // Icono de subida
            size: 60,
            color: isLoading ? const Color(0XFF18a34c) : Colors.blueGrey,
          ),
          const SizedBox(height: 15),
          Text(
            isLoading ? "Subiendo datos..." : "Enviar Asistencia al Servidor",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: const Color(0XFF18a34c),
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => context.read<UploadCubit>().iniciarCarga(),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_rounded),
              label: Text(isLoading ? "Enviando..." : "INICIAR CARGA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF18a34c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailsCard(UploadState state) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Resumen de Sincronización",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005595)),
          ),
        ),
        const Divider(height: 1),
        _buildUploadItem("Registros de Asistencia", state, 1.0),
        const SizedBox(height: 10),
      ],
    ),
  );
}

Widget _buildUploadItem(String label, UploadState state, double threshold) {
  IconData icon = Icons.circle_outlined;
  Color color = Colors.grey;
  bool isDone = state is UploadSuccess;
  bool inProgress = state is UploadInProgress;

  if (isDone) {
    icon = Icons.check_circle_rounded;
    color = const Color(0XFF18a34c);
  }

  return ListTile(
    leading: inProgress
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Icon(icon, color: color),
    title: Text(label),
    trailing:
        Text(isDone ? "Enviado" : (inProgress ? "Subiendo..." : "Pendiente")),
  );
}
