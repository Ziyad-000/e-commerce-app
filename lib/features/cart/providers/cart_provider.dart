import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item_model.dart';
import '../../products/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  static const String _cartCacheKey = 'cached_cart_items';

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  /// Load cart from local storage on startup
  Future<void> loadCachedCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cartCacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        _cartItems = jsonList
            .map((json) => CartItemModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save cart to local storage
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cartItems.map((item) => item.toMap()).toList();
      await prefs.setString(_cartCacheKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving cart to cache: $e');
    }
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
      // Item exists, update quantity
      _cartItems[existingIndex] = CartItemModel(
        id: _cartItems[existingIndex].id,
        product: _cartItems[existingIndex].product,
        quantity: _cartItems[existingIndex].quantity + 1,
        selectedSize: _cartItems[existingIndex].selectedSize,
        selectedColor: _cartItems[existingIndex].selectedColor,
      );
    } else {
      // New item
      final newItem = CartItemModel(
        id: '${product.id}_${size ?? 'nosize'}_${color ?? 'nocolor'}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: 1,
        selectedSize: size,
        selectedColor: color,
      );
      _cartItems.add(newItem);
    }

    notifyListeners();
    await _saveToCache();
  }

  Future<void> increaseQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index] = CartItemModel(
        id: _cartItems[index].id,
        product: _cartItems[index].product,
        quantity: _cartItems[index].quantity + 1,
        selectedSize: _cartItems[index].selectedSize,
        selectedColor: _cartItems[index].selectedColor,
      );
      notifyListeners();
      await _saveToCache();
    }
  }

  Future<void> decreaseQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index] = CartItemModel(
          id: _cartItems[index].id,
          product: _cartItems[index].product,
          quantity: _cartItems[index].quantity - 1,
          selectedSize: _cartItems[index].selectedSize,
          selectedColor: _cartItems[index].selectedColor,
        );
        notifyListeners();
        await _saveToCache();
      }
    }
  }

  Future<void> removeFromCart(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
      await _saveToCache();
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
    _cartItems.clear();
    notifyListeners();
    await _saveToCache();
  }
}
