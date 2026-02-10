import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<UserModel>> getAndSyncUsers() async {
    // 1. Intentar obtener usuarios de SQLite
    final List<Map<String, dynamic>> localData = await dbHelper.getUsers();

    if (localData.isNotEmpty) {
      print("Datos cargados desde SQLite");
      return localData.map((m) => UserModel.fromMap(m)).toList();
    } else {
      // 2. Si la tabla está vacía, llamar al Backend
      print("SQLite vacío, consultando API externa...");
      
      // CAMBIA ESTA URL por la de tu proyecto de CodeIgniter o Backend
      final url = Uri.parse('https://tu-api.com/usuarios/get_all'); 
      
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> remoteData = json.decode(response.body);
          
          // 3. Guardar en local para futuras consultas
          for (var userMap in remoteData) {
            await dbHelper.insertUser(userMap);
          }

          // Retornar la lista convertida a modelos
          return remoteData.map((m) => UserModel.fromMap(m)).toList();
        } else {
          throw Exception("Error en el servidor: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Fallo en la conexión: $e");
      }
    }
  }
}