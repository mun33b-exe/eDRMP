import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_names.dart';

/// App-wide router. Phase 1 fills in the real auth-gate redirect.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: appRoutes,
  redirect: (context, state) => null,
);
