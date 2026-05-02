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
import '../../features/police/presentation/police_dashboard_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/pta/presentation/pta_dashboard_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import 'route_names.dart';

/// Flat list of every `GoRoute` in the app.
///
/// Wired into `appRouter` (see [app_router.dart]). Phase 0 routes resolve to
/// stub pages — real screens land in their respective feature phases.
final List<RouteBase> appRoutes = <RouteBase>[
  GoRoute(
    path: RouteNames.splash,
    builder: (context, state) => const SplashPage(),
  ),
  GoRoute(
    path: RouteNames.onboarding,
    builder: (context, state) => const OnboardingPage(),
  ),
  GoRoute(
    path: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: RouteNames.register,
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    path: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(
    path: RouteNames.dashboard,
    builder: (context, state) => const DashboardPage(),
  ),
  GoRoute(
    path: RouteNames.appShell,
    builder: (context, state) => const AppShellPage(),
  ),
  GoRoute(
    path: RouteNames.myDevices,
    builder: (context, state) => const MyDevicesPage(),
  ),
  GoRoute(
    path: RouteNames.addDevice,
    builder: (context, state) => const AddDevicePage(),
  ),
  GoRoute(
    path: RouteNames.deviceDetails,
    builder: (context, state) {
      final deviceId = state.extra as String? ?? '';
      return DeviceDetailsPage(deviceId: deviceId);
    },
  ),
  GoRoute(
    path: RouteNames.firHistory,
    builder: (context, state) => const FirHistoryPage(),
  ),
  GoRoute(
    path: RouteNames.submitFir,
    builder: (context, state) => const SubmitFirPage(),
  ),
  GoRoute(
    path: RouteNames.caseTracking,
    builder: (context, state) => const CaseTrackingPage(),
  ),
  GoRoute(
    path: RouteNames.profile,
    builder: (context, state) => const ProfilePage(),
  ),
  GoRoute(
    path: RouteNames.settings,
    builder: (context, state) => const SettingsPage(),
  ),
  GoRoute(
    path: RouteNames.notifications,
    builder: (context, state) => const NotificationsPage(),
  ),
  GoRoute(
    path: RouteNames.policeDashboard,
    builder: (context, state) => const PoliceDashboardPage(),
  ),
  GoRoute(
    path: RouteNames.ptaDashboard,
    builder: (context, state) => const PtaDashboardPage(),
  ),
  GoRoute(
    path: RouteNames.theftMap,
    builder: (context, state) => const TheftMapPage(),
  ),
];
