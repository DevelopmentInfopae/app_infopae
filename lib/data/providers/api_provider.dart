import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiProvider {
  // Cambia esto por la IP de tu servidor o tu dominio
  final String _baseUrl = "https://tu-dominio.com/api"; 

  Future<List<UserModel>> getUsersFromApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/usuarios'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        // Convertimos el JSON de la API en una lista de UserModels
        return data.map((user) => UserModel.fromMap(user)).toList();
      } else {
        throw Exception("Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }
}