import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_store_model.dart';
import 'package:ofodep/repositories/product_store_repository.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';

class ProductStoreListCubit extends ListCubit<ProductStoreModel> {
  ProductStoreListCubit({
    ProductStoreRepository? productStoreRepository,
    ListState<ProductStoreModel>? initialState,
    super.limit,
    super.randomSeed,
  }) : super(
          initialState: initialState ?? const FilterState<ProductStoreModel>(),
          repository: productStoreRepository ?? ProductStoreRepository(),
        );
}
