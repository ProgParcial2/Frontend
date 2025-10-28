import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MarketplaceApp());
}

/// 🌐 CONFIG
const String baseUrl = 'https://app-251027220959.azurewebsites.net/api';

/// 🧩 API SERVICE
class Api {
  static final Api I = Api._();
  Api._();

  String? token;
  Map<String, dynamic>? me;

  Future<Map<String, dynamic>> _post(String path, Map body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> _put(String path, Map body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  // ✅ LOGIN
  Future<void> login(String email, String password) async {
    final r = await _post('/auth/login', {'email': email, 'password': password});
    token = r['token']?.toString();
    me = r['user'] ?? await _get('/auth/me');
  }

  // ✅ REGISTER
  Future<void> register(String email, String password, String role) async {
    await _post('/auth/register', {
      'email': email, 
      'password': password, 
      'role': role
    });
  }

  // ✅ LISTAR PRODUCTOS - Manejo seguro de tipos
  Future<List<dynamic>> getPublicProducts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/product/all'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Asegurarnos de que sea una lista
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('products')) {
          return data['products'] ?? [];
        }
        return [];
      } else {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  // ✅ AGREGAR PRODUCTO (Empresa)
  Future<void> addProduct(Map<String, dynamic> product) async {
    await _post('/product', product);
  }

  // ✅ AGREGAR AL CARRITO (Cliente)
  Future<void> addToCart(String productId, int quantity) async {
    await _post('/cart/add', {
      'productId': productId.toString(),
      'quantity': quantity
    });
  }

  // ✅ VER CARRITO (Cliente)
  Future<List<dynamic>> getCart() async {
    try {
      final res = await _get('/cart');
      if (res['items'] is List) {
        return res['items'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ CREAR ORDEN (Cliente)
  Future<void> createOrder() async {
    await _post('/order', {});
  }

  // ✅ VER ORDENES (Cliente)
  Future<List<dynamic>> getOrders() async {
    try {
      final res = await _get('/order/my-orders');
      if (res['orders'] is List) {
        return res['orders'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ VER PRODUCTOS DE EMPRESA
  Future<List<dynamic>> getMyProducts() async {
    try {
      final res = await _get('/product/my-products');
      if (res['products'] is List) {
        return res['products'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ✅ ACTUALIZAR STOCK
  Future<void> updateStock(String productId, int stock) async {
    await _put('/product/$productId/stock', {'stock': stock});
  }
}

/// 🎨 APP ROOT
class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F46E5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(8),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

/// 🔐 LOGIN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header con logo
                    const Column(
                      children: [
                        Icon(Icons.shopping_bag_rounded, size: 80, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Marketplace",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Encuentra lo que necesitas",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Card del formulario
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: emailCtrl,
                              decoration: const InputDecoration(
                                labelText: "Correo electrónico",
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Contraseña",
                                prefixIcon: Icon(Icons.lock),
                              ),
                            ),
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              icon: const Icon(Icons.login),
                              label: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text("Entrar"),
                              onPressed: loading
                                  ? null
                                  : () async {
                                      setState(() {
                                        loading = true;
                                        error = null;
                                      });
                                      // Capturamos el Navigator fuera del gap async para evitar usar BuildContext después de awaits
                                      final navigator = Navigator.of(context);
                                      try {
                                        await Api.I.login(emailCtrl.text, passCtrl.text);
                                        final role = Api.I.me?['role']?.toString().toLowerCase() ?? 'cliente';
                                        if (!mounted) return;
                                        if (role.contains('empresa')) {
                                          navigator.pushReplacement(
                                            MaterialPageRoute(builder: (_) => const EmpresaHome()),
                                          );
                                        } else {
                                          navigator.pushReplacement(
                                            MaterialPageRoute(builder: (_) => const ClienteHome()),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() => error = 'Error al iniciar sesión. Verifica tus credenciales.');
                                      } finally {
                                        if (mounted) setState(() => loading = false);
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              ),
                              child: const Text("¿No tienes cuenta? Regístrate"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 📝 REGISTER PAGE
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String role = "Cliente";
  bool loading = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Registro",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Correo electrónico",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Rol",
                          prefixIcon: Icon(Icons.person),
                        ),
                        initialValue: role,
                        items: const [
                          DropdownMenuItem<String>(
                            value: "Cliente",
                            child: Text("Cliente"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Empresa",
                            child: Text("Empresa"),
                          ),
                        ],
                        onChanged: (v) => setState(() => role = v ?? role),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Registrarse"),
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  message = null;
                                });
                                // Capturamos el Navigator antes del await para no usar context después
                                final navigator = Navigator.of(context);
                                try {
                                  await Api.I.register(emailCtrl.text, passCtrl.text, role);
                                  setState(() => message = "Registro exitoso. Inicia sesión.");
                                  await Future.delayed(const Duration(seconds: 2));
                                  if (!mounted) return;
                                  navigator.pop();
                                } catch (e) {
                                  setState(() => message = "Error en el registro. Intenta nuevamente.");
                                } finally {
                                  if (mounted) setState(() => loading = false);
                                }
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            message!,
                            style: TextStyle(
                              color: message!.contains("Error") ? Colors.red : Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🏠 CLIENTE HOME
class ClienteHome extends StatefulWidget {
  const ClienteHome({super.key});
  @override
  State<ClienteHome> createState() => _ClienteHomeState();
}

class _ClienteHomeState extends State<ClienteHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ProductosPage(),
    const CarritoPage(),
    const OrdenesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Api.I.token = null;
              Api.I.me = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Órdenes'),
        ],
      ),
    );
  }
}

/// 🛍️ PRODUCTOS PAGE
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});
  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await Api.I.getPublicProducts();
      setState(() => products = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _addToCart(String productId, String productName) async {
    try {
      await Api.I.addToCart(productId, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName agregado al carrito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No hay productos disponibles",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      // Manejo seguro de tipos
                      final id = p['_id']?.toString() ?? p['id']?.toString() ?? i.toString();
                      final name = p['name']?.toString() ?? 'Producto';
                      final description = p['description']?.toString() ?? '';
                      final price = (p['price'] is int ? (p['price'] as int).toDouble() : 
                                   (p['price'] is double ? p['price'] as double : 0.0));
                      final imageUrl = p['imageUrl']?.toString();

                      return ProductCard(
                        id: id,
                        name: name,
                        description: description,
                        price: price,
                        imageUrl: imageUrl,
                        onAddToCart: _addToCart,
                      );
                    },
                  ),
                ),
    );
  }
}

/// 🧱 PRODUCT CARD
class ProductCard extends StatelessWidget {
  final String id, name, description;
  final double price;
  final String? imageUrl;
  final Function(String, String) onAddToCart;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.grey[200],
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Icon(Icons.image, size: 50, color: Colors.grey)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF4F46E5)),
                      onPressed: () => onAddToCart(id, name),
                      tooltip: 'Agregar al carrito',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🛒 CARRITO PAGE
class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});
  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List cartItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final data = await Api.I.getCart();
      setState(() => cartItems = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar carrito: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _createOrder() async {
    try {
      await Api.I.createOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orden creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => cartItems.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear orden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Tu carrito está vacío",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (_, i) {
                          final item = cartItems[i];
                          final product = item['product'] ?? {};
                          // Manejo seguro de tipos
                          final productName = product['name']?.toString() ?? 'Producto';
                          final quantity = item['quantity'] is int ? item['quantity'] as int : 
                                         (item['quantity'] is String ? int.tryParse(item['quantity']) ?? 1 : 1);
                          final price = (product['price'] is int ? (product['price'] as int).toDouble() : 
                                       (product['price'] is double ? product['price'] as double : 0.0));
                          final imageUrl = product['imageUrl']?.toString();

                          return Card(
                            child: ListTile(
                              leading: imageUrl != null && imageUrl.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(imageUrl),
                                    )
                                  : const CircleAvatar(child: Icon(Icons.shopping_bag)),
                              title: Text(productName),
                              subtitle: Text('Cantidad: $quantity'),
                              trailing: Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: _createOrder,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Realizar Pedido'),
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// 📋 ORDENES PAGE
class OrdenesPage extends StatefulWidget {
  const OrdenesPage({super.key});
  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  List orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final data = await Api.I.getOrders();
      setState(() => orders = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar órdenes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No tienes órdenes",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final order = orders[i];
                      // Manejo seguro de tipos
                      final orderId = order['_id']?.toString() ?? '';
                      final status = order['status']?.toString() ?? 'Pendiente';
                      final total = (order['total'] is int ? (order['total'] as int).toDouble() : 
                                   (order['total'] is double ? order['total'] as double : 0.0));
                      final createdAt = order['createdAt']?.toString() ?? '';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Orden #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      status,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: const Color(0xFF4F46E5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Total: \$${total.toStringAsFixed(2)}'),
                              Text('Fecha: ${createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// 🏢 EMPRESA HOME
class EmpresaHome extends StatefulWidget {
  const EmpresaHome({super.key});
  @override
  State<EmpresaHome> createState() => _EmpresaHomeState();
}

class _EmpresaHomeState extends State<EmpresaHome> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ProductosEmpresaPage(),
    const StockPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel - ${Api.I.me?['email'] ?? 'Empresa'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Api.I.token = null;
              Api.I.me = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_business), label: 'Agregar Producto'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
        ],
      ),
    );
  }
}

/// ➕ AGREGAR PRODUCTO (Empresa)
class ProductosEmpresaPage extends StatefulWidget {
  const ProductosEmpresaPage({super.key});
  @override
  State<ProductosEmpresaPage> createState() => _ProductosEmpresaPageState();
}

class _ProductosEmpresaPageState extends State<ProductosEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  bool loading = false;
  String? imageUrl;

  void _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      try {
        await Api.I.addProduct({
          'name': _nameCtrl.text,
          'description': _descCtrl.text,
          'price': double.tryParse(_priceCtrl.text) ?? 0.0,
          'stock': int.tryParse(_stockCtrl.text) ?? 0,
          'imageUrl': imageUrl,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto agregado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState!.reset();
          setState(() => imageUrl = null);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => loading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Agregar Producto",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre del producto",
                          prefixIcon: Icon(Icons.shopping_bag),
                        ),
                        validator: (v) => v!.isEmpty ? 'Ingresa el nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          labelText: "Descripción",
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Ingresa la descripción' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(
                          labelText: "Precio",
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Ingresa el precio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stockCtrl,
                        decoration: const InputDecoration(
                          labelText: "Stock",
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Ingresa el stock' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "URL de imagen (opcional)",
                          prefixIcon: Icon(Icons.image),
                        ),
                        onChanged: (v) => setState(() => imageUrl = v),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.add),
                        label: loading ? const Text("Agregando...") : const Text("Agregar Producto"),
                        onPressed: loading ? null : _submitProduct,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 📊 STOCK PAGE
class StockPage extends StatefulWidget {
  const StockPage({super.key});
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await Api.I.getMyProducts();
      setState(() => products = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _updateStock(String productId, int newStock) async {
    try {
      await Api.I.updateStock(productId, newStock);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No tienes productos",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      // Manejo seguro de tipos
                      final stock = p['stock'] is int ? p['stock'] as int : 
                                   (p['stock'] is String ? int.tryParse(p['stock']) ?? 0 : 0);
                      final stockCtrl = TextEditingController(text: stock.toString());
                      final productId = p['_id']?.toString() ?? '';
                      final productName = p['name']?.toString() ?? 'Producto';
                      final price = (p['price'] is int ? (p['price'] as int).toDouble() : 
                                   (p['price'] is double ? p['price'] as double : 0.0));
                      final imageUrl = p['imageUrl']?.toString();

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Imagen
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: imageUrl != null && imageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: imageUrl == null || imageUrl.isEmpty
                                    ? const Icon(Icons.image, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // Información
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                              // Control de stock
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: stockCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock',
                                    isDense: true,
                                  ),
                                  onFieldSubmitted: (v) {
                                    final newStock = int.tryParse(v) ?? 0;
                                    _updateStock(productId, newStock);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}