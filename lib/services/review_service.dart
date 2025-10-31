import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';

class ReviewService {
  final AuthProvider _auth;
  ReviewService(this._auth);

  String get _baseUrl => '${AppConfig.apiBase}/api/review';
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_auth.token}',
      };

  Future<List<Review>> getByProduct(int productId) async {
    final res = await http.get(Uri.parse('$_baseUrl/product/$productId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener reseñas: ${res.body}');
    }
  }

  Future<void> create(int productId, int rating, String comment) async {
    final body = jsonEncode({
      'productId': productId,
      'rating': rating,
      'comment': comment,
    });
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al crear reseña: ${res.body}');
    }
  }
}
