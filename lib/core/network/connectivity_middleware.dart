import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';
import '../logic/connectivity_notifier.dart';

class ConnectivityMiddleware {
  ConnectivityMiddleware._();

  static void assertOnline(Ref ref) {
    final isOnline = ref.read(connectivityProvider).valueOrNull ?? true;
    if (!isOnline) throw const NetworkFailure();
  }
}
