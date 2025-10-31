import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';

class ProductService {
  final AuthProvider _auth;
  ProductService(this._auth);

  String get _baseUrl => '${AppConfig.apiBase}/api/product';
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_auth.token != null) 'Authorization': 'Bearer ${_auth.token}',
      };

  /// 🔹 Obtener todos los productos (públicos o filtrados)
  Future<List<Product>> getAll({
    int? empresaId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, String>{};
    if (empresaId != null) queryParams['empresaId'] = empresaId.toString();
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

    final uri = Uri.parse('$_baseUrl/all').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener productos: ${res.body}');
    }
  }

  /// 🔹 Obtener productos de la empresa autenticada
  Future<List<Product>> getMyProducts() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: _headers);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener mis productos: ${res.body}');
    }
  }

  /// 🔹 Crear un producto nuevo (solo empresa)
  Future<Product> create(Product product) async {
    final body = jsonEncode({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
    });

    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Error al crear producto: ${res.body}');
    }
  }

  /// 🔹 Actualizar un producto (solo empresa)
  Future<Product> update(Product product) async {
    final body = jsonEncode({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
    });

    final res = await http.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: _headers,
      body: body,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Error al actualizar producto: ${res.body}');
    }
  }

  /// 🔹 Eliminar un producto (solo empresa)
  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Error al eliminar producto: ${res.body}');
    }
  }
}

