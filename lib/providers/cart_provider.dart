import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(0.0, (s, e) => s + e.subtotal);

  void addItem(Product product, {int qty = 1}) {
    final idx = _items.indexWhere((it) => it.product.id == product.id);
    if (idx >= 0) {
      // no exceder stock
      final newQty = _items[idx].quantity + qty;
      _items[idx].quantity = newQty <= product.stock ? newQty : product.stock;
    } else {
      _items.add(CartItem(product: product, quantity: qty <= product.stock ? qty : product.stock));
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.removeWhere((it) => it.product.id == product.id);
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final idx = _items.indexWhere((it) => it.product.id == product.id);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void updateQuantity(Product product, int quantity) {
    final idx = _items.indexWhere((it) => it.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity = quantity <= product.stock ? quantity : product.stock;
      if (_items[idx].quantity <= 0) _items.removeAt(idx);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
