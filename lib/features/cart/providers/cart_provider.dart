import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';
import '../../products/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => _cartItems;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // إضافة منتج للـ Cart
  void addToCart(ProductModel product, {String? size, int? color}) {
    // البحث عن المنتج في الـ Cart
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      // زيادة الكمية
      _cartItems[existingIndex].quantity++;
    } else {
      // إضافة منتج جديد
      _cartItems.add(
        CartItemModel(
          product: product,
          quantity: 1,
          selectedSize: size,
          selectedColor: color,
        ),
      );
    }

    _saveCart();
    notifyListeners();
  }

  // زيادة الكمية
  void increaseQuantity(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  // تقليل الكمية
  void decreaseQuantity(int index) {
    if (index >= 0 && index < _cartItems.length) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
        _saveCart();
        notifyListeners();
      }
    }
  }

  // حذف منتج
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      _saveCart();
      notifyListeners();
    }
  }

  // مسح كل الـ Cart
  void clearCart() {
    _cartItems.clear();
    _cartService.clearCart();
    notifyListeners();
  }

  // حفظ الـ Cart
  Future<void> _saveCart() async {
    final cartData = _cartItems.map((item) => item.toMap()).toList();
    await _cartService.saveCart(cartData);
  }

  // تحميل الـ Cart (من SharedPreferences)
  Future<void> loadCart() async {
    //  تحميل المنتجات من Firebase بناءً على IDs
    notifyListeners();
  }
}
