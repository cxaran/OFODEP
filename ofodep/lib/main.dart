import 'package:flutter/material.dart';
import 'package:ofodep/config/supabase_config.dart';
import 'package:ofodep/pages/admin/admin_dashboard.dart';
import 'package:ofodep/pages/admin/users_management_screen.dart';
import 'package:ofodep/pages/auth/login_screen.dart';
import 'package:ofodep/pages/common/home_screen.dart';
import 'package:ofodep/pages/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OFODEP',
      theme: ThemeData(primarySwatch: Colors.blue),
      // La pantalla inicial es el SplashScreen, que redirige según la sesión
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),

        //Admin Screens
        '/admin/dashboard': (_) => const AdminDashboard(),
        '/admin/users': (_) => const UsersManagementScreen(),
      },
    );
  }
}
