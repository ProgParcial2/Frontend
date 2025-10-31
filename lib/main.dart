import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'services/order_service.dart';
import 'services/review_service.dart';
import 'services/product_service.dart';
import 'app_router.dart';

void main() {
  final key = GlobalKey<NavigatorState>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// 🔹 Conecta ProductProvider con AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, auth, provider) {
            provider ??= ProductProvider();
            provider.init(auth);
            return provider;
          },
        ),

        /// 🔹 Inyecta servicios globales con el token del AuthProvider
        ProxyProvider<AuthProvider, OrderService>(
          update: (_, auth, __) => OrderService(auth),
        ),
        ProxyProvider<AuthProvider, ReviewService>(
          update: (_, auth, __) => ReviewService(auth),
        ),
        ProxyProvider<AuthProvider, ProductService>(
          update: (_, auth, __) => ProductService(auth),
        ),
      ],
      child: MyApp(navKey: key),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  const MyApp({super.key, required this.navKey});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(navKey);

    return MaterialApp.router(
      title: 'Segundo Parcial',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.indigo.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}
