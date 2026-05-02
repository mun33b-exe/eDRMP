import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/dashboard/presentation/app_shell_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/devices/presentation/add_device_page.dart';
import '../../features/devices/presentation/device_details_page.dart';
import '../../features/devices/presentation/my_devices_page.dart';
import '../../features/fir/presentation/case_tracking_page.dart';
import '../../features/fir/presentation/fir_history_page.dart';
import '../../features/fir/presentation/submit_fir_page.dart';
import '../../features/map/presentation/theft_map_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/police/presentation/fir_review_page.dart';
import '../../features/police/presentation/pending_fir_queue_page.dart';
import '../../features/police/presentation/police_dashboard_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/pta/presentation/block_requests_page.dart';
import '../../features/pta/presentation/device_approvals_page.dart';
import '../../features/pta/presentation/pta_dashboard_page.dart';
import '../../features/pta/presentation/pta_history_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import 'route_names.dart';

/// Flat list of every `GoRoute` in the app.
///
/// Wired into `appRouter` (see [app_router.dart]). Phase 0 routes resolve to
/// stub pages — real screens land in their respective feature phases.
final List<RouteBase> appRoutes = <RouteBase>[
  GoRoute(
    name: RouteNames.splash,
    path: RouteNames.splash,
    builder: (context, state) => const SplashPage(),
  ),
  GoRoute(
    name: RouteNames.onboarding,
    path: RouteNames.onboarding,
    builder: (context, state) => const OnboardingPage(),
  ),
  GoRoute(
    name: RouteNames.login,
    path: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    name: RouteNames.register,
    path: RouteNames.register,
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    name: RouteNames.forgotPassword,
    path: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(
    name: RouteNames.dashboard,
    path: RouteNames.dashboard,
    builder: (context, state) => const DashboardPage(),
  ),
  GoRoute(
    name: RouteNames.appShell,
    path: RouteNames.appShell,
    builder: (context, state) => const AppShellPage(),
  ),
  GoRoute(
    name: RouteNames.myDevices,
    path: RouteNames.myDevices,
    builder: (context, state) => const MyDevicesPage(),
  ),
  GoRoute(
    name: RouteNames.addDevice,
    path: RouteNames.addDevice,
    builder: (context, state) => const AddDevicePage(),
  ),
  GoRoute(
    name: RouteNames.deviceDetails,
    path: RouteNames.deviceDetails,
    builder: (context, state) {
      final deviceId = state.extra as String? ?? '';
      return DeviceDetailsPage(deviceId: deviceId);
    },
  ),
  GoRoute(
    name: RouteNames.firHistory,
    path: RouteNames.firHistory,
    builder: (context, state) => const FirHistoryPage(),
  ),
  GoRoute(
    name: RouteNames.submitFir,
    path: RouteNames.submitFir,
    builder: (context, state) => const SubmitFirPage(),
  ),
  GoRoute(
    name: RouteNames.caseTracking,
    path: RouteNames.caseTracking,
    builder: (context, state) {
      final firId = state.extra as String?;
      return CaseTrackingPage(firId: firId ?? '');
    },
  ),
  GoRoute(
    name: RouteNames.policeDashboard,
    path: RouteNames.policeDashboard,
    builder: (context, state) => const PoliceDashboardPage(),
  ),
  GoRoute(
    name: RouteNames.pendingFirQueue,
    path: RouteNames.pendingFirQueue,
    builder: (context, state) => const PendingFirQueuePage(),
  ),
  GoRoute(
    name: RouteNames.firReview,
    path: RouteNames.firReview,
    builder: (context, state) {
      final firId = state.extra as String?;
      return FirReviewPage(firId: firId ?? '');
    },
  ),
  GoRoute(
    name: RouteNames.profile,
    path: RouteNames.profile,
    builder: (context, state) => const ProfilePage(),
  ),
  GoRoute(
    name: RouteNames.settings,
    path: RouteNames.settings,
    builder: (context, state) => const SettingsPage(),
  ),
  GoRoute(
    name: RouteNames.notifications,
    path: RouteNames.notifications,
    builder: (context, state) => const NotificationsPage(),
  ),

  GoRoute(
    name: RouteNames.ptaDashboard,
    path: RouteNames.ptaDashboard,
    builder: (context, state) => const PtaDashboardPage(),
  ),
  GoRoute(
    name: RouteNames.deviceApprovals,
    path: RouteNames.deviceApprovals,
    builder: (context, state) => const DeviceApprovalsPage(),
  ),
  GoRoute(
    name: RouteNames.blockRequests,
    path: RouteNames.blockRequests,
    builder: (context, state) => const BlockRequestsPage(),
  ),
  GoRoute(
    name: RouteNames.ptaHistory,
    path: RouteNames.ptaHistory,
    builder: (context, state) => const PtaHistoryPage(),
  ),
  GoRoute(
    name: RouteNames.theftMap,
    path: RouteNames.theftMap,
    builder: (context, state) => const TheftMapPage(),
  ),
];
