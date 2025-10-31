class OrderRequest {
  final int companyId;
  final List<OrderItemRequest> items;

  OrderRequest({required this.companyId, required this.items});

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
