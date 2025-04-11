import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_repository.dart';

class ProductsListCubit extends ListCubit<ProductModel, ProductRepository> {
  final String? storeId;

  ProductsListCubit({
    super.repository = const ProductRepository(),
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
