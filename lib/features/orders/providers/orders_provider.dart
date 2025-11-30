import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _ordersService = OrdersService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasOrders => _orders.isNotEmpty;
  int get orderCount => _orders.length;

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get pending orders
  List<OrderModel> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  // Get active orders (pending + processing + shipped)
  List<OrderModel> get activeOrders => _orders
      .where(
        (o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipped,
      )
      .toList();

  // Get completed orders
  List<OrderModel> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();

  // Get cancelled orders
  List<OrderModel> get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  /// Listen to orders (real-time)
  void listenToOrders() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _ordersSubscription?.cancel();
    _ordersSubscription = _ordersService.watchOrders().listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Refresh orders (one-time fetch)
  Future<void> refreshOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _ordersService.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new order
  Future<void> createOrder(OrderModel order) async {
    try {
      _errorMessage = null;
      await _ordersService.createOrder(order);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _ordersService.getOrderById(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _errorMessage = null;
      await _ordersService.updateOrderStatus(orderId, status);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      _errorMessage = null;
      await _ordersService.cancelOrder(orderId);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Add tracking number
  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      _errorMessage = null;
      await _ordersService.addTrackingNumber(orderId, trackingNumber);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      return await _ordersService.getOrderStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'total': 0,
        'pending': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };
    }
  }

  /// Get total spent
  Future<double> getTotalSpent() async {
    try {
      return await _ordersService.getTotalSpent();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear orders
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
