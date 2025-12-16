import 'package:flutter/material.dart';
import '../../address/models/address_model.dart';
import '../../payment/models/payment_card_model.dart';
import '../../orders/models/order_model.dart';
import '../../cart/models/cart_item_model.dart';

class CheckoutProvider extends ChangeNotifier {
  // Checkout steps
  int _currentStep = 0;

  // Selected data
  AddressModel? _selectedAddress;
  PaymentCardModel? _selectedPaymentMethod;

  // Order details
  List<CartItemModel> _cartItems = [];
  double _subtotal = 0.0;
  double _shippingFee = 0.0;
  String? _promoCode;
  double _discount = 0.0;

  // States
  bool _isProcessing = false;
  String? _errorMessage;

  // Getters
  int get currentStep => _currentStep;
  AddressModel? get selectedAddress => _selectedAddress;
  PaymentCardModel? get selectedPaymentMethod => _selectedPaymentMethod;
  List<CartItemModel> get cartItems => _cartItems;
  double get subtotal => _subtotal;
  double get shippingFee => _shippingFee;
  String? get promoCode => _promoCode;
  double get discount => _discount;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  // Calculated getters
  double get total => subtotal - discount + shippingFee;
  bool get canProceedToNextStep {
    switch (_currentStep) {
      case 0: // Address step
        return _selectedAddress != null;
      case 1: // Payment step
        return _selectedPaymentMethod != null;
      case 2: // Review step
        return true;
      default:
        return false;
    }
  }

  // Initialize checkout with cart data
  void initializeCheckout(List<CartItemModel> items, double cartSubtotal) {
    _cartItems = items;
    _subtotal = cartSubtotal;

    // Calculate shipping fee (free shipping over $100)
    const freeShippingThreshold = 100.0;
    _shippingFee = _subtotal >= freeShippingThreshold ? 0.0 : 10.0;

    _currentStep = 0;
    _selectedAddress = null;
    _selectedPaymentMethod = null;
    _promoCode = null;
    _discount = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  // Step navigation
  void goToNextStep() {
    if (_currentStep < 2 && canProceedToNextStep) {
      _currentStep++;
      notifyListeners();
    }
  }

  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // Set selected address
  void setSelectedAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  // Set selected payment method
  void setSelectedPaymentMethod(PaymentCardModel paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  // Apply promo code
  Future<void> applyPromoCode(String code) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call to validate promo code
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any code and apply 10% discount
      // In production, this should validate with backend
      if (code.isNotEmpty) {
        _promoCode = code;
        _discount = _subtotal * 0.10; // 10% discount
        _errorMessage = null;
      } else {
        throw Exception('Invalid promo code');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _promoCode = null;
      _discount = 0.0;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Remove promo code
  void removePromoCode() {
    _promoCode = null;
    _discount = 0.0;
    notifyListeners();
  }

  // Create order from checkout data
  OrderModel createOrder(String userId) {
    if (_selectedAddress == null) {
      throw Exception('No shipping address selected');
    }

    if (_selectedPaymentMethod == null) {
      throw Exception('No payment method selected');
    }

    // Convert cart items to order items
    final orderItems = _cartItems.map((cartItem) {
      return OrderItem(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        imageUrl: cartItem.product.imageUrl,
        size: cartItem.selectedSize,
        color: cartItem.selectedColor,
        quantity: cartItem.quantity,
        price: cartItem.product.price,
      );
    }).toList();

    // Generate order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    // Create order model
    return OrderModel(
      orderId: orderId,
      userId: userId,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      totalAmount: total,
      shippingFee: shippingFee,
      items: orderItems,
      shippingAddress: _selectedAddress!.fullAddress,
      paymentMethod:
          '${_selectedPaymentMethod!.cardType} ending in ${_selectedPaymentMethod!.lastFourDigits}',
    );
  }

  // Reset checkout state
  void reset() {
    _currentStep = 0;
    _selectedAddress = null;
    _selectedPaymentMethod = null;
    _cartItems = [];
    _subtotal = 0.0;
    _shippingFee = 0.0;
    _promoCode = null;
    _discount = 0.0;
    _isProcessing = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
