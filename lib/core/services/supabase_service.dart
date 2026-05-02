import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin initialiser wrapper around the Supabase Flutter SDK.
///
/// Call [init] once from [main] before [runApp]. After that, use [client]
/// anywhere in the app — Supabase stores its own singleton internally.
class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
