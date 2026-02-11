import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

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
      // Se necesita almacenar el dominio para el consumo de las api
      String? domain = await repository.getTenantDomain(username);
      print("******** domain ** ${domain} *****************");

      if (domain == null) {
        emit(LoginError("No se encontró un contrato vinculado a este correo"));
        return;
      }

      // 1. Intentamos buscar el usuario en la base de datos local
      UserModel? user = await repository.getLocalUser(username, password);
      if (user != null) {
        emit(LoginSuccess([user])); // Usuario encontrado localmente
      } else {
        // 2. Si no existe local, disparamos la sincronización desde la API
        print("Usuario no encontrado localmente. Sincronizando desde API...");
        
        // Esta función descarga los datos y los guarda en SQLite
        await repository.fetchAndSaveUsersFromApi();

        // 3. Reintentamos buscar localmente después de la descarga
        UserModel? newUser = await repository.getLocalUser(username, password);

        if (newUser != null) {
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