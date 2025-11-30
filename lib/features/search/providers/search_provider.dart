import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';
import '../../products/services/products_service.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  final ProductsService _productsService = ProductsService();

  List<String> _recentSearches = [];
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';

  List<String> get recentSearches => _recentSearches;
  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get lastQuery => _lastQuery;

  Future<void> loadRecentSearches() async {
    _recentSearches = await _searchService.getRecentSearches();
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _lastQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _lastQuery = query;
    notifyListeners();

    _searchService.saveSearch(query);
    loadRecentSearches();

    _productsService
        .searchProducts(query)
        .listen(
          (products) {
            _searchResults = products;
            _isSearching = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error searching products: $error');
            _searchResults = [];
            _isSearching = false;
            notifyListeners();
          },
        );
  }

  Future<void> removeRecentSearch(String query) async {
    await _searchService.removeSearch(query);
    await loadRecentSearches();
  }

  Future<void> clearAllSearches() async {
    await _searchService.clearAllSearches();
    _recentSearches = [];
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    _lastQuery = '';
    notifyListeners();
  }
}
