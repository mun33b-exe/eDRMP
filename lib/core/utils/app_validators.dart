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
}
