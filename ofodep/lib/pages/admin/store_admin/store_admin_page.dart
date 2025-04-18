import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_admin_cubit.dart';
import 'package:ofodep/blocs/list_cubits/users_public_list_cubit.dart';
import 'package:ofodep/models/store_admin_model.dart';
import 'package:ofodep/models/user_public_model.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';

class StoreAdminAdminPage extends StatelessWidget {
  final String? adminStoreId;
  final StoreAdminModel? createModel;
  StoreAdminAdminPage({
    super.key,
    this.adminStoreId,
    this.createModel,
  });

  final GlobalKey<FormState> formEditingKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formCreatingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (adminStoreId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<StoreAdminModel, StoreAdminCubit>(
        createCubit: (context) => StoreAdminCubit()
          ..load(
            adminStoreId!,
            createModel: createModel,
          ),
        loadedBuilder: loadedBuilder,
        editingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formEditingKey,
          cubit: cubit,
          edited: state.editedModel,
          editMode: state.editMode,
          isLoading: state.isSubmitting,
          onSave: () => submit(formEditingKey, cubit),
          onBack: cubit.cancelEditing,
        ),
        creatingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formCreatingKey,
          cubit: cubit,
          edited: state.editedModel,
          isLoading: state.isSubmitting,
          onSave: () => create(formCreatingKey, cubit),
        ),
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    StoreAdminCubit cubit,
    CrudLoaded<StoreAdminModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Administrador de comercio',
      loadedMessage: state.message,
      actions: [
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Eliminar administrador de comercio?'),
              content: const Text('Esta acción no se puede deshacer'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => cubit.delete().then(
                        (_) => context.mounted
                            ? Navigator.of(context).pop()
                            : null,
                      ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.delete),
          label: const Text('Eliminar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
      children: [
        ListTile(
          leading: const Icon(Icons.storefront),
          title: Text('Comercio'),
          subtitle: model.storeName != null
              ? Text(model.storeName!)
              : FutureBuilder(
                  future: StoreRepository().getValueById(model.storeId, 'name'),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('Nombre de contacto'),
          subtitle: Text(model.contactName),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: Text('Correo de contacto'),
          subtitle: Text(model.contactEmail),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text('Teléfono de contacto'),
          subtitle: Text(model.contactPhone),
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: Text('Contacto principal'),
          subtitle: Text(model.isPrimaryContact ?? false ? 'Si' : 'No'),
        ),
      ],
    );
  }

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required StoreAdminCubit cubit,
    required StoreAdminModel edited,
    required bool isLoading,
    bool editMode = true,
    required VoidCallback onSave,
    VoidCallback? onBack,
  }) {
    return CustomListView(
      title: 'Administrador de comercio',
      formKey: formKey,
      isLoading: isLoading,
      editMode: editMode,
      onSave: onSave,
      onBack: onBack,
      children: [
        ListTile(
          leading: const Icon(Icons.storefront),
          title: Text('Comercio'),
          subtitle: FutureBuilder(
            future: StoreRepository().getValueById(edited.storeId, 'name'),
            builder: (context, snapshot) => Text(snapshot.data ?? ''),
          ),
        ),
        Divider(),
        // El usario tiene que estar registrado y se busca segun su nombre correo o teléfono en la base de datos.
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(
            'El usuario debe estar previamente registrado. '
            'Puedes buscarlo escribiendo su nombre. '
            'Una vez encontrado, se asociará como administrador del comercio seleccionado',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: Text('Buscar usuario'),
          subtitle: Text(
            edited.userId.isEmpty
                ? 'Selecciona un usuario'
                : '${edited.userName}\n${edited.userId}',
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => showBottomSheet(
            context: context,
            builder: (context_) => UserSearch(
              onUserSelected: (user) => cubit.updateEditedModel(
                (model) => model.copyWith(
                  userName: user.name,
                  userId: user.id,
                ),
              ),
            ),
          ),
        ),
        Divider(),
        CheckboxListTile(
          value: edited.isPrimaryContact,
          secondary: const Icon(Icons.admin_panel_settings),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(isPrimaryContact: value),
          ),
          title: Text('Contacto principal'),
        ),
        TextFormField(
          initialValue: edited.contactName,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            labelText: 'Nombre de contacto',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(contactName: value),
          ),
        ),
        TextFormField(
          initialValue: edited.contactEmail,
          decoration: const InputDecoration(
            icon: Icon(Icons.email),
            labelText: 'Correo de contacto',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(contactEmail: value),
          ),
        ),
        TextFormField(
          initialValue: edited.contactPhone,
          decoration: const InputDecoration(
            icon: Icon(Icons.phone),
            labelText: 'Teléfono de contacto',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(contactPhone: value),
          ),
        ),
      ],
    );
  }
}

class UserSearch extends StatelessWidget {
  final Function(UserPublicModel) onUserSelected;
  const UserSearch({super.key, required this.onUserSelected});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height * 0.7;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: ListCubitStateHandler<UserPublicModel, UsersPublicListCubit>(
        showAppBar: false,
        createCubit: (context) =>
            UsersPublicListCubit()..updateFilter({'name': ''}),
        onSearch: (cubit, search) => cubit.updateFilter({'name': search}),
        itemBuilder: (context, cubit, user, state) => ListTile(
          title: Text(user.name),
          subtitle: Text(user.id),
          onTap: () {
            onUserSelected(user);
            context.pop();
          },
        ),
      ),
    );
  }
}
