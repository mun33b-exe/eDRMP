import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/services/supabase_service.dart';
import '../logic/auth_failure.dart';
import '../logic/auth_user.dart';

/// Supabase-backed auth repository.
///
/// Public interface is identical to the former mock so AuthController and all
/// UI layers remain unchanged. Session persistence is handled by supabase_flutter
/// (stores the session in flutter_secure_storage across cold starts).
class AuthRepository {
  AuthRepository();

  SupabaseClient get _client => SupabaseService.client;

  /// Returns the currently authenticated user by restoring the persisted
  /// Supabase session, or null when no session exists.
  Future<AuthUser?> currentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    try {
      return await _fetchProfile(session.user.id);
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final userId = response.user!.id;
      await _saveFcmToken(userId);
      return await _fetchProfile(userId);
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<AuthUser> register({
    required String fullName,
    required String cnic,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = response.user;
      if (user == null) throw const InvalidCredentialsFailure();

      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': fullName.trim(),
        'cnic': cnic.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': 'user',
      });

      return AuthUser(
        id: user.id,
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        cnic: cnic.trim(),
        phone: phone.trim(),
        role: UserRole.user,
      );
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        if (e.message.toLowerCase().contains('cnic')) {
          throw const CnicAlreadyRegisteredFailure();
        }
        throw const EmailAlreadyRegisteredFailure();
      }
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // ─── private helpers ────────────────────────────────────────────────────────

  Future<AuthUser> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return AuthUser(
      id: data['id'] as String,
      fullName: data['full_name'] as String,
      email: data['email'] as String,
      cnic: data['cnic'] as String,
      phone: (data['phone'] as String?) ?? '',
      role: _parseRole(data['role'] as String),
    );
  }

  Future<void> _saveFcmToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', userId);
      }
    } catch (_) {
      // FCM token save is best-effort — never fail login because of it.
    }
  }

  AuthFailure _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('user not found')) {
      return const InvalidCredentialsFailure();
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered') ||
        msg.contains('email address is already')) {
      return const EmailAlreadyRegisteredFailure();
    }
    return const InvalidCredentialsFailure();
  }

  UserRole _parseRole(String role) {
    switch (role) {
      case 'police':
        return UserRole.police;
      case 'pta':
        return UserRole.pta;
      default:
        return UserRole.user;
    }
  }
}
