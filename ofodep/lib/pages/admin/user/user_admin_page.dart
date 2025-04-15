import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/user_cubit.dart';
import 'package:ofodep/models/user_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

class UserAdminPage extends StatelessWidget {
  final String? userId;

  UserAdminPage({
    super.key,
    required this.userId,
  });

  final GlobalKey<FormState> formEditingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<UserModel, UserCubit>(
        createCubit: (context) => UserCubit()..load(userId!),
        loadedBuilder: loadedBuilder,
        editingBuilder: editingBuilder,
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    UserCubit cubit,
    CrudLoaded<UserModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Datos de usuario',
      loadedMessage: state.message,
      actions: [
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('Nombre'),
          subtitle: Text(model.name),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: Text('Correo'),
          subtitle: Text(model.email),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text('Teléfono'),
          subtitle: Text(model.phone ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: Text(model.authId),
        ),
      ],
    );
  }

  Widget editingBuilder(
    BuildContext context,
    UserCubit cubit,
    CrudEditing<UserModel> state,
  ) {
    final edited = state.editedModel;
    return CustomListView(
      title: 'Datos de usuario',
      formKey: formEditingKey,
      isLoading: state.isSubmitting,
      editMode: state.editMode,
      onSave: () => submit(formEditingKey, cubit),
      onBack: cubit.cancelEditing,
      children: [
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            labelText: 'Nombre',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(name: value),
          ),
        ),
        TextFormField(
          initialValue: edited.email,
          decoration: const InputDecoration(
            icon: Icon(Icons.email),
            labelText: 'Correo',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(email: value),
          ),
        ),
        TextFormField(
          initialValue: edited.phone,
          decoration: const InputDecoration(
            icon: Icon(Icons.phone),
            labelText: 'Teléfono',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(phone: value),
          ),
        ),
      ],
    );
  }
}
