import 'package:flutter/material.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/store_images_cubit.dart';
import 'package:ofodep/models/store_images_model.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreImagesAdminPage extends StatelessWidget {
  final String? storeId;

  const StoreImagesAdminPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    if (storeId == null) return const MessagePage.error();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Imgur'),
      ),
      body: CrudStateHandler(
        createCubit: (context) => StoreImagesCubit(id: storeId!)..load(),
        loadedBuilder: loadedBuilder,
        editingBuilder: editingBuilder,
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    CrudCubit<StoreImagesModel> cubit,
    CrudLoaded<StoreImagesModel> state,
  ) {
    return CustomListView(
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
        ElevatedButton.icon(
          onPressed: () => cubit.startEditing(),
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
      ],
    );
  }

  Widget editingBuilder(
    BuildContext context,
    CrudCubit<StoreImagesModel> cubit,
    CrudEditing<StoreImagesModel> state,
  ) {
    return CustomListView(
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
          initialValue: state.editedModel.imgurClientId,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock_open),
            labelText: 'Imgur Client ID',
          ),
          onChanged: (value) => cubit.updateEditingState(
            (model) => model.copyWith(imgurClientId: value),
          ),
        ),
        TextFormField(
          initialValue: state.editedModel.imgurClientSecret,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock_outline),
            labelText: 'Imgur Client Secret',
          ),
          onChanged: (value) => cubit.updateEditingState(
            (model) => model.copyWith(imgurClientSecret: value),
          ),
        ),
        ElevatedButton.icon(
          onPressed: state.isSubmitting || !state.editMode
              ? null
              : () => cubit.submit(),
          icon: const Icon(Icons.check),
          label: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Guardar"),
        ),
        ElevatedButton.icon(
          onPressed: state.isSubmitting ? null : () => cubit.cancelEditing(),
          icon: const Icon(Icons.arrow_back),
          label: state.isSubmitting
              ? const CircularProgressIndicator()
              : const Text("Cancelar"),
        ),
      ],
    );
  }
}
