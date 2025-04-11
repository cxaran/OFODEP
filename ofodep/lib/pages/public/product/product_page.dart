import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/pages/public/product/product_configuration_page.dart';
import 'package:ofodep/widgets/preview_image.dart';

class ProductPage extends StatelessWidget {
  final String? productId;
  const ProductPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    if (productId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              floating: true,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
                SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: BlocProvider<ProductCubit>(
          create: (context) => ProductCubit()..load(productId!),
          child: Builder(
            builder: (context) {
              return BlocConsumer<ProductCubit, CrudState<ProductModel>>(
                listener: (context, state) {
                  if (state is CrudError<ProductModel>) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
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
                        children: [
                          PreviewImage(imageUrl: state.model.imageUrl),
                          Text("Nombre: ${state.model.name}"),
                          Text("Descripción: ${state.model.description}"),
                          // Text("Precio: ${state.model.price}"),
                          Text("Categoría: ${state.model.category}"),
                          ProductConfigurationsPage(
                            productId: state.model.id,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("add_to_cart"),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
