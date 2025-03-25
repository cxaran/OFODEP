import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/session_cubit.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionAuthenticated && state.user.admin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('admin_dashboard'),
            ),
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/admin/users'),
                  child: const Text('users'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/stores'),
                  child: const Text('stores'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/subscriptions'),
                  child: const Text('subscriptions'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/store_admins'),
                  child: const Text('store_admins'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/products'),
                  child: const Text('products'),
                ),
              ],
            ),
          );
        } else {
          return const ErrorPage();
        }
      },
    );
  }
}
