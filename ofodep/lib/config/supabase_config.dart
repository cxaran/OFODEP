import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_URL =
      'https://pvkigznupqcjghyqfbkw.supabase.co';
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2a2lnem51cHFjamdoeXFmYmt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4MzgzODMsImV4cCI6MjA1OTQxNDM4M30.q5qMqNvuqVE5EJ-H0AGGXTFe9EP6kmHxug1PNk50rxk';
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EXPO_PUBLIC_SUPABASE_URL,
      anonKey: EXPO_PUBLIC_SUPABASE_ANON_KEY,
    );
  }
}
