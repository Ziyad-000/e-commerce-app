import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../products/models/product_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Stream<List<ProductModel>> watchFavorites() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('favorites')
        .doc(_userId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductModel.fromMap(
              data['product'] as Map<String, dynamic>,
            );
          }).toList();
        })
        .handleError((error) {
          debugPrint('Error watching favorites: $error');
          return <ProductModel>[];
        });
  }

  Future<void> addToFavorites(ProductModel product) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .doc(product.id)
          .set({
            'product': product.toMap(),
            'addedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  Future<bool> isFavorite(String productId) async {
    if (_userId == null) return false;

    try {
      final doc = await _firestore
          .collection('favorites')
          .doc(_userId)
          .collection('items')
          .doc(productId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }
}
