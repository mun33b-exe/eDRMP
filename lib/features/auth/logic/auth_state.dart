import 'package:flutter/foundation.dart';

import 'auth_user.dart';

/// Snapshot of the authenticated session, carried inside the
/// `AsyncNotifier`'s value channel.
///
/// `AsyncValue` itself models loading/error around state transitions
/// (login/register/logout). [AuthState] is just the success-side data —
/// either an authenticated user, or nothing.
@immutable
class AuthState {
  const AuthState.unauthenticated() : user = null;
  const AuthState.authenticated(AuthUser this.user);

  final AuthUser? user;

  bool get isAuthenticated => user != null;
  UserRole? get role => user?.role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthState && other.user == user;

  @override
  int get hashCode => user.hashCode;
}
