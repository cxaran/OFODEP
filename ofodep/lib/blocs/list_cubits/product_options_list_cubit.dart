import 'package:ofodep/blocs/list_cubits/abstract_list_cubit.dart';
import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/product_option_repository.dart';

class ProductOptionsListCubit
    extends ListCubit<ProductOptionModel, ProductOptionRepository> {
  final String productConfigurationId;

  ProductOptionsListCubit({
    super.repository = const ProductOptionRepository(),
    super.initialState,
    required this.productConfigurationId,
  });

  @override
  Map<String, dynamic>? getFilter(Map<String, dynamic>? filter) {
    filter ??= {};
    filter['configuration_id'] = productConfigurationId;
    return filter;
  }
}
