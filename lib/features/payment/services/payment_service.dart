import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_card_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Collection reference
  CollectionReference get _cardsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('payment_methods')
        .doc(_userId)
        .collection('cards');
  }

  /// Add new payment card
  Future<void> addCard(PaymentCardModel card) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // If this card is set as default, remove default from other cards
      if (card.isDefault) {
        await _removeDefaultFromAllCards();
      }

      await _cardsCollection.doc(card.id).set(card.toMap());
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  /// Update existing card
  Future<void> updateCard(PaymentCardModel card) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // If this card is set as default, remove default from other cards
      if (card.isDefault) {
        await _removeDefaultFromAllCards();
      }

      await _cardsCollection.doc(card.id).update(card.toMap());
    } catch (e) {
      throw Exception('Failed to update card: $e');
    }
  }

  /// Delete card
  Future<void> deleteCard(String cardId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _cardsCollection.doc(cardId).delete();
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  /// Set card as default
  Future<void> setDefaultCard(String cardId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // Remove default from all cards
      await _removeDefaultFromAllCards();

      // Set this card as default
      await _cardsCollection.doc(cardId).update({'isDefault': true});
    } catch (e) {
      throw Exception('Failed to set default card: $e');
    }
  }

  /// Remove default flag from all cards
  Future<void> _removeDefaultFromAllCards() async {
    try {
      final snapshot = await _cardsCollection
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove default flags: $e');
    }
  }

  /// Get all cards (one-time fetch)
  Future<List<PaymentCardModel>> getCards() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _cardsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => PaymentCardModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get cards: $e');
    }
  }

  /// Watch cards (real-time stream)
  Stream<List<PaymentCardModel>> watchCards() {
    if (_userId == null) throw Exception('User not authenticated');

    return _cardsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => PaymentCardModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  /// Get default card
  Future<PaymentCardModel?> getDefaultCard() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _cardsCollection
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return PaymentCardModel.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id,
      );
    } catch (e) {
      throw Exception('Failed to get default card: $e');
    }
  }

  /// Get card by ID
  Future<PaymentCardModel?> getCardById(String cardId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final doc = await _cardsCollection.doc(cardId).get();

      if (!doc.exists) return null;

      return PaymentCardModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get card: $e');
    }
  }

  /// Validate card number using Luhn algorithm
  static bool validateCardNumber(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');

    if (number.isEmpty || number.length < 13 || number.length > 19) {
      return false;
    }

    int sum = 0;
    bool isSecond = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (isSecond) {
        digit = digit * 2;
        if (digit > 9) {
          digit = digit - 9;
        }
      }

      sum += digit;
      isSecond = !isSecond;
    }

    return (sum % 10) == 0;
  }

  /// Detect card type from card number
  static String detectCardType(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');

    if (number.isEmpty) return 'Unknown';

    // Visa: starts with 4
    if (number.startsWith('4')) {
      return 'Visa';
    }

    // Mastercard: starts with 51-55 or 2221-2720
    if (number.startsWith(RegExp(r'^5[1-5]')) ||
        (number.length >= 4 &&
            int.parse(number.substring(0, 4)) >= 2221 &&
            int.parse(number.substring(0, 4)) <= 2720)) {
      return 'Mastercard';
    }

    // American Express: starts with 34 or 37
    if (number.startsWith(RegExp(r'^3[47]'))) {
      return 'American Express';
    }

    // Discover: starts with 6011, 622126-622925, 644-649, 65
    if (number.startsWith('6011') ||
        number.startsWith(RegExp(r'^64[4-9]')) ||
        number.startsWith('65')) {
      return 'Discover';
    }

    return 'Unknown';
  }

  /// Validate expiry date
  static bool validateExpiryDate(String month, String year) {
    final expMonth = int.tryParse(month);
    final expYear = int.tryParse(year);

    if (expMonth == null || expYear == null) return false;
    if (expMonth < 1 || expMonth > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (expYear < currentYear) return false;
    if (expYear == currentYear && expMonth < currentMonth) return false;

    return true;
  }

  /// Extract last 4 digits from card number
  static String getLastFourDigits(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.length < 4) return number;
    return number.substring(number.length - 4);
  }
}
