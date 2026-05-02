import '../../features/auth/logic/auth_user.dart';
import 'route_names.dart';

/// Resolves the post-login landing page for a given [UserRole].
///
/// Used by the splash hand-off and by the auth-gate redirect to keep one
/// source of truth for "where does this role live."
String homeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.user:
      return RouteNames.dashboard;
    case UserRole.police:
      return RouteNames.policeDashboard;
    case UserRole.pta:
      return RouteNames.ptaDashboard;
  }
}
