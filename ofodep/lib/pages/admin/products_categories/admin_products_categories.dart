import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofodep/blocs/list_cubits/products_categories_list_cubit.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/products_categories_repository.dart';
import 'package:ofodep/widgets/list_cubit_state_handler.dart';
import 'package:ofodep/widgets/message_page.dart';

class AdminProductsCategoriesPage extends StatelessWidget {
  final String? storeId;
  const AdminProductsCategoriesPage({
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
      body: ListCubitStateHandler<ProductsCategoryModel,
          ProductsCategoriesListCubit>(
        title: 'Categorías de productos',
        showSearchBar: false,
        createCubit: (context) => ProductsCategoriesListCubit(
          storeId: storeId!,
        )..updateOrdering(
            orderBy: 'position',
            ascending: true,
          ),
        itemBuilder: (context, cubit, category, index) => ListTile(
          title: Text(category.name),
          subtitle: Text(
            category.description ?? '',
          ),
          trailing: Column(
            children: [
              IconButton(
                onPressed: () =>
                    ProductsCategoriesRepository().moveUp(category.id).then(
                          (value) => cubit.updateOrdering(
                            orderBy: 'position',
                            ascending: true,
                          ),
                        ),
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                onPressed: () =>
                    ProductsCategoriesRepository().moveDown(category.id).then(
                          (value) => cubit.updateOrdering(
                            orderBy: 'position',
                            ascending: true,
                          ),
                        ),
                icon: const Icon(Icons.arrow_downward),
              ),
            ],
          ),
          onTap: () => context.push(
            '/admin/products_category/${category.id}',
          ),
        ),
        showFilterButton: false,
        onAdd: (context, cubit) => context.push(
          '/admin/products_category/create',
          extra: ProductsCategoryModel(
            id: 'new',
            name: '',
            storeId: storeId!,
          ),
        ),
      ),
    );
  }
}
