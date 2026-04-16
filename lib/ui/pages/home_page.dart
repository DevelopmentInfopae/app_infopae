import 'package:app_infopae/logic/cubits/asistencia_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _baseUrl = '';
  String _userName = "Usuario";
  String _userFoto = '';
  String _urlFoto = '';
  final int _selectedIndex = 0; // Controla cuál está seleccionado
  bool isSameWeek = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    context.read<AsistenciaCubit>().verificarPendientes();
  }

  // Cargamos el nombre que guardamos en SharedPreferences durante el Login
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    setState(() {
      _baseUrl = prefs.getString('api_url') ?? '';
      _userName = prefs.getString('user_nombre') ?? "Usuario";
      _userFoto = prefs.getString('user_foto') ?? '';
      if (_userFoto.trim().isNotEmpty) {
        String fotoLimpia = _userFoto.replaceAll('../../', '');
        if (_baseUrl != '') {
          _urlFoto = '$_baseUrl/$fotoLimpia';
        }
      }
    });

    final lastWeek = prefs.getString('last_week') ?? '';
    final currentWeek = prefs.getString('current_week') ?? '';
    isSameWeek = lastWeek.isNotEmpty &&
        currentWeek.isNotEmpty &&
        lastWeek == currentWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1a242e),
          // Eliminamos el espaciado interno por defecto para tener control total
          toolbarHeight: 80,
          title: Container(
            height: 80, // Forzamos la altura del contenedor del título
            alignment: Alignment
                .centerLeft, // Centrado vertical, alineado a la izquierda
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // ESTO centra verticalmente
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '@Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              28, // Bajé un poco de 30 para que no se vea tan apretado
                        ),
                      ),
                      TextSpan(
                        text: 'PAE',
                        style: TextStyle(
                          color: Color(0XFF18a34c),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      TextSpan(
                        text: ' - Inicio',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Centramos también el botón de notificaciones verticalmente
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0XFF18a34c),
                      width: 2), // Borde naranja decorativo
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  // Si la foto no es nula, no está vacía y no es un espacio en blanco
                  backgroundImage: (_urlFoto.trim().isNotEmpty)
                      ? NetworkImage(_urlFoto)
                      : null,
                  // Si no hay imagen, mostramos el icono de la personita
                  child: (_urlFoto.trim().isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hola, $_userName 👋",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("Bienvenido al panel central de InfoPAE."),
                const SizedBox(height: 30),
                _buildFeatureCard(
                  title: "Descarga Información",
                  subtitle: "Obtén el listado actualizado de beneficiarios.",
                  icon: Icons.cloud_download_rounded,
                  color: isSameWeek ? Colors.grey : const Color(0XFF18a34c),
                  onTap: () {
                    if (isSameWeek) {
                      // Navigator.pushNamed(context, '/download'); // TODO: comentar despues hacer pruebas
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Esta semana ya fue sincronizada.'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, '/download');
                    }
                  },
                ),
                _buildFeatureCard(
                  title: "Toma Asistencia",
                  subtitle:
                      "Registra la presencia de los beneficiarios en el comedor.",
                  icon: Icons.how_to_reg_rounded,
                  color: const Color(0XFF18a34c),
                  onTap: () {
                    final cubit = context
                        .read<AsistenciaCubit>(); // 👈 Guardar antes del async
                    Navigator.pushNamed(context, '/asistencia').then((_) {
                      cubit.verificarPendientes();
                    });
                  },
                ),
                _buildFeatureCard(
                  title: "Consultar Reportes",
                  subtitle:
                      "Visualiza el resumen de asistencias y entregas realizadas.",
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0XFF18a34c),
                  onTap: () {
                    final cubit = context.read<AsistenciaCubit>();
                    Navigator.pushNamed(context, '/reportes').then((_) {
                      cubit.verificarPendientes();
                    });
                  },
                ),
                BlocBuilder<AsistenciaCubit, AsistenciaState>(
                  builder: (context, state) {
                    return Opacity(
                      opacity: state.tienePendientes ? 0.4 : 1.0,
                      child: _buildFeatureCard(
                        title: "Envíar Información",
                        subtitle:
                            "Sincroniza los datos recolectados con el servidor central.",
                        icon: Icons.cloud_upload_rounded,
                        color: const Color(0XFF18a34c),
                        onTap: () {
                          if (state.tienePendientes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '⚠️ Debes confirmar todos los registros antes de enviar.'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, '/upload');
                          }
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex, // Marca el icono como activo
        onDestinationSelected: (int index) {
          final cubit = context.read<AsistenciaCubit>();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/asistencia').then((_) {
                cubit.verificarPendientes();
              });
              break;
            case 2:
              Navigator.pushNamed(context, '/reportes').then((_) {
                cubit.verificarPendientes();
              });
              break;
            case 3:
              // Lógica de cerrar sesión
              _cerrarSesion();
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          // NavigationDestination(icon: Icon(Icons.cloud_download_rounded), label: 'Descargar'),
          NavigationDestination(
              icon: Icon(Icons.how_to_reg_rounded), label: 'Asistencia'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded), label: 'Reportes'),
          // NavigationDestination(icon: Icon(Icons.cloud_upload_rounded), label: 'Enviar'),
          NavigationDestination(
              icon: Icon(Icons.logout_rounded), label: 'Salir'),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_date'); // 👈 Limpia la sesión del día

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false, // 👈 Limpia todo el stack, no puede volver al home
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap, // Agregamos el evento
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap, // Usamos el callback aquí
      ),
    );
  }
}
