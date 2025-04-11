import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/products_categories_repository.dart';

class ProductsCategoriesListCubit
    extends ListCubit<ProductsCategoryModel, ProductsCategoriesRepository> {
  final String? storeId;
  ProductsCategoriesListCubit({
    super.repository = const ProductsCategoriesRepository(),
    super.initialState,
    this.storeId,
  });

  @override
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    if (storeId != null) {
      filter ??= {};
      filter['store_id'] = storeId;
    }
    return filter;
  }
}
