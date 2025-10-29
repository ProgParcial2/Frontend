class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? companyId;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.companyId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        stock: (json['stock'] ?? 0).toInt(),
        companyId: json['companyId']?.toString() ?? json['company']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        if (companyId != null) 'companyId': companyId,
      };
}
