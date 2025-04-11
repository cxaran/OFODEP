import 'package:ofodep/blocs/curd_cubits/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_repository.dart';

class ProductCubit extends CrudCubit<ProductModel, ProductRepository> {
  ProductCubit({
    super.repository = const ProductRepository(),
    super.initialState,
  });
}
