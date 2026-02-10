import 'package:app_infopae/ui/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'data/repositories/user_repository.dart';
import 'logic/cubits/login_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

final sl = GetIt.instance; // sl = Service Locator

void initInjections() {
  // Repositorios
  sl.registerLazySingleton(() => UserRepository());
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