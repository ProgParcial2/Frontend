import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Precio: \$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Stock: ${product.stock}'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar al carrito'),
            onPressed: product.stock > 0
                ? () {
                    cart.addItem(product, qty: 1);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agregado al carrito')));
                  }
                : null,
          ),
        ]),
      ),
    );
  }
}
