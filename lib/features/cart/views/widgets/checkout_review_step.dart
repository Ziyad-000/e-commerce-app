import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../../orders/services/order_placement_service.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';

class CheckoutReviewStep extends StatelessWidget {
  const CheckoutReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, checkoutProvider, child) {
        final address = checkoutProvider.selectedAddress;
        final payment = checkoutProvider.selectedPaymentMethod;
        final subtotal = checkoutProvider.subtotal;
        final shipping = checkoutProvider.shippingFee;
        final discount = checkoutProvider.discount;
        final total = checkoutProvider.total;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Order Items
                  _buildSectionHeader(
                    'Order Items (${checkoutProvider.cartItems.length})',
                  ),
                  const SizedBox(height: 12),
                  ...checkoutProvider.cartItems.map(
                    (item) => _buildCartItem(item),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Address
                  _buildSectionHeader('Delivery Address'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: address?.name ?? 'No address selected',
                    subtitle: address?.fullAddress ?? '',
                    trailing: TextButton(
                      onPressed: () {
                        checkoutProvider.goToStep(0);
                      },
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildSectionHeader('Payment Method'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.payment_outlined,
                    title:
                        '${payment?.cardType ?? ''} ${payment?.maskedNumber ?? ''}',
                    subtitle: payment != null
                        ? 'Exp: ${payment.expiryDate}'
                        : '',
                    trailing: TextButton(
                      onPressed: () {
                        checkoutProvider.goToStep(1);
                      },
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionHeader('Order Summary'),
                  const SizedBox(height: 12),
                  _buildOrderSummaryCard(subtotal, shipping, discount, total),
                ],
              ),
            ),
            _buildBottomBar(context, checkoutProvider),
          ],
        );
      },
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

  Widget _buildCartItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surface2,
                  child: const Icon(Icons.image_not_supported, size: 24),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedSize != null ||
                    item.selectedColor != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${item.selectedSize != null ? 'Size: ${item.selectedSize}' : ''}${item.selectedSize != null && item.selectedColor != null ? ' • ' : ''}${item.selectedColor != null ? 'Color' : ''}',
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.foreground, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    double subtotal,
    double shipping,
    double discount,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Shipping',
            shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
          ),
          if (discount > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Discount',
              '-\$${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          _buildSummaryRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
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
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.foreground : AppColors.mutedForeground,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? AppColors.destructive : AppColors.foreground,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CheckoutProvider checkoutProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: checkoutProvider.isProcessing
                ? null
                : () async {
                    await _placeOrder(context, checkoutProvider);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: AppColors.surface2,
              disabledForegroundColor: AppColors.mutedForeground,
            ),
            child: checkoutProvider.isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CheckoutProvider checkoutProvider,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showErrorSnackBar(context, 'Please log in to continue');
      return;
    }

    // Show loading overlay
    _showLoadingOverlay(context);

    try {
      final orderService = OrderPlacementService();
      final cartProvider = context.read<CartProvider>();

      // Place order using Firestore Transaction
      // This ensures atomic stock validation and order creation
      final orderId = await orderService.placeOrder(
        cartItems: cartProvider.cartItems,
        shippingAddress: checkoutProvider.selectedAddress!.fullAddress,
        paymentMethod:
            '${checkoutProvider.selectedPaymentMethod!.cardType} ending in ${checkoutProvider.selectedPaymentMethod!.lastFourDigits}',
        totalAmount: checkoutProvider.total,
        shippingFee: checkoutProvider.shippingFee,
      );

      // Dismiss loading overlay
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to order confirmation
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.orderConfirmationRoute,
          arguments: orderId,
        );
      }
    } on OutOfStockException catch (e) {
      // Dismiss loading overlay
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show out of stock error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.userMessage),
            backgroundColor: AppColors.destructive,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading overlay
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show generic error
      if (context.mounted) {
        _showErrorSnackBar(context, 'Something went wrong. Please try again.');
      }
    }
  }

  /// Shows a loading overlay dialog
  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.destructive,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Placing your order...',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please wait',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows an error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.destructive,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
