class OrderResponse {
  final int id;
  final String status;
  final DateTime date;
  final List<OrderItemResponse> items;

  OrderResponse({
    required this.id,
    required this.status,
    required this.date,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemResponse.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItemResponse {
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItemResponse({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

/// 🟢 Modelo auxiliar para crear pedidos desde Flutter
class OrderRequest {
  final int companyId;
  final List<Map<String, dynamic>> items;

  OrderRequest({
    required this.companyId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'items': items,
    };
  }
}
