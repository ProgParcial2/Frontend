import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late OrderService _service;
  List<OrderResponse> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _service = OrderService(auth);
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() => loading = true);
    try {
      final list = await _service.getMyOrders();
      setState(() => orders = list);
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pedidos: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No tienes pedidos aún.'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text('Pedido #${o.id} - ${o.status}'),
                          subtitle: Text(
                              'Fecha: ${o.date.day}/${o.date.month}/${o.date.year}'),
                          children: [
                            ...o.items.map((item) => ListTile(
                                  title: Text(item.productName),
                                  subtitle: Text(
                                      'Cantidad: ${item.quantity} | \$${item.unitPrice.toStringAsFixed(2)}'),
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
