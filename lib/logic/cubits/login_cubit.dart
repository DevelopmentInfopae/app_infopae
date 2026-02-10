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
      // Aquí podrías validar contra la DB local o enviar al Repo
      final users = await repository.getAndSyncUsers();
      
      // Lógica simple: verificar si el usuario existe en los datos sincronizados
      bool exists = users.any((u) => u.username == username);

      if (exists) {
        emit(LoginSuccess(users));
      } else {
        emit(LoginError("Usuario no encontrado localmente"));
      }
    } catch (e) {
      emit(LoginError("Error: ${e.toString()}"));
    }
  }
}