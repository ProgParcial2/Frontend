import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marketplace',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5))),
      home: const LoginPage(),
    );
  }
}

enum UserRole { empresa, cliente }

enum OrderStatus { nuevo, enviado, entregado, cancelado }

String statusToStr(OrderStatus s) {
  switch (s) {
    case OrderStatus.nuevo:
      return 'Nuevo';
    case OrderStatus.enviado:
      return 'Enviado';
    case OrderStatus.entregado:
      return 'Entregado';
    case OrderStatus.cancelado:
      return 'Cancelado';
  }
  return 'Desconocido';
}

class Api {
  static final Api I = Api._();
  Api._();

  String baseUrl = 'https://app-251027211403.azurewebsites.net/';
  String? token;
  Map<String, dynamic>? me;

  Future<Map<String, dynamic>> _getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: token == null ? {} : {'Authorization': 'Bearer $token'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? '{}' : res.body;
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('GET $path ${res.statusCode}: ${res.body}');
  }

  Future<List<dynamic>> _getList(String path, {Map<String, String>? query}) async {
    final res = await http.get(Uri.parse('$baseUrl$path').replace(queryParameters: query), headers: token == null ? {} : {'Authorization': 'Bearer $token'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['items'] is List) return List<dynamic>.from(decoded['items']);
      return [];
    }
    throw Exception('GET $path ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>> _postJson(String path, Map body) async {
    final res = await http.post(Uri.parse('$baseUrl$path'), headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    }, body: json.encode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final b = res.body.isEmpty ? '{}' : res.body;
      return json.decode(b) as Map<String, dynamic>;
    }
    throw Exception('POST $path ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>> _putJson(String path, Map body) async {
    final res = await http.put(Uri.parse('$baseUrl$path'), headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    }, body: json.encode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final b = res.body.isEmpty ? '{}' : res.body;
      return json.decode(b) as Map<String, dynamic>;
    }
    throw Exception('PUT $path ${res.statusCode}: ${res.body}');
  }

  Future<void> _delete(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('DELETE $path ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> login(String email, String password) async {
    final r = await _postJson('/auth/login', {'email': email, 'password': password});
    token = r['token'] ?? r['accessToken'] ?? r['jwt'];
    if (r['user'] is Map) {
      me = Map<String, dynamic>.from(r['user']);
    } else {
      me = await _getJson('/auth/me');
    }
  }

  Future<List<Map<String, dynamic>>> listCompanies() async {
    final l = await _getList('/companies');
    return List<Map<String, dynamic>>.from(l);
  }

  Future<List<Map<String, dynamic>>> listProducts({String? companyId, double? minPrice, double? maxPrice}) async {
    final q = <String, String>{};
    if (companyId != null) q['companyId'] = companyId;
    if (minPrice != null) q['minPrice'] = minPrice.toString();
    if (maxPrice != null) q['maxPrice'] = maxPrice.toString();
    final l = await _getList('/products', query: q.isEmpty ? null : q);
    return List<Map<String, dynamic>>.from(l);
  }

  Future<Map<String, dynamic>> createProduct(Map body) => _postJson('/products', body);
  Future<Map<String, dynamic>> updateProduct(String id, Map body) => _putJson('/products/$id', body);
  Future<void> deleteProduct(String id) => _delete('/products/$id');

  Future<List<Map<String, dynamic>>> listOrdersForUser(String userId) async {
    final l = await _getList('/orders', query: {'userId': userId});
    return List<Map<String, dynamic>>.from(l);
  }

  Future<List<Map<String, dynamic>>> listOrdersForCompany(String companyId) async {
    final l = await _getList('/orders', query: {'companyId': companyId});
    return List<Map<String, dynamic>>.from(l);
  }

  Future<Map<String, dynamic>> createOrder({required String companyId, required List<Map<String, dynamic>> items}) async {
    return _postJson('/orders', {'companyId': companyId, 'items': items});
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, OrderStatus s) async {
    return _putJson('/orders/$id/status', {'status': statusToStr(s)});
  }

  Future<List<Map<String, dynamic>>> listReviews(String productId) async {
    final l = await _getList('/reviews', query: {'productId': productId});
    return List<Map<String, dynamic>>.from(l);
  }

  Future<Map<String, dynamic>> postReview(String productId, int stars, String comment) async {
    return _postJson('/reviews', {'productId': productId, 'stars': stars, 'comment': comment});
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Iniciar sesión', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  TextField(controller: email, decoration: const InputDecoration(labelText: 'Correo')),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
                  if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: loading
                        ? null
                        : () async {
                            setState(() => loading = true);
                            try {
                              await Api.I.login(email.text.trim(), password.text);
                              final role = (Api.I.me?['role'] ?? '').toString().toLowerCase();
                              if (!mounted) return;
                              if (role.contains('empresa')) {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const EmpresaHome()));
                              } else {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ClienteHome()));
                              }
                            } catch (e) {
                              error = e.toString();
                            } finally {
                              if (mounted) setState(() => loading = false);
                            }
                          },
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Entrar')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClienteHome extends StatefulWidget {
  const ClienteHome({super.key});
  @override
  State<ClienteHome> createState() => _ClienteHomeState();
}

