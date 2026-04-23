import 'dart:math';

import '../models/auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthUser? _currentUser;

  Future<AuthUser?> getCurrentSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _currentUser;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!email.contains('@') || password.length < 8) {
      throw const AuthException('Invalid email or password.');
    }

    _currentUser = AuthUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'eDRMP User',
      email: email.trim(),
    );

    return _currentUser!;
  }

  Future<void> register({
    required String fullName,
    required String cnic,
    required String phone,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (fullName.trim().isEmpty ||
        cnic.trim().isEmpty ||
        phone.trim().isEmpty ||
        !email.contains('@') ||
        password.length < 8) {
      throw const AuthException('Please fill all required fields correctly.');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!email.contains('@')) {
      throw const AuthException('Please enter a valid email address.');
    }
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  String generateMockUserId() {
    final random = Random();
    return 'mock_${100000 + random.nextInt(899999)}';
  }
}
