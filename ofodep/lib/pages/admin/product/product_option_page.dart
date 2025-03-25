import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_options_list_cubit.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/pages/error_page.dart';

class AdminProductOptionsPage extends StatelessWidget {
  final String? productConfigurationId;
  const AdminProductOptionsPage({
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
                      title: Text(option.name),
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
                        'error_not_found',
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
