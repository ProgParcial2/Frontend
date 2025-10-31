import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  bool loading = true;
  late ProductService _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _service = ProductService(auth);
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    setState(() => loading = true);
    try {
      final list = await _service.getMyProducts();
      setState(() => products = list);
    } catch (e) {
      debugPrint('Error al cargar mis productos: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createProductDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    final result = await showDialog<Product>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio')),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || stockCtrl.text.isEmpty) return;
              final product = Product(
                id: 0,
                name: nameCtrl.text,
                description: descCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? 0,
                stock: int.tryParse(stockCtrl.text) ?? 0,
                userId: 0,
              );
              Navigator.pop(context, product);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    // ✅ Corrección: si se creó producto, enviarlo al backend y refrescar lista
    if (result != null) {
      try {
        await _service.create(result);
        await _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado correctamente ✅')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear producto: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product p) async {
    try {
      await _service.delete(p.id);
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente 🗑️')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis productos'),
        actions: [
          IconButton(onPressed: _createProductDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Aún no tienes productos'))
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text('${p.description}\nStock: ${p.stock}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(p),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
