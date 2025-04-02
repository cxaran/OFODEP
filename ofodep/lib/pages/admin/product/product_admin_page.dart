import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_cubit.dart';
import 'package:ofodep/pages/admin/product/product_configuration_admin_page.dart';
import 'package:ofodep/pages/error_page.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/store_repository.dart';
import 'package:ofodep/widgets/admin_image.dart';
import 'package:ofodep/widgets/preview_image.dart';

class ProductAdminPage extends StatelessWidget {
  final String? productId;

  const ProductAdminPage({super.key, this.productId});

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
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PreviewImage(imageUrl: state.model.imageUrl),
                        Text("Nombre: ${state.model.name}"),
                        Text("Descripción: ${state.model.description}"),
                        Text("Precio: ${state.model.price}"),
                        Text("Categoría: ${state.model.category}"),
                        Text("Etiquetas: ${state.model.tags}"),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ProductCubit>().startEditing(),
                          child: const Text("Editar"),
                        ),
                        AdminProductConfigurationsPage(
                          productId: state.model.id,
                        ),
                      ],
                    ),
                  );
                } else if (state is CrudEditing<ProductModel>) {
                  // En modo edición, se usan TextFields que muestran los valores de editedModel.
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: StoreRepository().getValueById(
                            state.model.storeId,
                            'imgur_client_id',
                          ),
                          builder: (context, snapshot) => AdminImage(
                            clientId: snapshot.data,
                            imageUrl: state.editedModel.imageUrl,
                            onImageUploaded: (url) =>
                                context.read<ProductCubit>().updateEditingState(
                                      (model) => model.copyWith(
                                        imageUrl: url,
                                      ),
                                    ),
                          ),
                        ),
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
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) => model.copyWith(
                                      name: value,
                                    ),
                                  ),
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
                                    (model) => model.copyWith(
                                      description: value,
                                    ),
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
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) => model.copyWith(
                                      price: num.tryParse(value),
                                    ),
                                  ),
                        ),
                        TextField(
                          key: const ValueKey('category_product'),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.editedModel.category ?? "",
                              selection: TextSelection.collapsed(
                                offset: state.editedModel.category?.length ?? 0,
                              ),
                            ),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              context.read<ProductCubit>().updateEditingState(
                                    (model) => model.copyWith(
                                      category: value,
                                    ),
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
