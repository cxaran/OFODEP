import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_configuration_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_configurations_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/pages/admin/product/product_option_admin_page.dart';
import 'package:ofodep/widgets/message_page.dart';

class AdminProductConfigurationsPage extends StatelessWidget {
  final String? productId;
  const AdminProductConfigurationsPage({
    super.key,
    this.productId,
  });

  void add(BuildContext context) async {
    final cubit = context.read<ProductConfigurationsListCubit>();
    String? configurationName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
    if (configurationName != null && configurationName.isNotEmpty) {
      cubit.add(
        ProductConfigurationModel(
          id: '',
          productId: productId!,
          name: configurationName,
          rangeMin: 0,
          rangeMax: 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (productId == null) return const MessagePage.error();
    return BlocProvider<ProductConfigurationsListCubit>(
      create: (context) => ProductConfigurationsListCubit(
        productId: productId!,
      ),
      child: Builder(
        builder: (context) => Expanded(
          child: BlocConsumer<ProductConfigurationsListCubit, ListState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<ProductConfigurationsListCubit>();

              return RefreshIndicator(
                onRefresh: () async => cubit.pagingController.refresh(),
                child: PagingListener(
                  controller: cubit.pagingController,
                  builder: (context, state, fetchNextPage) =>
                      PagedListView<int, ProductConfigurationModel>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    builderDelegate:
                        PagedChildBuilderDelegate<ProductConfigurationModel>(
                      itemBuilder: (context, configuration, index) => ListTile(
                        title: ProductConfigurationAdminPage(
                          configuration: configuration,
                        ),
                      ),
                      firstPageErrorIndicatorBuilder: (context) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('error_loading'),
                            ElevatedButton(
                              onPressed: () => cubit.pagingController.refresh(),
                              child: const Text('retry'),
                            ),
                          ],
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (context) => Center(
                        child: IconButton(
                          onPressed: () => add(context),
                          icon: Icon(Icons.add),
                        ),
                      ),
                      noMoreItemsIndicatorBuilder: (context) => Center(
                        child: IconButton(
                          onPressed: () => add(context),
                          icon: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductConfigurationAdminPage extends StatelessWidget {
  final ProductConfigurationModel? configuration;
  const ProductConfigurationAdminPage({
    super.key,
    this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    if (configuration == null) return const MessagePage.error();
    if (configuration!.id.isEmpty) return const MessagePage.error();
    return BlocProvider<ProductConfigurationCubit>(
      create: (context) => ProductConfigurationCubit(
        id: configuration!.id,
        initialState: CrudLoaded<ProductConfigurationModel>(
          configuration!,
        ),
      ),
      child: Builder(
        builder: (context) => BlocConsumer<ProductConfigurationCubit,
            CrudState<ProductConfigurationModel>>(listener: (context, state) {
          if (state is CrudError<ProductConfigurationModel>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CrudEditing<ProductConfigurationModel> &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state is CrudDeleted<ProductConfigurationModel>) {
            // Por ejemplo, se puede redirigir a otra pantalla al eliminar
            Navigator.of(context).pop();
          }
        }, builder: (context, state) {
          if (state is CrudInitial<ProductConfigurationModel> ||
              state is CrudLoading<ProductConfigurationModel>) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CrudError<ProductConfigurationModel>) {
            return Center(child: Text(state.message));
          } else if (state is CrudLoaded<ProductConfigurationModel>) {
            // Estado no editable: muestra los datos y un botón para editar
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${state.model.name}"),
                  Text("Range min: ${state.model.rangeMin}"),
                  Text("Range max: ${state.model.rangeMax}"),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProductConfigurationCubit>()
                        .startEditing(),
                    child: const Text("Editar"),
                  ),
                  AdminProductOptionsPage(
                    productConfigurationId: state.model.id,
                  ),
                ],
              ),
            );
          } else if (state is CrudEditing<ProductConfigurationModel>) {
            // En modo edición, se usan TextFields que muestran los valores de editedModel.
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    key: const ValueKey('name_product_configuration'),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: state.editedModel.name,
                        selection: TextSelection.collapsed(
                          offset: state.editedModel.name.length,
                        ),
                      ),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => context
                        .read<ProductConfigurationCubit>()
                        .updateEditedModel(
                          (model) => model.copyWith(
                            name: value,
                          ),
                        ),
                  ),
                  TextField(
                    key: const ValueKey('range_min_product_configuration'),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: state.editedModel.rangeMin.toString(),
                        selection: TextSelection.collapsed(
                          offset: state.editedModel.rangeMin.toString().length,
                        ),
                      ),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Range min',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'd{0,2}'),
                      ),
                    ],
                    onChanged: (value) => context
                        .read<ProductConfigurationCubit>()
                        .updateEditedModel(
                          (model) => model.copyWith(
                            rangeMin: int.tryParse(value) ?? 0,
                          ),
                        ),
                  ),
                  TextField(
                    key: const ValueKey('range_max_product_configuration'),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: state.editedModel.rangeMax.toString(),
                        selection: TextSelection.collapsed(
                          offset: state.editedModel.rangeMax.toString().length,
                        ),
                      ),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Range max',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'd{0,2}'),
                      ),
                    ],
                    onChanged: (value) => context
                        .read<ProductConfigurationCubit>()
                        .updateEditedModel(
                          (model) => model.copyWith(
                            rangeMax: int.tryParse(value) ?? 0,
                          ),
                        ),
                  ),
                  ElevatedButton(
                    onPressed: state.isSubmitting || !state.editMode
                        ? null
                        : () =>
                            context.read<ProductConfigurationCubit>().submit(),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("Guardar"),
                  ),
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context
                            .read<ProductConfigurationCubit>()
                            .cancelEditing(),
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("Cancelar"),
                  ),
                ],
              ),
            );
          }
          return Container();
        }),
      ),
    );
  }
}
