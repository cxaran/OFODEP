import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/session_cubit.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionAuthenticated && state.usuario.admin) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard Admin'),
            ),
            body: Column(
              children: [
                Text('Panel de administración general.'),
                ElevatedButton(
                  onPressed: () => context.push('/admin/users'),
                  child: const Text('Administrar Usuarios'),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/admin/zones'),
                  child: const Text('Zonas'),
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
