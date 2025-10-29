import 'package:flutter/material.dart';

class OrdersHistory extends StatelessWidget {
  const OrdersHistory({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data temporal
    final orders = [
      {'id': 1, 'fecha': '2025-10-10', 'total': 80.0},
      {'id': 2, 'fecha': '2025-10-12', 'total': 50.0},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pedidos')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final order = orders[i];
          return ListTile(
            title: Text('Pedido #${order['id']}'),
            subtitle: Text('Fecha: ${order['fecha']}'),
            trailing: Text('\$${order['total']}'),
          );
        },
      ),
    );
  }
}
