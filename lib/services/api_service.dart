import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Cambia esta URL base por la de tu backend
  static const String baseUrl = 'http://localhost:5158/api';

  /// 🔹 Obtener productos con filtros opcionales
  static Future<List<Product>> fetchProducts({
    String? companyId,
    double? min,
    double? max,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
        if (companyId != null) 'companyId': companyId,
        if (min != null) 'min': min.toString(),
        if (max != null) 'max': max.toString(),
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Error al obtener productos (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error en fetchProducts: $e');
    }
  }

  /// 🔹 Crear producto (para empresa)
  static Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Error al crear producto');
      }
    } catch (e) {
      throw Exception('Error en createProduct: $e');
    }
  }

  /// 🔹 Eliminar producto
  static Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  /// 🔹 Actualizar producto
  static Future<bool> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }
}



