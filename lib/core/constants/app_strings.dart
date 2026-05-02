/// All user-facing strings live here. UI widgets must never hardcode literals.
///
/// Strings are grouped by surface area. Add new strings under the most
/// specific group rather than the generic bucket.
class AppStrings {
  AppStrings._();

  // ---------------------------------------------------------------------------
  // App
  // ---------------------------------------------------------------------------
  static const String appName = 'eDRMP';
  static const String appTagline =
      'Electronic Device Registration & Monitoring';

  // ---------------------------------------------------------------------------
  // Generic actions
  // ---------------------------------------------------------------------------
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String save = 'Save';
  static const String retry = 'Retry';
  static const String tryAgain = 'Try again';
  static const String close = 'Close';
  static const String continueAction = 'Continue';
  static const String back = 'Back';
  static const String done = 'Done';
  static const String delete = 'Delete';

  // ---------------------------------------------------------------------------
  // Generic states
  // ---------------------------------------------------------------------------
  static const String loading = 'Loading…';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No internet connection.';
  static const String emptyData = 'Nothing here yet.';

  // ---------------------------------------------------------------------------
  // Phase labels — placeholder copy for stub screens (Phase 0 only)
  // ---------------------------------------------------------------------------
  static const String stubPhaseFoundation = 'Phase 0 — Foundation';
  static const String stubPhaseAuth = 'Phase 1 — Authentication';
  static const String stubPhaseShell = 'Phase 2 — Citizen Shell';
  static const String stubPhaseDevices = 'Phase 3 — Devices';
  static const String stubPhaseFir = 'Phase 4 — FIR & Case Tracking';
  static const String stubPhasePolice = 'Phase 5 — Police Admin';
  static const String stubPhasePta = 'Phase 6 — PTA Admin';
  static const String stubPhaseMap = 'Phase 7 — Theft Hotspot Map';
  static const String stubPhaseProfile = 'Phase 2 — Profile';
  static const String stubPhaseSettings = 'Phase 2 — Settings';
  static const String stubPhaseNotifications = 'Phase 2 — Notifications';

  // ---------------------------------------------------------------------------
  // Screen titles
  // ---------------------------------------------------------------------------
  static const String titleSplash = 'Splash';
  static const String titleLogin = 'Login';
  static const String titleRegister = 'Register';
  static const String titleForgotPassword = 'Forgot password';
  static const String titleDashboard = 'Dashboard';
  static const String titleAppShell = 'Home';
  static const String titleMyDevices = 'My devices';
  static const String titleAddDevice = 'Add device';
  static const String titleDeviceDetails = 'Device details';
  static const String titleFirHistory = 'FIR history';
  static const String titleSubmitFir = 'Submit FIR';
  static const String titleCaseTracking = 'Case tracking';
  static const String titleProfile = 'Profile';
  static const String titleSettings = 'Settings';
  static const String titleNotifications = 'Notifications';
  static const String titlePoliceDashboard = 'Police dashboard';
  static const String titlePtaDashboard = 'PTA dashboard';
  static const String titleTheftMap = 'Theft hotspots';
}
