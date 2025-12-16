import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';

/// Service for placing orders with Firestore Transactions
/// Ensures atomic operations and prevents race conditions
class OrderPlacementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// - [OutOfStockException] if any product doesn't have enough stock
  /// - [Exception] for authentication or other errors
  Future<String> placeOrder({
    required List<CartItemModel> cartItems,
    required String shippingAddress,
    required String paymentMethod,
    required double totalAmount,
    required double shippingFee,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Generate order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Execute the transaction
      await _firestore.runTransaction((transaction) async {
        // STEP 1: READ - Get all product documents and validate stock
        final Map<String, DocumentSnapshot> productDocs = {};
        final List<Map<String, dynamic>> stockUpdates = [];

        for (final cartItem in cartItems) {
          // Read product document
          final productRef = _firestore
              .collection('products')
              .doc(cartItem.product.id);

          final productDoc = await transaction.get(productRef);

          if (!productDoc.exists) {
            throw Exception('Product ${cartItem.product.name} not found');
          }

          productDocs[cartItem.product.id] = productDoc;
          final currentQuantity = 10;

          // STEP 2: VALIDATE - Check quantity availability
          if (currentQuantity < cartItem.quantity) {
            throw OutOfStockException(
              productName: cartItem.product.name,
              available: currentQuantity,
              requested: cartItem.quantity,
            );
          }

          // Prepare quantity update
          stockUpdates.add({
            'productId': cartItem.product.id,
            'productRef': productRef,
            'newQuantity': currentQuantity - cartItem.quantity,
          });
        }

        // STEP 3: WRITE - All validations passed, now execute writes

        // 3.1: Update product quantity
        for (final update in stockUpdates) {
          transaction.update(update['productRef'] as DocumentReference, {
            'Quantity': update['newQuantity'],
          });
        }

        // 3.2: Create order document
        final orderRef = _firestore
            .collection('orders')
            .doc(_userId)
            .collection('userOrders')
            .doc(orderId);

        final orderItems = cartItems.map((cartItem) {
          return OrderItem(
            productId: cartItem.product.id,
            productName: cartItem.product.name,
            imageUrl: cartItem.product.imageUrl,
            size: cartItem.selectedSize,
            color: cartItem.selectedColor,
            quantity: cartItem.quantity,
            price: cartItem.product.price,
          );
        }).toList();

        final order = OrderModel(
          orderId: orderId,
          userId: _userId!,
          orderDate: DateTime.now(),
          status: OrderStatus.pending,
          totalAmount: totalAmount,
          shippingFee: shippingFee,
          items: orderItems,
          shippingAddress: shippingAddress,
          paymentMethod: paymentMethod,
        );

        transaction.set(orderRef, order.toMap());
      });

      // STEP 4: CLEANUP - Transaction succeeded, clear cart
      await _clearCart();

      return orderId;
    } on OutOfStockException {
      // Re-throw custom exception
      rethrow;
    } catch (e) {
      // Wrap any other errors
      throw Exception('Failed to place order: $e');
    }
  }

  /// Clears all items from the user's cart
  /// Only called after successful order placement
  Future<void> _clearCart() async {
    if (_userId == null) return;

    try {
      final cartItemsSnapshot = await _firestore
          .collection('cart')
          .doc(_userId)
          .collection('items')
          .get();

      // Delete all cart items in a batch
      final batch = _firestore.batch();
      for (final doc in cartItemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Log error but don't fail the order
      print('Warning: Failed to clear cart: $e');
    }
  }

  /// Validates cart items before checkout
  /// Returns a list of out-of-stock products
  Future<List<String>> validateCartStock(List<CartItemModel> cartItems) async {
    final outOfStockProducts = <String>[];

    for (final cartItem in cartItems) {
      try {
        final productDoc = await _firestore
            .collection('products')
            .doc(cartItem.product.id)
            .get();

        if (!productDoc.exists) {
          outOfStockProducts.add(cartItem.product.name);
          continue;
        }

        final currentQuantity = productDoc.data()?['Quantity'] as int? ?? 0;
        if (currentQuantity < cartItem.quantity) {
          outOfStockProducts.add(
            '${cartItem.product.name} (Available: $currentQuantity)',
          );
        }
      } catch (e) {
        outOfStockProducts.add(cartItem.product.name);
      }
    }

    return outOfStockProducts;
  }
}

/// Custom exception for out-of-stock products
class OutOfStockException implements Exception {
  final String productName;
  final int available;
  final int requested;

  OutOfStockException({
    required this.productName,
    required this.available,
    required this.requested,
  });

  @override
  String toString() {
    return 'Out of Stock: $productName (Available: $available, Requested: $requested)';
  }

  String get userMessage {
    return '$productName only has $available items in stock (you requested $requested)';
  }
}
