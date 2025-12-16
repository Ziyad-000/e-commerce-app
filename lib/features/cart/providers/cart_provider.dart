import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';
import '../../products/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void listenToCart() {
    _isLoading = true;
    notifyListeners();

    _cartService.watchCartItems().listen(
      (items) {
        _cartItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addToCart(
    ProductModel product, {
    String? size,
    int? color,
  }) async {
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      await _cartService.updateQuantity(
        existingItem.id,
        existingItem.quantity + 1,
      );
    } else {
      final newItem = CartItemModel(
        id: '${product.id}_${size ?? 'nosize'}_${color ?? 'nocolor'}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: 1,
        selectedSize: size,
        selectedColor: color,
      );
      await _cartService.addToCart(newItem);
    }
  }

  Future<void> increaseQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      await _cartService.updateQuantity(item.id, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      if (item.quantity > 1) {
        await _cartService.updateQuantity(item.id, item.quantity - 1);
      }
    }
  }

  Future<void> removeFromCart(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      await _cartService.removeFromCart(item.id);
    }
  }

  // Move item to favorites and remove from cart
  Future<void> moveToFavorites(
    int index,
    Function(ProductModel) addToFavorites,
  ) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      await addToFavorites(item.product);
      await removeFromCart(index);
    }
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
  }
}
