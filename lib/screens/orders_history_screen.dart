import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  List<OrderResponse> orders = [];
  bool loading = true;
  String selectedStatus = 'Todos';

  late OrderService _service;

  final List<String> estados = [
    'Todos',
    'Nuevo',
    'En proceso',
    'Enviado',
    'Entregado',
    'Cancelado',
  ];

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
      debugPrint('Error al cargar historial: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<OrderResponse> _filteredOrders() {
    if (selectedStatus == 'Todos') return orders;
    return orders
        .where((o) =>
            o.status.toLowerCase() == selectedStatus.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de pedidos'),
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No tienes pedidos en tu historial.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por estado',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedStatus,
                        items: estados
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedStatus = v ?? 'Todos');
                        },
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final o = filtered[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text('Pedido #${o.id}'),
                                subtitle: Text(
                                  'Estado: ${o.status} • ${o.date.day}/${o.date.month}/${o.date.year}',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailScreen(order: o),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
