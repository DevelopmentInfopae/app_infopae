import 'package:app_infopae/data/repositories/asistencia_repository.dart';
import 'package:app_infopae/data/repositories/reportes_repository.dart';
import 'package:app_infopae/data/repositories/upload_repository.dart';
import 'package:app_infopae/logic/cubits/asistencia_cubit.dart';
import 'package:app_infopae/logic/cubits/download_cubit.dart';
import 'package:app_infopae/logic/cubits/upload_cubit.dart';
import 'package:app_infopae/ui/pages/asistence_page.dart';
import 'package:app_infopae/ui/pages/download_page.dart';
import 'package:app_infopae/ui/pages/login_page.dart';
import 'package:app_infopae/ui/pages/home_page.dart';
import 'package:app_infopae/ui/pages/reportes_page.dart';
import 'package:app_infopae/ui/pages/upload_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database_helper.dart';
import 'data/providers/api_provider.dart';
import 'data/repositories/download_repository.dart';
import 'data/repositories/user_repository.dart';
import 'logic/cubits/login_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'logic/cubits/reportes_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

void initInjections() {
  // Repositorios
  // 1. Proveedores de Datos (Las herramientas base)
  sl.registerLazySingleton(
      () => DatabaseHelper.instance); // Usando el .instance que ya tienes
  sl.registerLazySingleton(() => ApiProvider());

  // 2. Repositorios (Le pasamos lo que necesita usando sl())
  sl.registerLazySingleton(() => UserRepository(
        dbHelper: sl<
            DatabaseHelper>(), // GetIt busca automáticamente el dbHelper registrado arriba
        apiProvider: sl<ApiProvider>(), // GetIt busca el apiProvider
      ));

  sl.registerLazySingleton(() => DownloadRepository(
        apiProvider:
            sl(), // Le pasas el sl() y GetIt le entrega el ApiProvider solo
        dbHelper: sl(),
      ));

  sl.registerLazySingleton(() => AsistenciaRepository(
        apiProvider:
            sl(), // Le pasas el sl() y GetIt le entrega el ApiProvider solo
        dbHelper: sl(),
      ));

  sl.registerLazySingleton(() => ReportesRepository(
        apiProvider:
            sl(), // Le pasas el sl() y GetIt le entrega el ApiProvider solo
        dbHelper: sl(),
      ));

  sl.registerLazySingleton(() => UploadRepository(
        apiProvider:
            sl(), // Le pasas el sl() y GetIt le entrega el ApiProvider solo
        dbHelper: sl(),
      ));

  // 3. Cubits
  sl.registerFactory(() => LoginCubit(sl<UserRepository>()));
  sl.registerFactory(() => DownloadCubit(sl<DownloadRepository>()));
  sl.registerFactory(() => AsistenciaCubit(sl<AsistenciaRepository>()));
  sl.registerFactory(() => ReportesCubit(sl<ReportesRepository>()));
  sl.registerFactory(() => UploadCubit(sl<UploadRepository>()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initInjections();
  final initialRoute = await _getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infopae App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF005595),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      // Definimos la ruta inicial
      initialRoute: initialRoute,
      // Mapa de rutas de la aplicación
      routes: {
        '/login': (context) => BlocProvider(
              create: (_) => LoginCubit(sl()),
              child: const LoginPage(),
            ),
        '/home': (context) => BlocProvider(
          create: (_) => sl<AsistenciaCubit>(),
          child : const HomePage(),
        ),
        '/download': (context) => BlocProvider(
              create: (_) => sl<DownloadCubit>(),
              child: const DownloadPage(),
            ),
        '/asistencia': (context) => BlocProvider(
              create: (_) => sl<AsistenciaCubit>(),
              child: const AsistenciaPage(),
            ),
        '/reportes': (context) => BlocProvider(
              create: (_) => sl<ReportesCubit>(),
              child: const ReportesPage(),
            ),
        '/upload': (context) => BlocProvider(
              create: (_) => sl<UploadCubit>(),
              child: const UploadPage(),
            ),
      },
    );
  }
}

Future<String> _getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final sessionDate = prefs.getString('session_date') ?? '';
  final hoy = DateTime.now().toIso8601String().substring(0, 10);

  if (sessionDate == hoy) {
    return '/home'; // 👈 Mismo día, va directo al home
  } else {
    // Limpia la sesión si es otro día
    await prefs.remove('session_date');
    return '/login';
  }
}