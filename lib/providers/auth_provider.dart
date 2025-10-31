import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();
  String? token;
  String? role;

  bool get isLoggedIn => token != null;

  Future<void> login(String email, String password) async {
    final res = await _auth.login(email, password);
    token = res['token'];
    role = res['role'];
    notifyListeners();
  }

  Future<void> register(String email, String password, String role) async {
    await _auth.register(email, password, role);
  }

  void logout() {
    _auth.logout();
    token = null;
    role = null;
    notifyListeners();
  }
}
