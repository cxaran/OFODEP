import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_configuration_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_configurations_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/widgets/message_page.dart';
import 'package:ofodep/pages/public/product/product_option_page.dart';

class ProductConfigurationsPage extends StatelessWidget {
  final String? productId;
  const ProductConfigurationsPage({
    super.key,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    if (productId == null) return const MessagePage.error();
    return BlocProvider<ProductConfigurationsListCubit>(
      create: (context) => ProductConfigurationsListCubit(
        productId: productId!,
      ),
      child: Builder(
        builder: (context) =>
            BlocConsumer<ProductConfigurationsListCubit, BasicListFilterState>(
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
                      title: ProductConfigurationPage(
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
                      child: const SizedBox.shrink(),
                    ),
                    noMoreItemsIndicatorBuilder: (context) => Center(
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductConfigurationPage extends StatelessWidget {
  final ProductConfigurationModel? configuration;
  const ProductConfigurationPage({
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
                  ProductOptionsPage(
                    productConfigurationId: state.model.id,
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
