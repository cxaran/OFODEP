import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/users_list_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListCubitStateHandler<UserModel, UsersListCubit>(
        title: 'Usuarios',
        createCubit: (context) => UsersListCubit()
          ..updateSearchFields(
            ['name', 'email'],
          ),
        itemBuilder: (context, cubit, user, index) => ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () => context.push('/admin/user/${user.authId}'),
        ),
      ),
    );
  }
}
