import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProductModel>> watchAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error watching all products: $error');
          return <ProductModel>[];
        });
  }

  Stream<List<ProductModel>> watchFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error watching featured products: $error');
          return <ProductModel>[];
        });
  }

  Stream<List<ProductModel>> watchByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error watching products by category: $error');
          return <ProductModel>[];
        });
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  Stream<List<ProductModel>> searchProducts(String query) {
    if (query.isEmpty) {
      return watchAllProducts();
    }

    final lowerQuery = query.toLowerCase();

    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final name = (data['name'] ?? '').toString().toLowerCase();
                final description = (data['description'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(lowerQuery) ||
                    description.contains(lowerQuery);
              })
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error searching products: $error');
          return <ProductModel>[];
        });
  }
}
