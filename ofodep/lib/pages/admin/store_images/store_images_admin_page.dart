import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_images_cubit.dart';
import 'package:ofodep/models/store_images_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreImagesAdminPage extends StatelessWidget {
  final String? storeId;
  final GlobalKey<FormState> formEditingKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formCreatingKey = GlobalKey<FormState>();
  StoreImagesAdminPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler(
        createCubit: (context) => StoreImagesCubit(id: storeId!)..load(),
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
    CrudCubit<StoreImagesModel> cubit,
    CrudLoaded<StoreImagesModel> state,
  ) {
    return CustomListView(
      title: 'Imgur',
      actions: [
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
      children: [
        ListTile(
          leading: const Icon(Icons.ads_click),
          title: Text('Obtener tus claves de Imgur'),
          onTap: () => launchUrl(
            Uri.parse('https://api.imgur.com/oauth2/addclient'),
          ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.lock_open),
          title: Text('Imgur Client ID'),
          subtitle: Text(state.model.imgurClientId),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text('Imgur Client Secret'),
          subtitle: Text(state.model.imgurClientSecret),
        ),
      ],
    );
  }

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required CrudCubit<StoreImagesModel> cubit,
    required StoreImagesModel edited,
    required bool isLoading,
    bool editMode = true,
    required VoidCallback onSave,
    VoidCallback? onBack,
  }) {
    return CustomListView(
      title: 'Imgur',
      formKey: formKey,
      isLoading: isLoading,
      editMode: editMode,
      onSave: onSave,
      onBack: onBack,
      children: [
        ListTile(
          leading: const Icon(Icons.ads_click),
          title: Text('Obtener tus claves de Imgur'),
          onTap: () => launchUrl(
            Uri.parse('https://api.imgur.com/oauth2/addclient'),
          ),
        ),
        Divider(),
        TextFormField(
          initialValue: edited.imgurClientId,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock_open),
            labelText: 'Imgur Client ID',
          ),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(imgurClientId: value),
          ),
        ),
        TextFormField(
          initialValue: edited.imgurClientSecret,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock_outline),
            labelText: 'Imgur Client Secret',
          ),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(imgurClientSecret: value),
          ),
        ),
      ],
    );
  }
}
