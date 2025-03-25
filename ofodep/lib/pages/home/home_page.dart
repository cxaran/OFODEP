import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/session_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        String message = 'loading...';
        if (state is SessionAuthenticated) {
          message = 'welcome ${state.user.name}';
        } else if (state is SessionUnauthenticated) {
          message = 'user_not_authenticated';
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('home'),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Text(message),
              if (state.admin)
                ElevatedButton(
                  onPressed: () => context.push('/admin'),
                  child: const Text('admin_dashboard'),
                ),
              ElevatedButton(
                onPressed: () => context.read<SessionCubit>().signOut(),
                child: const Text('sign_out'),
              ),
            ],
          ),
        );
      },
    );
  }
}
