import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/card_formatters.dart';
import '../../models/payment_card_model.dart';
import '../../providers/payment_provider.dart';

class AddPaymentDialog {
  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _AddPaymentDialogContent();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }
}

class _AddPaymentDialogContent extends StatefulWidget {
  const _AddPaymentDialogContent();

  @override
  State<_AddPaymentDialogContent> createState() =>
      _AddPaymentDialogContentState();
}

class _AddPaymentDialogContentState extends State<_AddPaymentDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();

  String _cardType = 'Unknown';
  bool _isLoading = false;
  bool _setAsDefault = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur Background
        Positioned.fill(
          child: GestureDetector(
            onTap: _isLoading ? null : () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Dialog Content
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 80),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Payment Method',
                                  style: TextStyle(
                                    color: AppColors.foreground,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Enter your card details',
                                  style: TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: AppColors.mutedForeground,
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Card Number
                      _buildLabel('Card Number'),
                      TextFormField(
                        controller: _cardNumberController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter(),
                        ],
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                        decoration: _buildInputDecoration(
                          hint: '1234 5678 9012 3456',
                          suffix: _cardType != 'Unknown'
                              ? Text(
                                  _cardType,
                                  style: const TextStyle(
                                    color: AppColors.destructive,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _cardType = CardUtils.getCardType(value);
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.replaceAll(' ', '').length < 16) {
                            return 'Invalid card number';
                          }
                          if (!CardUtils.isValidCardNumber(value)) {
                            return 'Invalid card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Card Holder Name
                      _buildLabel('Card Holder Name'),
                      TextFormField(
                        controller: _cardHolderController,
                        enabled: !_isLoading,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(hint: 'JOHN DOE'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card holder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expiry and CVV
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Expiry Date'),
                                TextFormField(
                                  controller: _expiryController,
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ExpiryDateFormatter(),
                                  ],
                                  style: const TextStyle(
                                    color: AppColors.foreground,
                                    fontSize: 16,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hint: 'MM/YY',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!value.contains('/') ||
                                        value.length < 5) {
                                      return 'Invalid';
                                    }
                                    if (!CardUtils.isValidExpiryDate(value)) {
                                      return 'Expired';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('CVV'),
                                TextFormField(
                                  controller: _cvvController,
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CVVFormatter(),
                                  ],
                                  style: const TextStyle(
                                    color: AppColors.foreground,
                                    fontSize: 16,
                                  ),
                                  decoration: _buildInputDecoration(
                                    hint: '123',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Billing Address
                      _buildLabel('Billing Address'),
                      TextFormField(
                        controller: _addressController,
                        enabled: !_isLoading,
                        maxLines: 2,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(
                          hint: '123 Main Street, New York, NY 10001',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter billing address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Set as Default Checkbox
                      InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _setAsDefault = !_setAsDefault;
                                });
                              },
                        child: Row(
                          children: [
                            Checkbox(
                              value: _setAsDefault,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _setAsDefault = value ?? false;
                                      });
                                    },
                              activeColor: AppColors.destructive,
                            ),
                            const Expanded(
                              child: Text(
                                'Set as default payment method',
                                style: TextStyle(
                                  color: AppColors.foreground,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Security Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'We only store the last 4 digits. CVV is never saved.',
                                style: TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.foreground,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.destructive,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Add Card'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<PaymentProvider>();

      // Extract last 4 digits
      final lastFourDigits = provider.getLastFourDigits(
        _cardNumberController.text,
      );

      // Split expiry date
      final expiryParts = _expiryController.text.split('/');
      final expiryMonth = expiryParts[0];
      final expiryYear = expiryParts[1];

      // Detect card type
      final cardType = provider.detectCardType(_cardNumberController.text);

      // Create card model
      final card = PaymentCardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardHolderName: _cardHolderController.text.trim(),
        cardType: cardType,
        lastFourDigits: lastFourDigits,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        billingAddress: _addressController.text.trim(),
        isDefault: _setAsDefault,
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      await provider.addCard(card);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.foreground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.mutedForeground),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.all(12), child: suffix)
          : null,
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}
