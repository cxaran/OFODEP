import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/session_cubit.dart';
import 'package:ofodep/config/locations_strings.dart';
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
              title: const Text(adminDashboardTitle),
            ),
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/admin/users'),
                  child: const Text(adminDashboardUsers),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/stores'),
                  child: const Text(adminDashboardStores),
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
