import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/repositories/store_repository.dart';

class DrawerHome extends StatelessWidget {
  const DrawerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('OFODEP'),
            ),
            if (state is SessionAuthenticated) ...[
              if (state.storeId != null)
                ListTile(
                  leading: const Icon(Icons.store_sharp),
                  title: FutureBuilder(
                    future: StoreRepository().getValueById(
                      state.storeId!,
                      'name',
                    ),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? '...',
                    ),
                  ),
                  onTap: () => context.push('/admin/store/${state.storeId}'),
                )
              else
                ListTile(
                  leading: const Icon(Icons.store_sharp),
                  title: const Text('Registrar comercio'),
                  onTap: () => context.push('/create_store'),
                ),
              if (state.admin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin'),
                  onTap: () => context.push('/admin'),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
