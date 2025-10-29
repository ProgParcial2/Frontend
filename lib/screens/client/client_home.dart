import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../providers/auth_provider.dart';

class HomeClient extends StatefulWidget {
  const HomeClient({super.key});

  @override
  State<HomeClient> createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  final companyCtrl = TextEditingController();
  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Empresa ID'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Min precio'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'Max precio'))),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                double? min = double.tryParse(minCtrl.text);
                double? max = double.tryParse(maxCtrl.text);
                Provider.of<ProductProvider>(context, listen: false).load(
                  companyId: companyCtrl.text.isEmpty ? null : companyCtrl.text,
                  min: min,
                  max: max,
                );
              },
              child: const Text('Filtrar'),
            )
          ]),
        ),
        Expanded(
          child: prodProv.loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  children: prodProv.products.map((p) => ProductCard(product: p)).toList(),
                ),
        ),
      ]),
    );
  }
}
