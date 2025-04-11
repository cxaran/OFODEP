import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/products_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
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
        createCubit: (context) => ProductsListCubit(storeId: storeId!),
        itemBuilder: (context, cubit, product, index) => ListTile(
          title: Text(product.name),
          subtitle: Text(
            '${product.category ?? ''}\n'
            '${product.description ?? ''}',
          ),
          trailing: Text(product.regularPrice.toString()),
          onTap: () => context.push(
            '/admin/product/${product.id}',
          ),
        ),
      ),
    );
  }
}
