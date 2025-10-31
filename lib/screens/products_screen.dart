import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  double? minPrice;
  double? maxPrice;
  int? empresaId;
  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final empresaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadAll());
  }

  @override
  void dispose() {
    minCtrl.dispose();
    maxCtrl.dispose();
    empresaCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = context.read<ProductProvider>();

    setState(() {
      minPrice = double.tryParse(minCtrl.text);
      maxPrice = double.tryParse(maxCtrl.text);
      empresaId = int.tryParse(empresaCtrl.text);
    });

    provider.loadAll(
      empresaId: empresaId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: empresaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Empresa ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: minCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio mínimo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: maxCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio máximo',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _applyFilters,
                ),
              ],
            ),
          ),

          // 🔹 Lista de productos
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(
                        child: Text('No hay productos disponibles'),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadAll,
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (_, i) {
                            final p = products[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${p.description}\nPrecio: \$${p.price.toStringAsFixed(2)} | Stock: ${p.stock}',
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.reviews,
                                          color: Colors.indigo),
                                      tooltip: 'Ver reseñas',
                                      onPressed: () {
                                        context.push(
                                            '/reseñas/${p.id}?name=${p.name}');
                                      },
                                    ),
                                  ],
                                ),
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
