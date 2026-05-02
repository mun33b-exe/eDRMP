import 'package:flutter/foundation.dart';

import '../../../core/constants/app_durations.dart';
import '../logic/auth_failure.dart';
import '../logic/auth_user.dart';

/// Single hard-coded mock account.
@immutable
class _MockAccount {
  const _MockAccount({required this.password, required this.user});

  final String password;
  final AuthUser user;
}

/// In-memory mock implementation of the auth backend.
///
/// All async ops return after [AppDurations.mockNetwork] to simulate latency.
/// Phase 9 swaps this for a Supabase-backed implementation **with the same
/// public interface** so the controller / UI layers don't change.
///
/// Mock data is intentionally not persisted across cold starts — restarting
/// the app returns the user to the login screen.
class AuthRepository {
  // TODO(Phase 9): replace this entire file with a Supabase-backed
  // implementation of the same public method signatures.
  AuthRepository();

  final List<_MockAccount> _accounts = <_MockAccount>[
    const _MockAccount(
      password: 'Demo@1234',
      user: AuthUser(
        id: 'mock-user-001',
        fullName: 'Hamza Khan',
        email: 'demo.user@edrmp.pk',
        cnic: '35202-1234567-9',
        phone: '+92 321 1234567',
        role: UserRole.user,
      ),
    ),
    const _MockAccount(
      password: 'Demo@1234',
      user: AuthUser(
        id: 'mock-police-001',
        fullName: 'Inspector Tariq Mehmood',
        email: 'demo.police@edrmp.pk',
        cnic: '42101-7654321-3',
        phone: '+92 333 9876543',
        role: UserRole.police,
      ),
    ),
    const _MockAccount(
      password: 'Demo@1234',
      user: AuthUser(
        id: 'mock-pta-001',
        fullName: 'Sana Iqbal',
        email: 'demo.pta@edrmp.pk',
        cnic: '61101-2468013-5',
        phone: '+92 300 5551234',
        role: UserRole.pta,
      ),
    ),
  ];

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(AppDurations.mockNetwork);
    final normalized = email.trim().toLowerCase();
    for (final acc in _accounts) {
      if (acc.user.email.toLowerCase() == normalized &&
          acc.password == password) {
        return acc.user;
      }
    }
    throw const InvalidCredentialsFailure();
  }

  Future<AuthUser> register({
    required String fullName,
    required String cnic,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(AppDurations.mockNetwork);
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedCnic = cnic.trim();
    if (_accounts.any((a) => a.user.email.toLowerCase() == normalizedEmail)) {
      throw const EmailAlreadyRegisteredFailure();
    }
    if (_accounts.any((a) => a.user.cnic == normalizedCnic)) {
      throw const CnicAlreadyRegisteredFailure();
    }
    final user = AuthUser(
      id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: normalizedEmail,
      cnic: normalizedCnic,
      phone: phone.trim(),
      role: UserRole.user,
    );
    _accounts.add(_MockAccount(password: password, user: user));
    return user;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(AppDurations.mockNetwork);
    final normalized = email.trim().toLowerCase();
    final exists = _accounts.any(
      (a) => a.user.email.toLowerCase() == normalized,
    );
    if (!exists) {
      throw const UnknownEmailFailure();
    }
    // Mock: pretend a reset link was emailed; nothing else to do.
  }

  Future<void> logout() async {
    await Future<void>.delayed(AppDurations.mockNetwork);
  }
}
