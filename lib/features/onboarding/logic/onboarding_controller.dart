import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-launch onboarding gate.
///
/// Holds a single boolean: whether the user has dismissed the onboarding
/// screen this session. The splash hand-off reads this to decide whether to
/// route to `/onboarding` or straight on to `/login` (or role home).
///
// TODO(Phase 9): persist via flutter_secure_storage so onboarding-seen
// survives cold restarts.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Mark onboarding as dismissed for the current session.
  void markSeen() {
    state = true;
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
