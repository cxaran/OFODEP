import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';
import 'package:ofodep/blocs/list_cubits/product_store_list_cubit.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';
import 'package:ofodep/models/product_store_model.dart';
import 'package:ofodep/widgets/container_page.dart';
import 'package:ofodep/widgets/location_button.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  // Explorar
  // Delivery
  // Pickup
  // Promociones
  // Tendencias
  // Reciente
  // Comentadas

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
            title: LocationButton(),
            forceElevated: innerBoxIsScrolled,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune),
              ),
              SizedBox(width: 8),
            ],
          ),
        ];
      },
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state is LocationLoaded) {
            return BlocProvider<ProductStoreListCubit>(
              create: (context) => ProductStoreListCubit(
                initialState: BasicListFilterState(
                  orderBy: 'product_is_open',
                  ascending: false,
                  params: {
                    'user_lat': state.location.latitude,
                    'user_lng': state.location.longitude,
                    'distance_max': 50000,
                  },
                ),
              ),
              child: BlocConsumer<ProductStoreListCubit, BasicListFilterState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    debugPrint(state.errorMessage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<ProductStoreListCubit>();
                  return ContainerPage(
                    padding: 0,
                    child: RefreshIndicator(
                      onRefresh: () async => cubit.pagingController.refresh(),
                      child: PagingListener(
                        controller: cubit.pagingController,
                        builder: (context, state, fetchNextPage) =>
                            PagedListView<int, ProductStoreModel>(
                          state: state,
                          fetchNextPage: fetchNextPage,
                          scrollController: PrimaryScrollController.of(context),
                          builderDelegate:
                              PagedChildBuilderDelegate<ProductStoreModel>(
                            itemBuilder: (context, product, index) => ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                'open:${product.isOpen ?? ''}\n'
                                'delivery:${product.deliveryArea ?? ''}\n'
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
