import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/product_option_repository.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';

class ProductOptionsListCubit
    extends ListCubit<ProductOptionModel, BasicListFilterState> {
  String productConfigurationId;

  ProductOptionsListCubit({
    required this.productConfigurationId,
    ProductOptionRepository? productConfigurationRepository,
    super.limit,
  }) : super(
          initialState: const BasicListFilterState(),
          repository:
              productConfigurationRepository ?? ProductOptionRepository(),
        );

  @override
  Future<List<ProductOptionModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    filter ??= {};
    filter['configuration_id'] = productConfigurationId;

    return repository.getPaginated(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}
