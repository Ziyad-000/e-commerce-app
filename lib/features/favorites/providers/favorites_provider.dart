import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  // تحميل المفضلات
  Future<void> loadFavorites() async {
    _favoriteIds = await _favoritesService.getFavorites();
    notifyListeners();
  }

  // التحقق لو المنتج مفضل
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  // إضافة/إزالة من المفضلات
  Future<void> toggleFavorite(String productId) async {
    await _favoritesService.toggleFavorite(productId);
    await loadFavorites();
  }

  // مسح كل المفضلات
  Future<void> clearFavorites() async {
    await _favoritesService.clearFavorites();
    _favoriteIds = [];
    notifyListeners();
  }
}
