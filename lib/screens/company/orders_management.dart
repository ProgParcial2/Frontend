import 'package:flutter/material.dart';

class OrdersManagement extends StatelessWidget {
  const OrdersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí podrías conectar un provider más adelante
    // para listar los pedidos reales
    final orders = [
      {'id': 1, 'cliente': 'Juan Pérez', 'total': 50.0, 'estado': 'Pendiente'},
      {'id': 2, 'cliente': 'Ana Gómez', 'total': 80.0, 'estado': 'Completado'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Text(order['id'].toString()),
              ),
              title: Text('Cliente: ${order['cliente']}'),
              subtitle: Text('Total: \$${order['total']} • Estado: ${order['estado']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar pedido próximamente')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

