import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import 'auth_state.dart';
import 'auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// AsyncNotifier-backed auth controller.
///
/// Exposes one async value channel so screens can render `AsyncValue.when(...)`
/// uniformly — `loading` for in-flight ops, `error` for typed
/// [AuthFailure]s, `data` for the resolved [AuthState].
class AuthController extends AsyncNotifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthState> build() async {
    return const AuthState.unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue<AuthState>.loading();
    state = await AsyncValue.guard<AuthState>(() async {
      final user = await _repo.login(email: email, password: password);
      return AuthState.authenticated(user);
    });
  }

  Future<void> register({
    required String fullName,
    required String cnic,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue<AuthState>.loading();
    state = await AsyncValue.guard<AuthState>(() async {
      final user = await _repo.register(
        fullName: fullName,
        cnic: cnic,
        email: email,
        phone: phone,
        password: password,
      );
      return AuthState.authenticated(user);
    });
  }

  Future<void> forgotPassword(String email) async {
    final previous = state.valueOrNull ?? const AuthState.unauthenticated();
    state = const AsyncValue<AuthState>.loading();
    state = await AsyncValue.guard<AuthState>(() async {
      await _repo.sendPasswordReset(email);
      return previous;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue<AuthState>.loading();
    state = await AsyncValue.guard<AuthState>(() async {
      await _repo.logout();
      return const AuthState.unauthenticated();
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Convenience selector — current authenticated user, or null when signed out
/// or while a transition is in flight.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull?.user;
});
