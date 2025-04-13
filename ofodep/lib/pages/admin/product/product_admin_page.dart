import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_cubit.dart';
import 'package:ofodep/blocs/list_cubits/products_categories_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/products_categories_repository.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/utils/constants.dart';
import 'package:ofodep/widgets/admin_image.dart';
import 'package:ofodep/widgets/crud_state_handler.dart';
import 'package:ofodep/widgets/custom_form_validator.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/widgets/preview_image.dart';

class ProductAdminPage extends StatelessWidget {
  final String? productId;
  final ProductModel? createModel;

  ProductAdminPage({
    super.key,
    this.productId,
    this.createModel,
  });

  final GlobalKey<FormState> formEditingKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formCreatingKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (productId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: CrudStateHandler<ProductModel, ProductCubit>(
        createCubit: (context) => ProductCubit()
          ..load(
            productId!,
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
    ProductCubit cubit,
    CrudLoaded<ProductModel> state,
  ) {
    final model = state.model;
    return CustomListView(
      title: 'Producto',
      actions: [
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Eliminar producto?'),
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
                  future: StoreRepository().getValueById(model.storeId, 'name'),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.category),
          title: Text('Categoría'),
          subtitle: model.categoryName != null
              ? Text(model.categoryName!)
              : FutureBuilder(
                  future: ProductsCategoriesRepository()
                      .getValueById(model.categoryId, 'name'),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
        ),
        PreviewImage.medium(
          imageUrl: model.imageUrl,
        ),
        ListTile(
          leading: const Icon(Icons.account_box),
          title: Text('Nombre del producto'),
          subtitle: Text(model.name),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text('Descripción'),
          subtitle: Text(model.description ?? ''),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text('Precio (regular)'),
          subtitle: Text(model.regularPrice.toString()),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text('Precio (oferta)'),
          subtitle: Text(model.salePrice?.toString() ?? ''),
        ),
        if (model.salePrice != null)
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Inicio de oferta'),
            subtitle: Text(
              model.saleStart == null
                  ? 'Sin fecha de oferta'
                  : MaterialLocalizations.of(context).formatShortDate(
                      model.saleStart!,
                    ),
            ),
          ),
        if (model.salePrice != null)
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Fin de oferta'),
            subtitle: Text(
              model.saleEnd == null
                  ? 'Sin fecha de oferta'
                  : MaterialLocalizations.of(context).formatShortDate(
                      model.saleEnd!,
                    ),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.currency_exchange),
          title: Text('Moneda'),
          subtitle: Text(model.currency ?? ''),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.tag),
          title: Text('Etiquetas'),
          subtitle: Text(model.tags?.join(', ') ?? ''),
        ),
        ListTile(
          leading: model.active
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
          title: Text('Visible para los clientes'),
          subtitle: Text(model.active ? 'Si' : 'No'),
        ),
      ],
    );
  }

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required ProductCubit cubit,
    required ProductModel edited,
    required bool isLoading,
    bool editMode = true,
    required VoidCallback onSave,
    VoidCallback? onBack,
  }) {
    return CustomListView(
      title: 'Producto',
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
                  future:
                      StoreRepository().getValueById(edited.storeId, 'name'),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.category),
          title: Text('Categoría'),
          subtitle: Text(edited.categoryName ?? ''),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => showBottomSheet(
            context: context,
            builder: (context) => ProductsCategorySearch(
              cubitProduct: cubit,
            ),
          ),
        ),
        CustomFormValidator(
          initialValue: edited.categoryId,
          validator: (value) => value == null || value.trim().isNotEmpty
              ? 'Selecciona una categoría'
              : null,
        ),
        Divider(),
        AdminImage(
          clientId: null,
          imageUrl: edited.imageUrl,
          onImageUploaded: (url) {
            cubit.updateEditedModel(
              (model) => model.copyWith(imageUrl: url),
            );
          },
        ),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.account_box),
            labelText: "Nombre del producto",
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
            labelText: "Descripción",
          ),
          validator: validate,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(description: value),
          ),
        ),
        CheckboxListTile(
          secondary: edited.active
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
          title: const Text("Visible para los clientes"),
          value: edited.active,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(active: value),
          ),
        ),
        Divider(),
        TextFormField(
          initialValue: edited.regularPrice.toString(),
          decoration: const InputDecoration(
            icon: Icon(Icons.attach_money),
            labelText: "Precio (regular)",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(regularPrice: num.tryParse(value) ?? 0),
          ),
        ),
        TextFormField(
          initialValue: edited.salePrice?.toString() ?? "",
          decoration: const InputDecoration(
            icon: Icon(Icons.price_check),
            labelText: "Precio (oferta)",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(salePrice: num.tryParse(value)),
          ),
        ),
        if (edited.salePrice != null)
          OutlinedButton.icon(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            ).then((date) => cubit.updateEditedModel(
                  (model) => model.copyWith(saleStart: date),
                )),
            label: Text(
              'Inicio de oferta: '
              '${edited.saleStart == null ? 'Sin fecha de oferta' : MaterialLocalizations.of(context).formatShortDate(edited.saleStart!)}',
            ),
            icon: const Icon(Icons.calendar_today),
          ),
        if (edited.salePrice != null)
          OutlinedButton.icon(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            ).then((date) => cubit.updateEditedModel(
                  (model) => model.copyWith(saleEnd: date),
                )),
            label: Text(
              'Fin de oferta: '
              '${edited.saleEnd == null ? 'Sin fecha de oferta' : MaterialLocalizations.of(context).formatShortDate(edited.saleEnd!)}',
            ),
            icon: const Icon(Icons.calendar_today),
          ),
        DropdownButtonFormField<Currency>(
          decoration: const InputDecoration(
            icon: Icon(Icons.payment),
            labelText: "Moneda",
          ),
          items: [
            for (final currency in americanCurrencies)
              DropdownMenuItem(
                value: currency,
                child: Text(
                  currency.description,
                  overflow: TextOverflow.clip,
                ),
              ),
          ],
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(currency: value?.code ?? ''),
          ),
        )
      ],
    );
  }
}

class ProductsCategorySearch extends StatelessWidget {
  final ProductCubit cubitProduct;
  const ProductsCategorySearch({super.key, required this.cubitProduct});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height * 0.7;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: ListCubitStateHandler<ProductsCategoryModel,
          ProductsCategoriesListCubit>(
        showAppBar: false,
        createCubit: (context) => ProductsCategoriesListCubit()
          ..updateOrdering(
            orderBy: 'position',
            ascending: true,
          ),
        onSearch: (cubit, search) => cubit.updateFilter({'name': search}),
        itemBuilder: (context, cubit, category, index) => ListTile(
          title: Text(category.name),
          subtitle: Text(
            '${category.storeName}\n'
            '${category.description ?? ''}',
          ),
          trailing: Text(category.position.toString()),
          onTap: () {
            cubitProduct.updateEditedModel(
              (model) => model.copyWith(
                categoryId: category.id,
                categoryName: category.name,
              ),
            );
            context.pop();
          },
        ),
      ),
    );
  }
}
