import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/models/store_schedule_exception_model.dart';
import 'package:ofodep/models/store_schedule_model.dart';
import 'package:ofodep/pages/admin/admin_store/admin_store_admins.dart';
import 'package:ofodep/pages/admin/admin_store/store_admin_page.dart';
import 'package:ofodep/pages/admin/order/order_page.dart';
import 'package:ofodep/pages/admin/store_images/store_images_admin_page.dart';
import 'package:ofodep/pages/admin/store_schedule_exception/admin_store_schedule_exceptions.dart';
import 'package:ofodep/pages/admin/store_schedule/admin_store_schedules.dart';
import 'package:ofodep/pages/admin/store_subscriptions/admin_store_subscriptions.dart';
import 'package:ofodep/pages/admin/store/admin_stores.dart';
import 'package:ofodep/pages/admin/admin_dashboard.dart';
import 'package:ofodep/pages/admin/order/admin_orders.dart';
import 'package:ofodep/pages/admin/product/admin_products.dart';
import 'package:ofodep/pages/admin/user/admin_users.dart';
import 'package:ofodep/pages/auth/login_page.dart';
import 'package:ofodep/pages/admin/product/product_admin_page.dart';
import 'package:ofodep/pages/admin/store/store_admin_page.dart';
import 'package:ofodep/pages/cart/cart_page.dart';
import 'package:ofodep/pages/create_store/create_store_page.dart';
import 'package:ofodep/pages/home/home_page.dart';
import 'package:ofodep/pages/admin/store_schedule/store_schedule_admin_page.dart';
import 'package:ofodep/pages/admin/store_schedule_exception/store_schedule_exception_admin_page.dart';
import 'package:ofodep/pages/admin/store_subscriptions/store_subscription_admin_page.dart';
import 'package:ofodep/pages/admin/user/user_admin_page.dart';
import 'package:ofodep/pages/public/product/product_page.dart';
import 'package:ofodep/pages/public/store/store_page.dart';
import 'package:ofodep/pages/splash/splash.dart';
import 'package:ofodep/pages/user/user_page.dart';

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
      final isInitial = sessionCubit.state is SessionInitial;
      final loggingIn = state.matchedLocation == '/login';
      final splash = state.matchedLocation == '/splash';

      // Si el estado es inicial, mostrar Splash y preservar la ruta original.
      if (isInitial) {
        if (!splash) {
          return '/splash?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        // Mientras se muestra Splash, no se redirige.
        return null;
      }

      // Si el usuario está autenticado y se intenta acceder a login, redirigir a home
      if (isAuthenticated && loggingIn) {
        // Aquí puedes también redirigir a la ruta guardada en el parámetro redirect
        final redirectPath = state.uri.queryParameters['redirect'] ?? '/home';
        return redirectPath;
      }

      final publicPaths = ['/home', '/product', '/store'];
      final isPublicRoute =
          publicPaths.any((path) => state.matchedLocation.startsWith(path));
      if (!isAuthenticated && !loggingIn && !isPublicRoute) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/create_store',
        builder: (context, state) => const CreateStorePage(),
      ),
      GoRoute(
        path: '/store/:storeId',
        builder: (context, state) => StorePage(
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
        path: '/user/:userId',
        builder: (context, state) => const UserPage(),
      ),
      GoRoute(
        path: '/order/:orderId',
        builder: (context, state) => OrderPage(
          orderId: state.pathParameters['orderId'],
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/user/:userId',
        builder: (context, state) => UserAdminPage(
          userId: state.pathParameters['userId'],
        ),
      ),
      GoRoute(
        path: '/admin/stores',
        builder: (context, state) => const AdminStoresPage(),
      ),
      GoRoute(
        path: '/admin/store/:storeId',
        builder: (context, state) => StoreAdminPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/store_admins',
        builder: (context, state) => const AdminStoreAdminsPage(),
      ),
      GoRoute(
        path: '/admin/store_admins/:storeId',
        builder: (context, state) => AdminStoreAdminsPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/store_admin/:adminStoreId',
        builder: (context, state) => StoreAdminAdminPage(
          adminStoreId: state.pathParameters['adminStoreId'],
          createModel: state.extra as StoreAdminModel?,
        ),
      ),
      GoRoute(
        path: '/admin/store_images/:storeId',
        builder: (context, state) => StoreImagesAdminPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsPage(),
      ),
      GoRoute(
        path: '/admin/products/:storeId',
        builder: (context, state) => AdminProductsPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/subscriptions',
        builder: (context, state) => const AdminStoreSubscriptionsAdminPage(),
      ),
      GoRoute(
        path: '/admin/subscription/:storeId',
        builder: (context, state) => StoreSubscriptionAdminPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/product/:productId',
        builder: (context, state) => ProductAdminPage(
          productId: state.pathParameters['productId'],
        ),
      ),
      GoRoute(
        path: '/admin/schedules/:storeId',
        builder: (context, state) => AdminStoreSchedulesPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/schedule/:scheduleId',
        builder: (context, state) => StoreScheduleAdminPage(
          scheduleId: state.pathParameters['scheduleId'],
          createModel: state.extra as StoreScheduleModel?,
        ),
      ),
      GoRoute(
        path: '/admin/schedule_exceptions/:storeId',
        builder: (context, state) => AdminStoreScheduleExceptionsPage(
          storeId: state.pathParameters['storeId'],
        ),
      ),
      GoRoute(
        path: '/admin/schedule_exception/:scheduleId',
        builder: (context, state) => StoreScheduleExceptionAdminPage(
          scheduleId: state.pathParameters['scheduleId'],
          createModel: state.extra as StoreScheduleExceptionModel?,
        ),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => AdminOrdersPage(
          storeId: state.uri.queryParameters['store'],
          userId: state.uri.queryParameters['user'],
        ),
      ),
    ],
  );
}
