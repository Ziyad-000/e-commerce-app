import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService {
  static const String _cartKey = 'shopping_cart';

  // حفظ الـ Cart
  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cartJson = jsonEncode(cartItems);
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      // Handle error
    }
  }

  // جلب الـ Cart
  Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        return decoded.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // مسح الـ Cart
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      // Handle error
    }
  }
}
