import 'package:ofodep/models/product_option_model.dart';
import 'package:ofodep/repositories/abstract_repository.dart';
import 'package:ofodep/repositories/product_configuration_repository.dart';

class ProductOptionRepository extends Repository<ProductOptionModel> {
  const ProductOptionRepository();

  @override
  String get tableName => 'product_options';

  @override
  ProductOptionModel fromMap(Map<String, dynamic> map) {
    return ProductOptionModel.fromMap(map);
  }

  @override
  Future<bool> update(ProductOptionModel model) async {
    final rangeMax = await ProductConfigurationRepository().getValueById(
      model.configurationId,
      'range_max',
    );

    if (rangeMax == null || model.optionMax > rangeMax) {
      throw Exception('rangeMax is greater than optionMax');
    }

    final result = await super.update(model);
    return result;
  }
}
