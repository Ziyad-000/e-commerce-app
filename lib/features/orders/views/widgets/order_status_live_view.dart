import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/order_model.dart';

/// Real-time order status tracking widget
/// Listens to Firestore and updates UI automatically when order status changes
class OrderStatusLiveView extends StatelessWidget {
  final String orderId;

  const OrderStatusLiveView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return _buildErrorState('User not authenticated');
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(userId)
          .collection('userOrders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Error state
        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }

        // No data state
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildErrorState('Order not found');
        }

        // Parse order data
        final orderData = snapshot.data!.data() as Map<String, dynamic>;
        final statusString = orderData['status'] as String? ?? 'pending';
        final OrderStatus status = _parseOrderStatus(statusString);

        // Build status UI
        return _buildStatusCard(status, orderData);
      },
    );
  }

  /// Parses string status to OrderStatus enum
  OrderStatus _parseOrderStatus(String statusString) {
    switch (statusString.toLowerCase()) {
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

  /// Builds the main status card with real-time updates
  Widget _buildStatusCard(OrderStatus status, Map<String, dynamic> orderData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Status Icon
          _buildStatusIcon(status),
          const SizedBox(width: 16),

          // Status Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusMessage(status),
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(status).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getStatusLabel(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate icon for each status
  Widget _buildStatusIcon(OrderStatus status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case OrderStatus.pending:
        iconData = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case OrderStatus.processing:
        iconData = Icons.autorenew;
        iconColor = Colors.orange;
        break;
      case OrderStatus.shipped:
        iconData = Icons.local_shipping;
        iconColor = Colors.green;
        break;
      case OrderStatus.delivered:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        iconData = Icons.cancel;
        iconColor = AppColors.destructive;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  /// Returns the status title text
  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Received';
      case OrderStatus.processing:
        return 'Processing Order';
      case OrderStatus.shipped:
        return 'Order Shipped';
      case OrderStatus.delivered:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  /// Returns the status message
  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'We are preparing your order';
      case OrderStatus.processing:
        return 'Your order is being processed';
      case OrderStatus.shipped:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'This order was cancelled';
    }
  }

  /// Returns the status label
  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Returns the status color
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return AppColors.destructive;
    }
  }

  /// Loading state widget
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          SizedBox(width: 16),
          Text(
            'Loading order status...',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.destructive, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
