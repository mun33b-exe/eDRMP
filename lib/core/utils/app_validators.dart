class AppValidators {
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? fullName(String? value) {
    final required = requiredField(value, fieldName: 'Full name');
    if (required != null) {
      return required;
    }

    if (value!.trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }

    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, fieldName: 'Email');
    if (required != null) {
      return required;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, fieldName: 'Password');
    if (required != null) {
      return required;
    }

    final passwordValue = value!.trim();
    if (passwordValue.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(passwordValue)) {
      return 'Password must include at least 1 uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(passwordValue)) {
      return 'Password must include at least 1 number';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final required = requiredField(value, fieldName: 'Confirm password');
    if (required != null) {
      return required;
    }

    if (value!.trim() != password.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? cnic(String? value) {
    final required = requiredField(value, fieldName: 'CNIC');
    if (required != null) {
      return required;
    }

    final normalized = value!.replaceAll('-', '').trim();
    if (!RegExp(r'^\d{13}$').hasMatch(normalized)) {
      return 'CNIC must be exactly 13 digits';
    }

    return null;
  }

  static String? phone(String? value) {
    final required = requiredField(value, fieldName: 'Phone number');
    if (required != null) {
      return required;
    }

    final normalized = value!.replaceAll(' ', '').trim();
    final regex = RegExp(r'^(\+92|0)?3\d{9}$');
    if (!regex.hasMatch(normalized)) {
      return 'Enter a valid Pakistan phone number';
    }

    return null;
  }

  /// Validates an IMEI using the Luhn algorithm (ISO/IEC 7812).
  ///
  /// Accepts digits with optional spaces or dashes as separators.
  /// Returns `null` if valid; an error string otherwise.
  static String? imei(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IMEI is required';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{15}$').hasMatch(digits)) {
      return 'IMEI must be exactly 15 digits';
    }
    if (!_luhnCheck(digits)) {
      return 'IMEI failed Luhn check — verify the number';
    }
    return null;
  }

  /// Returns `true` if [digits] passes the Luhn-10 check (ISO/IEC 7812).
  static bool _luhnCheck(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}
