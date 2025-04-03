import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/products_list_cubit.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';
import 'package:ofodep/models/product_model.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            title: const Text('Explore'),
            floating: true,
            snap: true,
            forceElevated: innerBoxIsScrolled,
          ),
        ];
      },
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state is LocationLoaded) {
            debugPrint(state.location.toString());
            return BlocProvider<ProductsListCubit>(
              create: (context) => ProductsListCubit(
                initialState: BasicListFilterState(),
              ),
              child: BlocConsumer<ProductsListCubit, BasicListFilterState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    debugPrint(state.errorMessage!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<ProductsListCubit>();
                  return RefreshIndicator(
                    onRefresh: () async => cubit.pagingController.refresh(),
                    child: PagingListener(
                      controller: cubit.pagingController,
                      builder: (context, state, fetchNextPage) =>
                          PagedListView<int, ProductModel>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        scrollController: PrimaryScrollController.of(context),
                        builderDelegate:
                            PagedChildBuilderDelegate<ProductModel>(
                          itemBuilder: (context, product, index) => ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              '${product.category ?? ''}\n'
                              '${product.storeName}\n'
                              '${product.description ?? ''}',
                            ),
                            trailing: Text(product.price?.toString() ?? ''),
                            onTap: () => context.push(
                              '/product/${product.id}',
                            ),
                          ),
                          firstPageErrorIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('error_loading'),
                                ElevatedButton(
                                  onPressed: () =>
                                      cubit.pagingController.refresh(),
                                  child: const Text('retry'),
                                ),
                              ],
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (context) =>
                              const Center(
                            child: Text('not_found'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is LocationError) {
            return Text("Error: ${state.error}");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
