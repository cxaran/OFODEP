import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/blocs/curd_cubits/product_option_cubit.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_options_list_cubit.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/pages/error_page.dart';

class ProductOptionsPage extends StatelessWidget {
  final String? productConfigurationId;
  const ProductOptionsPage({
    super.key,
    this.productConfigurationId,
  });

  @override
  Widget build(BuildContext context) {
    if (productConfigurationId == null) return const ErrorPage();
    return BlocProvider<ProductOptionsListCubit>(
      create: (context) => ProductOptionsListCubit(
        productConfigurationId: productConfigurationId!,
      ),
      child: Builder(
        builder: (context) =>
            BlocConsumer<ProductOptionsListCubit, BasicListFilterState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<ProductOptionsListCubit>();
            return RefreshIndicator(
              onRefresh: () async => cubit.pagingController.refresh(),
              child: PagingListener(
                controller: cubit.pagingController,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, ProductOptionModel>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  builderDelegate:
                      PagedChildBuilderDelegate<ProductOptionModel>(
                    itemBuilder: (context, option, index) => ListTile(
                      title: ProductOptionPage(
                        option: option,
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
                    noItemsFoundIndicatorBuilder: (context) => const Center(
                      child: Text(
                        'not_found',
                      ),
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

class ProductOptionPage extends StatelessWidget {
  final ProductOptionModel? option;
  const ProductOptionPage({
    super.key,
    this.option,
  });

  @override
  Widget build(BuildContext context) {
    if (option == null) return const ErrorPage();
    if (option!.id.isEmpty) return const ErrorPage();
    return BlocProvider<ProductOptionCubit>(
      create: (context) => ProductOptionCubit(
        id: option!.id,
        initialState: CrudLoaded<ProductOptionModel>(
          option!,
        ),
      ),
      child: Builder(
        builder: (context) =>
            BlocConsumer<ProductOptionCubit, CrudState<ProductOptionModel>>(
                listener: (context, state) {
          if (state is CrudError<ProductOptionModel>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CrudEditing<ProductOptionModel> &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state is CrudDeleted<ProductOptionModel>) {
            // Por ejemplo, se puede redirigir a otra pantalla al eliminar
            Navigator.of(context).pop();
          }
        }, builder: (context, state) {
          if (state is CrudInitial<ProductOptionModel> ||
              state is CrudLoading<ProductOptionModel>) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CrudError<ProductOptionModel>) {
            return Center(child: Text(state.message));
          } else if (state is CrudLoaded<ProductOptionModel>) {
            // Estado no editable: muestra los datos y un botón para editar
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${state.model.name}"),
                  Text("Option min: ${state.model.optionMin}"),
                  Text("Option max: ${state.model.optionMax}"),
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
