import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';
import '../services/favorites_service.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  final Set<String> _favoriteIds = {};
  List<ProductModel> _favorites = [];
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  List<ProductModel> get favorites => _favorites;
  int get favoriteCount => _favoriteIds.length;
  bool get isLoading => _isLoading;

  void listenToFavorites() {
    _isLoading = true;
    notifyListeners();

    _favoritesService.watchFavorites().listen(
      (products) {
        _favorites = products;
        _favoriteIds.clear();
        _favoriteIds.addAll(products.map((p) => p.id));
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleFavorite(ProductModel product) async {
    if (_favoriteIds.contains(product.id)) {
      await removeFromFavorites(product.id);
    } else {
      await addToFavorites(product);
    }
  }

  Future<void> addFavoriteProduct(ProductModel product) async {
    await addToFavorites(product);
  }

  Future<void> addToFavorites(ProductModel product) async {
    _favoriteIds.add(product.id);
    notifyListeners();
    await _favoritesService.addToFavorites(product);
  }

  Future<void> removeFavoriteProduct(String productId) async {
    await removeFromFavorites(productId);
  }

  Future<void> removeFromFavorites(String productId) async {
    _favoriteIds.remove(productId);
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();
    await _favoritesService.removeFromFavorites(productId);
  }

  Future<void> clearAll() async {
    await _favoritesService.clearAllFavorites();
  }
}
