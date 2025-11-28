import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب كل الفئات
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // جلب فئة واحدة
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching category: $e');
      return null;
    }
  }
}
