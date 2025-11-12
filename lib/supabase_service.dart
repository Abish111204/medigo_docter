// lib/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple getter for the Supabase client used across the app.
SupabaseClient get supabase => Supabase.instance.client;

/// Optional initialization hook (main.dart already calls this in your code).
Future<void> initializeSupabase(SupabaseClient client) async {
  // Add any custom initialization here if needed.
  return;
}
