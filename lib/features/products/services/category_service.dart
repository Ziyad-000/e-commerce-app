import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();
      if (doc.exists && doc.data() != null) {
        return CategoryModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting category: $e');
      return null;
    }
  }
}
