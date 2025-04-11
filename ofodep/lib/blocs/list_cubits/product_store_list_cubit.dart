import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_store_model.dart';
import 'package:ofodep/repositories/product_store_repository.dart';

class ProductStoreListCubit
    extends ListCubit<ProductStoreModel, ProductStoreRepository> {
  ProductStoreListCubit({
    super.repository = const ProductStoreRepository(),
    super.initialState,
  });
}
