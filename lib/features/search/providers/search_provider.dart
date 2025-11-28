import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  List<String> _recentSearches = [];
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;

  // Getters
  List<String> get recentSearches => _recentSearches;
  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  // تحميل Recent Searches
  Future<void> loadRecentSearches() async {
    _recentSearches = await _searchService.getRecentSearches();
    notifyListeners();
  }

  // البحث
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // حفظ البحث
      await _searchService.saveSearch(query);
      await loadRecentSearches();

      // البحث في المنتجات
      _searchResults = await _searchService.searchProducts(query);
    } catch (e) {
      debugPrint('Error searching products: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // حذف بحث معين
  Future<void> removeRecentSearch(String query) async {
    await _searchService.removeSearch(query);
    await loadRecentSearches();
  }

  // مسح كل الـ Recent Searches
  Future<void> clearAllSearches() async {
    await _searchService.clearAllSearches();
    _recentSearches = [];
    notifyListeners();
  }

  // مسح نتائج البحث
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
