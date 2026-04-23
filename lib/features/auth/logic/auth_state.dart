import '../data/models/auth_user.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    required this.isInitialized,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      isAuthenticated: false,
      isInitialized: false,
    );
  }

  final bool isLoading;
  final bool isAuthenticated;
  final bool isInitialized;
  final AuthUser? user;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isInitialized,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
