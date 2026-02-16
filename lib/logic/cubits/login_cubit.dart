import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definimos los estados posibles de la pantalla
abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final List<UserModel> users;
  LoginSuccess(this.users);
}
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginCubit extends Cubit<LoginState> {
  final UserRepository repository;

  LoginCubit(this.repository) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      emit(LoginError("Por favor, llena todos los campos"));
      return;
    }

    emit(LoginLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      // 1. Intentamos obtener el dominio guardado localmente
      String? domain = prefs.getString('api_url');

      // 2. Si NO existe (es la primera vez), lo buscamos en el servidor central
      if (domain == null) {
        print("--- Buscando dominio en el servidor central ---");
        domain = await repository.getTenantDomain(username);
      } 

      if (domain == null) {
        emit(LoginError("No se encontró un contrato vinculado a este correo"));
        return;
      }

      // Llegados a este punto sabemos el dominio por ejemplo: https://infopaegiron.com/2026/demo/app
      // 3. Intentamos buscar el usuario en la base de datos local
      UserModel? user = await repository.getLocalUser(username, password);
      if (user != null) {
        // Sí, el usuario existe sigue el proceso emite un success
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_nombre', user.nombre);
        await prefs.setString('user_foto', user.foto ?? '');
        await prefs.setString('user_id', user.id.toString());
        emit(LoginSuccess([user])); // Usuario encontrado localmente
      } else {
        // 2. Si no existe local, disparamos la sincronización desde la API
        print("Usuario no encontrado localmente. Sincronizando desde API...");
        
        // Esta función descarga los datos y los guarda en SQLite
        await repository.fetchAndSaveUsersFromApi();

        // 3. Reintentamos buscar localmente después de la descarga
        UserModel? newUser = await repository.getLocalUser(username, password);
        print("*********************************new user**** ${newUser?.nombre}");

        if (newUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_nombre', newUser.nombre);
          await prefs.setString('user_foto', newUser.foto ?? '');
          await prefs.setString('user_id', newUser.id.toString());
          emit(LoginSuccess([newUser]));
        } else {
          emit(LoginError("Credenciales incorrectas o usuario no autorizado"));
        }
      }
    } catch (e) {
      emit(LoginError("Error de conexión o base de datos: ${e.toString()}"));
    }
  }
}