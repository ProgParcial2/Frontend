import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderResponse order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final total = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${order.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Información general del pedido
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: const Text(
                  'Información del Pedido',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Estado: ${order.status}\n'
                  'Fecha: ${order.date.day}/${order.date.month}/${order.date.year}',
                ),
              ),
            ),

            // 🔹 Lista de productos en el pedido
            const Text(
              'Productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Text('Cantidad: ${item.quantity}'),
                  trailing: Text(
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const Divider(height: 32),

            // 🔹 Total del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


