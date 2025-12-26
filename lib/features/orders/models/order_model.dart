import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final String? size;
  final int? color;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    this.size,
    this.color,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      size: map['size'],
      color: map['color'],
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderModel {
  final String orderId;
  final String userId;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;
  final double shippingFee;
  final List<OrderItem> items;
  final String shippingAddress;
  final String? paymentMethod;
  final String? trackingNumber;
  final DateTime? deliveredAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    this.shippingFee = 0,
    required this.items,
    required this.shippingAddress,
    this.paymentMethod,
    this.trackingNumber,
    this.deliveredAt,
  });

  // Getters
  double get subtotal =>
      items.fold(0, (total, item) => total + item.totalPrice);
  double get grandTotal => subtotal + shippingFee;
  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return AppColors.destructive;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.processing;
  bool get isCompleted => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  // Copy with
  OrderModel copyWith({
    String? orderId,
    String? userId,
    DateTime? orderDate,
    OrderStatus? status,
    double? totalAmount,
    double? shippingFee,
    List<OrderItem>? items,
    String? shippingAddress,
    String? paymentMethod,
    String? trackingNumber,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.name,
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      'items': items.map((item) => item.toMap()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
    };
  }

  // From Firestore
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      status: _parseOrderStatus(map['status']),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      items:
          (map['items'] as List?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'],
      trackingNumber: map['trackingNumber'],
      deliveredAt: map['deliveredAt'] != null
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, status: ${status.name}, total: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}
