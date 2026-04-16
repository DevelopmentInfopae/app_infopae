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

class LoginUsuarioDiferente extends LoginState {
  final String mensaje;
  LoginUsuarioDiferente(this.mensaje);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginCubit extends Cubit<LoginState> {
  final UserRepository repository;

  // Helper para validar cambio de usuario
  Future<bool> _validarCambioUsuario(
      String username, SharedPreferences prefs) async {
    final ultimoUsuario = prefs.getString('ultimo_usuario') ?? '';
    if (ultimoUsuario.isNotEmpty && ultimoUsuario != username) {
      final tienePendientes = await repository.tieneAsistenciaPendiente();
      return tienePendientes;
    }
    return false;
  }

  // Helper para guardar sesión
  Future<void> _guardarSesion(UserModel user, SharedPreferences prefs) async {
    await prefs.setString('user_nombre', user.nombre);
    await prefs.setString('user_foto', user.foto ?? '');
    await prefs.setString('user_id', user.id.toString());
    await prefs.setString('ultimo_usuario', user.email);
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('session_date', hoy);
  }

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
      domain ??= await repository.getTenantDomain(username);

      if (domain == null) {
        emit(LoginError("No se encontró un contrato vinculado a este correo"));
        return;
      }

      final String? currentWeek = await repository.getCurrentWeek();
      print(" current week linea 75 $currentWeek");
      if (currentWeek == null) {
        emit(LoginError(
            "No se encontró una semana configurada en el día actual"));
        return;
      }
      await prefs.setString('current_week', currentWeek);

      // Llegados a este punto sabemos el dominio por ejemplo: https://infopaegiron.com/2026/demo/app
      // 3. Intentamos buscar el usuario en la base de datos local
      UserModel? user = await repository.getLocalUser(username, password);
      if (user != null) {
        final bloquear = await _validarCambioUsuario(username, prefs);
        if (bloquear) {
          emit(LoginUsuarioDiferente(
              "Este equipo tiene un proceso de toma de asistencia activo. "
              "Debes finalizar o sincronizar antes de cambiar de usuario."));
          return;
        }
        await _guardarSesion(user, prefs);

        emit(LoginSuccess([user])); // Usuario encontrado localmente
      } else {
        // Esta función descarga los datos y los guarda en SQLite
        await repository.fetchAndSaveUsersFromApi();
        UserModel? newUser = await repository.getLocalUser(username, password);

        if (newUser != null) {
          final bloquear = await _validarCambioUsuario(username, prefs);
          if (bloquear) {
            emit(LoginUsuarioDiferente(
                "Este equipo tiene un proceso de toma de asistencia activo. "
                "Debes finalizar o sincronizar antes de cambiar de usuario."));
            return;
          }
          await _guardarSesion(newUser, prefs);

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
