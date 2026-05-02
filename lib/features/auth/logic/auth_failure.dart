/// Typed errors thrown by the mock `AuthRepository` and surfaced to the UI.
///
/// Each subclass carries a humanised [message] that auth screens render
/// inline (in `AsyncValue.error.error.message`). New failure modes added in
/// Phase 9 should subclass this class so the existing UI keeps working.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Email or password is incorrect.');
}

class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure()
    : super('An account with this email already exists.');
}

class CnicAlreadyRegisteredFailure extends AuthFailure {
  const CnicAlreadyRegisteredFailure()
    : super('This CNIC is already registered to another account.');
}

class UnknownEmailFailure extends AuthFailure {
  const UnknownEmailFailure()
    : super('We could not find an account for that email.');
}

class TermsNotAcceptedFailure extends AuthFailure {
  const TermsNotAcceptedFailure()
    : super('Please accept the Terms & Privacy Policy to continue.');
}
