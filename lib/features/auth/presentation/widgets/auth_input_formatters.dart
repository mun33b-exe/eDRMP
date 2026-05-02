import 'package:flutter/services.dart';

/// Formats CNIC entry as `xxxxx-xxxxxxx-x` while the user types.
///
/// Strips non-digits, caps at 13 digits, and inserts dashes after the 5th
/// and 12th digits. Cursor stays at the end of the new text — adequate for a
/// numeric keypad input where the user only ever appends.
class CnicInputFormatter extends TextInputFormatter {
  const CnicInputFormatter();

  static const int _maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .padRight(0)
        .substring(
          0,
          newValue.text
              .replaceAll(RegExp(r'\D'), '')
              .length
              .clamp(0, _maxDigits),
        );

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 5 || i == 12) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats Pakistan mobile entry as `3XX XXXXXXX` (10 digits) while the user
/// types. The country prefix `+92 ` is shown by the surrounding
/// `InputDecoration` and is **not** part of the controller value.
///
/// The user supplies the local 10-digit mobile number starting with `3`.
class PhonePkInputFormatter extends TextInputFormatter {
  const PhonePkInputFormatter();

  static const int _maxDigits = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
