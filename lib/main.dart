import 'package:app_infopae/ui/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'data/database_helper.dart';
import 'data/providers/api_provider.dart';
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

  // 3. Cubits
  sl.registerFactory(() => LoginCubit(sl<UserRepository>()));
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
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(), 
      ),
      // 3. Proveemos el Cubit a la aplicación
      // sl<UserRepository>() busca el repositorio que guardamos en GetIt
      home: BlocProvider(
        create: (_) => LoginCubit(sl()), 
        child: const LoginPage(),
      ),
    );
  }
}