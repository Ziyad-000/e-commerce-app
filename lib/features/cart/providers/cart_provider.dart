import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../../products/models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  StreamSubscription<List<CartItemModel>>? _cartSubscription;

  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  CartProvider() {
    _initCart();
  }

  void _initCart() {
    _isLoading = true;
    notifyListeners();

    _cartSubscription = _cartService.watchCartItems().listen(
      (items) {
        _cartItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to cart items: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  Future<void> addToCart(
    ProductModel product, {
    String? size,
    int? color,
  }) async {
    // Generate a unique ID based on product and variants, or let Firestore generate it?
    // The current CartService works with the ID passed in the model.
    // We should check if it exists in the *current* list to increment,
    // BUT CartService structure is /cart/uid/items/docId.
    // If we use the same ID generation logic, we can update or set.

    // Logic:
    // 1. Check if item already exists in _cartItems (local mirror)
    // 2. If exists, update quantity via service
    // 3. If new, add via service

    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      final item = _cartItems[existingIndex];
      await _cartService.updateQuantity(item.id, item.quantity + 1);
    } else {
      final newItem = CartItemModel(
        id: '${product.id}_${size ?? 'nosize'}_${color ?? 'nocolor'}',
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
