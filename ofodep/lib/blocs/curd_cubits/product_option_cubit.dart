import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/product_option_repository.dart';

class ProductOptionCubit
    extends CrudCubit<ProductOptionModel, ProductOptionRepository> {
  ProductOptionCubit({
    super.repository = const ProductOptionRepository(),
    super.initialState,
  });
}
