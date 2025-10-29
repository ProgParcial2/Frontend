import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  User? _user;

  String? get token => _token;
  String? get role => _role;
  User? get user => _user;

  final String baseUrl = 'http://localhost:5158/api/auth'; // Ajusta si tu backend usa otro puerto

  /// 🔹 Registro de usuario
  Future<bool> register(String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        debugPrint("✅ Registro exitoso: ${data['message']}");
        return true;
      } else {
        final error = jsonDecode(res.body);
        debugPrint("❌ Error de registro: ${error['message'] ?? error.toString()}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Excepción en register: $e");
      return false;
    }
  }

  /// 🔹 Inicio de sesión
  Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        _role = data['role'];
        _user = User(email: email, role: data['role']);
        notifyListeners();
        debugPrint("✅ Login correcto: role=$_role");
        return true;
      } else {
        debugPrint("❌ Credenciales inválidas (${res.statusCode})");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Excepción en login: $e");
      return false;
    }
  }

  /// 🔹 Cerrar sesión
  void logout() {
    _token = null;
    _role = null;
    _user = null;
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;
}
