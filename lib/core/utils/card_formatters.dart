import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.length > 16) {
      return oldValue;
    }

    if (text.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(text)) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length > 4) {
      return oldValue;
    }

    if (text.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(text)) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CVVFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 3) {
      return oldValue;
    }

    if (text.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}

class CardUtils {
  static String getCardType(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');

    if (number.isEmpty) return 'Unknown';

    if (number.startsWith('4')) {
      return 'Visa';
    }

    if (number.startsWith(RegExp(r'^5[1-5]')) ||
        (number.length >= 4 &&
            int.parse(number.substring(0, 4)) >= 2221 &&
            int.parse(number.substring(0, 4)) <= 2720)) {
      return 'Mastercard';
    }

    if (number.startsWith(RegExp(r'^3[47]'))) {
      return 'Amex';
    }

    if (number.startsWith('6011') ||
        number.startsWith(RegExp(r'^64[4-9]')) ||
        number.startsWith('65') ||
        (number.length >= 6 &&
            int.parse(number.substring(0, 6)) >= 622126 &&
            int.parse(number.substring(0, 6)) <= 622925)) {
      return 'Discover';
    }

    if (number.startsWith(
      RegExp(r'^(5018|5020|5038|5893|6304|6759|676[1-3])'),
    )) {
      return 'Maestro';
    }

    if (number.length >= 4 &&
        int.parse(number.substring(0, 4)) >= 3528 &&
        int.parse(number.substring(0, 4)) <= 3589) {
      return 'JCB';
    }

    return 'Unknown';
  }

  static String getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'amex':
        return '💳';
      case 'discover':
        return '💳';
      case 'maestro':
        return '💳';
      case 'jcb':
        return '💳';
      default:
        return '💳';
    }
  }

  /// Validate card number using Luhn algorithm
  static bool isValidCardNumber(String cardNumber) {
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

  static bool isValidExpiryDate(String expiryDate) {
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;

    return true;
  }

  static bool isValidCVV(String cvv, String cardType) {
    if (cvv.isEmpty) return false;

    // Amex CVV is 4 digits, others are 3
    if (cardType.toLowerCase() == 'amex') {
      return cvv.length == 4;
    }

    return cvv.length == 3;
  }

  static String maskCardNumber(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.length < 8) return cardNumber;

    final first4 = number.substring(0, 4);
    final last4 = number.substring(number.length - 4);

    return '$first4 **** **** $last4';
  }
}
