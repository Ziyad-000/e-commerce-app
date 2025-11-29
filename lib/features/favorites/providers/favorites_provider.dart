import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};
  final List<ProductModel> _favorites = [];

  Set<String> get favoriteIds => _favoriteIds;
  List<ProductModel> get favorites => _favorites;
  int get favoriteCount => _favoriteIds.length;

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      _favorites.removeWhere((product) => product.id == productId);
    } else {
      _favoriteIds.add(productId);
      // Note: Product will be added via addFavoriteProduct method
    }
    notifyListeners();
  }

  void addFavoriteProduct(ProductModel product) {
    if (!_favoriteIds.contains(product.id)) {
      _favoriteIds.add(product.id);
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFavoriteProduct(String productId) {
    _favoriteIds.remove(productId);
    _favorites.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  void clearAll() {
    _favoriteIds.clear();
    _favorites.clear();
    notifyListeners();
  }
}
