import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final it = cart.items[i];
                      return ListTile(
                        title: Text(it.product.name),
                        subtitle: Text('Cantidad: ${it.quantity} • Stock: ${it.product.stock}'),
                        leading: Text('\$${it.product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cart.decreaseQuantity(it.product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => cart.addItem(it.product, qty: 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.removeItem(it.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('Total: \$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () {
                                // Aquí podrías crear la orden agrupando por empresa y llamar a ApiService.createOrder(...)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido realizado (simulado)')));
                                cart.clearCart();
                              },
                        child: const Text('Realizar pedido'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
