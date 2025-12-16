import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String status;

  const OrderStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Check if order is cancelled
    if (status.toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.destructive, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.destructive, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This order has been cancelled',
                    style: TextStyle(
                      color: AppColors.destructive.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Active order timeline
    final steps = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    final currentIndex = _getCurrentStepIndex(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                // Step circle
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex <= currentIndex;
                final isCurrent = stepIndex == currentIndex;

                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.destructive
                              : AppColors.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.destructive
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  isCurrent
                                      ? _getStatusIcon(steps[stepIndex])
                                      : Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[stepIndex],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.foreground
                              : AppColors.mutedForeground,
                          fontSize: 11,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Connecting line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentIndex;

                return Expanded(
                  flex: 1,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 32),
                    color: isCompleted
                        ? AppColors.destructive
                        : AppColors.border,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  int _getCurrentStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  IconData _getStatusIcon(String step) {
    switch (step.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }
}
