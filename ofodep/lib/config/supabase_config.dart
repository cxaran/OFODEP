import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_URL =
      'https://glshomqxdnjjvhsecyce.supabase.co';
  // ignore: non_constant_identifier_names
  static String EXPO_PUBLIC_SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdsc2hvbXF4ZG5qanZoc2VjeWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5ODc3NDAsImV4cCI6MjA1NzU2Mzc0MH0.vAqaadXXvFihTBoaNde5Dxb1xPdI4K4H2MPJGjnz6LI';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EXPO_PUBLIC_SUPABASE_URL,
      anonKey: EXPO_PUBLIC_SUPABASE_ANON_KEY,
    );
  }
}
