// USAGE EXAMPLE: How to use OrderPlacementService and OrderStatusLiveView

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_placement_service.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../cart/providers/checkout_provider.dart';
import 'order_status_live_view.dart';

/// Example: Placing an order from your checkout screen
class CheckoutExample extends StatefulWidget {
  const CheckoutExample({super.key});

  @override
  State<CheckoutExample> createState() => _CheckoutExampleState();
}

class _CheckoutExampleState extends State<CheckoutExample> {
  final OrderPlacementService _orderService = OrderPlacementService();
  bool _isPlacingOrder = false;

  Future<void> _handlePlaceOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Capture context before any async gaps if it's needed after them
      // However, in a StatefulWidget's State, `context` is always available
      // and `mounted` check handles its validity.
      final cartProvider = context.read<CartProvider>();
      final checkoutProvider = context.read<CheckoutProvider>();

      // Validate stock before attempting transaction
      final outOfStockItems = await _orderService.validateCartStock(
        cartProvider.cartItems,
      );

      if (outOfStockItems.isNotEmpty) {
        if (!mounted) return;
        _showOutOfStockDialog(context, outOfStockItems);
        setState(() {
          _isPlacingOrder = false;
        });
        return;
      }

      // Place order using transaction
      final orderId = await _orderService.placeOrder(
        cartItems: cartProvider.cartItems,
        shippingAddress: checkoutProvider.selectedAddress!.fullAddress,
        paymentMethod: checkoutProvider.selectedPaymentMethod!.cardType,
        totalAmount: checkoutProvider.total,
        shippingFee: checkoutProvider.shippingFee,
      );

      if (!mounted) return;

      // Navigate to order confirmation
      Navigator.pushReplacementNamed(
        context,
        '/order-confirmation',
        arguments: orderId,
      );
    } on OutOfStockException catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Out of Stock', e.userMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Order Failed', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _showOutOfStockDialog(BuildContext context, List<String> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Items Out of Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following items are out of stock:'),
            const SizedBox(height: 12),
            ...items.map((item) => Text('• $item')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          // Your checkout UI here
          const Spacer(),

          // Place Order Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example: Using OrderStatusLiveView in your order confirmation screen
class OrderConfirmationExample extends StatelessWidget {
  final String orderId;

  const OrderConfirmationExample({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Order ID: $orderId'),
            const SizedBox(height: 24),

            // Real-time status widget
            const Text(
              'Order Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            OrderStatusLiveView(orderId: orderId),

            const SizedBox(height: 24),
            const Text(
              '✨ Status updates automatically in real-time!',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
