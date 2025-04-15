import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/widgets/custom_list_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomListView(
      children: [
        ListTile(
          title: const Text('Usuario'),
          subtitle: Text(context.read<SessionCubit>().user?.name ?? ''),
          onTap: () => context
              .push('/admin/user/${context.read<SessionCubit>().user?.authId}'),
        ),
        Divider(),
        Text('Configuraciones'),
        ListTile(
          title: const Text('Cerrar sesión'),
          onTap: () => context.read<SessionCubit>().signOut(),
        ),
      ],
    );
  }
}
