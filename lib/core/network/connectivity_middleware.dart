import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';
import '../logic/connectivity_notifier.dart';

class ConnectivityMiddleware {
  ConnectivityMiddleware._();

  // TODO(Phase 9D): replace connectivityProvider with real connectivity_plus check.
  static void assertOnline(Ref ref) {
    final isOnline = ref.read(connectivityProvider);
    if (!isOnline) throw const NetworkFailure();
  }
}
