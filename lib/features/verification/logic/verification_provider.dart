import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/verification_repository.dart';
import '../data/verification_result.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (_) => VerificationRepository(),
);

final verificationResultProvider = StateProvider<VerificationResult?>(
  (_) => null,
);

final verificationLoadingProvider = StateProvider<bool>((_) => false);

final verificationErrorProvider = StateProvider<String?>((_) => null);

Future<void> checkImei(String imei, WidgetRef ref) async {
  ref.read(verificationLoadingProvider.notifier).state = true;
  ref.read(verificationErrorProvider.notifier).state = null;
  ref.read(verificationResultProvider.notifier).state = null;
  try {
    final result = await ref
        .read(verificationRepositoryProvider)
        .checkImei(imei);
    ref.read(verificationResultProvider.notifier).state = result;
  } catch (_) {
    ref.read(verificationErrorProvider.notifier).state =
        'Verification failed. Check your connection and try again.';
  } finally {
    ref.read(verificationLoadingProvider.notifier).state = false;
  }
}
