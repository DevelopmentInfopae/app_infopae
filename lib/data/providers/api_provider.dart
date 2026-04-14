import 'dart:convert';
import 'package:app_infopae/data/models/beneficiario_model.dart';
import 'package:app_infopae/data/models/calendar_model.dart';
import 'package:app_infopae/data/models/priorizacion_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Importante
import '../models/sedes_model.dart';
import '../models/user_model.dart';

class ApiProvider {
  Future<List<UserModel>> getUsersFromApi() async {
    try {
      // 1. Obtener la instancia de shared preferences
      final prefs = await SharedPreferences.getInstance();

      // 2. Leer el dominio guardado (el mismo nombre que usaste en el Repository)
      final String? baseUrl = prefs.getString('api_url');

      // 3. Validar que el dominio exista
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }
      final response =
          await http.get(Uri.parse('$baseUrl/modules/api/get_users.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convertimos el JSON de la API en una lista de UserModels
        return data.map((user) => UserModel.fromMap(user)).toList();
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  Future<List<SedesModel>> getSedesFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? baseUrl = prefs.getString('api_url');
      final String? id = prefs.getString('user_id');

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }

      final uri = Uri.parse('$baseUrl/modules/api/get_sedes.php').replace(
        queryParameters: {
          'id': id,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data.map((sede) => SedesModel.fromMap(sede)).toList();
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<BeneficiarioModel>> getBeneficiariosFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? baseUrl = prefs.getString('api_url');
      final String? id = prefs.getString('user_id');

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }

      final uri =
          Uri.parse('$baseUrl/modules/api/get_beneficiarios.php').replace(
        queryParameters: {
          'id': id,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data.map((sede) => BeneficiarioModel.fromMap(sede)).toList();
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<PriorizacionModel>> getPriorizacionFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? baseUrl = prefs.getString('api_url');
      final String? id = prefs.getString('user_id');

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }

      final uri =
          Uri.parse('$baseUrl/modules/api/get_priorizacion.php').replace(
        queryParameters: {
          'id': id,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data
            .map((priorizacion) => PriorizacionModel.fromMap(priorizacion))
            .toList();
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<CalendarModel>> getCalendarFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? baseUrl = prefs.getString('api_url');

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }

      final uri = Uri.parse('$baseUrl/modules/api/get_calendar.php');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data.map((calendar) => CalendarModel.fromMap(calendar)).toList();
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  postAsistencia(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String? baseUrl = prefs.getString('api_url');
    final response = await http.post(
      Uri.parse('$baseUrl/modules/api/registrar_asistencia.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) throw Exception("Fallo en el servidor");
  }

  Future<String?> getCurrentWeek() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? baseUrl = prefs.getString('api_url');
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("No se ha configurado un dominio de contrato.");
      }
      final response =
          await http.get(Uri.parse('$baseUrl/modules/api/get_current_week.php'));

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedData = json.decode(response.body);

        Map<String, String> data = decodedData.cast<String, String>();
        if (data["1"] != '') {
          return data["1"];
        }else{
          return null;
        }
      } else {
        throw Exception(
            "Error al conectar con el servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }
}
