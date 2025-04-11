import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/products_category_cubit.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/message_page.dart';

class ProductsCategoryAdminPage extends StatelessWidget {
  final String? productCategoryId;
  final ProductsCategoryModel? createModel;
  ProductsCategoryAdminPage({
    super.key,
    this.productCategoryId,
    this.createModel,
  });
  final GlobalKey<FormState> formEditingKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formCreatingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (productCategoryId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<ProductsCategoryModel, ProductsCategoryCubit>(
        createCubit: (context) => ProductsCategoryCubit()
          ..load(
            productCategoryId!,
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
    ProductsCategoryCubit cubit,
    CrudLoaded<ProductsCategoryModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Categoría de productos',
      actions: [
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Eliminar categoría de productos?'),
              content: const Text('Esta acción no se puede deshacer.'),
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
                  future: StoreRepository().getValueById(
                    model.storeId,
                    'name',
                  ),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? '',
                  ),
                ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.category),
          title: Text('Nombre de categoría'),
          subtitle: Text(model.name),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text('Descripción'),
          subtitle: Text(model.description ?? ''),
        ),
      ],
    );
  }

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required ProductsCategoryCubit cubit,
    required ProductsCategoryModel edited,
    required bool isLoading,
    bool editMode = true,
    required VoidCallback onSave,
    VoidCallback? onBack,
  }) {
    return CustomListView(
      title: 'Categoría de productos',
      formKey: formKey,
      isLoading: isLoading,
      editMode: editMode,
      onSave: onSave,
      onBack: onBack,
      children: [
        ListTile(
          leading: const Icon(Icons.storefront),
          title: Text('Comercio'),
          subtitle: edited.storeName != null
              ? Text(edited.storeName!)
              : FutureBuilder(
                  future: StoreRepository().getValueById(
                    edited.storeId,
                    'name',
                  ),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? '',
                  ),
                ),
        ),
        const Text('Categoría para agrupar productos de tu comercio.'),
        Divider(),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.category),
            labelText: 'Nombre de categoría',
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(name: value),
          ),
        ),
        TextFormField(
          initialValue: edited.description,
          decoration: const InputDecoration(
            icon: Icon(Icons.description),
            labelText: 'Descripción',
          ),
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(description: value),
          ),
        ),
      ],
    );
  }
}
