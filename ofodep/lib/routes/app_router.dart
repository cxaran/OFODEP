import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/pages/admin/admin_store_admins.dart';
import 'package:ofodep/pages/admin/store_schedule_exception/admin_store_schedule_exceptions.dart';
import 'package:ofodep/pages/admin/store_schedule/admin_store_schedules.dart';
import 'package:ofodep/pages/admin/store_subscriptions/admin_store_subscriptions.dart';
import 'package:ofodep/pages/admin/store/admin_stores.dart';
import 'package:ofodep/pages/admin/admin_dashboard.dart';
import 'package:ofodep/pages/admin/order/admin_orders.dart';
import 'package:ofodep/pages/admin/product/admin_products.dart';
import 'package:ofodep/pages/admin/user/admin_users.dart';
import 'package:ofodep/pages/auth/login_page.dart';
import 'package:ofodep/pages/admin/product/product_page.dart';
import 'package:ofodep/pages/admin/store/store_page.dart';
import 'package:ofodep/pages/home/home_page.dart';
import 'package:ofodep/pages/admin/store_schedule/store_schedule_page.dart';
import 'package:ofodep/pages/admin/store_schedule_exception/store_schedule_exception_page.dart';
import 'package:ofodep/pages/admin/store_subscriptions/store_subscriptions_page.dart';
import 'package:ofodep/pages/admin/user/user_page.dart';

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
  GoRouter.optionURLReflectsImperativeAPIs = true;
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
            path: '/dashboard',
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const AdminUsersPage(),
          ),
          GoRoute(
            path: '/user/:userId',
            builder: (context, state) => UserPage(
              userId: state.pathParameters['userId'],
            ),
          ),
          GoRoute(
            path: '/stores',
            builder: (context, state) => const AdminStoresPage(),
          ),
          GoRoute(
            path: '/store/:storeId',
            builder: (context, state) => StorePage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/store_admins',
            builder: (context, state) => const AdminStoreAdminsPage(),
          ),
          GoRoute(
            path: '/store_admins/:storeId',
            builder: (context, state) => AdminStoreAdminsPage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const AdminProductsPage(),
          ),
          GoRoute(
            path: '/products/:storeId',
            builder: (context, state) => AdminProductsPage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (context, state) => const AdminStoreSubscriptionsPage(),
          ),
          GoRoute(
            path: '/subscription/:storeId',
            builder: (context, state) => StoreSubscriptionsPage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/product/:productId',
            builder: (context, state) => ProductPage(
              productId: state.pathParameters['productId'],
            ),
          ),
          GoRoute(
            path: '/schedules/:storeId',
            builder: (context, state) => AdminStoreSchedulesPage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/schedule/:scheduleId',
            builder: (context, state) => StoreSchedulePage(
              scheduleId: state.pathParameters['scheduleId'],
            ),
          ),
          GoRoute(
            path: '/schedule_exceptions/:storeId',
            builder: (context, state) => AdminStoreScheduleExceptionsPage(
              storeId: state.pathParameters['storeId'],
            ),
          ),
          GoRoute(
            path: '/schedule_exception/:scheduleId',
            builder: (context, state) => StoreScheduleExceptionPage(
              scheduleId: state.pathParameters['scheduleId'],
            ),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => AdminOrdersPage(
              storeId: state.uri.queryParameters['store'],
              userId: state.uri.queryParameters['user'],
            ),
          ),
        ],
      ),
    ],
  );
}
