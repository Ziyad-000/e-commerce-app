import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/order_status_timeline.dart';
import '../../../../core/widgets/universal_image.dart';
import '../widgets/order_status_live_view.dart';
import '../../models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Order Details'),
        ),
        body: const Center(child: Text('Please log in to view order details')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(userId)
            .collection('userOrders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.destructive,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading order',
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // No data
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Not Found',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This order does not exist',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Parse order data
          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final order = OrderModel.fromMap(orderData, snapshot.data!.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real-Time Status Widget (Updates Live!)
                OrderStatusLiveView(orderId: orderId),
                const SizedBox(height: 16),

                // Header - Order ID and Date
                _buildOrderHeader(order),
                const SizedBox(height: 20),

                // Status Timeline
                OrderStatusTimeline(status: order.status.name),
                const SizedBox(height: 24),

                // Shipping Address
                _buildSectionHeader('Shipping Address'),
                const SizedBox(height: 12),
                _buildAddressCard(order.shippingAddress),
                const SizedBox(height: 24),

                // Order Items
                _buildSectionHeader('Order Items (${order.itemCount})'),
                const SizedBox(height: 12),
                ...order.items.map((item) => _buildOrderItem(item)),
                const SizedBox(height: 24),

                // Payment Summary
                _buildSectionHeader('Payment Summary'),
                const SizedBox(height: 12),
                _buildPaymentSummary(order),
                const SizedBox(height: 24),

                // Action Buttons
                if (order.canCancel) ...[
                  _buildCancelButton(context, orderId),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order ID',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: order.statusColor, width: 1),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: order.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.orderId,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(order.orderDate),
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.foreground,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressCard(String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppColors.foreground,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(
                color: AppColors.foreground,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildProductImage(item.imageUrl),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.size != null || item.color != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${item.size != null ? 'Size: ${item.size}' : ''}${item.size != null && item.color != null ? ' • ' : ''}${item.color != null ? 'Color' : ''}',
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal',
            '\$${order.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Shipping',
            order.shippingFee == 0
                ? 'Free'
                : '\$${order.shippingFee.toStringAsFixed(2)}',
          ),
          if (order.paymentMethod != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Payment Method',
              order.paymentMethod!,
              isText: true,
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          _buildSummaryRow(
            'Total Amount',
            '\$${order.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isText = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.foreground : AppColors.mutedForeground,
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: isTotal ? 17 : (isText ? 13 : 14),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context, String orderId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showCancelConfirmation(context, orderId),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancel Order'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.destructive,
          side: const BorderSide(color: AppColors.destructive),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    String orderId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Cancel Order?',
          style: TextStyle(color: AppColors.foreground),
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, Keep Order',
              style: TextStyle(color: AppColors.foreground),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) return;

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(userId)
            .collection('userOrders')
            .doc(orderId)
            .update({'status': 'cancelled'});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel order: $e'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      }
    }
  }

  Widget _buildProductImage(String imageUrl) {
    return UniversalImage(
      imageUrl: imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorWidget: _buildErrorImage(),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 70,
      height: 70,
      color: AppColors.surface2,
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.mutedForeground,
        size: 28,
      ),
    );
  }
}
