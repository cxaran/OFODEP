import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/local_cubits/session_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/repositories/admin_global_repository.dart';
import 'package:ofodep/repositories/store_admin_repository.dart';

class DrawerHome extends StatelessWidget {
  const DrawerHome({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel? user = context.read<SessionCubit>().user;

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Text('OFODEP')),
            if (user != null)
              FutureBuilder(
                future: StoreAdminRepository().getById(
                  user.id,
                  field: 'user_id',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ListTile(
                        leading: const Icon(Icons.store_sharp),
                        title: Text(snapshot.data?.storeName ?? '...'),
                        onTap: () => context.push(
                          '/admin/store/${snapshot.data?.storeId}',
                        ),
                      );
                    } else {
                      return ListTile(
                        leading: const Icon(Icons.store_sharp),
                        title: const Text('Registrar comercio'),
                        onTap: () => context.push('/create_store'),
                      );
                    }
                  }
                  return SizedBox.shrink();
                },
              ),
            if (user != null)
              FutureBuilder(
                future: AdminGlobalRepository().getById(user.authId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: Text('Panel de administración'),
                        onTap: () => context.push('/admin'),
                      );
                    }
                  }
                  return SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}
