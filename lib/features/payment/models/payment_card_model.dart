import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCardModel {
  final String id;
  final String cardHolderName;
  final String cardType;
  final String lastFourDigits;
  final String expiryMonth;
  final String expiryYear;
  final String billingAddress;
  final bool isDefault;
  final DateTime createdAt;

  PaymentCardModel({
    required this.id,
    required this.cardHolderName,
    required this.cardType,
    required this.lastFourDigits,
    required this.expiryMonth,
    required this.expiryYear,
    required this.billingAddress,
    this.isDefault = false,
    required this.createdAt,
  });

  // From Firestore
  factory PaymentCardModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentCardModel(
      id: id,
      cardHolderName: map['cardHolderName'] ?? '',
      cardType: map['cardType'] ?? 'Visa',
      lastFourDigits: map['lastFourDigits'] ?? '',
      expiryMonth: map['expiryMonth'] ?? '',
      expiryYear: map['expiryYear'] ?? '',
      billingAddress: map['billingAddress'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'cardHolderName': cardHolderName,
      'cardType': cardType,
      'lastFourDigits': lastFourDigits,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'billingAddress': billingAddress,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with
  PaymentCardModel copyWith({
    String? id,
    String? cardHolderName,
    String? cardType,
    String? lastFourDigits,
    String? expiryMonth,
    String? expiryYear,
    String? billingAddress,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardType: cardType ?? this.cardType,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      billingAddress: billingAddress ?? this.billingAddress,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getters
  String get expiryDate => '$expiryMonth/$expiryYear';
  String get maskedNumber => '•••• •••• •••• $lastFourDigits';

  // Card icon based on type
  String get cardIcon {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'amex':
      case 'american express':
        return '💳';
      default:
        return '💳';
    }
  }

  // Check if card is expired
  bool get isExpired {
    final now = DateTime.now();
    final expYear = int.tryParse('20$expiryYear') ?? 0;
    final expMonth = int.tryParse(expiryMonth) ?? 0;

    if (expYear < now.year) return true;
    if (expYear == now.year && expMonth < now.month) return true;

    return false;
  }

  @override
  String toString() {
    return 'PaymentCardModel(id: $id, type: $cardType, last4: $lastFourDigits)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
