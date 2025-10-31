import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  final bool isClient;

  const DashboardScreen({super.key, required this.isClient});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isClient ? 'Panel del Cliente' : 'Panel de la Empresa',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isClient
                      ? 'Bienvenido, cliente 👋'
                      : 'Bienvenido, empresa 🏢',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Botones según el rol del usuario
                if (isClient) ...[
                  _DashboardButton(
                    icon: Icons.shopping_bag,
                    label: 'Ver productos disponibles',
                    color: Colors.indigo.shade700,
                    onTap: () => context.push('/productos'),
                  ),
                  _DashboardButton(
                    icon: Icons.add_shopping_cart,
                    label: 'Hacer un pedido',
                    color: Colors.indigo.shade600,
                    onTap: () => context.push('/pedido'),
                  ),
                  _DashboardButton(
                    icon: Icons.history,
                    label: 'Mis pedidos',
                    color: Colors.indigo.shade500,
                    onTap: () => context.push('/mis-pedidos'),
                  ),
                ] else ...[
                  _DashboardButton(
                    icon: Icons.inventory_2,
                    label: 'Mis productos',
                    color: Colors.indigo.shade700,
                    onTap: () => context.push('/mis-productos'),
                  ),
                  _DashboardButton(
                    icon: Icons.shopping_cart,
                    label: 'Pedidos recibidos',
                    color: Colors.indigo.shade600,
                    onTap: () => context.push('/pedidos-empresa'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
