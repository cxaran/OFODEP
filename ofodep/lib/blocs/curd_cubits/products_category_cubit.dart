import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/products_categories_repository.dart';

class ProductsCategoryCubit
    extends CrudCubit<ProductsCategoryModel, ProductsCategoriesRepository> {
  ProductsCategoryCubit({
    super.repository = const ProductsCategoriesRepository(),
    super.initialState,
  });
}
