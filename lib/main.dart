import 'package:app_infopae/logic/cubits/download_cubit.dart';
import 'package:app_infopae/ui/pages/download_page.dart';
import 'package:app_infopae/ui/pages/login_page.dart';
import 'package:app_infopae/ui/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'data/database_helper.dart';
import 'data/providers/api_provider.dart';
import 'data/repositories/download_repository.dart';
import 'data/repositories/user_repository.dart';
import 'logic/cubits/login_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

final sl = GetIt.instance; // sl = Service Locator

void initInjections() {
  // Repositorios
  // 1. Proveedores de Datos (Las herramientas base)
  sl.registerLazySingleton(() => DatabaseHelper.instance); // Usando el .instance que ya tienes
  sl.registerLazySingleton(() => ApiProvider());

  // 2. Repositorios (Le pasamos lo que necesita usando sl())
  sl.registerLazySingleton(() => UserRepository(
    dbHelper: sl<DatabaseHelper>(), // GetIt busca automáticamente el dbHelper registrado arriba
    apiProvider: sl<ApiProvider>(), // GetIt busca el apiProvider
  ));
  // REGISTRA EL NUEVO REPOSITORIO AQUÍ
  sl.registerLazySingleton(() => DownloadRepository(
    apiProvider: sl(), // Le pasas el sl() y GetIt le entrega el ApiProvider solo
    dbHelper: sl(),
  ));

  // 3. Cubits
  sl.registerFactory(() => LoginCubit(sl<UserRepository>()));
  sl.registerFactory(() => DownloadCubit(sl<DownloadRepository>()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initInjections();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      initialRoute: '/',
      // Mapa de rutas de la aplicación
      routes: {
        '/': (context) => BlocProvider(
              create: (_) => LoginCubit(sl()),
              child: const LoginPage(),
            ),
        '/home': (context) => const HomePage(), 
        '/download': (context) => BlocProvider(
              create: (_) => sl<DownloadCubit>(),
              child: const DownloadPage(),
            ),
      },
    );
  }
}