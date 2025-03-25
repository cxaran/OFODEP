import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/session_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/user_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/pages/error_page.dart';

class UserPage extends StatelessWidget {
  final String? userId;

  const UserPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const ErrorPage();

    return BlocProvider<UserCubit>(
      create: (context) => UserCubit(id: userId!)..load(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar Usuario'),
            actions: [
              BlocBuilder<UserCubit, CrudState<UserModel>>(
                builder: (context, state) {
                  if (state is CrudLoaded<UserModel>) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.read<UserCubit>().startEditing(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocConsumer<UserCubit, CrudState<UserModel>>(
            listener: (context, state) {
              if (state is CrudError<UserModel>) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is CrudEditing<UserModel> &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
              if (state is CrudDeleted<UserModel>) {
                // Por ejemplo, se puede redirigir a otra pantalla al eliminar
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              if (state is CrudInitial<UserModel> ||
                  state is CrudLoading<UserModel>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CrudError<UserModel>) {
                return Center(child: Text(state.message));
              } else if (state is CrudLoaded<UserModel>) {
                // Estado no editable: muestra los datos y un botón para editar
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${state.model.email}"),
                      Text("Nombre: ${state.model.name}"),
                      Text("Teléfono: ${state.model.phone}"),
                      Text("Admin: ${state.model.admin ? 'Sí' : 'No'}"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<UserCubit>().startEditing(),
                        child: const Text("Editar"),
                      ),
                    ],
                  ),
                );
              } else if (state is CrudEditing<UserModel>) {
                // En modo edición, se usan TextFields que muestran los valores de editedModel.
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        key: const ValueKey('email_user'),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: state.editedModel.email,
                            selection: TextSelection.collapsed(
                                offset: state.editedModel.email.length),
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
                            text: state.editedModel.name,
                            selection: TextSelection.collapsed(
                                offset: state.editedModel.name.length),
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
                            text: state.editedModel.phone,
                            selection: TextSelection.collapsed(
                                offset: state.editedModel.phone.length),
                          ),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            context.read<UserCubit>().phoneChanged(value),
                      ),
                      BlocBuilder<SessionCubit, SessionState>(
                        builder: (context, sessionState) {
                          if (sessionState is SessionAuthenticated) {
                            return Row(
                              children: [
                                const Text('Admin'),
                                Checkbox(
                                  value: state.editedModel.admin,
                                  onChanged: (value) => context
                                      .read<UserCubit>()
                                      .adminChanged(value ?? false),
                                ),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                      if (state.isSubmitting)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: () => context.read<UserCubit>().submit(),
                          child: const Text('Guardar'),
                        ),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<UserCubit>().cancelEditing(),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
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
