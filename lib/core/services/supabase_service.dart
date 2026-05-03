import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://pmyhjofehydwuyxncmet.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBteWhqb2ZlaHlkd3V5eG5jbWV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4MjAzMzYsImV4cCI6MjA5MzM5NjMzNn0.Xp22JaHpCbTnY3kwsWaG5cf-p-1_udadKBis2GkWIGE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseServiceProvider).client;
});
