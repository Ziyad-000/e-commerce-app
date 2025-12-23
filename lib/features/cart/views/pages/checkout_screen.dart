import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../../address/providers/address_provider.dart';
import '../../../payment/providers/payment_provider.dart';
import '../widgets/checkout_address_step.dart';
import '../widgets/checkout_payment_step.dart';
import '../widgets/checkout_review_step.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();

    // Check Auth
    if (!AuthGuard.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
      });
      return;
    }

    // Initialize providers to load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().listenToAddresses();
      context.read<PaymentProvider>().listenToCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () {
            final checkoutProvider = context.read<CheckoutProvider>();
            if (checkoutProvider.currentStep > 0) {
              checkoutProvider.goToPreviousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(checkoutProvider.currentStep),

              // Step content
              Expanded(
                child: IndexedStack(
                  index: checkoutProvider.currentStep,
                  children: const [
                    CheckoutAddressStep(),
                    CheckoutPaymentStep(),
                    CheckoutReviewStep(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(1, 'Address', currentStep >= 0),
          _buildStepLine(currentStep >= 1),
          _buildStepCircle(2, 'Payment', currentStep >= 1),
          _buildStepLine(currentStep >= 2),
          _buildStepCircle(3, 'Review', currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.destructive : AppColors.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.destructive : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.mutedForeground,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.foreground : AppColors.mutedForeground,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? AppColors.destructive : AppColors.border,
    );
  }
}
