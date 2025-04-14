import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_cubit.dart';
import 'package:ofodep/blocs/list_cubits/products_categories_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/products_categories_repository.dart';
import 'package:ofodep/repositories/store_images_repository.dart';
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
  final TextEditingController tagsController = TextEditingController();

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
        loadedBuilder: (context, cubit, state) => loadedBuilder(
          context,
          cubit,
          state,
          state is ProductCrudLoaded ? state.configurations : [],
          state is ProductCrudLoaded ? state.options : [],
        ),
        editingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formEditingKey,
          cubit: cubit,
          edited: state.editedModel,
          editMode: state.editMode,
          configurations:
              state is ProductCrudEditing ? state.configurations : [],
          options: state is ProductCrudEditing ? state.options : [],
          isLoading: state.isSubmitting,
          onSave: () => submit(formEditingKey, cubit),
          onBack: cubit.cancelEditing,
        ),
        creatingBuilder: (context, cubit, state) => buildForm(
          context,
          formKey: formCreatingKey,
          cubit: cubit,
          edited: state.editedModel,
          configurations:
              state is ProductCrudCreate ? state.configurations : [],
          options: state is ProductCrudCreate ? state.options : [],
          isLoading: state.isSubmitting,
          onSave: () => create(
            formCreatingKey,
            cubit,
          ),
        ),
      ),
    );
  }

  Widget loadedBuilder(
    BuildContext context,
    ProductCubit cubit,
    CrudLoaded<ProductModel> state,
    List<ProductConfigurationModel> configurations,
    List<ProductOptionModel> options,
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
          leading: const Icon(Icons.category),
          title: Text('Categoría'),
          subtitle: model.categoryName != null
              ? Text(model.categoryName!)
              : (model.categoryId == null
                  ? const Text('No definida')
                  : FutureBuilder(
                      future: ProductsCategoriesRepository()
                          .getValueById(model.categoryId!, 'name'),
                      builder: (context, snapshot) => Text(snapshot.data ?? ''),
                    )),
        ),
        PreviewImage.medium(
          imageUrl: model.imageUrl,
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: Text('Nombre del producto'),
          subtitle: Text(model.name ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text('Descripción'),
          subtitle: Text(model.description ?? ''),
        ),
        ListTile(
          leading: model.active
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
          title: Text('Visible para los clientes'),
          subtitle: Text(model.active ? 'Si' : 'No'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text('Dias de disponibilidad del producto'),
          subtitle: Text(model.days.map(dayName).join(', ')),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text('Precio (regular)'),
          subtitle: Text(currencyFormatter.format(model.regularPrice)),
        ),
        if (model.salePrice != null)
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text('Precio (oferta)'),
            subtitle: Text(currencyFormatter.format(model.salePrice!)),
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
          title: Text('Etiquetas para la búsqueda'),
          subtitle: Text(model.tags.join(', ')),
        ),
        ListTile(
          leading: model.active
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
          title: Text('Visible para los clientes'),
          subtitle: Text(model.active ? 'Si' : 'No'),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text('Configuraciones:'),
          subtitle: state is ProductCrudLoaded
              ? Text(configurations.map((e) => e.name).join(', '))
              : null,
        ),
        for (var configuration in configurations) ...[
          Divider(color: Theme.of(context).colorScheme.onPrimary),
          ListTile(
            leading: const Icon(Icons.arrow_drop_down_sharp),
            title: Text('Configuración'),
            subtitle: Text(configuration.name),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('Descripción'),
            subtitle: Text(configuration.description ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(
              'Rango de selección para las opciones de esta configuración',
            ),
            subtitle:
                Text('${configuration.rangeMin} - ${configuration.rangeMax}'),
          ),
          ListTile(
            leading: const SizedBox.shrink(),
            title: Text('Opciones:'),
            subtitle: Column(
              children: options
                  .where((e) => e.configurationId == configuration.id)
                  .map(
                    (e) => ListTile(
                      title: Text(e.name),
                      subtitle: Text('${e.rangeMin} - ${e.rangeMax}'),
                      trailing: e.extraPrice == null || e.extraPrice == 0
                          ? null
                          : Text(currencyFormatter.format(e.extraPrice!)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ]
      ],
    );
  }

  Widget buildForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required ProductCubit cubit,
    required ProductModel edited,
    required List<ProductConfigurationModel> configurations,
    required List<ProductOptionModel> options,
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
              onSelected: (category) => cubit.updateEditedModel(
                (model) => model.copyWith(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              ),
            ),
          ),
        ),
        CustomFormValidator(
          initialValue: edited.categoryId,
          validator: (value) =>
              edited.categoryId == null ? 'Selecciona una categoría' : null,
        ),
        Divider(),
        FutureBuilder(
          future: StoreImagesRepository().getValueById(
            edited.storeId,
            'imgur_client_id',
          ),
          builder: (context, snapshot) {
            return AdminImage(
              clientId: snapshot.data,
              imageUrl: edited.imageUrl,
              onImageUploaded: (url) {
                cubit.updateEditedModel(
                  (model) => model.copyWith(imageUrl: url),
                );
              },
            );
          },
        ),
        TextFormField(
          initialValue: edited.name,
          decoration: const InputDecoration(
            icon: Icon(Icons.shopping_cart),
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
          maxLines: 5,
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
        const Text(
          'Precios del producto',
        ),
        TextFormField(
          initialValue: edited.regularPrice?.toString() ?? '',
          decoration: const InputDecoration(
            icon: Icon(Icons.attach_money),
            labelText: "Precio (regular)",
          ),
          validator: validateNumber,
          keyboardType: TextInputType.number,
          onChanged: (value) => cubit.updateEditedModel(
            (model) => model.copyWith(regularPrice: num.tryParse(value) ?? 0),
          ),
        ),
        TextFormField(
          initialValue: edited.salePrice?.toString() ?? '',
          decoration: const InputDecoration(
            icon: Icon(Icons.price_check),
            labelText: "Precio (oferta)",
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final num? salePrice = num.tryParse(value ?? '');
            if (salePrice != null) {
              if (edited.regularPrice == null) {
                return 'Defina el precio regular antes de definir el precio de oferta';
              }
              if (salePrice >= edited.regularPrice!) {
                return 'El precio de la oferta no puede ser mayor o igual al precio regular';
              }
            } else if (value?.trim().isNotEmpty ?? false) {
              return 'El valor no es válido';
            }
            return null;
          },
          onChanged: (value) => cubit.updateEditedModel(
            (model) {
              final num? numValue = num.tryParse(value);

              model.salePrice = numValue;
              if (numValue == null) {
                model.saleStart = null;
                model.saleEnd = null;
              }
              return model;
            },
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
        CustomFormValidator(
          initialValue: edited.saleStart,
          validator: (value) {
            if (edited.salePrice != null && value == null) {
              return 'Se requiere una fecha de inicio del periodo de oferta';
            }
            return null;
          },
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
        CustomFormValidator(
          initialValue: edited.saleEnd,
          validator: (value) {
            if (edited.salePrice != null) {
              if (value == null) {
                return 'Se requiere una fecha de fin de la oferta';
              }
              if (value.isBefore(edited.saleStart!)) {
                return 'La fecha de fin de la oferta debe ser posterior a la de inicio';
              }
            }
            return null;
          },
        ),
        DropdownButtonFormField<Currency?>(
          value: edited.currency == null
              ? null
              : americanCurrencies.firstWhere(
                  (e) => e.description == edited.currency,
                  orElse: () {
                    cubit.updateEditedModel(
                      (model) => model.copyWith(
                          currency: americanCurrencies.first.description),
                    );
                    return americanCurrencies.first;
                  },
                ),
          decoration: const InputDecoration(
            icon: Icon(Icons.payment),
            labelText: "Moneda",
          ),
          validator: (value) => value == null ? 'Selecciona una moneda' : null,
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
        ),
        Divider(),
        const Text(
          'Dias de disponibilidad en la semana',
        ),
        for (var day in [1, 2, 3, 4, 5, 6, 7])
          CheckboxListTile(
            title: Text(dayName(day) ?? ''),
            value: edited.days.contains(day),
            onChanged: (value) => cubit.updateEditedModel(
              (model) => model.copyWith(
                days: edited.days.contains(day)
                    ? (List.from(model.days)..remove(day))
                    : (List.from(model.days)..add(day)),
              ),
            ),
          ),
        CustomFormValidator(
          initialValue: edited.days,
          validator: (value) =>
              value!.isEmpty ? 'Selecciona al menos un día' : null,
        ),
        Divider(),
        ListTile(
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              String newTag = tagsController.text.trim();
              if (newTag.isEmpty && edited.tags.contains(newTag)) {
                return;
              }
              cubit.updateEditedModel(
                (model) => model.copyWith(
                  tags: [...edited.tags, newTag],
                ),
              );
              tagsController.clear();
            },
          ),
          title: TextFormField(
            controller: tagsController,
            decoration: const InputDecoration(
              icon: Icon(Icons.tag),
              labelText: "Etiquetas para la búsqueda",
            ),
            onFieldSubmitted: (value) {
              String newTag = value.trim();
              if (newTag.isEmpty && edited.tags.contains(newTag)) {
                return;
              }
              cubit.updateEditedModel(
                (model) => model.copyWith(
                  tags: [...edited.tags, newTag],
                ),
              );
              tagsController.clear();
            },
          ),
        ),
        ListTile(
          title: Text('Etiquetas para la búsqueda'),
          subtitle: Wrap(
            children: [
              for (final tag in edited.tags)
                Chip(
                  label: Text('#$tag'),
                  onDeleted: () => cubit.updateEditedModel(
                    (model) => model.copyWith(
                      tags: edited.tags.where((e) => e != tag).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(),
        const Text(
          'Configuraciones del producto:',
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text('Configuraciones'),
          subtitle: Text('(${configurations.length})'),
        ),
        for (var configuration in configurations) ...[
          Divider(color: Theme.of(context).colorScheme.onPrimary),
          TextFormField(
            initialValue: configuration.name,
            decoration: InputDecoration(
              icon: const Icon(Icons.arrow_drop_down_sharp),
              labelText: "Configuración",
              suffix: IconButton(
                tooltip: 'Eliminar configuración',
                onPressed: () => cubit.deleteConfiguration(configuration.id),
                icon: const Icon(Icons.delete),
              ),
            ),
            onChanged: (value) => cubit.updateConfiguration(
              configuration.id,
              name: value,
            ),
          ),
          TextFormField(
            initialValue: configuration.description,
            decoration: const InputDecoration(
              icon: Icon(Icons.description),
              labelText: "Descripción",
            ),
            maxLines: 2,
            onChanged: (value) => cubit.updateConfiguration(
              configuration.id,
              description: value,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(
              'Rango de selección para las opciones de esta configuración',
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: configuration.rangeMin?.toString() ?? '',
                    decoration: const InputDecoration(labelText: "Mínimo"),
                    keyboardType: TextInputType.number,
                    validator: validateNumberInteger,
                    onChanged: (value) => cubit.updateConfiguration(
                      configuration.id,
                      rangeMin: int.tryParse(value),
                    ),
                  ),
                ),
                gap,
                Expanded(
                  child: TextFormField(
                    initialValue: configuration.rangeMax?.toString() ?? '',
                    decoration: const InputDecoration(labelText: "Máximo"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      String? error = validateNumberInteger(value);
                      if (error != null) {
                        return error;
                      }
                      if (configuration.rangeMin != null) {
                        if (int.parse(value!) < configuration.rangeMin!) {
                          return 'El rango mínimo no puede ser mayor que el máximo';
                        }
                        return null;
                      } else {
                        return 'El rango mínimo no puede ser mayor que el máximo';
                      }
                    },
                    onChanged: (value) => cubit.updateConfiguration(
                      configuration.id,
                      rangeMax: int.tryParse(value),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var option in options
              .where((e) => e.configurationId == configuration.id)) ...[
            Divider(
              color: Theme.of(context).colorScheme.onPrimary,
              indent: MediaQuery.of(context).size.width * 0.2,
              endIndent: MediaQuery.of(context).size.width * 0.2,
            ),
            TextFormField(
              initialValue: option.name,
              decoration: InputDecoration(
                icon: const Icon(Icons.arrow_right_sharp),
                labelText: "Opción",
                suffix: IconButton(
                  tooltip: 'Eliminar opción',
                  onPressed: () => cubit.deleteOption(option.id),
                  icon: const Icon(Icons.delete),
                ),
              ),
              validator: validate,
              onChanged: (value) => cubit.updateOption(
                option.id,
                name: value,
              ),
            ),
            TextFormField(
              initialValue: option.extraPrice?.toString() ?? '',
              decoration: const InputDecoration(
                icon: Icon(Icons.attach_money),
                labelText: "Precio extra por unidad de esta opción",
              ),
              keyboardType: TextInputType.number,
              validator: validateNumber,
              onChanged: (value) => cubit.updateOption(
                option.id,
                extraPrice: num.tryParse(value),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: Text(
                'Rango de selección para la opción',
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: option.rangeMin?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: "Mínimo",
                      ),
                      keyboardType: TextInputType.number,
                      validator: validateNumberInteger,
                      onChanged: (value) => cubit.updateOption(
                        option.id,
                        rangeMin: int.tryParse(value),
                      ),
                    ),
                  ),
                  gap,
                  Expanded(
                    child: TextFormField(
                      initialValue: option.rangeMax?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: "Máximo",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        String? error = validateNumberInteger(value);
                        if (error != null) {
                          return error;
                        }
                        if (option.rangeMax != null) {
                          if (int.parse(value!) < option.rangeMin!) {
                            return 'El rango mínimo no puede ser mayor que el máximo';
                          }
                          return null;
                        } else {
                          return 'El rango mínimo no puede ser mayor que el máximo';
                        }
                      },
                      onChanged: (value) => cubit.updateOption(
                        option.id,
                        rangeMax: int.tryParse(value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          OutlinedButton.icon(
            onPressed: () => cubit.addOption(
              'Opción ${options.where((e) => e.configurationId == configuration.id).length + 1}',
              configuration.id,
            ),
            icon: const Icon(Icons.add),
            label: Text('Agregar opción'),
          ),
          CustomFormValidator(
            initialValue: options
                .where((e) => e.configurationId == configuration.id)
                .map((e) => e.name),
            validator: (value) => value!.isEmpty
                ? 'Agrega al menos una opción a la configuración'
                : null,
          )
        ],
        Divider(),
        OutlinedButton.icon(
          onPressed: () => cubit.addConfiguration(
            'Configuración ${configurations.length + 1}',
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar configuración'),
        )
      ],
    );
  }
}

class ProductsCategorySearch extends StatelessWidget {
  final Function(ProductsCategoryModel) onSelected;
  const ProductsCategorySearch({super.key, required this.onSelected});

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
            onSelected(category);
            context.pop();
          },
        ),
      ),
    );
  }
}
