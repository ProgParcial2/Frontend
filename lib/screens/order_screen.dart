import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final Map<Product, int> _selected = {};
  int? selectedCompanyId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadAll());
  }

  Future<void> _makeOrder() async {
    if (selectedCompanyId == null || _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona una empresa y al menos un producto.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final auth = context.read<AuthProvider>();
    final service = OrderService(auth);

    setState(() => loading = true);

    try {
      final items = _selected.entries
          .where((e) => e.value > 0)
          .map((e) => {
                'productId': e.key.id,
                'quantity': e.value,
              })
          .toList();

      if (items.isEmpty) {
        throw Exception('No has seleccionado productos válidos.');
      }

      await service.createOrder(
        companyId: selectedCompanyId!,
        items: items,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pedido realizado con éxito 🎉'),
        backgroundColor: Colors.green,
      ));
      setState(() => _selected.clear());
    } catch (e) {
      debugPrint('Error al crear pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear pedido: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Hacer pedido')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text('No hay productos disponibles'),
                )
              : Column(
                  children: [
                    // 🔹 Selector de empresa
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Selecciona empresa',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCompanyId,
                        items: products
                            .map((p) => p.userId)
                            .toSet()
                            .map((id) => DropdownMenuItem<int>(
                                  value: id,
                                  child: Text('Empresa #$id'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCompanyId = v),
                      ),
                    ),

                    // 🔹 Lista de productos
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.loadAll(),
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (_, i) {
                            final p = products[i];
                            if (selectedCompanyId != null &&
                                p.userId != selectedCompanyId) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text(p.name),
                                subtitle: Text(
                                    '${p.description}\nPrecio: \$${p.price.toStringAsFixed(2)} | Stock: ${p.stock}'),
                                isThreeLine: true,
                                trailing: SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            final current = _selected[p] ?? 0;
                                            if (current > 0) {
                                              _selected[p] = current - 1;
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text('${_selected[p] ?? 0}'),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            final current = _selected[p] ?? 0;
                                            if (current < p.stock) {
                                              _selected[p] = current + 1;
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 🔹 Botón para confirmar pedido
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _makeOrder,
                        icon: loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Confirmar pedido'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

