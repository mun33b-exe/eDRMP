import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/logic/auth_controller.dart';
import 'app_routes.dart';
import 'route_helpers.dart';
import 'route_names.dart';

/// `Listenable` that fires whenever the wrapped Riverpod `Provider` emits a
/// new value. Bridges Riverpod's reactive auth state into GoRouter's
/// `refreshListenable`-based invalidation pipeline.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _sub = ref.listen<Object?>(
      authControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// App-wide router exposed as a Riverpod provider so the redirect can read
/// the authenticated user (and its role) without resorting to globals.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    routes: appRoutes,
    redirect: (context, state) {
      final asyncAuth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      const authPaths = <String>{
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
      };
      final atAuthArea = authPaths.contains(loc);

      // While the controller is mid-transition (login/register/logout) we
      // do not want to bounce the user — leave them on the current page so
      // the in-flight CTA's loading spinner stays visible.
      if (asyncAuth.isLoading) {
        return null;
      }

      final auth = asyncAuth.valueOrNull;
      final isAuthenticated = auth?.isAuthenticated ?? false;

      if (!isAuthenticated) {
        return atAuthArea ? null : RouteNames.login;
      }

      // Authenticated — block return-trips into the auth area, but allow
      // splash to keep playing (it routes itself once the brand pause ends).
      if (atAuthArea && loc != RouteNames.splash) {
        return homeRouteForRole(auth!.role!);
      }
      return null;
    },
  );
});
