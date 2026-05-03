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
  static const String featureComingSoon = 'This feature is coming soon.';

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
  // Theft map (Phase 7)
  // ---------------------------------------------------------------------------
  static const String theftMapLegendTitle = 'Risk legend';
  static const String theftMapLowRisk = 'Low';
  static const String theftMapMediumRisk = 'Medium';
  static const String theftMapHighRisk = 'High';
  static const String theftMapRecenter = 'Recenter map';
  static const String theftMapZoneDetails = 'Zone details';
  static const String theftMapRiskLabel = 'Risk level';
  static const String theftMapFirLabel = 'Active FIRs';
  static const String theftMapLocationLabel = 'Location';

  // Zone labels
  static const String theftZoneClifton = 'Clifton Coastal Belt';
  static const String theftZoneSaddar = 'Saddar Market Loop';
  static const String theftZoneGulberg = 'Gulberg Boulevard';
  static const String theftZoneJoharTown = 'Johar Town Sector G';
  static const String theftZoneBlueArea = 'Blue Area Spine';
  static const String theftZoneF7 = 'F-7 Civic Grid';
  static const String theftZoneHayatabad = 'Hayatabad Phase 3';
  static const String theftZoneSatelliteTown = 'Satellite Town Core';

  // City labels
  static const String cityKarachi = 'Karachi';
  static const String cityLahore = 'Lahore';
  static const String cityIslamabad = 'Islamabad';
  static const String cityPeshawar = 'Peshawar';
  static const String cityQuetta = 'Quetta';

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
  static const String notificationsMarkAllRead = 'Mark all read';

  // ---------------------------------------------------------------------------
  // Devices (Phase 3)
  // ---------------------------------------------------------------------------
  // My Devices
  static const String myDevicesEmpty = 'No devices yet';
  static const String myDevicesEmptyBody =
      'Register your first device to protect it against theft and blocking.';
  static const String myDevicesFilterAll = 'All';
  static const String myDevicesFilterActive = 'Active';
  static const String myDevicesFilterPending = 'Pending';
  static const String myDevicesFilterBlocked = 'Blocked';
  static const String myDevicesImeiLabel = 'IMEI';

  // Add Device flow
  static const String addDeviceTitle = 'Register device';
  static const String addDeviceStep1Title = 'Enter IMEI';
  static const String addDeviceStep1Subtitle = 'Step 1 of 3';
  static const String addDeviceStep2Title = 'Confirm device';
  static const String addDeviceStep2Subtitle = 'Step 2 of 3';
  static const String addDeviceStep3Title = 'Submitted!';
  static const String addDeviceStep3Subtitle = 'Step 3 of 3';
  static const String addDeviceImeiLabel = 'IMEI 1';
  static const String addDeviceImei2Label = 'IMEI 2 (dual-SIM)';
  static const String addDeviceImeiHint = 'e.g. 356938 09 123456 7';
  static const String addDeviceImeiHelper =
      '15-digit number found in Settings › About or dial *#06#';
  static const String addDeviceImeiError =
      'IMEI failed Luhn check — verify the number';
  static const String addDeviceImeiDuplicate =
      'This IMEI is already registered to your account.';
  static const String addDeviceOperatorLabel = 'Operator / Network';
  static const String addDeviceOperatorHint = 'e.g. Jazz';
  static const String addDeviceDetected = 'DETECTED';
  static const String addDeviceAutoFilled = 'Auto-filled from IMEI lookup';
  static const String addDeviceInvoiceLabel = 'Purchase invoice';
  static const String addDeviceInvoiceHint = 'Tap to upload PDF or photo';
  static const String addDeviceInfoBanner =
      'Devices imported into Pakistan must be registered within 60 days. PTA tax may apply.';
  static const String addDeviceContinue = 'Continue';
  static const String addDeviceSubmit = 'Submit for approval';
  static const String addDeviceSaveDraft = 'Save draft';
  static const String addDeviceSuccessTitle = 'Application submitted!';
  static const String addDeviceSuccessBody =
      'Your device has been submitted for PTA review. You will be notified once the status changes.';
  static const String addDeviceSuccessAction = 'View my devices';
  static const String addDeviceDuplicateTitle = 'Duplicate IMEI';
  static const String addDeviceDuplicateBody =
      'This IMEI is already registered in your account.';

  // Device Details
  static const String deviceDetailsTitle = 'Device';
  static const String deviceDetailsImei = 'IMEI';
  static const String deviceDetailsOperator = 'Operator';
  static const String deviceDetailsDate = 'Registered';
  static const String deviceDetailsTimeline = 'Application timeline';
  static const String deviceDetailsTransfer = 'Transfer';
  static const String deviceDetailsReportFir = 'Report FIR';
  static const String deviceDetailsReportFirDisabled =
      'FIR can only be filed for approved devices';

  // Timeline step titles
  static const String timelineSubmitted = 'Application submitted';
  static const String timelineDocVerified = 'Documents verified';
  static const String timelinePtaReview = 'PTA review in progress';
  static const String timelineApproved = 'Approval & registration';

  // ---------------------------------------------------------------------------
  // FIR & Case Tracking (Phase 4)
  // ---------------------------------------------------------------------------
  static const String firHistoryEmpty = 'No FIRs reported';
  static const String firHistoryEmptyBody =
      'You have not reported any stolen devices. If your device is lost or stolen, you can file an FIR from the device details page.';
  static const String submitFirTitle = 'Report stolen device';
  static const String submitFirWarning =
      'Filing a false FIR is a criminal offence under Section 182. Your device will be blocked on the PTA network within 30 minutes.';
  static const String submitFirDeviceLabel = 'Select device';
  static const String submitFirDateLabel = 'Date & time of incident';
  static const String submitFirLocationLabel = 'Location';
  static const String submitFirStationLabel = 'Police station';
  static const String submitFirDescriptionLabel = 'Description';
  static const String submitFirDescriptionHint =
      'Briefly describe what happened...';
  static const String submitFirAction = 'File FIR & block device';

  // Case tracking timeline steps
  static const String caseTimelineDeviceRegistered = 'Device Registered';
  static const String caseTimelineFirSubmitted = 'FIR Submitted';
  static const String caseTimelineFirUnderReview = 'FIR Under Review';
  static const String caseTimelineFirVerified = 'FIR Verified';
  static const String caseTimelineFirRejected = 'FIR Rejected';
  static const String caseTimelineBlockPending = 'Block Pending';
  static const String caseTimelineBlockApproved = 'Block Approved';
  static const String caseTimelineBlockRejected = 'Block Rejected';
  static const String caseTimelineDeviceBlocked = 'Device Blocked';
  static const String caseTimelineDeviceRecovered = 'Device Recovered';
  static const String caseTimelineUnblockPending = 'Unblock Pending';
  static const String caseTimelineUnblockApproved = 'Unblock Approved';
  static const String caseTimelineDeviceUnblocked = 'Device Unblocked';

  // ---------------------------------------------------------------------------
  // Admin / PTA / Police (Phase 5-8)
  // ---------------------------------------------------------------------------
  static const String ptaRegulatoryLabel = 'PTA REGULATORY';
  static const String ptaApprovalQueueTitle = 'Approval queue';
  static const String ptaBlockRequestsTitle = 'Block requests';
  static const String ptaFilterPending = 'Pending';
  static const String ptaFilterApproved = 'Approved';
  static const String ptaFilterRejected = 'Rejected';
  static const String ptaFilterBlocked = 'Blocked';
  static const String ptaFilterAll = 'All';
  static const String ptaApprovalsEmpty = 'No devices awaiting approval.';
  static const String ptaBlockEmpty = 'No block requests right now.';
  static const String ptaReviewCta = 'Review';
  static const String ptaApprove = 'Approve';
  static const String ptaReject = 'Reject';
  static const String ptaBlock = 'Block device';
  static const String ptaSearchHint = 'Search by name, IMEI or model...';

  static const String policeQueueTitle = 'Approval queue';
  static const String policeQueuePending = 'Pending';
  static const String policeQueueAll = 'All';
  static const String policeQueueEmptyTitle = 'No FIRs in queue';
  static const String policeQueueEmptyBody =
      'New FIR verifications will appear here once submitted.';
  static const String policeQueueCasePrefix = 'Case';
  static const String policeQueueStationPrefix = 'Station:';
  static const String policeQueueFiledPrefix = 'Filed:';
  static const String policeQueuePendingReview = 'Pending Review';
  static const String policeQueueVerified = 'Verified';
  static const String policeQueueRejected = 'Rejected';
  static const String policeQueueOther = 'Other';
  static const String caseIdLabel = 'Case ID:';

  // ---------------------------------------------------------------------------
  // Connectivity
  // ---------------------------------------------------------------------------
  static const String connectivityOffline =
      'Offline — reconnecting to the network.';

  // ---------------------------------------------------------------------------
  // Verification (Phase 9C)
  // ---------------------------------------------------------------------------
  static const String verifyImeiTitle = 'Verify IMEI';
  static const String verifyTabScan = 'Scan QR';
  static const String verifyTabEnter = 'Enter IMEI';
  static const String verifyImeiHint = 'Enter 15-digit IMEI';
  static const String verifyButton = 'Verify';
  static const String verifyNotFound = 'IMEI not registered';
  static const String verifyNotFoundBody =
      'This device is not in the eDRMP registry.';
  static const String verifyRegisterCta = 'Register this device';
  static const String verifyBlockedWarning =
      'This device has been reported stolen and blocked.';
  static const String verifyCameraPermission = 'Camera permission required';
  static const String verifyCameraPermissionBody =
      'Enable camera access in your device settings to scan QR codes.';
  static const String verifyImeiCopied = 'IMEI copied to clipboard';
  static const String deviceQrTitle = 'Device QR code';
  static const String deviceQrSubtitle =
      'Show this to verify your device registration.';
  static const String deviceQrShareTooltip = 'Copy IMEI';

  // ---------------------------------------------------------------------------
  // Location Picker (Phase 9D)
  // ---------------------------------------------------------------------------
  static const String locationPickerTitle = 'Pick Incident Location';
  static const String locationPickerConfirm = 'Confirm Location';
  static const String locationPickerHint = 'Tap to pick on map';

  // ---------------------------------------------------------------------------
  // Device Transfer
  // ---------------------------------------------------------------------------
  static const String transferTitle = 'Transfer Device';
  static const String transferSubtitle =
      'Transfer ownership of a registered device to another person.';
  static const String transferSelectDevice = 'Select device to transfer';
  static const String transferRecipientCnic = 'Recipient CNIC';
  static const String transferRecipientCnicHint = 'e.g. 42101-1234567-8';
  static const String transferNote = 'Note (optional)';
  static const String transferNoteHint = 'Add a message for the recipient';
  static const String transferSubmit = 'Send Transfer Request';
  static const String transferSuccessTitle = 'Transfer request sent!';
  static const String transferSuccessBody =
      'The recipient will be notified. They must accept the request for the transfer to complete.';
  static const String transferSuccessAction = 'View Transfers';
  static const String transferEmpty = 'No transfer requests';
  static const String transferEmptyBody =
      'You have no pending or past transfer requests.';
  static const String transferFilterAll = 'All';
  static const String transferFilterPending = 'Pending';
  static const String transferFilterCompleted = 'Completed';
  static const String transferIncoming = 'Incoming';
  static const String transferOutgoing = 'Outgoing';
  static const String transferAccept = 'Accept';
  static const String transferReject = 'Reject';
  static const String transferCancel = 'Cancel';
  static const String transferFrom = 'From';
  static const String transferTo = 'To';
  static const String transferCnicNotFound =
      'No registered user found with this CNIC';
  static const String transferSameOwner =
      'Cannot transfer a device to yourself';
  static const String transferNoDevices =
      'No approved devices available to transfer';
  static const String transferHistory = 'Transfer History';
}
