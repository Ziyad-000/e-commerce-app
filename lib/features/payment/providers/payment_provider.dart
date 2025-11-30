import 'dart:async';
import 'package:flutter/material.dart';
import '../models/payment_card_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentCardModel> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<PaymentCardModel>>? _cardsSubscription;

  // Getters
  List<PaymentCardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCards => _cards.isNotEmpty;
  int get cardCount => _cards.length;

  // Get default card
  PaymentCardModel? get defaultCard {
    try {
      return _cards.firstWhere((card) => card.isDefault);
    } catch (e) {
      return null;
    }
  }

  /// Listen to cards (real-time)
  void listenToCards() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _cardsSubscription?.cancel();
    _cardsSubscription = _paymentService.watchCards().listen(
      (cards) {
        _cards = cards;
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

  /// Add new card
  Future<void> addCard(PaymentCardModel card) async {
    try {
      _errorMessage = null;
      await _paymentService.addCard(card);
      // No need to call notifyListeners() - stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update card
  Future<void> updateCard(PaymentCardModel card) async {
    try {
      _errorMessage = null;
      await _paymentService.updateCard(card);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete card
  Future<void> deleteCard(String cardId) async {
    try {
      _errorMessage = null;
      await _paymentService.deleteCard(cardId);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Set card as default
  Future<void> setDefaultCard(String cardId) async {
    try {
      _errorMessage = null;
      await _paymentService.setDefaultCard(cardId);
      // Stream will update automatically
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get card by ID
  PaymentCardModel? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  /// Validate card number
  bool validateCardNumber(String cardNumber) {
    return PaymentService.validateCardNumber(cardNumber);
  }

  /// Detect card type
  String detectCardType(String cardNumber) {
    return PaymentService.detectCardType(cardNumber);
  }

  /// Validate expiry date
  bool validateExpiryDate(String month, String year) {
    return PaymentService.validateExpiryDate(month, year);
  }

  /// Get last four digits
  String getLastFourDigits(String cardNumber) {
    return PaymentService.getLastFourDigits(cardNumber);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh cards (one-time fetch)
  Future<void> refreshCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _paymentService.getCards();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    super.dispose();
  }
}
