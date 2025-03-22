import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/session_cubit.dart';
import 'package:ofodep/blocs/user_cubit.dart';
import 'package:ofodep/pages/error_page.dart';

class UserPage extends StatelessWidget {
  final String? userId;

  const UserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return ErrorPage();
    }
    return BlocProvider<UserCubit>(
      create: (context) => UserCubit(userId!)..loadUser(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Editar Usuario'),
          ),
          body: BlocConsumer<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is UserEditState) {
                if (state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is UserLoading || state is UserInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UserError) {
                return Center(child: Text(state.message));
              } else if (state is UserEditState) {
                return Column(
                  children: [
                    TextField(
                      key: const ValueKey('email_user'),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.email,
                          selection: TextSelection.collapsed(
                              offset: state.email.length),
                        ),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    TextField(
                      key: const ValueKey('name_user'),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.name,
                          selection: TextSelection.collapsed(
                              offset: state.name.length),
                        ),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          context.read<UserCubit>().nameChanged(value),
                    ),
                    TextField(
                      key: const ValueKey('phone_user'),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: state.phone,
                          selection: TextSelection.collapsed(
                              offset: state.phone.length),
                        ),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Telefono',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          context.read<UserCubit>().phoneChanged(value),
                    ),
                    // Check Box to set Admin
                    BlocBuilder<SessionCubit, SessionState>(
                      builder: (context, state) {
                        if (state is SessionAuthenticated) {
                          return Row(
                            children: [
                              Text('Admin'),
                              Checkbox(
                                value: state.admin,
                                onChanged: (value) => context
                                    .read<UserCubit>()
                                    .adminChanged(value ?? false),
                              )
                            ],
                          );
                        }
                        return Container();
                      },
                    ),

                    ElevatedButton(
                      onPressed: () => context.read<UserCubit>().submit(),
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        );
      }),
    );
  }
}