class _ClienteHomeState extends State<ClienteHome> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const CatalogPage(), const CartPage(), const MyOrdersPage(), const ProfilePage()];
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Catálogo', selectedIcon: Icon(Icons.storefront)),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrito', selectedIcon: Icon(Icons.shopping_cart)),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos', selectedIcon: Icon(Icons.receipt_long)),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil', selectedIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

class EmpresaHome extends StatefulWidget {
  const EmpresaHome({super.key});
  @override
  State<EmpresaHome> createState() => _EmpresaHomeState();
}

class _EmpresaHomeState extends State<EmpresaHome> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const MyProductsPage(), const CompanyOrdersPage(), const ProfilePage()];
    final title = (Api.I.me?['company']?['name'] ?? Api.I.me?['companyName'] ?? 'Empresa').toString();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: pages[i],
      floatingActionButton: i == 0
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(context: context, builder: (_) => const ProductEditor()),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo producto'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Productos', selectedIcon: Icon(Icons.inventory_2)),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Pedidos', selectedIcon: Icon(Icons.local_shipping)),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil', selectedIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = Api.I.me ?? {};
    final name = u['name'] ?? u['fullName'] ?? u['email'] ?? 'Usuario';
    final email = u['email'] ?? '';
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 32, child: Text(name.toString().substring(0, 1).toUpperCase())),
            const SizedBox(height: 12),
            Text(name.toString(), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(email.toString()),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Api.I.token = null;
                Api.I.me = null;
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
              },
              child: const Text('Cerrar sesión'),
            )
          ]),
        ),
      ),
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> products = [];
  String? companyId;
  RangeValues range = const RangeValues(0, 50);
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      companies = await Api.I.listCompanies();
      products = await Api.I.listProducts();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _apply() async {
    setState(() => loading = true);
    try {
      products = await Api.I.listProducts(companyId: companyId, minPrice: range.start, maxPrice: range.end);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 8, children: [
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String?>(
              value: companyId,
              decoration: const InputDecoration(labelText: 'Empresa'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...companies.map((c) => DropdownMenuItem(value: c['id']?.toString(), child: Text(c['name']?.toString() ?? 'Empresa')))
              ],
              onChanged: (v) => setState(() => companyId = v),
            ),
          ),
          SizedBox(
            width: 320,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rango de precio'),
              RangeSlider(
                min: 0,
                max: 100,
                divisions: 100,
                values: range,
                labels: RangeLabels('\$${range.start.toStringAsFixed(0)}', '\$${range.end.toStringAsFixed(0)}'),
                onChanged: (v) => setState(() => range = v),
                onChangeEnd: (_) => _apply(),
              ),
            ]),
          ),
          FilledButton.tonal(onPressed: _apply, child: const Text('Aplicar filtros'))
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.25, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          ),
        ),
      ]),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Producto';
    final desc = product['description']?.toString() ?? '';
    final price = (product['price'] is num ? product['price'] : double.tryParse(product['price']?.toString() ?? '0')) ?? 0.0;
    final stock = product['stock'] is int ? product['stock'] : int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetail(product: product))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Expanded(child: Text(desc, maxLines: 3, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('\$${price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              FilledButton.icon(onPressed: stock > 0 ? () => Cart.I.add(product) : null, icon: const Icon(Icons.add_shopping_cart), label: const Text('Agregar')),
            ]),
            const SizedBox(height: 4),
            Text('Stock: $stock', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetail({super.key, required this.product});
  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Map<String, dynamic>> reviews = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      reviews = await Api.I.listReviews(widget.product['id']?.toString() ?? '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final name = p['name']?.toString() ?? 'Producto';
    final desc = p['description']?.toString() ?? '';
    final price = (p['price'] is num ? p['price'] : double.tryParse(p['price']?.toString() ?? '0')) ?? 0.0;
    final stock = p['stock'] is int ? p['stock'] : int.tryParse(p['stock']?.toString() ?? '0') ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc),
              const SizedBox(height: 8),
              Text('Precio: \$${price.toStringAsFixed(2)}'),
              Text('Stock: $stock'),
              const SizedBox(height: 8),
              FilledButton.icon(onPressed: stock > 0 ? () => Cart.I.add(p) : null, icon: const Icon(Icons.add_shopping_cart), label: const Text('Agregar al carrito')),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        if (reviews.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reseñas', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...reviews.map((r) => ListTile(title: Text(r['comment']?.toString() ?? ''), subtitle: Text('★${r['stars']}'))),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        ReviewComposer(productId: p['id']?.toString() ?? ''),
      ]),
    );
  }
}

