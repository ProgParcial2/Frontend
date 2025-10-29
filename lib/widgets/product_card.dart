import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/client/product_detail.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            Expanded(child: Text(product.description, overflow: TextOverflow.ellipsis, maxLines: 3)),
            SizedBox(height: 6),
            Text('Precio: \$${product.price.toStringAsFixed(2)}'),
            Text('Stock: ${product.stock}'),
          ]),
        ),
      ),
    );
  }
}
