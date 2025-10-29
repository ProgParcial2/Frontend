import 'package:flutter/material.dart';
import '../models/product.dart';

class OrderProvider extends ChangeNotifier {
  final List<Product> _orders = [];

  List<Product> get orders => _orders;

  void addOrder(Product product) {
    _orders.add(product);
    notifyListeners();
  }

  void removeOrder(Product product) {
    _orders.remove(product);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
