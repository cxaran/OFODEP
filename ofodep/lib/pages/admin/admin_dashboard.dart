import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionAuthenticated && state.user.admin) {
          return ListView(
            children: [
              ListTile(
                title: const Text('users'),
                onTap: () => context.push('/admin/users'),
              ),
              ListTile(
                title: const Text('stores'),
                onTap: () => context.push('/admin/stores'),
              ),
              ListTile(
                title: const Text('subscriptions'),
                onTap: () => context.push('/admin/subscriptions'),
              ),
              ListTile(
                title: const Text('store_admins'),
                onTap: () => context.push('/admin/store_admins'),
              ),
              ListTile(
                title: const Text('products'),
                onTap: () => context.push('/admin/products'),
              ),
            ],
          );
        } else {
          return const ErrorPage();
        }
      },
    );
  }
}
