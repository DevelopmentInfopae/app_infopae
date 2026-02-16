import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import 'dart:convert'; // Para utf8.encode
import 'package:crypto/crypto.dart'; // Para sha1

class UserRepository {
  final DatabaseHelper dbHelper; // Tu clase de SQLite
  final ApiProvider apiProvider; // Tu clase de conexión a la API

  UserRepository({required this.dbHelper, required this.apiProvider});

  // Busca específicamente en la tabla local
  Future<UserModel?> getLocalUser(String username, String password) async {
    final pass = encryptPassword(password);
    return await dbHelper.getUser(username, pass);
  }

  String encryptPassword(String password) {
    var bytes = utf8.encode(password); // Convierte el texto a bytes
    var digest = sha1.convert(bytes);  // Genera el hash SHA-1
    return digest.toString();          // Retorna el hash en String
  }

  // Descarga los usuarios de la API y los inserta en la DB local
  Future<void> fetchAndSaveUsersFromApi() async {
    final List<UserModel> remoteUsers = await apiProvider.getUsersFromApi();
    // Guardamos cada usuario en SQLite (upsert)
    for (var user in remoteUsers) {
      await dbHelper.insertOrUpdateUser(user);
    }
  }

  Future<String?> getTenantDomain(String email) async {
    try {
      // La URL de tu archivo PHP puro en el servidor central
      final url = Uri.parse('https://infopae.com.co/api/check_tenant.php');

      final response = await http.post(
        url,
        body: {'email': email}, // Enviamos el email por POST
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final String dominio = data['dominio'];
          
          // Guardamos el dominio de forma permanente
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('api_url', dominio);
          
          return dominio;
        }
      }
      return null; // Si el usuario no existe o hay error
    } catch (e) {
      print("Error consultando el central: $e");
      return null;
    }
  }
}

