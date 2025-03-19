import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/session_cubit.dart';
import 'package:ofodep/pages/admin/admin_dashboard.dart';
import 'package:ofodep/pages/admin/admin_users.dart';
import 'package:ofodep/pages/admin/admin_zones.dart';
import 'package:ofodep/pages/auth/login_page.dart';
import 'package:ofodep/pages/home/home_page.dart';

/// Envuelve el SessionCubit en un ChangeNotifier para que go_router se actualice
class SessionNotifier extends ChangeNotifier {
  final SessionCubit sessionCubit;
  late final StreamSubscription subscription;

  SessionNotifier(this.sessionCubit) {
    subscription = sessionCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}

/// Crea el router utilizando el estado del SessionCubit
GoRouter createRouter(SessionCubit sessionCubit) {
  final sessionNotifier = SessionNotifier(sessionCubit);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: sessionNotifier,
    redirect: (context, state) {
      final isAuthenticated = sessionCubit.state is SessionAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      // Si no está autenticado y no se encuentra en la pantalla de login, redirige a /login
      if (!isAuthenticated && !loggingIn) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }
      // Si ya está autenticado y se intenta acceder a /login, redirige a /home
      if (isAuthenticated && loggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(
          redirectPath: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          if (state.uri.pathSegments.length == 1 &&
              state.matchedLocation == '/admin') {
            return '/admin/dashboard';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const AdminUsersPage(),
          ),
          GoRoute(
            path: 'zones',
            builder: (context, state) => const AdminZonesPage(),
          )
        ],
      ),
    ],
  );
}
