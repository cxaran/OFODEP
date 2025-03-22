import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_URL =
      'https://rqdzaabiotkdasyelyht.supabase.co';
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxZHphYWJpb3RrZGFzeWVseWh0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1OTgxMTEsImV4cCI6MjA1ODE3NDExMX0.9dXT2hvvnUVKStT2ZhhKFBe93ejD6D-oBRucroLJ8YU';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EXPO_PUBLIC_SUPABASE_URL,
      anonKey: EXPO_PUBLIC_SUPABASE_ANON_KEY,
    );
  }
}
