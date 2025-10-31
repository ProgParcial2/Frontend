import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen> {
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
      final list = await _service.getCompanyOrders();
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

  Future<void> _updateStatus(int orderId) async {
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Actualizar estado'),
        children: [
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'En proceso'),
              child: const Text('En proceso')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Enviado'),
              child: const Text('Enviado')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Entregado'),
              child: const Text('Entregado')),
        ],
      ),
    );

    if (nuevoEstado == null) return;

    try {
      await _service.updateOrderStatus(orderId, nuevoEstado);
      await _loadOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$nuevoEstado" ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos recibidos')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No hay pedidos recibidos aún.'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
                              'Pedido #${o.id} - Estado: ${o.status.toUpperCase()}'),
                          subtitle: Text(
                              'Fecha: ${o.date.day}/${o.date.month}/${o.date.year}'),
                          children: [
                            ...o.items.map((item) => ListTile(
                                  title: Text(item.productName),
                                  subtitle: Text(
                                      'Cantidad: ${item.quantity} | \$${item.unitPrice.toStringAsFixed(2)}'),
                                )),
                            const Divider(),
                            TextButton.icon(
                              onPressed: () => _updateStatus(o.id),
                              icon: const Icon(Icons.edit),
                              label: const Text('Actualizar estado'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
