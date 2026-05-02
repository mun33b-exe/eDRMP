import 'package:flutter/material.dart';
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
import '../../features/map/presentation/theft_map_page.dart';
import 'route_names.dart';

/// Flat list of every `GoRoute` in the app.
///
/// Wired into `appRouter` (see [app_router.dart]). Phase 0 routes resolve to
/// stub pages — real screens land in their respective feature phases.
CustomTransitionPage<void> _buildTransitionPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slideTween = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slideTween.animate(curved),
          child: child,
        ),
      );
    },
  );
}

final List<RouteBase> appRoutes = <RouteBase>[
  GoRoute(
    name: RouteNames.splash,
    path: RouteNames.splash,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const SplashPage()),
  ),
  GoRoute(
    name: RouteNames.onboarding,
    path: RouteNames.onboarding,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const OnboardingPage()),
  ),
  GoRoute(
    name: RouteNames.login,
    path: RouteNames.login,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const LoginPage()),
  ),
  GoRoute(
    name: RouteNames.register,
    path: RouteNames.register,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const RegisterPage()),
  ),
  GoRoute(
    name: RouteNames.forgotPassword,
    path: RouteNames.forgotPassword,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const ForgotPasswordPage()),
  ),
  GoRoute(
    name: RouteNames.dashboard,
    path: RouteNames.dashboard,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const DashboardPage()),
  ),
  GoRoute(
    name: RouteNames.appShell,
    path: RouteNames.appShell,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const AppShellPage()),
  ),
  GoRoute(
    name: RouteNames.myDevices,
    path: RouteNames.myDevices,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const MyDevicesPage()),
  ),
  GoRoute(
    name: RouteNames.addDevice,
    path: RouteNames.addDevice,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const AddDevicePage()),
  ),
  GoRoute(
    name: RouteNames.deviceDetails,
    path: RouteNames.deviceDetails,
    pageBuilder: (context, state) {
      final deviceId = state.extra as String? ?? '';
      return _buildTransitionPage(state, DeviceDetailsPage(deviceId: deviceId));
    },
  ),
  GoRoute(
    name: RouteNames.firHistory,
    path: RouteNames.firHistory,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const FirHistoryPage()),
  ),
  GoRoute(
    name: RouteNames.submitFir,
    path: RouteNames.submitFir,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const SubmitFirPage()),
  ),
  GoRoute(
    name: RouteNames.caseTracking,
    path: RouteNames.caseTracking,
    pageBuilder: (context, state) {
      final firId = state.extra as String?;
      return _buildTransitionPage(state, CaseTrackingPage(firId: firId ?? ''));
    },
  ),
  GoRoute(
    name: RouteNames.policeDashboard,
    path: RouteNames.policeDashboard,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const PoliceDashboardPage()),
  ),
  GoRoute(
    name: RouteNames.pendingFirQueue,
    path: RouteNames.pendingFirQueue,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const PendingFirQueuePage()),
  ),
  GoRoute(
    name: RouteNames.firReview,
    path: RouteNames.firReview,
    pageBuilder: (context, state) {
      final firId = state.extra as String?;
      return _buildTransitionPage(state, FirReviewPage(firId: firId ?? ''));
    },
  ),
  GoRoute(
    name: RouteNames.profile,
    path: RouteNames.profile,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const ProfilePage()),
  ),
  GoRoute(
    name: RouteNames.settings,
    path: RouteNames.settings,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const SettingsPage()),
  ),
  GoRoute(
    name: RouteNames.notifications,
    path: RouteNames.notifications,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const NotificationsPage()),
  ),

  GoRoute(
    name: RouteNames.ptaDashboard,
    path: RouteNames.ptaDashboard,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const PtaDashboardPage()),
  ),
  GoRoute(
    name: RouteNames.deviceApprovals,
    path: RouteNames.deviceApprovals,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const DeviceApprovalsPage()),
  ),
  GoRoute(
    name: RouteNames.blockRequests,
    path: RouteNames.blockRequests,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const BlockRequestsPage()),
  ),
  GoRoute(
    name: RouteNames.ptaHistory,
    path: RouteNames.ptaHistory,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const PtaHistoryPage()),
  ),
  GoRoute(
    name: RouteNames.theftMap,
    path: RouteNames.theftMap,
    pageBuilder: (context, state) =>
        _buildTransitionPage(state, const TheftMapPage()),
  ),
];
