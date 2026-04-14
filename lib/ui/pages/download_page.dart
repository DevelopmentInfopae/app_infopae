import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/download_cubit.dart';
// ... tus otros imports

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<DownloadCubit>().verificarConexion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Moví el AppBar a una función para limpiar el build
      body: BlocListener<DownloadCubit, DownloadState>(
        // El listener escucha cambios y ejecuta la navegación
        listener: (context, state) {
          if (state is DownloadSuccess) {
            // Mostramos un mensaje breve antes de irnos (opcional)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Sincronización finalizada!'), backgroundColor: Color(0XFF18a34c)),
            );
            
            // Redirección a Home
            // Usamos pushReplacementNamed para que no pueda volver a la carga con el botón físico
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: BlocConsumer<DownloadCubit, DownloadState>(
            listener: (context, state) {
              if (state is DownloadSinConexion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Sin conexión a internet. No es posible sincronizar.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              if (state is DownloadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Descarga completada exitosamente.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is DownloadFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('💥 ${(state).error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          builder: (context, state) {
            double globalProgress = 0.0;
            if (state is DownloadInProgress) globalProgress = state.progress;
            if (state is DownloadSuccess) globalProgress = 1.0;

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
    );
  }

  // Tu AppBar actual (limpiado para legibilidad)
  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1a242e),
        toolbarHeight: 80,
        title: Container(
          height: 80,
          alignment: Alignment.centerLeft,
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '@Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                TextSpan(text: 'PAE', style: TextStyle(color: Color(0XFF18a34c), fontWeight: FontWeight.bold, fontSize: 21)),
                TextSpan(text: ' - Descarga Información', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta superior con el botón principal
  Widget _buildMainActionCard(BuildContext context, DownloadState state, double progress) {
    bool isLoading = state is DownloadInProgress;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.cloud_sync_rounded,
              size: 60,
              color: isLoading ? const Color(0XFF18a34c) : Colors.grey,
            ),
            const SizedBox(height: 15),
            Text(
              isLoading ? "Descarga en curso..." : "Actualización de Datos",
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
                onPressed: isLoading ? null : () => context.read<DownloadCubit>().iniciarDescarga(),
                icon: isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_rounded),
                label: Text(isLoading ? "Procesando..." : "INICIAR DESCARGA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF18a34c),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta inferior con el listado de módulos
  Widget _buildDetailsCard(DownloadState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Módulos a Sincronizar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF005595)),
            ),
          ),
          const Divider(height: 1),
          _buildDownloadItem("Instituciones", state, 0.2),
          _buildDownloadItem("Sedes", state, 0.4),
          _buildDownloadItem("Beneficiarios", state, 0.6),
          _buildDownloadItem("Raciones", state, 0.8),
          _buildDownloadItem("Calendario", state, 1.0),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Item individual de la lista
  Widget _buildDownloadItem(String label, DownloadState state, double threshold) {
    IconData icon = Icons.circle_outlined;
    Color color = Colors.grey;
    bool showLoading = false;

    if (state is DownloadInProgress) {
      if (state.progress >= threshold) {
        icon = Icons.check_circle_rounded;
        color = const Color(0XFF18a34c);
      } else if (state.progress > (threshold - 0.3)) {
        showLoading = true;
      }
    } else if (state is DownloadSuccess) {
      icon = Icons.check_circle_rounded;
      color = const Color(0XFF18a34c);
    }

    return ListTile(
      leading: showLoading 
        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0XFF18a34c)))
        : Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        color == const Color(0XFF18a34c) ? "Completado" : (showLoading ? "Cargando..." : "Pendiente"),
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }