import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';

class OrderService {
  final AuthProvider _auth;
  OrderService(this._auth);

  String get _baseUrl => '${AppConfig.apiBase}/api/order';
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_auth.token}',
      };

  /// 🔹 Crear un nuevo pedido (Cliente)
  Future<void> createOrder({
    required int companyId,
    required List<Map<String, dynamic>> items,
  }) async {
    final body = jsonEncode({
      'companyId': companyId,
      'items': items,
    });

    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al crear pedido: ${res.body}');
    }
  }

  /// 🔹 Obtener pedidos del cliente autenticado
  Future<List<OrderResponse>> getMyOrders() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/mis-pedidos'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => OrderResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener pedidos del cliente: ${res.body}');
    }
  }

  /// 🔹 Obtener pedidos recibidos por empresa
  Future<List<OrderResponse>> getCompanyOrders() async {
    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => OrderResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener pedidos de empresa: ${res.body}');
    }
  }

  /// 🔹 Actualizar estado de un pedido (Empresa)
  Future<void> updateOrderStatus(int orderId, String nuevoEstado) async {
    final uri = Uri.parse('$_baseUrl/$orderId/estado');
    final res = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(nuevoEstado),
    );

    if (res.statusCode != 200) {
      throw Exception('Error al actualizar estado: ${res.body}');
    }
  }
}

