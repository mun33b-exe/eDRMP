import 'package:flutter/foundation.dart';

/// Application-level user roles.
///
/// `user` is the citizen persona; `police` and `pta` are the two admin
/// personas declared in the PRD. The role drives the post-login landing page
/// (citizen shell vs. police dashboard vs. PTA dashboard).
enum UserRole { user, police, pta }

extension UserRoleX on UserRole {
  /// Short human-readable label, e.g. "Citizen" / "Police" / "PTA".
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Citizen';
      case UserRole.police:
        return 'Police';
      case UserRole.pta:
        return 'PTA';
    }
  }
}

/// Authenticated user profile carried in app state.
///
/// Phase 1 populates this from the in-memory mock repository. Phase 9 will
/// swap the source for the Supabase `profiles` table without changing this
/// shape.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.cnic,
    required this.phone,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String cnic;
  final String phone;
  final UserRole role;

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }

  AuthUser copyWith({
    String? fullName,
    String? email,
    String? cnic,
    String? phone,
  }) {
    return AuthUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      role: role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id == id &&
          other.fullName == fullName &&
          other.email == email &&
          other.cnic == cnic &&
          other.phone == phone &&
          other.role == role;

  @override
  int get hashCode => Object.hash(id, fullName, email, cnic, phone, role);
}
