import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Collection reference
  CollectionReference _ordersCollection(String userId) {
    return _firestore.collection('orders').doc(userId).collection('userOrders');
  }

  /// Create new order
  Future<void> createOrder(OrderModel order) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _ordersCollection(_userId!).doc(order.orderId).set(order.toMap());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get all orders (real-time stream)
  Stream<List<OrderModel>> watchOrders() {
    if (_userId == null) throw Exception('User not authenticated');

    return _ordersCollection(
      _userId!,
    ).orderBy('orderDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  /// Get orders (one-time fetch)
  Future<List<OrderModel>> getOrders() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _ordersCollection(
        _userId!,
      ).orderBy('orderDate', descending: true).get();

      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final doc = await _ordersCollection(_userId!).doc(orderId).get();

      if (!doc.exists) return null;

      return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _ordersCollection(_userId!)
          .where('status', isEqualTo: status.name)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{'status': status.name};

      // If delivered, add delivered timestamp
      if (status == OrderStatus.delivered) {
        updates['deliveredAt'] = Timestamp.now();
      }

      await _ordersCollection(_userId!).doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // Get order first to check if it can be cancelled
      final order = await getOrderById(orderId);

      if (order == null) throw Exception('Order not found');

      if (!order.canCancel) {
        throw Exception('This order cannot be cancelled');
      }

      await _ordersCollection(
        _userId!,
      ).doc(orderId).update({'status': OrderStatus.cancelled.name});
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Add tracking number
  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _ordersCollection(
        _userId!,
      ).doc(orderId).update({'trackingNumber': trackingNumber});
    } catch (e) {
      throw Exception('Failed to add tracking number: $e');
    }
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _ordersCollection(_userId!).doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final orders = await getOrders();

      return {
        'total': orders.length,
        'pending': orders.where((o) => o.status == OrderStatus.pending).length,
        'processing': orders
            .where((o) => o.status == OrderStatus.processing)
            .length,
        'shipped': orders.where((o) => o.status == OrderStatus.shipped).length,
        'delivered': orders
            .where((o) => o.status == OrderStatus.delivered)
            .length,
        'cancelled': orders
            .where((o) => o.status == OrderStatus.cancelled)
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  /// Get total spent
  Future<double> getTotalSpent() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final orders = await getOrders();

      return orders
          .where((o) => o.status != OrderStatus.cancelled)
          .map((o) => o.grandTotal)
          .fold<double>(0.0, (sum, amount) => sum + amount);
    } catch (e) {
      throw Exception('Failed to get total spent: $e');
    }
  }
}
