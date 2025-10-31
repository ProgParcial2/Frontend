import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  final _baseUrl = '${AppConfig.apiBase}/api/auth';

  /// 🔹 Iniciar sesión
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {
        'token': data['token'],
        'role': data['role'],
      };
    } else {
      throw Exception('Error al iniciar sesión: ${res.body}');
    }
  }

  /// 🔹 Registrar un nuevo usuario
  Future<void> register(String email, String password, String role) async {
    final uri = Uri.parse('$_baseUrl/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al registrar usuario: ${res.body}');
    }
  }

  /// 🔹 Cerrar sesión (limpia estado local)
  void logout() {
    // No hay llamada al backend, solo limpia datos locales.
  }
}
