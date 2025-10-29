import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> products = [];
  bool loading = false;

  Future<void> load({String? companyId, double? min, double? max}) async {
    loading = true;
    notifyListeners();
    try {
      products = await ApiService.fetchProducts(
        companyId: companyId,
        min: min,
        max: max,
      );
    } catch (e) {
      products = [];
      debugPrint('Error cargando productos: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

