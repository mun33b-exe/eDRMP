/// Single source of truth for navigation paths.
///
/// Use these constants whenever calling `context.go(...)` or wiring a
/// `GoRoute(path: ...)`. Do not duplicate the literal anywhere else.
class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Citizen shell
  static const String appShell = '/app-shell';
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Devices
  static const String myDevices = '/devices';
  static const String addDevice = '/devices/add';
  static const String deviceDetails = '/devices/details';
  static const String transferDevice = '/devices/transfer';

  // FIR
  static const String firHistory = '/fir';
  static const String submitFir = '/fir/submit';
  static const String caseTracking = '/fir/case';

  // Admin
  static const String policeDashboard = '/police';
  static const String pendingFirQueue = '/police/queue';
  static const String firReview = '/police/review';
  static const String policeUnblockQueue = '/police/unblock-queue';
  static const String ptaDashboard = '/pta';
  static const String deviceApprovals = '/pta/device-approvals';
  static const String blockRequests = '/pta/block-requests';
  static const String ptaUnblockQueue = '/pta/unblock-queue';
  static const String ptaHistory = '/pta/history';

  // Misc
  static const String theftMap = '/map';
  static const String verifyImei = '/verify-imei';
  static const String locationPicker = '/location-picker';
}
