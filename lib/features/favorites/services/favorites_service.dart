import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_products';

  // جلب المفضلات
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // إضافة/إزالة من المفضلات
  Future<void> toggleFavorite(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = await getFavorites();

      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }

      await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      // Handle error
    }
  }

  // مسح كل المفضلات
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      // Handle error
    }
  }
}
