import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../products/models/product_model.dart';

class SearchService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب Recent Searches من SharedPreferences
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // حفظ بحث جديد
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
      // Handle error
    }
  }

  // حذف بحث معين
  Future<void> removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searches = await getRecentSearches();
      searches.remove(query);
      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      // Handle error
    }
  }

  // مسح كل Recent Searches
  Future<void> clearAllSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      // Handle error
    }
  }

  // البحث في المنتجات (من Firebase)
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
