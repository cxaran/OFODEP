import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_configuration_model.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';

class ProductConfigurationsListCubit extends ListCubit<
    ProductConfigurationModel, ProductConfigurationRepository> {
  final String productId;

  ProductConfigurationsListCubit({
    super.repository = const ProductConfigurationRepository(),
    super.initialState,
    required this.productId,
  });

  @override
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    filter ??= {};
    filter['product_id'] = productId;
    return filter;
  }
}
