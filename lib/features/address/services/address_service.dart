import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Stream<List<AddressModel>> watchAddresses() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('addresses')
        .doc(_userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AddressModel.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          debugPrint('Error watching addresses: $error');
          return <AddressModel>[];
        });
  }

  Future<void> addAddress(AddressModel address) async {
    if (_userId == null) return;

    try {
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      await _firestore
          .collection('addresses')
          .doc(_userId)
          .collection('items')
          .doc(address.id)
          .set(address.toMap());
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    if (_userId == null) return;

    try {
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      await _firestore
          .collection('addresses')
          .doc(_userId)
          .collection('items')
          .doc(address.id)
          .update(address.toMap());
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('addresses')
          .doc(_userId)
          .collection('items')
          .doc(addressId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_userId == null) return;

    try {
      await _clearDefaultAddresses();

      await _firestore
          .collection('addresses')
          .doc(_userId)
          .collection('items')
          .doc(addressId)
          .update({'isDefault': true});
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }

  Future<void> _clearDefaultAddresses() async {
    if (_userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('addresses')
          .doc(_userId)
          .collection('items')
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing default addresses: $e');
    }
  }
}
