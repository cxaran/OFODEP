import 'package:ofodep/blocs/abstract_curd_cubit.dart';
import 'package:ofodep/models/product_model.dart';
import 'package:ofodep/repositories/product_repository.dart';

class ProductCubit extends CrudCubit<ProductModel> {
  ProductCubit({required super.id, ProductRepository? productRepository})
      : super(
          repository: productRepository ?? ProductRepository(),
        );
}
