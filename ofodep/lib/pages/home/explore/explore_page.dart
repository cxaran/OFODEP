import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/product_explore_list_cubit.dart';
import 'package:ofodep/blocs/local_cubits/location_cubit.dart';
import 'package:ofodep/models/product_explore_model.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';

import 'package:ofodep/widgets/location_button.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LocationError) {
          return const Center(child: Text('Error al obtener la ubicación'));
        }
        if (state is LocationLoaded) {
          return locationLoadedBuilder(context, state);
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget locationLoadedBuilder(BuildContext context, LocationLoaded state) {
    return ListCubitStateHandler<ProductExploreModel, ProductExploreListCubit>(
      title: 'Explorar',
      actions: [LocationButton()],
      createCubit: (context) => ProductExploreListCubit()
        ..initParams(
          ProductExploreParams(
            countryCode: 'MX',
            userLat: state.location.latitude,
            userLng: state.location.longitude,
            maxDistance: 10000,
            page: 1,
          ),
        ),
      itemBuilder: (context, cubit, item, index) => ListTile(
        title: Text(item.productName),
        trailing: Text(item.distance.toStringAsFixed(2)),
        subtitle: Row(
          children: [
            IconButton(
              onPressed: () => context.push('/admin/store/${item.storeId}'),
              icon: Icon(Icons.store),
            ),
            Text(item.storeName),
          ],
        ),
      ),
      showSearchBar: false,
      showFilterButton: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
