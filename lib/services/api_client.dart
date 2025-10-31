import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart'; // ✅ usa apiBase

class ApiClient {
  final String token;

  ApiClient({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$apiBase$path');
    final response = await http.get(uri, headers: _headers);
    _checkError(response);
    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$apiBase$path');
    final response = await http.post(uri,
        headers: _headers, body: jsonEncode(data));
    _checkError(response);
    return response;
  }

  Future<http.Response> put(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$apiBase$path');
    final response = await http.put(uri,
        headers: _headers, body: jsonEncode(data));
    _checkError(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$apiBase$path');
    final response = await http.delete(uri, headers: _headers);
    _checkError(response);
    return response;
  }

  void _checkError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Error HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
