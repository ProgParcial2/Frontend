import 'product.dart';

class Order {
  final int? id;
  final String clientId;
  final String companyId;
  final List<Product> products;
  final String date;
  final String status;

  Order({
    this.id,
    required this.clientId,
    required this.companyId,
    required this.products,
    required this.date,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        clientId: json['clientId'] ?? '',
        companyId: json['companyId'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? 'Nuevo',
        products: (json['products'] as List<dynamic>?)
                ?.map((p) => Product.fromJson(p))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'clientId': clientId,
        'companyId': companyId,
        'date': date,
        'status': status,
        'products': products.map((p) => p.toJson()).toList(),
      };
}
