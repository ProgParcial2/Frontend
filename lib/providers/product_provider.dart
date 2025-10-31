import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../providers/auth_provider.dart';

class ProductProvider extends ChangeNotifier {
  late ProductService _service;
  List<Product> all = [];
  bool loading = false;

  /// 🔹 Inicializa el servicio con la autenticación actual
  void init(AuthProvider auth) {
    _service = ProductService(auth);
  }

  /// 🔹 Carga todos los productos disponibles (públicos o filtrados)
  Future<void> loadAll({
    int? empresaId,
    double? minPrice,
    double? maxPrice,
  }) async {
    loading = true;
    notifyListeners();

    try {
      all = await _service.getAll(
        empresaId: empresaId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    } catch (e) {
      debugPrint('❌ Error al cargar productos: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🔹 Agrega un nuevo producto (solo empresa)
  Future<void> addProduct(Product product) async {
    try {
      final created = await _service.create(product);
      all.add(created);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al agregar producto: $e');
    }
  }

  /// 🔹 Actualiza un producto existente (solo empresa)
  Future<void> updateProduct(Product product) async {
    try {
      final updated = await _service.update(product);
      final index = all.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        all[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar producto: $e');
    }
  }

  /// 🔹 Elimina un producto (solo empresa)
  Future<void> deleteProduct(int id) async {
    try {
      await _service.delete(id);
      all.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al eliminar producto: $e');
    }
  }
}
