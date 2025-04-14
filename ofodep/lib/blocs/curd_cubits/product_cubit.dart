import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/models/products_category_model.dart';
import 'package:ofodep/repositories/product_repository.dart';

class ProductCrudEditing extends CrudEditing<ProductModel> {
  final List<ProductsCategoryModel> categories;
  final List<ProductsCategoryModel> deletedCategories;
  final List<ProductOptionModel> options;
  final List<ProductOptionModel> deletedOptions;

  ProductCrudEditing({
    required super.model,
    super.editedModel,
    super.editMode = false,
    super.isSubmitting = false,
    super.errorMessage,
    this.categories = const [],
    this.deletedCategories = const [],
    this.options = const [],
    this.deletedOptions = const [],
  });
}

class ProductCubit extends CrudCubit<ProductModel, ProductRepository> {
  ProductCubit({
    super.repository = const ProductRepository(),
    super.initialState,
  });
}
