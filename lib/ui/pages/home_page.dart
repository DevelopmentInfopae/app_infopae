import 'package:app_infopae/ui/pages/asistence_page.dart';
import 'package:app_infopae/ui/pages/enviar_page.dart';
import 'package:app_infopae/ui/pages/reportes_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import 'download_page.dart';

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
  int _selectedIndex = 0; // Controla cuál está seleccionado

  // Esta lista DEBE tener el mismo orden que tus destinations
  final List<Widget> _paginas = [
    const HomePage(), // Índice 0
    //const DownloadPage(),      // Índice 1 (La que crearemos)
    const AsistenciaPage(), // Índice 2
    ReportesPage(), // Índice 3
    //const EnviarPage(),        // Índice 4
    // El índice 5 (Salir) no necesita página, lo manejaremos con una función
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
          _urlFoto = _baseUrl + '/' + fotoLimpia;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $_userName 👋",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Bienvenido al panel central de InfoPAE."),
            const SizedBox(height: 30),
            _buildFeatureCard(
                title: "Descarga Información",
                subtitle: "Obtén el listado actualizado de beneficiarios.",
                icon: Icons.cloud_download_rounded,
                color: const Color(0XFF18a34c),
                onTap: () => Navigator.pushNamed(context, '/download')),
            _buildFeatureCard(
              title: "Toma Asistencia",
              subtitle:
                  "Registra la presencia de los beneficiarios en el comedor.",
              icon: Icons.how_to_reg_rounded,
              color: const Color(0XFF18a34c),
              onTap: () => Navigator.pushNamed(context, '/asistencia'),
            ),
            _buildFeatureCard(
              title: "Consultar Reportes",
              subtitle:
                  "Visualiza el resumen de asistencias y entregas realizadas.",
              icon: Icons.bar_chart_rounded,
              color: const Color(0XFF18a34c),
              onTap: () => Navigator.pushNamed(context, '/reportes'),
            ),
            _buildFeatureCard(
              title: "Envíar Información",
              subtitle:
                  "Sincroniza los datos recolectados con el servidor central.",
              icon: Icons.cloud_upload_rounded,
              color: const Color(0XFF18a34c),
              onTap: () => Navigator.pushNamed(context, '/download'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex, // Marca el icono como activo
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/asistencia');
              break;
            case 2:
              Navigator.pushNamed(context, '/reportes');
              break;
            case 3:
              // Lógica de cerrar sesión
              Navigator.pushNamed(context, '/login');
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

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap, // Agregamos el evento
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap, // Usamos el callback aquí
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que deseas salir?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_logged_in'); // Limpiamos sesión activa
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
