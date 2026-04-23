import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/dashboard/presentation/app_shell_page.dart';
import '../../features/devices/presentation/add_device_page.dart';
import '../../features/devices/presentation/device_details_page.dart';
import '../../features/devices/presentation/my_devices_page.dart';
import '../../features/fir/presentation/case_tracking_page.dart';
import '../../features/fir/presentation/fir_history_page.dart';
import '../../features/fir/presentation/submit_fir_page.dart';
import '../../features/map/presentation/theft_map_page.dart';
import '../../features/police/presentation/police_dashboard_page.dart';
import '../../features/pta/presentation/pta_dashboard_page.dart';
import '../../features/auth/logic/auth_controller.dart';
import 'app_routes.dart';
import 'route_names.dart';

final AuthController _authController = AuthController.instance;

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: _authController,
  redirect: (context, state) {
    final isAuthenticated = _authController.state.isAuthenticated;
    final location = state.matchedLocation;

    final isUserShellRoute =
        location == AppRoutes.appShell ||
        location == AppRoutes.dashboard ||
        location == AppRoutes.notifications ||
        location == AppRoutes.profile ||
        location == AppRoutes.settings;

    final isOnAuthPage =
        location == AppRoutes.splash ||
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword;

    if (!isAuthenticated && isUserShellRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isOnAuthPage) {
      return AppRoutes.appShell;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.appShell,
      name: RouteNames.appShell,
      builder: (context, state) => const AppShellPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: RouteNames.dashboard,
      builder: (context, state) => const AppShellPage(initialIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.myDevices,
      name: RouteNames.myDevices,
      builder: (context, state) => const MyDevicesPage(),
    ),
    GoRoute(
      path: AppRoutes.addDevice,
      name: RouteNames.addDevice,
      builder: (context, state) => const AddDevicePage(),
    ),
    GoRoute(
      path: AppRoutes.deviceDetails,
      name: RouteNames.deviceDetails,
      builder: (context, state) => const DeviceDetailsPage(),
    ),
    GoRoute(
      path: AppRoutes.firHistory,
      name: RouteNames.firHistory,
      builder: (context, state) => const FirHistoryPage(),
    ),
    GoRoute(
      path: AppRoutes.submitFir,
      name: RouteNames.submitFir,
      builder: (context, state) => const SubmitFirPage(),
    ),
    GoRoute(
      path: AppRoutes.caseTracking,
      name: RouteNames.caseTracking,
      builder: (context, state) => const CaseTrackingPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: RouteNames.profile,
      builder: (context, state) => const AppShellPage(initialIndex: 2),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: RouteNames.settings,
      builder: (context, state) => const AppShellPage(initialIndex: 3),
    ),
    GoRoute(
      path: AppRoutes.policeDashboard,
      name: RouteNames.policeDashboard,
      builder: (context, state) => const PoliceDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.ptaDashboard,
      name: RouteNames.ptaDashboard,
      builder: (context, state) => const PtaDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: RouteNames.notifications,
      builder: (context, state) => const AppShellPage(initialIndex: 1),
    ),
    GoRoute(
      path: AppRoutes.map,
      name: RouteNames.map,
      builder: (context, state) => const TheftMapPage(),
    ),
  ],
);
