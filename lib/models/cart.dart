import 'package:flutter/material.dart';

class CartItem {
  final String productName;
  final int productQuantity;
  final double productPrice;

  CartItem({
    required this.productName,
    required this.productQuantity,
    required this.productPrice,
  });
}

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  bool get isEmpty => _items.isEmpty;

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double calculateTotal() {
    double total = 0;
    for (var item in _items) {
      total += item.productQuantity * item.productPrice;
    }
    return total;
  }

  void addToCart({
    required String productName,
    required int productQuantity,
    required double productPrice,
  }) {
    _items.add(
      CartItem(
        productName: productName,
        productQuantity: productQuantity,
        productPrice: productPrice,
      ),
    );
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}