class ReviewComposer extends StatefulWidget {
  final String productId;
  const ReviewComposer({super.key, required this.productId});
  @override
  State<ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends State<ReviewComposer> {
  int stars = 5;
  final ctrl = TextEditingController();
  bool sending = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dejar reseña', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) => IconButton(icon: Icon(i < stars ? Icons.star : Icons.star_border), onPressed: () => setState(() => stars = i + 1)))),
          TextField(controller: ctrl, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Comentario')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: sending
                ? null
                : () async {
                    sending = true;
                    setState(() {});
                    try {
                      await Api.I.postReview(widget.productId, stars, ctrl.text.trim());
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña publicada')));
                      ctrl.clear();
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      sending = false;
                      if (mounted) setState(() {});
                    }
                  },
            child: const Text('Publicar'),
          )
        ]),
      ),
    );
  }
}

class CartItemVM {
  final Map<String, dynamic> product;
  int qty;
  CartItemVM(this.product, this.qty);
}

class Cart {
  static final Cart I = Cart._();
  Cart._();
  final items = <CartItemVM>[];
  void add(Map<String, dynamic> p) {
    final id = p['id']?.toString();
    final i = items.indexWhere((e) => e.product['id']?.toString() == id);
    if (i == -1) {
      items.add(CartItemVM(p, 1));
    } else {
      items[i].qty++;
    }
  }
  void remove(Map<String, dynamic> p) {
    items.removeWhere((e) => e.product['id']?.toString() == p['id']?.toString());
  }
  void change(Map<String, dynamic> p, int q) {
    final i = items.indexWhere((e) => e.product['id']?.toString() == p['id']?.toString());
    if (i != -1) items[i].qty = q.clamp(1, 999);
  }
  double get total => items.fold(0.0, (a, e) {
        final price = (e.product['price'] is num ? e.product['price'] : double.tryParse(e.product['price']?.toString() ?? '0')) ?? 0.0;
        return a + price * e.qty;
      });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> companies = [];
  Map<String, dynamic>? selectedCompany;
  bool sending = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    companies = await Api.I.listCompanies();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = Cart.I.items;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        Expanded(
          child: ListView.separated(
            itemCount: cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final it = cart[i];
              final p = it.product;
              final price = (p['price'] is num ? p['price'] : double.tryParse(p['price']?.toString() ?? '0')) ?? 0.0;
              final stock = p['stock'] is int ? p['stock'] : int.tryParse(p['stock']?.toString() ?? '0') ?? 0;
              return Card(
                child: ListTile(
                  title: Text(p['name']?.toString() ?? 'Producto'),
                  subtitle: Text('Precio: \$${price.toStringAsFixed(2)} • Stock: $stock'),
                  trailing: SizedBox(
                    width: 160,
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      IconButton(onPressed: () => setState(() => Cart.I.change(p, it.qty - 1)), icon: const Icon(Icons.remove_circle_outline)),
                      Text('${it.qty}', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(onPressed: () => setState(() => Cart.I.change(p, it.qty + 1)), icon: const Icon(Icons.add_circle_outline)),
                      IconButton(onPressed: () => setState(() => Cart.I.remove(p)), icon: const Icon(Icons.delete_outline)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text('\$${Cart.I.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: selectedCompany,
                items: companies.map((c) => DropdownMenuItem(value: c, child: Text(c['name']?.toString() ?? 'Empresa'))).toList(),
                onChanged: (v) => setState(() => selectedCompany = v),
                decoration: const InputDecoration(labelText: 'Empresa'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: cart.isEmpty || selectedCompany == null || sending
                    ? null
                    : () async {
                        sending = true;
                        setState(() {});
                        try {
                          final items = cart.map((e) => {'productId': e.product['id'], 'qty': e.qty}).toList();
                          await Api.I.createOrder(companyId: selectedCompany!['id']?.toString() ?? '', items: List<Map<String, dynamic>>.from(items));
                          Cart.I.items.clear();
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido creado')));
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          sending = false;
                          if (mounted) setState(() {});
                        }
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar pedido'),
              )
            ]),
          ),
        )
      ]),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});
  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final uid = Api.I.me?['id']?.toString() ?? '';
      orders = await Api.I.listOrdersForUser(uid);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return const Center(child: Text('Aún no tienes pedidos'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (_, i) => OrderTile(order: orders[i], canChange: false),
      ),
    );
  }
}

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});
  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final companyId = Api.I.me?['company']?['id']?.toString() ?? Api.I.me?['companyId']?.toString() ?? '';
      products = await Api.I.listProducts(companyId: companyId);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductAdminTile(product: products[i], onReload: _load),
      ),
    );
  }
}

class ProductAdminTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final Future<void> Function() onReload;
  const ProductAdminTile({super.key, required this.product, required this.onReload});
  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Producto';
    final price = (product['price'] is num ? product['price'] : double.tryParse(product['price']?.toString() ?? '0')) ?? 0.0;
    final stock = product['stock'] is int ? product['stock'] : int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('Precio: \$${price.toStringAsFixed(2)} • Stock: $stock'),
        trailing: Wrap(spacing: 8, children: [
          IconButton(onPressed: () => showDialog(context: context, builder: (_) => ProductEditor(existing: product)).then((_) => onReload()), icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: () async { await Api.I.deleteProduct(product['id']?.toString() ?? ''); await onReload(); }, icon: const Icon(Icons.delete_outline)),
        ]),
      ),
    );
  }
}

class ProductEditor extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const ProductEditor({super.key, this.existing});
  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  late final name = TextEditingController(text: widget.existing?['name']?.toString());
  late final desc = TextEditingController(text: widget.existing?['description']?.toString());
  late final price = TextEditingController(text: widget.existing?['price']?.toString() ?? '0');
  late final stock = TextEditingController(text: widget.existing?['stock']?.toString() ?? '0');
  bool sending = false;
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(isEdit ? 'Editar producto' : 'Nuevo producto', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            TextField(controller: desc, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Precio'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock'))),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        sending = true;
                        setState(() {});
                        try {
                          final body = {
                            'name': name.text.trim(),
                            'description': desc.text.trim(),
                            'price': double.tryParse(price.text.replaceAll(',', '.')) ?? 0,
                            'stock': int.tryParse(stock.text) ?? 0,
                            'companyId': Api.I.me?['company']?['id'] ?? Api.I.me?['companyId'],
                          };
                          if (isEdit) {
                            await Api.I.updateProduct(widget.existing?['id']?.toString() ?? '', body);
                          } else {
                            await Api.I.createProduct(body);
                          }
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          sending = false;
                          if (mounted) setState(() {});
                        }
                      },
                child: Text(isEdit ? 'Guardar' : 'Crear'),
              )
            ])
          ]),
        ),
      ),
    );
  }
}

class CompanyOrdersPage extends StatefulWidget {
  const CompanyOrdersPage({super.key});
  @override
  State<CompanyOrdersPage> createState() => _CompanyOrdersPageState();
}

class _CompanyOrdersPageState extends State<CompanyOrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final companyId = Api.I.me?['company']?['id']?.toString() ?? Api.I.me?['companyId']?.toString() ?? '';
      orders = await Api.I.listOrdersForCompany(companyId);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return const Center(child: Text('Aún no hay pedidos'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (_, i) => OrderTile(order: orders[i], canChange: true, onChanged: _load),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool canChange;
  final Future<void> Function()? onChanged;
  const OrderTile({super.key, required this.order, required this.canChange, this.onChanged});
  @override
  Widget build(BuildContext context) {
    final id = order['id']?.toString() ?? '';
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final status = order['status']?.toString() ?? 'Nuevo';
    final total = (order['total'] is num ? order['total'] : double.tryParse(order['total']?.toString() ?? '0')) ?? items.fold(0.0, (a, e) {
      final price = (e['price'] is num ? e['price'] : double.tryParse(e['price']?.toString() ?? '0')) ?? 0.0;
      final qty = (e['qty'] is num ? e['qty'] : int.tryParse(e['qty']?.toString() ?? '0')) ?? 0;
      return a + price * qty;
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Pedido #$id', style: Theme.of(context).textTheme.titleMedium),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(999)), child: Text(status))
          ]),
          const Divider(height: 20),
          ...items.map((i) => ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('${i['qty']} × ${i['name'] ?? i['productName'] ?? 'Producto'}'), trailing: Text('\$${(((i['price'] is num ? i['price'] : double.tryParse(i['price']?.toString() ?? '0')) ?? 0.0) * ((i['qty'] is num ? i['qty'] : int.tryParse(i['qty']?.toString() ?? '0')) ?? 0)).toStringAsFixed(2)}'))),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total'),
            Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
          ]),
          if (canChange)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(spacing: 8, children: [
                for (final s in OrderStatus.values)
                  OutlinedButton(
                    onPressed: status.toLowerCase() == statusToStr(s).toLowerCase()
                        ? null
                        : () async {
                            await Api.I.updateOrderStatus(id, s);
                            if (onChanged != null) await onChanged!();
                          },
                    child: Text(statusToStr(s)),
                  )
              ]),
            )
        ]),
      ),
    );
  }
}
