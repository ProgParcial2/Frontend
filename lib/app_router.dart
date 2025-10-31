import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
import 'screens/my_products_screen.dart';
import 'screens/order_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/company_orders_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/dashboard_screen.dart';

GoRouter buildRouter(GlobalKey<NavigatorState> navKey) {
  return GoRouter(
    navigatorKey: navKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final loggedIn = auth.isLoggedIn;
      final loggingIn = state.uri.toString().startsWith('/login');

      // Si no está logueado, lo manda al login
      if (!loggedIn && !loggingIn) return '/login';
      // Si ya está logueado, lo manda al dashboard
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, _) => const LoginScreen(),
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, _) {
          final auth = context.read<AuthProvider>();
          final isClient = auth.role == 'Cliente';
          return DashboardScreen(isClient: isClient);
        },
      ),

      // 🔹 Productos (Cliente - ver todos)
      GoRoute(
        path: '/productos',
        builder: (context, _) => const ProductsScreen(),
      ),

      // 🔹 Mis productos (Empresa)
      GoRoute(
        path: '/mis-productos',
        builder: (context, _) => const MyProductsScreen(),
      ),

      // 🔹 Realizar pedido (Cliente)
      GoRoute(
        path: '/pedido',
        builder: (context, _) => const OrderScreen(),
      ),

      // 🔹 Historial de pedidos (Cliente)
      GoRoute(
        path: '/mis-pedidos',
        builder: (context, _) => const MyOrdersScreen(),
      ),

      // 🔹 Pedidos recibidos (Empresa)
      GoRoute(
        path: '/pedidos-empresa',
        builder: (context, _) => const CompanyOrdersScreen(),
      ),

      // 🔹 Reseñas por producto
      GoRoute(
        path: '/reseñas/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final name = state.uri.queryParameters['name'] ?? 'Producto';
          return ReviewsScreen(productId: id, productName: name);
        },
      ),
    ],
  );
}
