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
  // Authentication
  // ---------------------------------------------------------------------------
  static const String authLoginTitle = 'Welcome back';
  static const String authLoginSubtitle =
      'Sign in to manage your devices and track active cases.';
  static const String authLoginCta = 'Sign in';
  static const String authLoginEmailLabel = 'Email address';
  static const String authLoginEmailHint = 'you@example.com';
  static const String authPasswordLabel = 'Password';
  static const String authPasswordHint = 'Enter your password';
  static const String authForgotPasswordLink = 'Forgot password?';
  static const String authNoAccountPrompt = 'New to eDRMP?';
  static const String authNoAccountCta = 'Create an account';

  static const String authRegisterTitle = 'Create your account';
  static const String authRegisterSubtitle =
      'Register to protect your devices and report incidents securely.';
  static const String authRegisterCta = 'Create account';
  static const String authFullNameLabel = 'Full name';
  static const String authFullNameHint = 'As on your CNIC';
  static const String authCnicLabel = 'CNIC';
  static const String authCnicHint = '35202-1234567-9';
  static const String authPhoneLabel = 'Mobile number';
  static const String authPhoneHint = '3xx xxxxxxx';
  static const String authPhonePrefix = '+92 ';
  static const String authConfirmPasswordLabel = 'Confirm password';
  static const String authConfirmPasswordHint = 'Re-enter your password';
  static const String authTermsAccept =
      'I agree to the Terms of Service and Privacy Policy.';
  static const String authHasAccountPrompt = 'Already registered?';
  static const String authHasAccountCta = 'Sign in';

  static const String authForgotTitle = 'Reset your password';
  static const String authForgotSubtitle =
      'Enter the email associated with your account. We will send you a secure link to set a new password.';
  static const String authForgotCta = 'Send reset link';
  static const String authForgotSuccessTitle = 'Check your inbox';
  static const String authForgotSuccessBody =
      'If an eDRMP account exists for this email, a reset link is on its way.';
  static const String authForgotBackToLogin = 'Back to sign in';

  static const String authShowPassword = 'Show password';
  static const String authHidePassword = 'Hide password';
  static const String authPasswordRules =
      'At least 8 characters, with one uppercase letter and one number.';

  static const String authDemoAccountsTitle = 'Demo accounts (mock data)';
  static const String authDemoAccountsBody =
      'demo.user@edrmp.pk · demo.police@edrmp.pk · demo.pta@edrmp.pk\nPassword for all: Demo@1234';
  static const String authUseDemoUserCta = 'Fill citizen demo';

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------
  static const String onboardingSkip = 'Skip';
  static const String onboardingTitle = 'Register your phone with PTA';
  static const String onboardingBody =
      'Verify your IMEI, link it to your CNIC, and protect your device against theft and blocking.';
  static const String onboardingCta = 'Get started';
  static const String onboardingAlreadyRegistered = 'Already registered?';
  static const String onboardingSignInLink = 'Sign in';

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

  // ---------------------------------------------------------------------------
  // Dashboard (Phase 2)
  // ---------------------------------------------------------------------------
  static const String dashboardGreeting = 'Assalam-o-Alaikum';
  static const String dashboardRegisteredDevices = 'REGISTERED DEVICES';
  static const String dashboardAllActive = 'ALL ACTIVE';
  static const String dashboardApproved = 'Approved';
  static const String dashboardPending = 'Pending';
  static const String dashboardFirs = 'FIRs';
  static const String dashboardQuickActions = 'Quick actions';
  static const String dashboardMyDevices = 'My devices';
  static const String dashboardSeeAll = 'See all';
  static const String dashboardRegisterDevice = 'Register device';
  static const String dashboardReportFir = 'Report FIR';
  static const String dashboardTransfer = 'Transfer';
  static const String dashboardVerifyImei = 'Verify IMEI';

  // Bottom nav labels
  static const String navHome = 'Home';
  static const String navDevices = 'Devices';
  static const String navRegister = 'Register';
  static const String navFir = 'FIR';
  static const String navProfile = 'Profile';

  // Quick-action bottom sheet
  static const String qsTitle = 'Quick actions';

  // ---------------------------------------------------------------------------
  // Profile (Phase 2)
  // ---------------------------------------------------------------------------
  static const String profileFullName = 'Full name';
  static const String profileCnic = 'CNIC';
  static const String profileEmail = 'Email';
  static const String profilePhone = 'Mobile';
  static const String profileRole = 'Role';
  static const String profileMemberSince = 'Member since';
  static const String profileSignOut = 'Sign out';
  static const String profileSignOutConfirm =
      'Are you sure you want to sign out?';

  // ---------------------------------------------------------------------------
  // Settings (Phase 2)
  // ---------------------------------------------------------------------------
  static const String settingsLanguage = 'Language';
  static const String settingsLanguageValue = 'English';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeSystem = 'System';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsNotifications = 'Notifications';
  static const String settingsAbout = 'About eDRMP';
  static const String settingsVersion = 'Version';
  static const String settingsAboutText =
      'Electronic Device Registration \u0026 Monitoring Portal — a government initiative by PTA to protect citizens against device theft.';

  // ---------------------------------------------------------------------------
  // Notifications (Phase 2)
  // ---------------------------------------------------------------------------
  static const String notificationsEmptyTitle = "You're all caught up";
  static const String notificationsEmptyBody =
      "No new notifications right now. We'll alert you when your device status changes.";
}
