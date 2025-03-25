import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';
import 'package:ofodep/blocs/list_cubits/filter_state.dart';

class ProductConfigurationsListCubit
    extends ListCubit<ProductConfigurationModel, BasicListFilterState> {
  String productId;

  ProductConfigurationsListCubit({
    required this.productId,
    ProductConfigurationRepository? productConfigurationRepository,
    super.limit,
  }) : super(
          initialState: const BasicListFilterState(),
          repository: productConfigurationRepository ??
              ProductConfigurationRepository(),
        );

  @override
  Future<List<ProductConfigurationModel>> getPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filter,
    String? search,
    String? orderBy,
    bool ascending = false,
  }) {
    filter ??= {};
    filter['product_id'] = productId;

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
