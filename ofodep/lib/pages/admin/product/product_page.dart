import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_cubit.dart';
import 'package:ofodep/pages/admin/product/product_configuration_page.dart';
import 'package:ofodep/pages/error_page.dart';
import 'package:ofodep/models/product_model.dart';

class ProductPage extends StatelessWidget {
  final String? productId;

  const ProductPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    if (productId == null) return const ErrorPage();

    return BlocProvider<ProductCubit>(
      create: (context) => ProductCubit(id: productId!)..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('product'),
              actions: [
                BlocBuilder<ProductCubit, CrudState<ProductModel>>(
                  builder: (context, state) {
                    if (state is CrudLoaded<ProductModel>) {
                      return IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.read<ProductCubit>().startEditing(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: BlocConsumer<ProductCubit, CrudState<ProductModel>>(
              listener: (context, state) {
                if (state is CrudError<ProductModel>) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is CrudEditing<ProductModel> &&
                    state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
                if (state is CrudDeleted<ProductModel>) {
                  // Por ejemplo, se puede redirigir a otra pantalla al eliminar
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                if (state is CrudInitial<ProductModel> ||
                    state is CrudLoading<ProductModel>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CrudError<ProductModel>) {
                  return Center(child: Text(state.message));
                } else if (state is CrudLoaded<ProductModel>) {
                  // Estado no editable: muestra los datos y un botón para editar
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nombre: ${state.model.name}"),
                        Text("Descripción: ${state.model.description}"),
                        Text("Imagen URL: ${state.model.imageUrl}"),
                        Text("Precio: ${state.model.price}"),
                        Text("Categoría: ${state.model.category}"),
                        Text("Etiquetas: ${state.model.tags}"),
                        AdminProductConfigurationsPage(
                          productId: state.model.id,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ProductCubit>().startEditing(),
                          child: const Text("Editar"),
                        ),
                      ],
                    ),
                  );
                } else if (state is CrudEditing<ProductModel>) {
                  // En modo edición, se usan TextFields que muestran los valores de editedModel.
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          key: const ValueKey('name_product'),
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
                          enabled: false,
                        ),
                        TextField(
                          key: const ValueKey('description_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.description ?? "",
                              selection: TextSelection.collapsed(
                                offset:
                                    state.editedModel.description?.length ?? 0,
                              ),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) =>
                                        model.copyWith(description: value),
                                  ),
                        ),
                        TextField(
                          key: const ValueKey('image_url_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.imageUrl ?? "",
                              selection: TextSelection.collapsed(
                                  offset:
                                      state.editedModel.imageUrl?.length ?? 0),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Imagen URL',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) => model.copyWith(imageUrl: value),
                                  ),
                        ),
                        TextField(
                          key: const ValueKey('price_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.price?.toString() ?? "",
                              selection: TextSelection.collapsed(
                                  offset: state.editedModel.price
                                      .toString()
                                      .length),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => context
                              .read<ProductCubit>()
                              .updateEditingState(
                                (model) =>
                                    model.copyWith(price: num.tryParse(value)),
                              ),
                        ),
                        TextField(
                          key: const ValueKey('category_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.category ?? "",
                              selection: TextSelection.collapsed(
                                  offset:
                                      state.editedModel.category?.length ?? 0),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) => model.copyWith(category: value),
                                  ),
                        ),
                        TextField(
                          key: const ValueKey('tags_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.tags?.join(', ') ?? "",
                              selection: TextSelection.collapsed(
                                  offset: state.editedModel.tags
                                          ?.join(', ')
                                          .length ??
                                      0),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Etiquetas',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) =>
                                        model.copyWith(tags: value.split(',')),
                                  ),
                        ),
                        ElevatedButton(
                          onPressed: state.isSubmitting || !state.editMode
                              ? null
                              : () => context.read<ProductCubit>().submit(),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text("Guardar"),
                        ),
                        ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () =>
                                  context.read<ProductCubit>().cancelEditing(),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text("Cancelar"),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}
