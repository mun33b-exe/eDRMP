import 'package:flutter/foundation.dart';

import '../data/models/auth_user.dart';
import '../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController._(this._authService);

  static final AuthController instance = AuthController._(AuthService());

  final AuthService _authService;

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  void _setState(AuthState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> initializeSession() async {
    if (_state.isInitialized) {
      return;
    }

    try {
      final currentUser = await _authService.getCurrentSession();
      _setState(
        _state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: currentUser != null,
          user: currentUser,
          clearError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: false,
          user: null,
          errorMessage: 'Unable to restore session.',
        ),
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final user = await _authService.login(email: email, password: password);
      _setState(
        _state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          isInitialized: true,
          user: user,
          clearError: true,
        ),
      );
      return true;
    } on AuthException catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (_) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          errorMessage: 'Login failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String cnic,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      await _authService.register(
        fullName: fullName,
        cnic: cnic,
        phone: phone,
        email: email,
        password: password,
      );

      _setState(_state.copyWith(isLoading: false, clearError: true));
      return true;
    } on AuthException catch (e) {
      _setState(_state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Registration failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      await _authService.forgotPassword(email: email);
      _setState(_state.copyWith(isLoading: false, clearError: true));
      return true;
    } on AuthException catch (e) {
      _setState(_state.copyWith(isLoading: false, errorMessage: e.message));
      return false;
    } catch (_) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send reset link.',
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));
    await _authService.logout();
    _setState(
      _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        clearError: true,
      ),
    );
  }

  AuthUser createSessionReadyPlaceholderUser({
    required String fullName,
    required String email,
  }) {
    return AuthUser(
      id: _authService.generateMockUserId(),
      fullName: fullName,
      email: email,
    );
  }
}
