import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Stream<List<CartItemModel>> watchCartItems() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('cart')
        .doc(_userId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CartItemModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error watching cart items: $error');
          return <CartItemModel>[];
        });
  }

  Future<void> addToCart(CartItemModel item) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('cart')
          .doc(_userId)
          .collection('items')
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('cart')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .update({'quantity': quantity});
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('cart')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('cart')
          .doc(_userId)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}
