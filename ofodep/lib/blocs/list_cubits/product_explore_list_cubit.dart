import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/abstract_params.dart';
import 'package:ofodep/models/product_explore_model.dart';
import 'package:ofodep/repositories/product_explore_repository.dart';

class ProductExploreListCubit
    extends ListCubit<ProductExploreModel, ProductExploreRepository> {
  ProductExploreListCubit({
    super.repository = const ProductExploreRepository(),
  });

  @override
  void refresh() {
    if (state.rpcParams is ProductExploreParams) {
      setParams(
        (current) => current.copyWith(
          randomSeed: newRandomSeed(),
        ),
      );
    } else {
      super.refresh();
    }
  }

  void setParams(
      ProductExploreParams Function(ProductExploreParams current) updater) {
    if (state.rpcParams is ProductExploreParams) {
      emit(
        state.copyWith(
          rpcParams: updater(state.rpcParams as ProductExploreParams),
        ),
      );
      super.refresh();
    }
  }

  @override
  Future<List<ProductExploreModel>> getPaginated({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) async {
    if (state.rpcParams is ProductExploreParams) {
      try {
        final newItems = await repository.getProducts(
          params: state.rpcParams as ProductExploreParams,
          page: page,
        );
        if (newItems.isEmpty) {
          pagingController.value = pagingController.value.copyWith(
            hasNextPage: false,
          );
        }
        return newItems;
      } catch (_) {}
    }
    return [];
  }
}
