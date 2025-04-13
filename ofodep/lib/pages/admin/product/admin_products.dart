import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/products_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/widgets/custom_list_view.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';

class AdminProductsPage extends StatelessWidget {
  final String? storeId;
  const AdminProductsPage({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    if (storeId == null) {
      return MessagePage.error(
        onBack: context.pop,
      );
    }

    return Scaffold(
      body: ListCubitStateHandler<ProductModel, ProductsListCubit>(
        title: 'Productos',
        createCubit: (context) => ProductsListCubit(storeId: storeId!),
        itemBuilder: (context, cubit, product, index) => ListTile(
          title: Text(product.name),
          subtitle: Text(
            '${product.categoryName ?? ''}\n'
            '${product.description ?? ''}',
          ),
          trailing: Text(product.regularPrice.toString()),
          onTap: () => context.push(
            '/admin/product/${product.id}',
          ),
        ),
        filterSectionBuilder: (context, cubit, state) => CustomListView(
          children: [
            Text('Ordenar por: '),
            SegmentedButton<String?>(
              segments: const [
                ButtonSegment(
                  value: 'created_at',
                  label: Text('Fecha'),
                ),
                ButtonSegment(
                  value: 'updated_at',
                  label: Text('Actualización'),
                ),
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
        onAdd: (context, cubit) => context.push(
          '/admin/product/create',
          extra: ProductModel(
            id: 'new',
            storeId: storeId!,
            categoryId: '',
            name: '',
            regularPrice: 0,
          ),
        ),
      ),
    );
  }
}
