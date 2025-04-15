import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/products_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/utils/aux_forms.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/preview_image.dart';
import 'package:ofodep/widgets/product_price.dart';

class AdminProductsPage extends StatelessWidget {
  final String? storeId;
  const AdminProductsPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListCubitStateHandler<ProductModel, ProductsListCubit>(
        title: 'Productos',
        createCubit: (context) => ProductsListCubit(storeId: storeId)
          ..updateSearchFields(
            ['name', 'description'],
          ),
        itemBuilder: (context, cubit, product, index) => ListTile(
          leading: PreviewImage.mini(imageUrl: product.imageUrl),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${product.name ?? ' '} '),
              if (!product.active) const Icon(Icons.visibility_off),
            ],
          ),
          subtitle: Text(
            '${storeId == null ? '${product.storeName ?? ''}\n' : ''}'
            '${product.categoryName ?? ''}',
          ),
          trailing: ProductPrice(product: product),
          onTap: () => context
              .push(
                '/admin/product/${product.id}',
              )
              .then(
                (back) => back == true ? cubit.refresh() : null,
              ),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'name',
                  label: Text('Nombre'),
                ),
                ButtonSegment(
                  value: 'category_id',
                  label: Text('Categoría'),
                ),
                ButtonSegment(
                  value: 'price',
                  label: Text('Precio'),
                ),
              ],
              selected: {state.orderBy},
              onSelectionChanged: (orderBy) => cubit.updateOrdering(
                orderBy: orderBy.first,
              ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ascendente')),
                ButtonSegment(value: false, label: Text('Descendente')),
              ],
              selected: {state.ascending},
              onSelectionChanged: (ascending) => cubit.updateOrdering(
                ascending: ascending.first,
              ),
            ),
          ],
        ),
        onAdd: (context, cubit) => pageNewModel(
          context,
          '/admin/product',
          ProductModel(
            storeId: storeId!,
            days: [1, 2, 3, 4, 5, 6, 7],
            active: false,
            tags: [],
          ),
        ).then(
          (back) => back == true ? cubit.refresh() : null,
        ),
      ),
    );
  }
}
