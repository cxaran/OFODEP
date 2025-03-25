import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_configurations_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/pages/admin/product/product_option_page.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminProductConfigurationsPage extends StatelessWidget {
  final String? productId;
  const AdminProductConfigurationsPage({
    super.key,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    if (productId == null) return const ErrorPage();
    return BlocProvider<ProductConfigurationsListCubit>(
      create: (context) => ProductConfigurationsListCubit(
        productId: productId!,
      ),
      child: Builder(
        builder: (context) => Expanded(
          child: BlocConsumer<ProductConfigurationsListCubit,
              BasicListFilterState>(
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
                    builderDelegate:
                        PagedChildBuilderDelegate<ProductConfigurationModel>(
                      itemBuilder: (context, configuration, index) => ListTile(
                        title: Text(configuration.name),
                        subtitle: AdminProductOptionsPage(
                          productConfigurationId: configuration.id,
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
                        child: Text('error_not_found'),
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
