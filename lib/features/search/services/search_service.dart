import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = await getRecentSearches();

      searches.remove(query);
      searches.insert(0, query);

      if (searches.length > _maxRecentSearches) {
        searches = searches.sublist(0, _maxRecentSearches);
      }

      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      debugPrint('Error saving search: $e');
    }
  }

  Future<void> removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = await getRecentSearches();
      searches.remove(query);
      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      debugPrint('Error removing search: $e');
    }
  }

  Future<void> clearAllSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      debugPrint('Error clearing searches: $e');
    }
  }
}
